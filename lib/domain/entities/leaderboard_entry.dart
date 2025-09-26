import 'package:equatable/equatable.dart';
import 'package:nakama/nakama.dart';

class LeaderboardEntry extends Equatable {
  final LeaderboardRecord record;
  final User user;

  const LeaderboardEntry({
    required this.record,
    required this.user,
  });

  @override
  List<Object?> get props => [record, user];
}
