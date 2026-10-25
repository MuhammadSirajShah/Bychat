
class ByChatContactModel {
  final String uid;
  final String name;
  final String phoneNumber;
  final String username;
  final String? photoUrl;
  final bool isRegistered;

  const ByChatContactModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    this.username = '',
    this.photoUrl,
    required this.isRegistered,
  });
}
