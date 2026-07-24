import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gift_grab_client/data/repositories/session_repository.dart';
import 'package:gift_grab_client/domain/services/group_service.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/controllers/account_read_controller.dart';
import 'package:gift_grab_client/presentation/controllers/auth_controller.dart';
import 'package:gift_grab_client/presentation/controllers/group_members_list_controller.dart';
import 'package:gift_grab_client/presentation/controllers/group_members_update_controller.dart';
import 'package:gift_grab_client/presentation/services/modal_service.dart';
import 'package:nakama/nakama.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

final di = GetIt.I;

Future<void> configureDependencies({
  required ClerkAuthState clerkAuthState,
}) async {
  di.registerSingleton<ClerkAuthState>(clerkAuthState);

  // -- SERVICES --
  // Modal Service
  di.registerSingleton<ModalService>(ModalService());

  // Session Service
  di.registerSingleton<SessionService>(
    SessionService(
      SessionRepository(const FlutterSecureStorage(), getNakamaClient()),
    ),
  );

  // Group Service
  di.registerSingleton<GroupService>(
    GroupService(di<SessionService>(), getNakamaClient()),
  );

  // -- CONTROLLERS --
  di.registerLazySingleton<AuthController>(
    () => AuthController(
      client: getNakamaClient(),
      sessionService: di<SessionService>(),
      clerkAuth: di<ClerkAuthState>(),
    ),
  );

  // Account Read Controller
  di.registerLazySingleton<AccountReadController>(
    () => AccountReadController(getNakamaClient(), di<SessionService>()),
  );

  // Group Members List Controller
  di.registerFactoryParam<GroupMembersListController, String, void>(
    (groupId, _) => GroupMembersListController(
      groupId,
      di<AccountReadController>(),
      di<GroupService>(),
    ),
  );

  // Group Members Update Controller
  di.registerFactoryParam<GroupMembersUpdateController, String, void>(
    (groupId, _) => GroupMembersUpdateController(groupId, di<GroupService>()),
  );
}
