import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:gift_grab_client/data/constants/label_text.dart';
import 'package:gift_grab_client/domain/services/modal_service.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:gift_grab_client/presentation/pages/group_form_page.dart';
import 'package:gift_grab_ui/widgets/gg_scaffold_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:nakama/nakama.dart';
import 'package:profanity_api/profanity_api.dart';

import '../../../cubits/group_refresh/cubit/group_refresh_cubit.dart';
import '../group_update.dart';

class EditGroupPage extends StatelessWidget {
  final Group group;

  const EditGroupPage(this.group, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GroupUpdateBloc(getNakamaClient(),
          context.read<SessionService>(), ProfanityApi.instance)
        ..add(InitForm(group)),
      child: EditGroupView(group),
    );
  }
}

class EditGroupView extends StatelessWidget {
  final Group group;
  const EditGroupView(this.group, {super.key});

  @override
  Widget build(BuildContext context) {
    final groupUpdateBloc = context.read<GroupUpdateBloc>();
    final modalService = context.read<ModalService>();

    return BlocConsumer<GroupUpdateBloc, GroupUpdateState>(
      listener: (context, state) {
        if (state.error != null) {
          modalService.shadToastDestructive(context, title: Text(state.error!));
        }

        if (state.success != null) {
          modalService.shadToast(context, title: Text(state.success!));
          context.read<GroupRefreshCubit>().triggerRefresh();
          context.pop(true);
        }
      },
      builder: (context, state) {
        return GGScaffoldWidget(
          title: 'Update Group',
          child: SafeArea(
            child: GroupFormPage(
              name: state.name,
              nameChanged: (val) => groupUpdateBloc.add(NameChanged(val)),
              description: state.description,
              descriptionChanged: (val) =>
                  groupUpdateBloc.add(DescriptionChanged(val)),
              open: state.open,
              openChanged: (val) => groupUpdateBloc.add(OpenChanged(val)),
              submit: () async {
                final formValid = Formz.validate(state.inputs);

                if (!formValid) {
                  modalService.shadToastDestructive(context,
                      title: const Text('Form not valid'));
                  return;
                }

                final confirm = await modalService.shadConfirmationDialog(
                  context,
                  title: const Text('Update group'),
                  description: const Text(LabelText.confirm),
                );

                if (!confirm.falseIfNull()) return;

                groupUpdateBloc.add(SaveForm(group.id));
              },
            ),
          ),
        );
      },
    );
  }
}
