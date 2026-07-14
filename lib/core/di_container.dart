import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:gift_grab_client/data/repositories/session_repository.dart';
import 'package:gift_grab_client/domain/services/group_service.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/controllers/group_users_controller.dart';
import 'package:gift_grab_client/presentation/services/modal_service.dart';
import 'package:nakama/nakama.dart';

final di = GetIt.I;

Future<void> configureDependencies() async {
  di.registerSingleton<ModalService>(ModalService());

  di.registerSingleton<SessionService>(
    SessionService(
      SessionRepository(const FlutterSecureStorage(), getNakamaClient()),
    ),
  );

  di.registerSingleton<GroupService>(
    GroupService(di<SessionService>(), getNakamaClient()),
  );

  di.registerFactoryParam<GroupUsersController, String, void>(
    (groupId, _) => GroupUsersController(groupId, di<GroupService>()),
  );
}
