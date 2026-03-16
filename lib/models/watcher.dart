class Watcher {
  final String id;
  final String watcherId;
  final String targetId;
  final bool isActive;
  final DateTime createdAt;

  Watcher({
    required this.id,
    required this.watcherId,
    required this.targetId,
    required this.isActive,
    required this.createdAt,
  });

  factory Watcher.fromMap(Map<String, dynamic> map) {
    return Watcher(
      id: map['id'],
      watcherId: map['watcher_id'],
      targetId: map['target_id'],
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
