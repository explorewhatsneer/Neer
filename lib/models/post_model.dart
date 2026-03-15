class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String type;          // 'checkin', 'review', 'event'
  final String content;       // Açıklama
  final String? reviewComment; // Yorum (varsa)
  final double? rating;       // Puan (varsa)
  final String locationName;  
  final String locationId;    
  final String? imageUrl;      // Post görseli (nullable yaptım, boş string yerine null daha güvenli)
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final List<String> likes;   // Supabase'de text[] array sütunu veya join ile gelir

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.type,
    required this.content,
    this.reviewComment,
    this.rating,
    required this.locationName,
    required this.locationId,
    this.imageUrl, 
    this.likeCount = 0,
    this.commentCount = 0,
    required this.createdAt,
    this.likes = const [],
  });

  // Supabase'e veri gönderirken (snake_case)
  Map<String, dynamic> toMap() {
    return {
      // 'id': id, // Genelde ID'yi Supabase otomatik oluşturur, update hariç göndermeyiz
      'user_id': userId,
      'user_name': userName,   // Eğer denormalize tutuyorsan
      'user_image': userImage, // Eğer denormalize tutuyorsan
      'type': type,
      'content': content,
      'review_comment': reviewComment,
      'rating': rating,
      'location_name': locationName,
      'location_id': locationId,
      'image_url': imageUrl,
      'like_count': likeCount,
      'comment_count': commentCount,
      'created_at': createdAt.toIso8601String(), // DateTime -> String
      'likes': likes, // Postgres array
    };
  }

  // Supabase'den veri çekerken
  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: (map['id'] ?? '').toString(),
      userId: map['user_id'] ?? '',
      userName: map['user_name'] ?? map['sender_name'] ?? 'Kullanıcı', // sender_name join'den gelebilir
      userImage: map['user_image'] ?? map['sender_image'] ?? '',
      type: map['type'] ?? 'checkin',
      content: map['content'] ?? '',
      reviewComment: map['review_comment'],
      // Sayısal değerlerin dönüşüm güvenliği
      rating: (map['rating'] != null) ? (map['rating'] as num).toDouble() : null,
      locationName: map['location_name'] ?? '',
      locationId: map['location_id'] ?? '',
      imageUrl: map['image_url'] ?? '',
      likeCount: map['like_count'] ?? 0,
      commentCount: map['comment_count'] ?? 0,
      
      // 🔥 GÜNCELLEME: Timestamp yerine DateTime.parse
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString()) 
          : DateTime.now(),
          
      // Postgres array'i List<String>'e çevirme
      likes: List<String>.from(map['likes'] ?? []),
    );
  }
}