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

  // Profil güncelleme
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _supabase.from('profiles').update(data).eq('id', uid);
    } catch (e) {
      print("Profil güncelleme hatası: $e");
    }
  }

  // Profil stream (realtime)
  Stream<Map<String, dynamic>?> streamProfile(String uid) {
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', uid)
        .map((data) => data.isNotEmpty ? data.first : null);
  }

  // Birden fazla profil çek (inFilter)
  Future<List<Map<String, dynamic>>> getUsersByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      final response = await _supabase.from('profiles').select().inFilter('id', ids);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
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

  // ════════════════════════════════════════════
  // 18. MESAJ İŞLEMLERİ
  // ════════════════════════════════════════════
  Future<void> sendMessage(Map<String, dynamic> message) async {
    try {
      await _supabase.from('messages').insert(message);
    } catch (e) {
      print("Mesaj gönderme hatası: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> streamDMMessages(String roomId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: false);
  }

  Stream<List<Map<String, dynamic>>> streamGroupMessages(String groupId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .order('created_at', ascending: false);
  }

  Stream<List<Map<String, dynamic>>> streamRecentMessages() {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(50);
  }

  // ════════════════════════════════════════════
  // 19. FEED (RPC)
  // ════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> getFeedPosts({
    required String userId,
    required String filterMode,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase.rpc('get_feed_posts', params: {
        'p_user_id': userId,
        'p_filter': filterMode,
        'p_limit': limit,
        'p_offset': offset,
      });
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // ════════════════════════════════════════════
  // 20. HARİTA İŞLEMLERİ
  // ════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> getNearbyPlaces({
    required double lat,
    required double lng,
    double radiusKm = 5.0,
  }) async {
    try {
      final response = await _supabase.rpc('get_nearby_places', params: {
        'p_lat': lat,
        'p_lng': lng,
        'p_radius_km': radiusKm,
      });
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMutualFriendsLocations(String userId) async {
    try {
      final response = await _supabase.rpc('get_mutual_friends_locations', params: {
        'my_id': userId,
      });
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // ════════════════════════════════════════════
  // 21. TAKİP İŞLEMLERİ
  // ════════════════════════════════════════════
  Future<bool> isFollowing(String followerId, String followingId) async {
    try {
      final response = await _supabase
          .from('followers')
          .select('id')
          .eq('follower_id', followerId)
          .eq('following_id', followingId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> follow(String followerId, String followingId) async {
    await _supabase.from('followers').insert({
      'follower_id': followerId,
      'following_id': followingId,
    });
  }

  Future<void> unfollow(String followerId, String followingId) async {
    await _supabase
        .from('followers')
        .delete()
        .match({'follower_id': followerId, 'following_id': followingId});
  }

  // Takip istekleri
  Stream<List<Map<String, dynamic>>> streamFollowRequests(String userId) {
    return _supabase
        .from('friend_requests')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', userId)
        .order('created_at', ascending: false);
  }

  Future<void> sendFollowRequest(String senderId, String receiverId) async {
    await _supabase.from('friend_requests').insert({
      'sender_id': senderId,
      'receiver_id': receiverId,
    });
  }

  Future<void> acceptFollowRequest(String requestId, String followerId, String followingId) async {
    await _supabase.from('followers').insert({
      'follower_id': followerId,
      'following_id': followingId,
    });
    await _supabase.from('friend_requests').delete().eq('id', requestId);
  }

  Future<void> declineFollowRequest(String requestId) async {
    await _supabase.from('friend_requests').delete().eq('id', requestId);
  }

  // ════════════════════════════════════════════
  // 22. ARAMA
  // ════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> searchUsers(String query, {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .ilike('search_key', '%$query%')
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchPlaces(String query, {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('places')
          .select()
          .ilike('name', '%$query%')
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Bildirim silme
  Future<void> deleteNotification(dynamic notificationId) async {
    await _supabase.from('notifications').delete().eq('id', notificationId);
  }

  // Bildirim stream (harita ekranı için)
  Stream<List<Map<String, dynamic>>> streamNotifications(String userId) {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  // ════════════════════════════════════════════
  // 23. YARDIMCI METODLAR
  // ════════════════════════════════════════════

  /// Supabase client erişimi (auth işlemleri için)
  SupabaseClient get client => _supabase;

  /// Tek profil alanı çek
  Future<Map<String, dynamic>?> getProfileSingle(String uid) async {
    try {
      final response = await _supabase.from('profiles').select().eq('id', uid).single();
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Belirli alanları çek
  Future<Map<String, dynamic>?> getProfileFields(String uid, String fields) async {
    try {
      final response = await _supabase.from('profiles').select(fields).eq('id', uid).single();
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Profil stream (liste döndürür)
  Stream<List<Map<String, dynamic>>> streamProfileAsList(String uid) {
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', uid);
  }

  /// Profil sil
  Future<void> deleteProfile(String uid) async {
    await _supabase.from('profiles').delete().eq('id', uid);
  }

  /// Mekan sohbet mesaj stream
  Stream<List<Map<String, dynamic>>> streamPlaceMessages(String groupId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .order('created_at', ascending: false);
  }

  /// Takip isteği kontrol (gelen)
  Future<Map<String, dynamic>?> getIncomingFollowRequest(String senderId, String receiverId) async {
    try {
      return await _supabase
          .from('friend_requests')
          .select()
          .eq('sender_id', senderId)
          .eq('receiver_id', receiverId)
          .maybeSingle();
    } catch (e) {
      return null;
    }
  }

  /// Gönderilen takip isteği kontrol
  Future<Map<String, dynamic>?> getSentFollowRequest(String senderId, String receiverId) async {
    try {
      return await _supabase
          .from('friend_requests')
          .select()
          .eq('sender_id', senderId)
          .eq('receiver_id', receiverId)
          .maybeSingle();
    } catch (e) {
      return null;
    }
  }

  /// Takip isteği sil (match ile)
  Future<void> deleteFollowRequestByMatch(String senderId, String receiverId) async {
    await _supabase.from('friend_requests').delete().match({
      'sender_id': senderId,
      'receiver_id': receiverId,
    });
  }

  /// Kullanıcı konumu güncelle
  Future<void> updateLocation(String uid, double lat, double lng) async {
    try {
      await _supabase.from('profiles').update({
        'latitude': lat,
        'longitude': lng,
        'last_location_update': DateTime.now().toIso8601String(),
      }).eq('id', uid);
    } catch (e) {
      print("Konum güncelleme hatası: $e");
    }
  }

  /// Posts sorgusu (kullanıcıya ait, belirli alanlar ve filtre)
  Future<List<Map<String, dynamic>>> getUserPosts({
    required String userId,
    String? type,
    String? selectFields,
    int limit = 50,
  }) async {
    try {
      var query = _supabase.from('posts').select(selectFields ?? '*').eq('user_id', userId);
      if (type != null) query = query.eq('type', type);
      final response = await query.order('created_at', ascending: false).limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Posts sorgusu (null olmayan alan filtresi ile)
  Future<List<Map<String, dynamic>>> getUserPostsNotNull({
    required String userId,
    required String notNullField,
    String? selectFields,
    int limit = 50,
  }) async {
    try {
      final response = await _supabase
          .from('posts')
          .select(selectFields ?? '*')
          .eq('user_id', userId)
          .not(notNullField, 'is', null)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // ════════════════════════════════════════════
  // 28. ÖNEK ARAMA (Glass Suggestions için)
  // ════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> searchPlacesPrefix(String query, {int limit = 5}) async {
    try {
      final response = await _supabase
          .from('places')
          .select()
          .ilike('name', '$query%')
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchUsersPrefix(String query, {int limit = 5}) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .ilike('full_name', '$query%')
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}