import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gift_grab_client/data/constants/label_text.dart';
import 'package:gift_grab_client/domain/services/modal_service.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/domain/services/social_auth_service.dart';
import 'package:gift_grab_client/main.dart';
import 'package:gift_grab_client/presentation/blocs/account_delete/account_delete.dart';
import 'package:gift_grab_client/presentation/blocs/account_read/bloc/account_read_bloc.dart';
import 'package:gift_grab_client/presentation/blocs/account_update/account_update.dart';
import 'package:gift_grab_client/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:gift_grab_ui/widgets/gg_scaffold_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nakama/nakama.dart';
import 'package:profanity_api/profanity_api.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:universal_platform/universal_platform.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accountReadBloc = context.read<AccountReadBloc>();
    final account = accountReadBloc.state.account!;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AccountDeleteBloc>(
          create: (context) => AccountDeleteBloc(
            context.read<AuthCubit>(),
            context.read<SessionService>(),
            getNakamaClient(),
          ),
        ),
        BlocProvider<AccountUpdateBloc>(
          create: (context) => AccountUpdateBloc(
            account,
            context.read<SessionService>(),
            getNakamaClient(),
            context.read<SocialAuthService>(),
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
    final authCubit = context.read<AuthCubit>();
    final accountDeleteBloc = context.read<AccountDeleteBloc>();
    final accountUpdateBloc = context.read<AccountUpdateBloc>();
    final accountReadBloc = context.read<AccountReadBloc>();
    final modalService = context.read<ModalService>();

    return MultiBlocListener(
      listeners: [
        BlocListener<AccountDeleteBloc, AccountDeleteState>(
          listener: (context, state) {
            if (state.success != null) {
              modalService.shadToast(context, title: Text(state.success!));
            }

            if (state.error != null) {
              modalService.shadToastDestructive(context,
                  title: Text(state.error!));
            }
          },
        ),
        BlocListener<AccountUpdateBloc, AccountUpdateState>(
          listener: (context, state) {
            if (state.success != null) {
              modalService.shadToast(context, title: Text(state.success!));
              accountReadBloc.add(const ReadAccount());
            }

            if (state.error != null) {
              modalService.shadToastDestructive(context,
                  title: Text(state.error!));
            }
          },
        ),
      ],
      child: BlocBuilder<AccountReadBloc, AccountReadState>(
        builder: (context, state) {
          final isEmailLinked = state.account?.email?.isNotEmpty ?? false;
          final isGoogleLinked =
              state.account?.user.googleId?.isNotEmpty ?? false;
          final isAppleLinked =
              state.account?.user.appleId?.isNotEmpty ?? false;

          return GGScaffoldWidget(
            title: 'Settings',
            child: SettingsList(
              sections: [
                SettingsSection(
                  title: const Text('Connected Accounts'),
                  tiles: [
                    SettingsTile.switchTile(
                      initialValue: isEmailLinked,
                      onToggle: (val) async {
                        // TODO (Trey) - Added showEmailPasswordDialog to modalService
                        // if (val) {
                        //   final result =
                        //       await ModalUtil.showEmailPasswordDialog(context);

                        //   if (result == null) return;

                        //   final email = result.$1;
                        //   final password = result.$2;

                        //   accountUpdateBloc.add(LinkEmail(email, password));
                        // } else {
                        //   accountUpdateBloc.add(const UnlinkEmail());
                        // }
                      },
                      leading: const Icon(Icons.email),
                      title: const Text('Link to Email'),
                    ),
                    SettingsTile.switchTile(
                      initialValue: isGoogleLinked,
                      onToggle: (val) async => accountUpdateBloc
                          .add(val ? const LinkGoogle() : const UnlinkGoogle()),
                      leading: const Icon(FontAwesomeIcons.google),
                      title: const Text('Link to Google'),
                    ),
                    if (UniversalPlatform.isIOS ||
                        UniversalPlatform.isMacOS) ...[
                      SettingsTile.switchTile(
                        initialValue: isAppleLinked,
                        onToggle: (val) async => accountUpdateBloc
                            .add(val ? const LinkApple() : const UnlinkApple()),
                        leading: const Icon(FontAwesomeIcons.apple),
                        title: const Text('Link to Apple'),
                      ),
                    ],
                  ],
                ),
                SettingsSection(
                  title: const Text('App Info'),
                  tiles: [
                    SettingsTile.navigation(
                      leading: Icon(MdiIcons.license),
                      title: const Text('Licenses'),
                      value: Text(
                          'v ${packageInfo.version}.${packageInfo.buildNumber}'),
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
                        final confirm =
                            await modalService.shadConfirmationDialog(
                          context,
                          title: const Text('Logout'),
                          description: const Text(LabelText.confirm),
                        );

                        if (!confirm.falseIfNull()) return;

                        authCubit.logout();
                      },
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.delete),
                      title: const Text('Delete account'),
                      onPressed: (context) async {
                        final confirm =
                            await modalService.shadConfirmationDialog(
                          context,
                          title: const Text('Delete reqaccountuest'),
                          description: const Text(LabelText.confirm),
                        );

                        if (!confirm.falseIfNull()) return;

                        accountDeleteBloc.add(const DeleteAccount());
                      },
                    )
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
