# Gift Grab

Gift Grab is a Christmas arcade game for Flutter: steer Santa around the screen with a joystick, grab as many falling gifts as you can in 30 seconds, and post your score to a monthly leaderboard you share with friends and groups. This repo is the **client app**: sign-in, menus, leaderboard and social features wrapped around the game itself, which lives in the separate [`gift_grab_game`](https://github.com/trey-a-hope/gift_grab_game) package. Everything online runs on a [Nakama](https://heroiclabs.com/nakama/) server ([`gift_grab_server`](https://github.com/trey-a-hope/gift_grab_server)).

## Features

**The game** (from `gift_grab_game`, launched by the client at `/main/game`)
- 30-second rounds. Each gift Santa touches is a point, and the timer and score sit in the HUD.
- **Ice** freezes Santa in place for a moment.
- **Flames** give Santa 10 seconds of protection, so ice can't freeze him.
- **Cookies** give a short speed boost.
- When a round ends, the score is written to the `monthly_leaderboard` and a game-over overlay lets you play again.

**The app around it**
- **Sign-in** through Clerk's prebuilt auth UI. The Clerk session JWT is exchanged for a Nakama session (`authenticateCustom`), and new Clerk users get a Nakama account created on first login.
- **Main menu** greets you by username and links to Play, Profile, Leaderboard, Friends and Groups, plus user search and Settings.
- **Leaderboard** pages through the monthly leaderboard, 10 records at a time.
- **Profiles** show a player's details. On someone else's profile a single button follows your friendship state with them: send, cancel, accept or reject a request, remove a friend, block or unblock. A blocked user's profile is hidden. You can edit your own username.
- **Friends** has four tabs: Friends, Invites, Requests and Blocked.
- **Groups** has "All Groups" and "My Groups" tabs, group search, and create and edit forms (name, description, open or closed). Members can join, leave or cancel a pending request. Admins can add, kick, ban, promote and demote members from a bottom sheet.
- **Profanity check**: usernames and group names and descriptions are scanned with `profanity_api` before saving.
- **Settings** shows the app version and licenses, and lets you log out or delete your account (through a server RPC).
- **Analytics**: PostHog tracks screen views (`PosthogObserver` on the router), identifies users at login, logs `User Played Game` with the score and `User Logged Out`, and captures Flutter, isolate and native errors.
- **Over-the-air patches** with Shorebird (`shorebird.yaml`).

## How it works

```
Clerk sign-in ──JWT──▶ AuthController ──authenticateCustom──▶ Nakama session
                                                                 │
                                         SessionService ◀────────┘
                                         (Hive box, auto-refresh 5 min before expiry)
                                                                 │
          BLoCs / controllers ──session──▶ Nakama client (leaderboards, friends, groups, RPCs)
```

- **Startup** (`lib/main.dart`): sets up the Nakama client and Hive, wraps the app in `ClerkAuth`, then `AppInitializer` registers dependencies, builds the router, and shows a Lottie loader until everything is ready.
- **Dependency injection** (`lib/core/di_container.dart`): `get_it` registers `PostHogService`, `ClerkAuthState`, `ModalService`, `SessionService`, `GroupService`, and signal-based controllers (`AuthController`, `AccountReadController`, and per-group member controllers).
- **State**: each feature is a BLoC with sealed events and `Equatable` states, using `bloc_error_handler`'s `runWithErrorHandling()`. Most were scaffolded with the `flutter_bloc_feature` Mason brick. Auth, account and group-member state use `signals` (`AsyncSignal`) instead.
- **Routing** (`lib/data/configuration/app_routes.dart`): GoRouter with every screen nested under `/main`. The router refreshes when `AuthController.isAuthenticated` changes and redirects to `/login` when you're signed out. A `ShellRoute` shows Clerk errors as toasts.
- **Server calls**: mostly standard Nakama APIs, plus four custom RPCs in `lib/data/enums/rpc_functions.dart`: `account_delete_id`, `get_friendship_state`, `get_group_by_id` and `get_group_membership_state`. These must exist on the server.
- **UI**: `shadcn_ui` themes the app (dark mode, ABeeZee font from Google Fonts). Shared widgets such as `GGScaffoldWidget`, `MenuButtonWidget` and `FlexGridviewWidget` come from the [`gift_grab_ui`](https://github.com/trey-a-hope/gift_grab_ui) package.

## Tech stack

- Flutter, Dart SDK `>=3.12.0 <4.0.0`
- Game: `gift_grab_game` (Flame engine, git dependency)
- UI: `gift_grab_ui` (git dependency), `shadcn_ui`, `google_fonts`, `lottie`, `settings_ui`, `font_awesome_flutter`
- State: `flutter_bloc`, `bloc_error_handler`, `signals`, `equatable`, `formz` (form validation)
- Navigation: `go_router`
- Backend: `nakama`
- Auth: `clerk_flutter` (beta). `google_sign_in` and `sign_in_with_apple` are also dependencies.
- Storage: `hive` / `hive_flutter` (session tokens)
- Analytics: `posthog_flutter`
- Other: `get_it`, `result_dart`, `profanity_api`, `package_info_plus`, `window_manager` (desktop window sizing), `logger`
- Testing: `flutter_test`, `bloc_test`, `mocktail`
- Releases: Shorebird code push

## Getting started

### Prerequisites

- A Flutter SDK whose Dart version satisfies `>=3.12.0`
- Git access to `trey-a-hope/gift_grab_game` and `trey-a-hope/gift_grab_ui` (both public, pulled by `flutter pub get`)
- A running Nakama server with the Gift Grab modules ([`gift_grab_server`](https://github.com/trey-a-hope/gift_grab_server)), meaning the `monthly_leaderboard` leaderboard and the four RPCs above
- Optional: the [Shorebird CLI](https://docs.shorebird.dev) for releases and patches

### Installation

```bash
git clone https://github.com/trey-a-hope/gift_grab_client.git
cd gift_grab_client
flutter pub get
```

### Configuration

The environment comes from the build mode, not from a flag you set (`lib/data/configuration/environment.dart`):

| | Debug and profile builds | Release builds |
|---|---|---|
| Nakama host | `127.0.0.1` | `gift-grab-server.app` |
| Clerk key | test key (`pk_test_…`) | live key (`pk_live_…`) |

Other settings in `lib/data/constants/globals.dart`:
- Nakama uses server key `defaultkey` and HTTP port `443` in both environments. SSL is only on for web builds. So a local Nakama server has to listen on `127.0.0.1:443`, or you need to change `nakamaClientHttpPort` (Nakama's default is `7350`).
- Page sizes: `recordListLimit` 10, `friendListLimit` 15, `groupListLimit` 10.
- The PostHog project token and US host are in `lib/domain/services/post_hog_service.dart`.

The VS Code launch configs (`.vscode/launch.json`) pass `--dart-define-from-file=./env/local.json`. `env/example_prod.json` shows the expected shape, which is one `FLUO_API_KEY`. That key is currently **not read**: the code that reads it in `main.dart` is commented out, left over from an earlier auth provider.

### Running

```bash
flutter devices
flutter run -d <device_id>
# same as the VS Code "debug" config:
flutter run --dart-define-from-file=./env/local.json
```

There are platform folders for Android, iOS, web, macOS, Windows and Linux. A note in `pubspec.yaml` says **Clerk doesn't support web yet** ([clerk-sdk-flutter#302](https://github.com/clerk-community/clerk-sdk-flutter/issues/302)), so sign-in won't work in the browser for now.

## Testing

Unit tests cover the event, state and bloc of each feature BLoC, in `test/blocs/<feature>/bloc/`. There are 15 features, using `bloc_test` and `mocktail`, with shared mocks in `test/test_helper.dart`. `test/widget_test.dart` is a basic smoke test.

```bash
flutter test
flutter test --coverage
flutter analyze
```

`mason.yaml` also includes the `flutter_coverage_updater` brick for generating coverage reports.

## Releasing

The version format is `YY.M.D+build`, for example `26.7.3+82` in `pubspec.yaml`. Store release notes go in `release_notes.json`. With Shorebird:

```bash
shorebird release android   # or ios
shorebird patch android     # push a Dart-only fix to existing installs
```

## Project structure

```
lib/
├── main.dart                 # bootstrap: Nakama client, Hive, ClerkAuth, theme
├── core/                     # get_it container, logger
├── data/
│   ├── configuration/        # app_routes.dart, environment.dart, gap sizes, signal observer
│   ├── constants/            # globals, label text, feedback messages
│   ├── enums/                # GoRoutes, Leaderboards, RpcFunctions
│   └── repositories/         # SessionRepository (Hive)
├── domain/
│   ├── entities/             # LeaderboardEntry
│   ├── repositories/         # ISessionRepository
│   └── services/             # SessionService, GroupService, PostHogService
├── presentation/
│   ├── blocs/                # one folder per feature: bloc/ + view/
│   ├── controllers/          # signal-based auth, account and group-member controllers
│   ├── cubits/               # GroupRefreshCubit
│   ├── pages/                # login, main menu, settings, group/*
│   ├── services/             # ModalService (toasts, dialogs)
│   ├── extensions/
│   └── widgets/
└── util/                     # desktop window setup
assets/                       # images and audio the game package loads, plus the app icon
test/blocs/                   # BLoC unit tests
flutter_packages_json/        # package lists grouped by course module (setup, auth, users, leaderboards)
```

## Known limitations

- Sign-in doesn't work on web until Clerk adds web support (see above).
- `main.dart` has a TODO to add a timeout to the Clerk auth request.
- Debug builds point at `127.0.0.1` on port 443, so testing against a local server needs that port or a code change.
- `PostHogService` runs with `debug = true` in every build.
