class CatchRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String status; // 'pending', 'accepted', 'rejected', 'expired'
  final DateTime createdAt;
  final DateTime expiresAt;

  // Sender bilgileri (join ile gelir)
  final String? senderName;
  final String? senderAvatar;

  CatchRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.senderName,
    this.senderAvatar,
  });

  factory CatchRequest.fromMap(Map<String, dynamic> map) {
    // sender profil bilgisi join ile gelebilir
    final senderProfile = map['profiles'] as Map<String, dynamic>?;

    return CatchRequest(
      id: map['id'],
      senderId: map['sender_id'],
      receiverId: map['receiver_id'],
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['created_at']),
      expiresAt: DateTime.parse(map['expires_at']),
      senderName: senderProfile?['full_name'],
      senderAvatar: senderProfile?['avatar_url'],
    );
  }

  bool get isPending => status == 'pending';
  bool get isExpired => expiresAt.isBefore(DateTime.now());
}
