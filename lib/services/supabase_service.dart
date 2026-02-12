import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // --- 1. KULLANICI BİLGİSİ ---
  Future<UserModel?> getUser(String uid) async {
    try {
      final response = await _supabase.from('profiles').select().eq('id', uid).maybeSingle();
      if (response == null) return null;
      return UserModel.fromMap(response); // UserModel'inin fromMap yapısına güveniyoruz
    } catch (e) {
      print("Hata (getUser): $e");
      return null;
    }
  }

  // --- 2. AKTİVİTE AKIŞI (Sadece O Kullanıcının Gönderileri) ---
  // 🔥 DÜZELTME: Artık sadece 'uid' parametresine sahip gönderileri getiriyor.
  Stream<List<PostModel>> getUserActivityFeed(String uid) {
    return _supabase
        .from('posts')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid) // <--- İŞTE BU SATIR FEED'İ KİŞİSELLEŞTİRİR
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => PostModel.fromMap(json)).toList());
  }

  // --- 3. FAVORİ MEKANLAR (Sadece O Kullanıcının) ---
  Stream<List<Map<String, dynamic>>> getUserFavorites(String uid) {
    return _supabase
        .from('favorites')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid) // Sadece bu kullanıcının favorileri
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  // --- 4. NOTLAR (Sadece O Kullanıcının) ---
  Stream<List<Map<String, dynamic>>> getUserNotes(String uid) {
    return _supabase
        .from('notes')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid) // Sadece bu kullanıcının notları
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

// --- 5. GALERİ / FOTOĞRAFLAR ---
  Stream<List<String>> getUserPhotos(String uid) {
    return _supabase
        .from('posts')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid) // Kullanıcıyı filtrele
        .order('created_at', ascending: false)
        .map((data) {
          // 'type' == 'post' ve 'image_url' != null olanları Dart tarafında filtreliyoruz
          return data
              .where((e) => e['type'] == 'post' && e['image_url'] != null)
              .map((e) => e['image_url'] as String)
              .toList();
        });
  }

  // --- 6. GÖREVLER (Future olarak) ---
  Future<List<Map<String, dynamic>>> getUserQuests(String uid) async {
    try {
      final response = await _supabase
          .from('quests')
          .select()
          .eq('user_id', uid); // Sadece bu kullanıcının görevleri
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // --- 7. SIK UĞRANANLAR (RPC Fonksiyonu) ---
  Future<List<Map<String, dynamic>>> getFrequentPlaces(String uid) async {
    try {
      // SQL tarafında yazdığımız 'get_top_places' fonksiyonunu çağırıyoruz
      final response = await _supabase.rpc('get_top_places', params: {'target_uid': uid});
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Sık Uğrananlar Hatası: $e");
      return [];
    }
  }

  // --- 8. DEĞERLENDİRME GEÇMİŞİ ---
  Future<List<Map<String, dynamic>>> getSurveyHistory(String uid) async {
    try {
      // 'review' tipindeki postları çekiyoruz
      final response = await _supabase
          .from('posts')
          .select()
          .eq('user_id', uid)
          .eq('type', 'review')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
// --- CHECK-IN GÖNDERME ---
  Future<String> sendCheckIn(String userId, String placeId, String placeName) async {
    try {
      // 1. Posts tablosuna check-in verisi ekle
      final response = await _supabase.from('posts').insert({
        'user_id': userId,
        'location_name': placeName,
        'type': 'check_in', // Tipi check-in olarak belirledik
        'content': '$placeName konumunda check-in yapıldı.',
        'created_at': DateTime.now().toIso8601String(),
        // place_id veya business_id varsa ekleyebilirsin
      }).select().single();

      // 2. Profildeki check-in sayısını artır (Opsiyonel ama iyi olur)
      await _supabase.rpc('increment_check_in_count', params: {'user_id': userId});

      return response['id'].toString(); // Oluşan postun ID'sini döndür
    } catch (e) {
      print("Check-in Hatası: $e");
      return ""; // Hata durumunda boş string
    }
  }
  // Kullanıcının son ziyaretlerini getir
  Future<List<Map<String, dynamic>>> getRecentVisits(String uid) async {
    try {
      final response = await _supabase.rpc('get_user_recent_visits', params: {'target_uid': uid});
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Ziyaretler çekilirken hata: $e");
      return [];
    }
  }
}
