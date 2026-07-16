import 'package:gift_grab_client/core/logging.dart';
import 'package:nakama/nakama.dart';

extension ListGroupUser on List<GroupUser> {
  void log({required String authenticatedUserId}) {
    for (final groupUser in this) {
      final isMe = groupUser.user.id == authenticatedUserId;
      logger.i(
        '${groupUser.user.username} (${groupUser.state.name})${isMe ? ' (me)' : ''}',
      );
    }
  }
}



// Thought process
// That's your shared ancestor. GroupDetailsView is currently StatelessWidget, so resolving the controller inside its build() would still call di<GroupMembersListController>(param1: ...) on every BlocBuilder rebuild (e.g., after ReadGroup() fires again post-edit) — same bug, just moved up one level. It needs to be resolved once and held in state.

// Convert GroupDetailsView to a StatefulWidget so the controller is created once in initState and stays stable across rebuilds:

// dart
// import 'package:gift_grab_client/core/di_container.dart';
// import 'package:gift_grab_client/presentation/controllers/group_members_list_controller.dart';
// // ...keep all existing imports

// class GroupDetailsView extends StatefulWidget {
//   final String groupId;
//   const GroupDetailsView(this.groupId, {super.key});

//   @override
//   State<GroupDetailsView> createState() => _GroupDetailsViewState();
// }

// class _GroupDetailsViewState extends State<GroupDetailsView> {
//   late final GroupMembersListController _groupMembersListController;

//   @override
//   void initState() {
//     super.initState();
//     _groupMembersListController = di<GroupMembersListController>(
//       param1: widget.groupId,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     final accountReadBloc = context.read<AccountReadBloc>();
//     final account = accountReadBloc.state.account!;
//     final groupReadBloc = context.read<GroupReadBloc>();
//     final groupRefreshCubit = context.read<GroupRefreshCubit>();
//     final groupDeleteBloc = context.read<GroupDeleteBloc>();
//     final modalService = context.read<ModalService>();

//     return BlocListener<GroupDeleteBloc, GroupDeleteState>(
//       listener: (context, state) {
//         if (state.error != null) {
//           modalService.shadToastDestructive(context, title: Text(state.error!));
//         }

//         if (state.success != null) {
//           modalService.shadToast(context, title: Text(state.success!));
//           groupRefreshCubit.triggerRefresh();
//           context.pop();
//         }
//       },
//       child: BlocBuilder<GroupReadBloc, GroupReadState>(
//         builder: (context, state) {
//           final group = state.group;
//           final isLoading = state.isLoading;

//           return GGScaffoldWidget(
//             title: group?.name ?? '',
//             actions: [
//               // ...unchanged
//             ],
//             child: SafeArea(
//               child: isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : group == null
//                   ? const NoResultsWidget(NoResultsEnum.allGroups)
//                   : Padding(
//                       padding: const EdgeInsetsGeometry.all(32),
//                       child: Column(
//                         crossAxisAlignment: .center,
//                         children: [
//                           NetworkCircleAvatar(
//                             imgUrl: group.avatarUrl,
//                             radius: 100,
//                           ),
//                           GapSizes.largeGap,
//                           GroupMembershipStateButton(
//                             groupId: group.id,
//                             groupMembersListController: _groupMembersListController,
//                           ),
//                           GapSizes.largeGap,
//                           Expanded(
//                             child: Row(
//                               children: [
//                                 // ...unchanged left column
//                                 Expanded(
//                                   child: MembersList(
//                                     widget.groupId,
//                                     _groupMembersListController,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
// Only real changes: class becomes StatefulWidget/State, controller created once in initState, and the two call sites (GroupMembershipStateButton, MembersList) now receive _groupMembersListController instead of resolving it themselves. Everything else in the middle (the actions, the description/join-type/date ListTiles) is untouched — just keep it as in your original.

// GroupDetailsPage itself doesn't need to change; it's still fine as StatelessWidget since it only constructs GroupDetailsView(groupId) once via MultiBlocProvider.