import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/domain/services/social_auth_service.dart';
import 'package:gift_grab_client/presentation/blocs/account/account_read/bloc/account_read_bloc.dart';
import 'package:gift_grab_client/presentation/blocs/account/account_update/bloc/account_update_bloc.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_util/modal_util.dart';
import 'package:nakama/nakama.dart';

import '../user_update.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final account = context.read<AccountReadBloc>().state.account!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => UserUpdateBloc(
            account,
            context.read<SessionService>(),
          )..add(const Init()),
        ),
        BlocProvider(
          create: (_) => AccountUpdateBloc(
            account,
            context.read<SessionService>(),
            getNakamaClient(),
            context.read<SocialAuthService>(),
          ),
        ),
      ],
      child: const EditProfileView(),
    );
  }
}

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountUpdateBloc, AccountUpdateState>(
      listener: (context, state) {
        if (state.success != null) {
          ModalUtil.showSuccess(context, title: state.success!);
          context.pop(true);
        }

        if (state.error != null) {
          ModalUtil.showError(context, title: state.error!);
          context.read<UserUpdateBloc>().add(const Init());
        }
      },
      child: BlocConsumer<UserUpdateBloc, UserUpdateState>(
        listener: (context, state) {
          if (state.status == FormzSubmissionStatus.inProgress) {
            context.read<AccountUpdateBloc>().add(
                  UpdateAccount(username: state.username.value),
                );
          }
        },
        builder: (context, state) {
          final userUpdateBloc = context.read<UserUpdateBloc>();

          return GGScaffoldWidget(
            title: 'Edit Profile',
            child: state.status == FormzSubmissionStatus.inProgress
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShortTextInput(
                          state.username,
                          labelText: 'Username',
                          onChanged: (name) => userUpdateBloc.add(
                            UsernameChange(name),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final inputs = [state.username];

                            final inputsValid = Formz.validate(inputs);

                            if (!inputsValid) {
                              ModalUtil.showError(context,
                                  title: 'Form not valid');
                              return;
                            }

                            final confirm = await ModalUtil.showConfirmation(
                              context,
                              title: 'Save profile',
                              message: 'Are you sure?',
                            );

                            if (confirm != true) return;

                            userUpdateBloc.add(const SaveForm());
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
