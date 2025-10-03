import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:gift_grab_client/data/constants/label_text.dart';
import 'package:gift_grab_client/domain/services/modal_service.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/domain/services/social_auth_service.dart';
import 'package:gift_grab_client/presentation/blocs/account_read/account_read.dart';
import 'package:gift_grab_client/presentation/blocs/account_update/bloc/account_update_bloc.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:gift_grab_ui/formz_inputs/short_text/short_text_input.dart';
import 'package:gift_grab_ui/widgets/gg_scaffold_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:nakama/nakama.dart';
import 'package:profanity_api/profanity_api.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
    final modalService = context.read<ModalService>();

    return BlocListener<AccountUpdateBloc, AccountUpdateState>(
      listener: (context, state) {
        if (state.success != null) {
          modalService.shadToast(context, title: Text(state.success!));
          context.pop(true);
        }

        if (state.error != null) {
          modalService.shadToastDestructive(context, title: Text(state.error!));
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
            child: state.status == FormzSubmissionStatus.inProgress
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: const EdgeInsetsGeometry.all(32),
                    child: Column(
                      children: [
                        ShortTextInput(
                          state.username,
                          labelText: 'Username',
                          onChanged: (name) => userUpdateBloc.add(
                            UsernameChange(name),
                          ),
                        ),
                        const Spacer(),
                        ShadButton(
                            onPressed: () async {
                              final inputs = <FormzInput>[state.username];

                              final inputsValid = Formz.validate(inputs);

                              if (!inputsValid) {
                                modalService.shadToastDestructive(context,
                                    title: const Text('Form not valid'));

                                return;
                              }

                              final confirm =
                                  await modalService.shadConfirmationDialog(
                                context,
                                title: const Text('Save profile'),
                                description: const Text(LabelText.confirm),
                              );

                              if (!confirm.falseIfNull()) return;

                              userUpdateBloc.add(const SaveForm());
                            },
                            child: const Text('Save')),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
