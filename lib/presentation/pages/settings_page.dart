import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:gift_grab_client/presentation/widgets/flex_gridview_widget.dart';
import 'package:gift_grab_client/presentation/widgets/menu_button/menu_button_widget.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:modal_util/modal_util.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    return GGScaffoldWidget(
      title: 'Settings',
      child: Padding(
        padding: const EdgeInsetsGeometry.all(32),
        child: FlexGridviewWidget(
          children: [
            MenuButtonWidget(
              menuButton: MenuButton.logout,
              onTap: () async {
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
          ],
        ),
      ),
    );
  }
}
