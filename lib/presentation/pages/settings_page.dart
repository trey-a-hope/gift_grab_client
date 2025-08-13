import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/main.dart';
import 'package:gift_grab_client/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:gift_grab_ui/widgets/gg_scaffold_widget.dart';
import 'package:modal_util/modal_util.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsView();
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
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
              )
            ],
          ),
          SettingsSection(
            title: const Text('App Info'),
            tiles: [
              SettingsTile(
                title: const Text('Version'),
                trailing: Text(packageInfo.version),
              ),
              SettingsTile(
                title: const Text('Build'),
                trailing: Text(packageInfo.buildNumber),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
