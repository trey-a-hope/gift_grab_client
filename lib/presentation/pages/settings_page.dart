import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/domain/services/social_auth_service.dart';
import 'package:gift_grab_client/presentation/blocs/account/account_delete/bloc/account_delete_bloc.dart';
import 'package:gift_grab_client/presentation/blocs/account/account_read/account_read.dart';
import 'package:gift_grab_client/presentation/blocs/account/account_update/bloc/account_update_bloc.dart';
import 'package:gift_grab_client/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_util/modal_util.dart';
import 'package:nakama/nakama.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final account = context.read<AccountReadBloc>().state.account!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AccountDeleteBloc(
            getNakamaClient(),
            context.read<SessionService>(),
            context.read<AuthCubit>(),
          ),
          child: const SettingsView(),
        ),
        BlocProvider(
          create: (context) => AccountUpdateBloc(
            account,
            context.read<SessionService>(),
            getNakamaClient(),
            context.read<SocialAuthService>(),
          ),
          child: const SettingsView(),
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
    final accountReadBloc = context.read<AccountReadBloc>();
    final accountDeleteBloc = context.read<AccountDeleteBloc>();
    final accountUpdateBloc = context.read<AccountUpdateBloc>();

    return MultiBlocListener(
      listeners: [
        BlocListener<AccountDeleteBloc, AccountDeleteState>(
          listener: (context, state) {
            if (state.error != null) {
              ModalUtil.showError(context, title: state.error!);
            }

            if (state.success != null) {
              ModalUtil.showSuccess(context, title: state.success!);
            }
          },
        ),
        BlocListener<AccountUpdateBloc, AccountUpdateState>(
          listener: (context, state) {
            if (state.error != null) {
              ModalUtil.showError(context, title: state.error!);
            }

            if (state.success != null) {
              ModalUtil.showSuccess(context, title: state.success!);
              accountReadBloc.add(const ReadAccount());
            }
          },
        ),
      ],
      child: GGScaffoldWidget(
        title: 'Settings',
        child: BlocConsumer<AccountReadBloc, AccountReadState>(
          listener: (context, state) {
            if (state.error != null) {
              ModalUtil.showError(context, title: state.error!);
            }
          },
          builder: (context, state) {
            final account = state.account!;

            final isEmailLinked = account.email?.isNotEmpty ?? false;
            final isGoogleLinked = account.user.googleId?.isNotEmpty ?? false;
            final isAppleLinked = account.user.appleId?.isNotEmpty ?? false;

            return SettingsList(
              sections: [
                SettingsSection(
                  title: const Text('Authentication'),
                  tiles: [
                    SettingsTile.navigation(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onPressed: (_) async {
                        final confirm = await ModalUtil.showConfirmation(
                          context,
                          title: 'Logout',
                          message: 'Are you sure?',
                        );

                        if (confirm != true) {
                          return;
                        }

                        if (!context.mounted) return;

                        authCubit.logout();
                      },
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.delete),
                      title: const Text('Delete Account'),
                      onPressed: (_) async {
                        final account = accountReadBloc.state.account!;

                        final confirm =
                            await ModalUtil.showInputMatchConfirmation(
                          context: context,
                          title: 'Delete Account?',
                          hintText: 'Enter your email to confirm.',
                          match: account.email!,
                        );

                        if (confirm == null || confirm == false) {
                          return;
                        }

                        if (!context.mounted) return;

                        accountDeleteBloc.add(const DeleteAccount());
                      },
                    ),
                  ],
                ),
                SettingsSection(
                  title: const Text('Connected Accounts'),
                  tiles: <SettingsTile>[
                    SettingsTile.switchTile(
                      onToggle: (val) async {
                        if (val) {
                          final result =
                              await ModalUtil.showEmailPasswordDialog(
                            context,
                          );

                          if (result == null) return;

                          final email = result.$1;
                          final password = result.$2;

                          if (!context.mounted) return;

                          accountUpdateBloc.add(LinkEmail(email, password));
                        } else {
                          accountUpdateBloc.add(const UnlinkEmail());
                        }
                      },
                      initialValue: isEmailLinked,
                      leading: const Icon(Icons.email),
                      title: const Text('Link to Email'),
                    ),
                    SettingsTile.switchTile(
                      onToggle: (val) async => val
                          ? accountUpdateBloc.add(const LinkGoogle())
                          : accountUpdateBloc.add(const UnlinkGoogle()),
                      initialValue: isGoogleLinked,
                      leading: Icon(MdiIcons.google),
                      title: const Text('Link to Google'),
                    ),
                    SettingsTile.switchTile(
                      onToggle: (val) async => val
                          ? accountUpdateBloc.add(const LinkApple())
                          : accountUpdateBloc.add(const UnlinkApple()),
                      initialValue: isAppleLinked,
                      leading: Icon(MdiIcons.apple),
                      title: const Text('Link to Apple'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
