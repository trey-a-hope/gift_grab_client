import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/cubits/group_refresh/cubit/group_refresh_cubit.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:gift_grab_client/presentation/pages/group_form_page.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_util/modal_util.dart';
import 'package:nakama/nakama.dart';
import 'package:profanity_api/profanity_api.dart';

import '../group_create.dart';

class GroupCreatePage extends StatelessWidget {
  const GroupCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GroupCreateBloc(
        getNakamaClient(),
        context.read<SessionService>(),
        ProfanityApi.instance,
      ),
      child: const GroupCreateView(),
    );
  }
}

class GroupCreateView extends StatelessWidget {
  const GroupCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    final groupCreateBloc = context.read<GroupCreateBloc>();

    return BlocConsumer<GroupCreateBloc, GroupCreateState>(
      listener: (context, state) {
        if (state.error != null) {
          ModalUtil.showError(context, title: state.error!);
        }

        if (state.success != null) {
          ModalUtil.showSuccess(context, title: state.success!);
          context.read<GroupRefreshCubit>().triggerRefresh();
          context.pop(true);
        }
      },
      builder: (context, state) {
        return GGScaffoldWidget(
            title: 'Create Group',
            child: SafeArea(
                child: GroupFormPage(
                    name: state.name,
                    nameChanged: (val) => groupCreateBloc.add(NameChanged(val)),
                    description: state.description,
                    descriptionChanged: (val) =>
                        groupCreateBloc.add(DescriptionChanged(val)),
                    maxCount: state.maxCount,
                    maxCountChanged: (val) =>
                        groupCreateBloc.add(MaxCountChanged(val.toInt())),
                    open: state.open,
                    openChanged: (val) => groupCreateBloc.add(OpenChanged(val)),
                    submit: () async {
                      final formValid = Formz.validate(state.inputs);

                      if (!formValid) {
                        ModalUtil.showError(context, title: 'Form not valid');
                        return;
                      }

                      final confirm = await ModalUtil.showConfirmation(
                        context,
                        title: 'Create Group',
                        message: 'Press yes to confirm',
                      );

                      if (!confirm.falseIfNull()) return;

                      groupCreateBloc.add(const SaveForm());
                    })));
      },
    );
  }
}
