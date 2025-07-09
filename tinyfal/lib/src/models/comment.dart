class Comment {
  final String id;
  final String userId;
  final String postId;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.text,
    required this.timestamp,
  });
}
