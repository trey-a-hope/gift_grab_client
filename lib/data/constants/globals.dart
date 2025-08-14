part 'feedback_messages.dart';
part 'test_descriptions.dart';

class Globals {
  Globals._();

  static final feedbackMessages = _FeedbackMessages();
  static final testDescriptions = _TestDescriptions();

  // Limits
  static const paginationLimit = 20;

  // Image Paths
  static const String emptyProfile =
      'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';

  static const String giftAsset = 'assets/images/gift-sprite.png';

  static const String nakamaClientHost = 'gift-grab-server.app';
  static const String nakamaClientServerKey = 'defaultkey';
  static const int nakamaClientHttpPort = 443;
}
