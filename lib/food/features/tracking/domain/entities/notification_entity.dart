class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  @override
  String toString() {
    return 'NotificationEntity(id: $id, title: $title, body: $body, createdAt: $createdAt, isRead: $isRead)';
  }
}
