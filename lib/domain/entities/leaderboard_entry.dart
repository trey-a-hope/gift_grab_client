import 'package:nakama/nakama.dart';

class LeaderboardEntry {
  final LeaderboardRecord record;
  final User user;

  LeaderboardEntry({required this.record, required this.user});
}
