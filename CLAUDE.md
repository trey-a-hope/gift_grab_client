# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Gift Grab Client is a Flutter mobile game application that integrates with a Nakama backend server. Users play a Flame-based game to grab presents, submit scores to leaderboards, and interact with friends and groups.

**Key Technologies:**
- Flutter 3.0+ / Dart 3.0+
- BLoC pattern for state management (flutter_bloc)
- GoRouter for navigation
- Nakama for backend (authentication, leaderboards, social features)
- Flame game engine (via git dependency)
- Shorebird for OTA code push updates

## Development Commands

### Setup & Dependencies
```bash
# Get dependencies
flutter pub get

# Install packages from a file (custom script)
./install_flutter_packages.sh [package_file]

# Clean and rebuild
flutter clean && flutter pub get
```

### Running the App
```bash
# Run on connected device/emulator
flutter run

# Run with specific flavor/target
flutter run -t lib/main.dart

# Run on web
flutter run -d chrome

# Run on specific device
flutter devices
flutter run -d <device_id>
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/path/to/test_file.dart

# Generate coverage report (custom script)
./update_coverage.sh
# Opens coverage/html/index.html for HTML report
```

### Code Quality
```bash
# Run linter
flutter analyze

# Format code
dart format lib/ test/

# Fix linting issues automatically where possible
dart fix --apply
```

### Building
```bash
# Build APK (Android)
flutter build apk

# Build App Bundle (Android)
flutter build appbundle

# Build iOS
flutter build ios

# Build web
flutter build web
```

### Shorebird (Code Push)
```bash
# Create a new release
shorebird release android
shorebird release ios

# Create a patch (hot fix)
shorebird patch android
shorebird patch ios

# Check for updates
shorebird preview
```

## Architecture Overview

### Clean Architecture Layers

**Domain Layer** (`lib/domain/`)
- Contains abstract repository interfaces (prefix: `I`)
- Business logic services (`SessionService`, `SocialAuthService`)
- Domain entities (`LeaderboardEntry`)
- No Flutter/framework dependencies

**Data Layer** (`lib/data/`)
- Concrete repository implementations
- Constants (`Globals`, `LabelText`, `FeedbackMessages`)
- Enums (`GoRoutes`, `Leaderboards`, `RpcFunctions`)
- Configuration (`app_routes.dart`)

**Presentation Layer** (`lib/presentation/`)
- 16 feature BLoCs (account, friend, group, record, user operations)
- 2 Cubits (auth, group_refresh)
- Pages, views, and reusable widgets
- Extensions for BuildContext, String, DateTime, etc.

### State Management

**BLoC Pattern:**
- Each feature has dedicated BLoC with event/state files
- Events use sealed classes for type safety
- States implement `Equatable` and include `copyWith()` for immutability
- Error handling via `bloc_error_handler` package with `runWithErrorHandling()`
- List BLoCs support cursor-based pagination

**BLoC Structure Example:**
```dart
// Event
sealed class RecordListEvent extends Equatable { }
class InitialFetch extends RecordListEvent { }
class FetchMore extends RecordListEvent { }

// State
class RecordListState extends Equatable implements ErrorState {
  final List<LeaderboardEntry> entries;
  final String? cursor;
  final bool isLoading;
  final String? error;

  RecordListState copyWith({...}) => RecordListState(...);
}

// BLoC
class RecordListBloc extends Bloc<RecordListEvent, RecordListState> {
  RecordListBloc(...) : super(const RecordListState()) {
    on<InitialFetch>(_onInitialFetch);
    on<FetchMore>(_onFetchMore);
  }
}
```

**Cubit Pattern:**
- `AuthCubit`: Manages authentication state (login/logout)
- `GroupRefreshCubit`: Simple event signaling for group list refresh

### Routing

**GoRouter Configuration** (`lib/data/configuration/app_routes.dart`):
- Declarative routing with nested routes
- Authentication-based redirects (unauthenticated users → `/login`)
- Route refreshing tied to `AuthCubit` stream
- Route names defined in `GoRoutes` enum for type safety
- Path parameters: `/:uid`, `/:group_id`
- Extra data passing for edit flows

