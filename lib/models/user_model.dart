class UserModel {
  final String uid;
  final String email;
  final String name;
  final String username;
  final String bio;
  final String profileImage;
  final bool isAnonymous;
  final bool isOnline;
  final DateTime? createdAt;
  final String searchKey;

  // 🔥 YENİ EKLENEN ALANLAR (SQL ile uyumlu)
  final bool isPrivate;       // Gizli hesap mı?
  final int checkInCount;
  final int photoCount;
  final double trustScore;
  final double neerScore;     // neer_score (sync trigger ile güncelleniyor)
  final int followersCount;   // Takipçi Sayısı (SQL: followers_count)
  final int followingCount;   // Takip Edilen Sayısı (SQL: following_count)
  final double? latitude;
  final double? longitude;
  final DateTime? lastLocationUpdate;

  // Catch feature
  final String catchStatus;       // 'available', 'busy', 'pending'
  final DateTime? availableUntil;
  final String? pendingCatchId;
  final String? phoneNumber;

  // Neer Score v2
  final String neerScoreLabel;
  final int totalUniquePlaces;
  final int totalCities;
  final int activeDays;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.username,
    required this.bio,
    required this.profileImage,
    required this.isAnonymous,
    required this.isOnline,
    this.createdAt,
    this.searchKey = "",
    // Varsayılan değerler
    this.isPrivate = false,
    this.checkInCount = 0,
    this.photoCount = 0,
    this.trustScore = 5.0,
    this.neerScore = 5.0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.latitude,
    this.longitude,
    this.lastLocationUpdate,
    this.catchStatus = 'busy',
    this.availableUntil,
    this.pendingCatchId,
    this.phoneNumber,
    this.neerScoreLabel = 'Standart',
    this.totalUniquePlaces = 0,
    this.totalCities = 0,
    this.activeDays = 0,
  });

  // Veritabanına yazarken (Supabase snake_case kullanır)
  Map<String, dynamic> toMap() {
    return {
      'id': uid, 
      'email': email,
      'full_name': name,
      'username': username,
      'bio': bio,
      'avatar_url': profileImage,
      'is_anonymous': isAnonymous,
      'is_online': isOnline,
      'is_private': isPrivate, // 🔥 Veritabanına yazılıyor
      'created_at': createdAt?.toIso8601String(),
      'search_key': name.toLowerCase(),
      // İstatistikler
      'check_in_count': checkInCount,
      'photo_count': photoCount,
      'trust_score': trustScore,
      'latitude': latitude,
      'longitude': longitude,
      'last_location_update': lastLocationUpdate?.toIso8601String(),
      'status': catchStatus,
      'available_until': availableUntil?.toIso8601String(),
      'pending_catch_id': pendingCatchId,
      'phone_number': phoneNumber,
    };
  }

  // Veritabanından okurken (Factory Constructor)
  factory UserModel.fromMap(Map<String, dynamic> map) { // 👈 'map' ismi burada tanımlanıyor
    return UserModel(
      uid: (map['id'] ?? map['uid'] ?? '').toString(),
      email: map['email'] ?? '',
      name: map['full_name'] ?? map['name'] ?? '',
      username: map['username'] ?? '',
      bio: map['bio'] ?? '',
      profileImage: map['avatar_url'] ?? map['profile_image'] ?? '',
      
      // Booleanlar
      isAnonymous: map['is_anonymous'] ?? false,
      isOnline: map['is_online'] ?? false,
      isPrivate: map['is_private'] ?? false, // 🔥 Yeni

      // Tarih
      createdAt: map['created_at'] != null 
          ? DateTime.tryParse(map['created_at'].toString()) 
          : (map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) : null),
          
      searchKey: map['search_key'] ?? '',
      
      // 🔥 İstatistikler (Yeni SQL isimleri)
      checkInCount: map['check_in_count'] ?? 0,
      photoCount: map['photo_count'] ?? 0,
      trustScore: (map['trust_score'] ?? 5.0).toDouble(),
      neerScore: (map['neer_score'] ?? map['trust_score'] ?? 5.0).toDouble(),

      // 🔥 'map' hatası burada çözüldü:
      followersCount: map['followers_count'] ?? 0,
      followingCount: map['following_count'] ?? 0,

      // Neer Score v2
      neerScoreLabel: map['neer_score_label'] ?? 'Standart',
      totalUniquePlaces: map['total_unique_places'] ?? 0,
      totalCities: map['total_cities'] ?? 0,
      activeDays: map['active_days'] ?? 0,
      // 🔥 KONUM VERİLERİNİ ÇEKİYORUZ
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      lastLocationUpdate: map['last_location_update'] != null
          ? DateTime.tryParse(map['last_location_update'].toString())
          : null,
      catchStatus: map['status'] ?? 'busy',
      availableUntil: map['available_until'] != null
          ? DateTime.tryParse(map['available_until'].toString())
          : null,
      pendingCatchId: map['pending_catch_id']?.toString(),
      phoneNumber: map['phone_number']?.toString(),
    );
  }

  // CopyWith (Durum güncellemek için)
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? username,
    String? bio,
    String? profileImage,
    bool? isAnonymous,
    bool? isOnline,
    bool? isPrivate,
    DateTime? createdAt,
    String? searchKey,
    int? checkInCount,
    int? photoCount,
    double? trustScore,
    double? neerScore,
    int? followersCount,
    int? followingCount,
    String? catchStatus,
    DateTime? availableUntil,
    String? pendingCatchId,
    String? phoneNumber,
    String? neerScoreLabel,
    int? totalUniquePlaces,
    int? totalCities,
    int? activeDays,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isOnline: isOnline ?? this.isOnline,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      searchKey: searchKey ?? this.searchKey,
      checkInCount: checkInCount ?? this.checkInCount,
      photoCount: photoCount ?? this.photoCount,
      trustScore: trustScore ?? this.trustScore,
      neerScore: neerScore ?? this.neerScore,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      catchStatus: catchStatus ?? this.catchStatus,
      availableUntil: availableUntil ?? this.availableUntil,
      pendingCatchId: pendingCatchId ?? this.pendingCatchId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      neerScoreLabel: neerScoreLabel ?? this.neerScoreLabel,
      totalUniquePlaces: totalUniquePlaces ?? this.totalUniquePlaces,
      totalCities: totalCities ?? this.totalCities,
      activeDays: activeDays ?? this.activeDays,
    );
  }
}