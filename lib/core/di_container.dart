import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/data/repositories/session_repository.dart';
import 'package:gift_grab_client/domain/services/group_service.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/controllers/account_read_controller.dart';
import 'package:gift_grab_client/presentation/controllers/auth_controller.dart';
import 'package:gift_grab_client/presentation/controllers/group_members_list_controller.dart';
import 'package:gift_grab_client/presentation/controllers/group_members_update_controller.dart';
import 'package:gift_grab_client/presentation/services/modal_service.dart';
import 'package:nakama/nakama.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;

final di = GetIt.I;

Future<void> configureDependencies() async {
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

  di.registerSingleton<clerk.Auth>(clerk.Auth(config: Globals.clerkAuthConfig));

  // -- CONTROLLERS --

  di.registerSingleton<AuthController>(
    AuthController(
      client: getNakamaClient(),
      sessionService: di<SessionService>(),
      clerkAuth: di<clerk.Auth>(),
    ),
  );

  // Account Read Controller
  di.registerSingleton<AccountReadController>(
    AccountReadController(getNakamaClient(), di<SessionService>()),
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
