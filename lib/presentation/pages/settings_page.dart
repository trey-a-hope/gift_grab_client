import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/domain/services/social_auth_service.dart';
import 'package:gift_grab_client/main.dart';
import 'package:gift_grab_client/presentation/blocs/account_delete/account_delete.dart';
import 'package:gift_grab_client/presentation/blocs/account_read/bloc/account_read_bloc.dart';
import 'package:gift_grab_client/presentation/blocs/account_update/account_update.dart';
import 'package:gift_grab_client/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:gift_grab_ui/widgets/gg_scaffold_widget.dart';
import 'package:modal_util/modal_util.dart';
import 'package:nakama/nakama.dart';
import 'package:settings_ui/settings_ui.dart';

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

    return MultiBlocListener(
      listeners: [
        BlocListener<AccountDeleteBloc, AccountDeleteState>(
          listener: (context, state) {
            if (state.success != null) {
              ModalUtil.showSuccess(context, title: state.success!);
            }

            if (state.error != null) {
              ModalUtil.showError(context, title: state.error!);
            }
          },
        ),
        BlocListener<AccountUpdateBloc, AccountUpdateState>(
          listener: (context, state) {
            if (state.success != null) {
              ModalUtil.showSuccess(context, title: state.success!);
              accountReadBloc.add(const ReadAccount());
            }

            if (state.error != null) {
              ModalUtil.showError(context, title: state.error!);
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
                  title: const Text('Authentication'),
                  tiles: [
                    SettingsTile.navigation(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onPressed: (context) async {
                        final confirm = await ModalUtil.showConfirmation(
                          context,
                          title: 'Logout',
                          message: 'Are you sure?',
                        );

                        if (confirm != true) return;

                        authCubit.logout();
                      },
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.delete),
                      title: const Text('Delete Account'),
                      onPressed: (context) async {
                        final confirm = await ModalUtil.showConfirmation(
                          context,
                          title: 'Delete Account',
                          message: 'Press yes to confirm',
                        );

                        if (confirm != true) return;

                        accountDeleteBloc.add(const DeleteAccount());
                      },
                    )
                  ],
                ),
                SettingsSection(
                  title: const Text('Connected Accounts'),
                  tiles: [
                    SettingsTile.switchTile(
                      initialValue: isEmailLinked,
                      onToggle: (val) async {
                        if (val) {
                          final result =
                              await ModalUtil.showEmailPasswordDialog(context);

                          if (result == null) return;

                          final email = result.$1;
                          final password = result.$2;

                          accountUpdateBloc.add(LinkEmail(email, password));
                        } else {
                          accountUpdateBloc.add(const UnlinkEmail());
                        }
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
                    SettingsTile.switchTile(
                      initialValue: isAppleLinked,
                      onToggle: (val) async => accountUpdateBloc
                          .add(val ? const LinkApple() : const UnlinkApple()),
                      leading: const Icon(FontAwesomeIcons.apple),
                      title: const Text('Link to Apple'),
                    )
                  ],
                ),
                SettingsSection(
                  title: const Text('App Info'),
                  tiles: [
                    SettingsTile(
                      title: Text(packageInfo.version),
                      leading: const Icon(Icons.phone_android),
                      value: const Text('version'),
                    ),
                    SettingsTile(
                      title: Text(packageInfo.buildNumber),
                      leading: const Icon(Icons.phone_iphone),
                      value: const Text('build'),
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