**Navigation Example:**
```dart
// Using route enum
context.go('/${GoRoutes.MAIN.name}/${GoRoutes.PROFILE.name}/$userId');

// With extra data
context.go(
  '/${GoRoutes.EDIT_GROUP.name}',
  extra: groupObject,
);
```

### Nakama Integration

**Backend Client Setup** (`lib/main.dart`):
```dart
final client = getNakamaClient(
  host: Globals.nakamaClientHost,        // 'gift-grab-server.app' (prod) or '127.0.0.1' (dev)
  serverKey: Globals.nakamaClientServerKey,
  httpPort: Globals.nakamaClientHttpPort,
  ssl: UniversalPlatform.isWeb,
);
```

**Environment Toggle:**
- Set `Globals.isProd` in `lib/data/constants/globals.dart` to switch environments
- Production: `gift-grab-server.app:443`
- Development: `127.0.0.1:7350`

**Common Operations:**
- Authentication: `client.authenticateEmail()`, `client.authenticateGoogle()`, etc.
- Session management: `client.sessionRefresh()`, `client.sessionLogout()`
- Account: `client.getAccount()`, `client.updateAccount()`, `client.deleteAccount()`
- Leaderboards: `client.writeLeaderboardRecord()`, `client.listLeaderboardRecords()`
- Friends: `client.addFriends()`, `client.deleteFriends()`, `client.listFriends()`
- Groups: `client.createGroup()`, `client.updateGroup()`, `client.listGroups()`
- Users: `client.getUsers()` (search by username/IDs)

### Game Integration

**gift_grab_game Package** (Flame-based):
- Embedded as git dependency
- Integrated in game route with `GiftGrabGameWidget`
- Callback-based scoring: `onEndGame: (score) => recordCreateBloc.add(SubmitRecord(score))`
- Game widget handles gameplay loop independently

**gift_grab_ui Package**:
- Shared UI components and theming
- `GiftGrabTheme.lightTheme` / `GiftGrabTheme.darkTheme`
- Reusable widgets: `GGScaffoldWidget`, `FlexGridviewWidget`, `MenuButtonWidget`

### Dependency Injection

**App-Level Setup** (`lib/main.dart`):
```dart
MultiRepositoryProvider(
  providers: [
    RepositoryProvider<NakamaBaseClient>(create: (_) => client),
    RepositoryProvider<ISessionRepository>(create: (_) => SessionRepository(...)),
    RepositoryProvider<ISocialAuthRepository>(create: (_) => SocialAuthRepository(...)),
    RepositoryProvider<SessionService>(create: (_) => SessionService(...)),
    RepositoryProvider<SocialAuthService>(create: (_) => SocialAuthService(...)),
  ],
  child: MultiBlocProvider(
    providers: [
      BlocProvider<AuthCubit>(create: (_) => AuthCubit(...)),
      BlocProvider<AccountReadBloc>(create: (_) => AccountReadBloc(...)),
      BlocProvider<GroupRefreshCubit>(create: (_) => GroupRefreshCubit()),
      // ... other global BLoCs
    ],
    child: MaterialApp.router(...),
  ),
)
```

**Route-Level BLoCs:**
- Feature-specific BLoCs created in route builders
- Pass necessary repositories/services from context
- Disposed automatically when route pops

## Key Patterns & Conventions

### Feature Organization
Each feature follows consistent structure:
```
feature_name/
├── bloc/
│   ├── feature_bloc.dart
│   ├── feature_event.dart
│   └── feature_state.dart
└── view/
    ├── feature_page.dart      # Root page with BlocProvider
    └── feature_view.dart       # UI with BlocConsumer/BlocBuilder
```

### Constants & Text
- **All user-facing text** in `lib/data/constants/label_text.dart`
- **All feedback messages** in `lib/data/constants/feedback_messages.dart`
- **All global config** in `lib/data/constants/globals.dart`
- Use constants instead of hardcoded strings for maintainability

### Extensions
- `BuildContext`: `showSnackBar()`, `showErrorDialog()`, `showLoadingDialog()`
- `String`: `capitalize()`, `isValidEmail()`, `truncate()`
- `DateTime`: `toFormattedString()`, `timeAgo()`
- `Session`: `isExpired`, `hasExpired()`

