import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gift_grab_client/core/di_container.dart';
import 'package:gift_grab_client/data/constants/label_text.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/main.dart';
import 'package:gift_grab_client/presentation/blocs/account_delete/account_delete.dart';
import 'package:gift_grab_client/presentation/blocs/account_update/account_update.dart';
import 'package:gift_grab_client/presentation/controllers/account_read_controller.dart';
import 'package:gift_grab_client/presentation/controllers/auth_controller.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:gift_grab_client/presentation/services/modal_service.dart';
import 'package:gift_grab_ui/widgets/gg_scaffold_widget.dart';
import 'package:nakama/nakama.dart';
import 'package:profanity_api/profanity_api.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accountReadController = di<AccountReadController>();
    final authController = di<AuthController>();
    final sessionService = di<SessionService>();
    final account = accountReadController.accountSignal.value.value!;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AccountDeleteBloc>(
          create: (context) => AccountDeleteBloc(
            authController,
            sessionService,
            getNakamaClient(),
          ),
        ),
        BlocProvider<AccountUpdateBloc>(
          create: (context) => AccountUpdateBloc(
            account,
            sessionService,
            getNakamaClient(),
            ProfanityApi.instance,
          ),
        ),
      ],
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = di<AuthController>();
    final accountDeleteBloc = context.read<AccountDeleteBloc>();
    final accountReadController = di<AccountReadController>();
    final modalService = di<ModalService>();

    return MultiBlocListener(
      listeners: [
        BlocListener<AccountDeleteBloc, AccountDeleteState>(
          listener: (context, state) {
            if (state.success != null) {
              modalService.shadToast(context, title: Text(state.success!));
            }

            if (state.error != null) {
              modalService.shadToastDestructive(
                context,
                title: Text(state.error!),
              );
            }
          },
        ),
        BlocListener<AccountUpdateBloc, AccountUpdateState>(
          listener: (context, state) {
            if (state.success != null) {
              modalService.shadToast(context, title: Text(state.success!));
              accountReadController.accountSignal.reset();
            }

            if (state.error != null) {
              modalService.shadToastDestructive(
                context,
                title: Text(state.error!),
              );
            }
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          return GGScaffoldWidget(
            title: 'Settings',
            child: SettingsList(
              sections: [
                SettingsSection(
                  title: const Text('App Info'),
                  tiles: [
                    SettingsTile.navigation(
                      leading: const FaIcon(FontAwesomeIcons.idCard),
                      title: const Text('Licenses'),
                      value: Text(
                        'v ${packageInfo.version}.${packageInfo.buildNumber}',
                      ),
                      onPressed: (context) async =>
                          showLicensePage(context: context),
                    ),
                  ],
                ),
                SettingsSection(
                  title: const Text('Authentication'),
                  tiles: [
                    SettingsTile.navigation(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onPressed: (context) async {
                        final confirm = await modalService
                            .shadConfirmationDialog(
                              context,
                              title: const Text('Logout'),
                              description: const Text(LabelText.confirm),
                            );

                        if (!confirm.falseIfNull()) return;

                        await authController.logout();
                      },
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.delete),
                      title: const Text('Delete account'),
                      onPressed: (context) async {
                        final confirm = await modalService
                            .shadConfirmationDialog(
                              context,
                              title: const Text('Delete account'),
                              description: const Text(LabelText.confirm),
                            );

                        if (!confirm.falseIfNull()) return;

                        accountDeleteBloc.add(const DeleteAccount());
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
