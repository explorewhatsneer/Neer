class PlaceModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String category;
  final String? image;
  final double averageRating;
  final double? distanceMeters; // RPC'den gelen mesafe verisi
  final String? crowdStatus;    // 'High', 'Medium', 'Low' (Sonradan eklenecek)

  PlaceModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.image,
    this.averageRating = 0.0,
    this.distanceMeters,
    this.crowdStatus,
  });

  factory PlaceModel.fromMap(Map<String, dynamic> map) {
    return PlaceModel(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      name: map['name'] ?? 'İsimsiz Mekan',
      // Supabase bazen sayıları int, bazen double gönderebilir; güvenli dönüşüm:
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      category: map['category'] ?? 'Genel',
      image: map['image'],
      averageRating: map['average_rating'] != null 
          ? (map['average_rating'] as num).toDouble() 
          : 0.0,
      distanceMeters: map['dist_meters'] != null 
          ? (map['dist_meters'] as num).toDouble() 
          : null,
      crowdStatus: map['density_status'], // View'dan gelen veri
    );
  }
}