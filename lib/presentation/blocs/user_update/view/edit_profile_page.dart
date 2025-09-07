import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:gift_grab_client/data/constants/label_text.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/domain/services/social_auth_service.dart';
import 'package:gift_grab_client/presentation/blocs/account_read/account_read.dart';
import 'package:gift_grab_client/presentation/blocs/account_update/bloc/account_update_bloc.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:gift_grab_ui/formz_inputs/short_text/short_text_input.dart';
import 'package:gift_grab_ui/widgets/gg_scaffold_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_util/modal_util.dart';
import 'package:nakama/nakama.dart';
import 'package:profanity_api/profanity_api.dart';

import '../user_update.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final accountReadBloc = context.read<AccountReadBloc>();

    final account = accountReadBloc.state.account!;

    return MultiBlocProvider(
      providers: [
        BlocProvider<UserUpdateBloc>(
          create: (context) => UserUpdateBloc(
            account,
            context.read<SessionService>(),
          )..add(const Init()),
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
      child: const EditProfileView(),
    );
  }
}

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final userUpdateBloc = context.read<UserUpdateBloc>();
    final accountUpdateBloc = context.read<AccountUpdateBloc>();

    return BlocListener<AccountUpdateBloc, AccountUpdateState>(
      listener: (context, state) {
        if (state.success != null) {
          ModalUtil.showSuccess(context, title: state.success!);
          context.pop(true);
        }

        if (state.error != null) {
          ModalUtil.showError(context, title: state.error!);
          userUpdateBloc.add(const Init());
        }
      },
      child: BlocConsumer<UserUpdateBloc, UserUpdateState>(
        listener: (context, state) {
          if (state.status == FormzSubmissionStatus.inProgress) {
            accountUpdateBloc.add(
              UpdateAccount(state.username.value),
            );
          }
        },
        builder: (context, state) {
          return GGScaffoldWidget(
            title: 'Edit Profile',
            child: Center(
              child: state.status == FormzSubmissionStatus.inProgress
                  ? const CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsetsGeometry.all(32),
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
                                final inputs = <FormzInput>[state.username];

                                final inputsValid = Formz.validate(inputs);

                                if (!inputsValid) {
                                  ModalUtil.showError(context,
                                      title: 'Form not valid');
                                  return;
                                }

                                final confirm =
                                    await ModalUtil.showConfirmation(
                                  context,
                                  title: 'Save Profile?',
                                  message: LabelText.confirm,
                                );

                                if (!confirm.falseIfNull()) return;

                                userUpdateBloc.add(const SaveForm());
                              },
                              child: const Text('Save')),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
