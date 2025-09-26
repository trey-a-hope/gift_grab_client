import 'package:bloc/bloc.dart';

class GroupRefreshCubit extends Cubit<DateTime> {
  GroupRefreshCubit() : super(DateTime.now());

  void triggerRefresh() => emit(DateTime.now());
}
