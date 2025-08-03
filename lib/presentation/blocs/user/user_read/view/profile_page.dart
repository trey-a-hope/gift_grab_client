import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/data/enums/go_routes.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/account/account_read/bloc/account_read_bloc.dart';
import 'package:gift_grab_ui/widgets/gg_scaffold_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_util/modal_util.dart';
import 'package:nakama/nakama.dart';

import '../user_read.dart';

class ProfilePage extends StatelessWidget {
  final String uid;

  const ProfilePage(this.uid, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserReadBloc(
        uid,
        context.read<SessionService>(),
        getNakamaClient(),
      )..add(const ReadUser()),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserReadBloc, UserReadState>(
      listener: (context, state) {
        if (state.error != null) {
          ModalUtil.showError(context, title: state.error!);
        }
      },
      builder: (context, state) {
        final user = state.user;

        return GGScaffoldWidget(
          title: user?.username ?? '',
          actions: [
            if (state.isMyProfile) ...[
              IconButton.filledTonal(
                onPressed: () async {
                  final success = await context.pushNamed<bool>(
                    GoRoutes.PROFILE_EDIT.name,
                    pathParameters: {'uid': user!.id},
                  );

                  if (!context.mounted) return;

                  if (success == true) {
                    context.read<UserReadBloc>().add(const ReadUser());
                    context.read<AccountReadBloc>().add(const ReadAccount());
                  }
                },
                icon: const Icon(Icons.edit),
              ),
            ]
          ],
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CircleAvatar(
                        radius: 100,
                        backgroundImage: Image.network(
                          user!.avatarUrl?.isEmpty ?? true
                              ? Globals.emptyProfile
                              : user.avatarUrl!,
                        ).image,
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
