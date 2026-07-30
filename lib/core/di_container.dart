import 'package:get_it/get_it.dart';
import 'package:gift_grab_client/data/repositories/session_repository.dart';
import 'package:gift_grab_client/domain/services/group_service.dart';
import 'package:gift_grab_client/domain/services/post_hog_service.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/controllers/account_read_controller.dart';
import 'package:gift_grab_client/presentation/controllers/auth_controller.dart';
import 'package:gift_grab_client/presentation/controllers/group_members_list_controller.dart';
import 'package:gift_grab_client/presentation/controllers/group_members_update_controller.dart';
import 'package:gift_grab_client/presentation/services/modal_service.dart';
import 'package:nakama/nakama.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

/// Global Dependency Injection container instance.
final di = GetIt.I;

/// Configures and registers all the dependency injections for the application.
Future<void> configureDependencies({
  required ClerkAuthState clerkAuthState,
}) async {
  // PostHog analytics
  di.registerSingleton<PostHogService>(
    await PostHogService()
      ..initialize(),
  );

  // Clerk authentication state managed externally.
  di.registerSingleton<ClerkAuthState>(clerkAuthState);

  // App-wide helper for displaying modal dialogs.
  di.registerSingleton<ModalService>(ModalService());

  // Manages user session credentials and local secure storage.
  di.registerSingleton<SessionService>(
    SessionService(SessionRepository(getNakamaClient())),
  );

  // Handles group-related actions and member retrieval.
  di.registerSingleton<GroupService>(
    GroupService(di<SessionService>(), getNakamaClient()),
  );

  // Manages authentication flows and login state.
  di.registerLazySingleton<AuthController>(
    () => AuthController(
      getNakamaClient(),
      di<SessionService>(),
      di<ClerkAuthState>(),
      di<PostHogService>(),
    ),
  );

  // Handles retrieving and caching user account details.
  di.registerLazySingleton<AccountReadController>(
    () => AccountReadController(
      getNakamaClient(),
      di<SessionService>(),
      di<AuthController>(),
      di<PostHogService>(),
    ),
  );

  // Instantiated per-group with a specific groupId to list members.
  di.registerFactoryParam<GroupMembersListController, String, void>(
    (groupId, _) => GroupMembersListController(
      groupId,
      di<AccountReadController>(),
      di<GroupService>(),
    ),
  );

  // Instantiated per-group to perform admin/member updates.
  di.registerFactoryParam<GroupMembersUpdateController, String, void>(
    (groupId, _) => GroupMembersUpdateController(groupId, di<GroupService>()),
  );
}
