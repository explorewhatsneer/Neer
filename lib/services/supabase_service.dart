import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ════════════════════════════════════════════
  // 1. KULLANICI BİLGİSİ
  // ════════════════════════════════════════════
  Future<UserModel?> getUser(String uid) async {
    try {
      final response = await _supabase.from('profiles').select().eq('id', uid).maybeSingle();
      if (response == null) return null;
      return UserModel.fromMap(response);
    } catch (e) {
      print("Hata (getUser): $e");
      return null;
    }
  }

  // ════════════════════════════════════════════
  // 2. AKTİVİTE AKIŞI (Kullanıcının Gönderileri)
  // ════════════════════════════════════════════
  Stream<List<PostModel>> getUserActivityFeed(String uid) {
    return _supabase
        .from('posts')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => PostModel.fromMap(json)).toList());
  }

  // ════════════════════════════════════════════
  // 3. FAVORİ MEKANLAR
  // ════════════════════════════════════════════
  Stream<List<Map<String, dynamic>>> getUserFavorites(String uid) {
    return _supabase
        .from('favorites')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  // ════════════════════════════════════════════
  // 4. NOTLAR
  // ════════════════════════════════════════════
  Stream<List<Map<String, dynamic>>> getUserNotes(String uid) {
    return _supabase
        .from('notes')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  // ════════════════════════════════════════════
  // 5. GALERİ / FOTOĞRAFLAR
  // ════════════════════════════════════════════
  Stream<List<String>> getUserPhotos(String uid) {
    return _supabase
        .from('posts')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .map((data) {
          return data
              .where((e) => e['type'] == 'post' && e['image_url'] != null)
              .map((e) => e['image_url'] as String)
              .toList();
        });
  }

  // ════════════════════════════════════════════
  // 6. GÖREVLER
  // ════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> getUserQuests(String uid) async {
    try {
      final response = await _supabase.from('quests').select().eq('user_id', uid);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // ════════════════════════════════════════════
  // 7. SIK UĞRANANLAR (RPC)
  // ════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> getFrequentPlaces(String uid) async {
    try {
      final response = await _supabase.rpc('get_top_places', params: {'target_uid': uid});
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Sık Uğrananlar Hatası: $e");
      return [];
    }
  }

  // ════════════════════════════════════════════
  // 8. DEĞERLENDİRME GEÇMİŞİ
  // ════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> getSurveyHistory(String uid) async {
    try {
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

  // ════════════════════════════════════════════
  // 9. 🔥 CHECK-IN (YENİ — Sunucu tarafı geofence)
  // Eski: client'ta mesafe hesaplayıp visits'e insert
  // Yeni: Sunucuda mesafe + session + live_count güncelle
  // ════════════════════════════════════════════
  Future<Map<String, dynamic>> checkIn({
    required String userId,
    required int placeId,
    required double userLat,
    required double userLng,
  }) async {
    try {
      final result = await _supabase.rpc('check_in_to_place', params: {
        'p_user_id': userId,
        'p_place_id': placeId,
        'p_user_lat': userLat,
        'p_user_lng': userLng,
      });
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print("Check-in Hatası: $e");
      return {'success': false, 'error': e.toString()};
    }
  }

  // ════════════════════════════════════════════
  // 10. 🔥 CHECK-OUT (YENİ — Sunucu tarafı)
  // ════════════════════════════════════════════
  Future<Map<String, dynamic>> checkOut(String userId) async {
    try {
      final result = await _supabase.rpc('check_out_from_place', params: {
        'p_user_id': userId,
      });
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print("Check-out Hatası: $e");
      return {'success': false, 'error': e.toString()};
    }
  }

  // ════════════════════════════════════════════
  // 11. 🔥 ANKET GÖNDERME (YENİ — Sunucu tarafı doğrulama)
  // Proof of Presence + Dwell Time kontrolü sunucuda yapılır
  // ════════════════════════════════════════════
  Future<Map<String, dynamic>> submitReview({
    required String userId,
    required int placeId,
    required double rating,
    double ratingTaste = 0,
    double ratingService = 0,
    double ratingAmbiance = 0,
    double ratingPrice = 0,
    String? comment,
  }) async {
    try {
      final result = await _supabase.rpc('submit_review', params: {
        'p_user_id': userId,
        'p_place_id': placeId,
        'p_rating': rating,
        'p_rating_taste': ratingTaste,
        'p_rating_service': ratingService,
        'p_rating_ambiance': ratingAmbiance,
        'p_rating_price': ratingPrice,
        'p_comment': comment,
      });
      return Map<String, dynamic>.from(result);
    } catch (e) {
      print("Review Hatası: $e");
      return {'success': false, 'error': e.toString()};
    }
  }

  // ════════════════════════════════════════════
  // 12. 🔥 MESAJ GÖNDERMEDEN ÖNCE KONTROL (Rate Limiting)
  // Rapordaki cooldown kuralları sunucuda hesaplanır
  // ════════════════════════════════════════════
  Future<Map<String, dynamic>> canSendMessage(String userId, String groupId) async {
    try {
      final result = await _supabase.rpc('can_send_message', params: {
        'p_user_id': userId,
        'p_group_id': groupId,
      });
      return Map<String, dynamic>.from(result);
    } catch (e) {
      return {'allowed': true, 'cooldown': 3}; // Hata durumunda izin ver
    }
  }

  // ════════════════════════════════════════════
  // 13. 🔥 ENGELLEME (YENİ — Sunucu tarafı)
  // İki yönlü görünmezlik + arkadaşlık silme
  // ════════════════════════════════════════════
  Future<bool> blockUser(String blockerId, String blockedId) async {
    try {
      await _supabase.rpc('block_user', params: {
        'p_blocker': blockerId,
        'p_blocked': blockedId,
      });
      return true;
    } catch (e) {
      print("Engelleme Hatası: $e");
      return false;
    }
  }

  Future<bool> unblockUser(String blockerId, String blockedId) async {
    try {
      await _supabase.rpc('unblock_user', params: {
        'p_blocker': blockerId,
        'p_blocked': blockedId,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Engellenen kullanıcı listesi
  Future<List<Map<String, dynamic>>> getBlockedUsers(String userId) async {
    try {
      final response = await _supabase
          .from('blocked_users')
          .select('blocked_id, created_at, profiles!blocked_users_blocked_id_fkey(full_name, username, avatar_url)')
          .eq('blocker_id', userId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // ════════════════════════════════════════════
  // 14. 🔥 BİLDİRİMLER (YENİ)
  // ════════════════════════════════════════════
  Stream<List<Map<String, dynamic>>> getNotifications(String userId) {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);
      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> markNotificationRead(int notificationId) async {
    await _supabase.from('notifications').update({'is_read': true}).eq('id', notificationId);
  }

  Future<void> markAllNotificationsRead(String userId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  // ════════════════════════════════════════════
  // 15. 🔥 TRUST SCORE (YENİ — Sunucu tarafı)
  // ════════════════════════════════════════════
  Future<double> updateTrustScore(String userId, int amount, String reason) async {
    try {
      final result = await _supabase.rpc('update_trust_score_v2', params: {
        'p_user_id': userId,
        'p_amount': amount,
        'p_reason': reason,
      });
      return (result as num).toDouble();
    } catch (e) {
      print("Trust Score Hatası: $e");
      return 70.0;
    }
  }

  // ════════════════════════════════════════════
  // 16. AKTİF OTURUMLAR (Kim nerede?)
  // ════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> getActiveUsersAtPlace(int placeId) async {
    try {
      final response = await _supabase
          .from('active_sessions')
          .select('user_id, entered_at, profiles(full_name, username, avatar_url)')
          .eq('place_id', placeId)
          .eq('is_active', true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Kullanıcının aktif oturumu var mı?
  Future<Map<String, dynamic>?> getActiveSession(String userId) async {
    try {
      final response = await _supabase
          .from('active_sessions')
          .select('*, places(name, image)')
          .eq('user_id', userId)
          .eq('is_active', true)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  // ════════════════════════════════════════════
  // 17. SON ZİYARETLER (RPC)
  // ════════════════════════════════════════════
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