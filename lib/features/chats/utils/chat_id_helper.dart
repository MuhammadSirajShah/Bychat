
String createChatId(String firstUid, String secondUid) {
  if (firstUid.trim().isEmpty || secondUid.trim().isEmpty) {
    throw ArgumentError('Both user IDs are required.');
  }

  if (firstUid == secondUid) {
    throw ArgumentError('A user cannot start a chat with themselves.');
  }

  final sortedUids = [firstUid, secondUid]..sort();

  return '${sortedUids[0]}_${sortedUids[1]}';
}