### Error Handling
BLoCs use `bloc_error_handler` package:
```dart
await runWithErrorHandling(
  action: () async {
    // Operation that may throw
  },
  onSuccess: (result) {
    emit(state.copyWith(data: result));
  },
  onError: (error) {
    emit(state.copyWith(error: error));
  },
);
```

### Testing Patterns
- Use `blocTest` from `bloc_test` package
- Mock dependencies with `mocktail`
- Initialize test logger: `initializeTestLogger()` (from `test/test_helper.dart`)
- Test file mirrors source path: `lib/foo/bar.dart` → `test/foo/bar_test.dart`

**Test Structure:**
```dart
void main() {
  group('FeatureBloc', () {
    late MockDependency mockDependency;

    setUp(() {
      mockDependency = MockDependency();
      initializeTestLogger();
    });

    blocTest<FeatureBloc, FeatureState>(
      'description of test case',
      build: () => FeatureBloc(mockDependency),
      act: (bloc) => bloc.add(SomeEvent()),
      expect: () => [expectedState1, expectedState2],
      verify: (_) {
        verify(() => mockDependency.method()).called(1);
      },
    );
  });
}
```

## Configuration Files

### .env
Contains `NAKAMA_SERVER_KEY` (currently `defaultkey`)

### shorebird.yaml
- `app_id`: Unique identifier for Shorebird
- `auto_update`: Defaults to true (automatic background updates)

### analysis_options.yaml
Enforces:
- `prefer_const_constructors`
- `prefer_const_declarations`
- `use_key_in_widget_constructors`
- `prefer_final_fields`
- `avoid_unnecessary_containers`

## Common Development Scenarios

### Adding a New Feature
1. Create BLoC structure in `lib/presentation/blocs/feature_name/`
2. Define events (sealed class) and states (Equatable with copyWith)
3. Implement BLoC with event handlers using `runWithErrorHandling()`
4. Create page/view in `lib/presentation/blocs/feature_name/view/`
5. Add route to `app_routes.dart` and enum to `GoRoutes`
6. Add text constants to `label_text.dart` and `feedback_messages.dart`
7. Write tests in `test/presentation/blocs/feature_name/`

### Modifying Authentication
- Authentication logic in `AuthCubit` (`lib/presentation/cubits/auth/`)
- OAuth providers in `SocialAuthRepository` (`lib/data/repositories/social_auth_repository.dart`)
- Session management in `SessionService` (`lib/domain/services/session_service.dart`)
- Secure storage via `flutter_secure_storage` in `SessionRepository`

### Working with Leaderboards
- Leaderboard IDs defined in `Leaderboards` enum (`lib/data/enums/leaderboards.dart`)
- Submit scores: `RecordCreateBloc` (`lib/presentation/blocs/record_create/`)
- Fetch scores: `RecordListBloc` (`lib/presentation/blocs/record_list/`)
- Domain entity: `LeaderboardEntry` (`lib/domain/entities/leaderboard_entry.dart`)

### Adding a New Route
1. Add route name to `GoRoutes` enum
2. Add `GoRoute` in `appRouter()` function
3. Create page with necessary BLoC providers
4. Use `context.go()` or `context.push()` to navigate

### Switching Environments
Change `Globals.isProd` in `lib/data/constants/globals.dart`:
- `true`: Production server (`gift-grab-server.app`)
- `false`: Local development (`127.0.0.1`)

## Project-Specific Notes

- **Version Format:** `YY.M.D+build` (e.g., `25.9.7+69`)
- **Assets:** Images in `assets/images/`, audio in `assets/audio/`
- **Platforms:** Android, iOS, Web, macOS (Flutter multi-platform)
- **Git Dependencies:** `gift_grab_game` and `gift_grab_ui` are external packages
- **Secure Storage:** Session tokens stored via `flutter_secure_storage`
- **Logger:** Global logger instance in `main.dart` (use `logger.i()`, `logger.e()`, etc.)
- **Pagination:** List BLoCs use cursor-based pagination with configurable limits in `Globals`

## Useful Scripts

- `./install_flutter_packages.sh`: Batch install Flutter packages from file
- `./update_coverage.sh`: Run tests, generate coverage report and badge
