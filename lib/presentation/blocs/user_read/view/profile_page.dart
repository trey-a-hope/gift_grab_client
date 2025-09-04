import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/data/enums/go_routes.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/account_read/bloc/account_read_bloc.dart';
import 'package:gift_grab_client/presentation/extensions/user_extensions.dart';
import 'package:gift_grab_ui/widgets/gg_scaffold_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:nakama/nakama.dart';

import '../user_read.dart';

class ProfilePage extends StatelessWidget {
  final String uid;

  const ProfilePage(this.uid, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserReadBloc>(
      create: (context) => UserReadBloc(
        uid,
        getNakamaClient(),
        context.read<SessionService>(),
      )..add(const ReadUser()),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserReadBloc, UserReadState>(
      builder: (context, state) {
        final user = state.user;

        return GGScaffoldWidget(
          title: user?.username ?? '',
          actions: [
            if (state.isMyProfile) ...[
              IconButton.filledTonal(
                  onPressed: () async {
                    final success = await context.pushNamed<bool>(
                      GoRoutes.EDIT_PROFILE.name,
                      pathParameters: {'uid': user!.id},
                    );

                    if (success == true) {
                      context.read<UserReadBloc>().add(const ReadUser());
                      context.read<AccountReadBloc>().add(const ReadAccount());
                    }
                  },
                  icon: const Icon(Icons.edit))
            ]
          ],
          child: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsetsGeometry.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CircleAvatar(
                        radius: 100,
                        backgroundImage: user?.getAvatar(),
                      )
                    ],
                  ),
                ),
        );
      },
    );
  }
}
