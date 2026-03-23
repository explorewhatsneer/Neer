import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_exception.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ════════════════════════════════════════════
  // 1. KULLANICI BİLGİSİ
  // ════════════════════════════════════════════
  Future<Result<UserModel>> getUser(String uid) async {
    try {
      final response = await _supabase.from('profiles').select().eq('id', uid).maybeSingle();
      if (response == null) {
        return Result.failure(const AppException('Kullanıcı bulunamadı.', code: 'NOT_FOUND'));
      }
      return Result.success(UserModel.fromMap(response));
    } catch (e) {
      debugPrint("Hata (getUser): $e");
      return Result.failure(AppException.fromSupabase(e));
    }
  }

  Future<Result<void>> updateProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _supabase.from('profiles').update(data).eq('id', uid);
      return const Result.success(null);
    } catch (e) {
      debugPrint("Profil güncelleme hatası: $e");
      return Result.failure(AppException.fromSupabase(e));
    }
  }

  Stream<Map<String, dynamic>?> streamProfile(String uid) {
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', uid)
        .map((data) => data.isNotEmpty ? data.first : null);
  }

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
  // 2. AKTİVİTE AKIŞI
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

  /// @deprecated Use getUserPhotosList instead — this method filters client-side
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

  Future<List<String>> getUserPhotosList(String uid) async {
    try {
      final response = await _supabase
          .from('posts')
          .select('image_url')
          .eq('user_id', uid)
          .eq('type', 'post')
          .not('image_url', 'is', null)
          .order('created_at', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(response)
          .map((e) => e['image_url'] as String)
          .where((url) => url.isNotEmpty)
          .toList();
    } catch (e) {
      return [];
    }
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
      debugPrint("Sık Uğrananlar Hatası: $e");
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
  // 9. CHECK-IN (Sunucu tarafı geofence)
  // ════════════════════════════════════════════
  Future<Result<Map<String, dynamic>>> checkIn({
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
      return Result.success(Map<String, dynamic>.from(result));
    } catch (e) {
      debugPrint("Check-in Hatası: $e");
      return Result.failure(AppException.fromSupabase(e));
    }
  }

  // ════════════════════════════════════════════
  // 10. CHECK-OUT (Sunucu tarafı)
  // ════════════════════════════════════════════
  Future<Result<Map<String, dynamic>>> checkOut(String userId) async {
    try {
      final result = await _supabase.rpc('check_out_from_place', params: {
        'p_user_id': userId,
      });
      return Result.success(Map<String, dynamic>.from(result));
    } catch (e) {
      debugPrint("Check-out Hatası: $e");
      return Result.failure(AppException.fromSupabase(e));
    }
  }

  // ════════════════════════════════════════════
  // 11. ANKET GÖNDERME (Sunucu tarafı doğrulama)
  // ════════════════════════════════════════════
  Future<Result<Map<String, dynamic>>> submitReview({
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
      return Result.success(Map<String, dynamic>.from(result));
    } catch (e) {
      debugPrint("Review Hatası: $e");
      return Result.failure(AppException.fromSupabase(e));
    }
  }

  // ════════════════════════════════════════════
  // 12. MESAJ GÖNDERMEDEN ÖNCE KONTROL (Rate Limiting)
  // ════════════════════════════════════════════
  Future<Map<String, dynamic>> canSendMessage(String userId, String groupId) async {
    try {
      final result = await _supabase.rpc('can_send_message', params: {
        'p_user_id': userId,
        'p_group_id': groupId,
      });
      return Map<String, dynamic>.from(result);
    } catch (e) {
      return {'allowed': true, 'cooldown': 3};
    }
  }

  // ════════════════════════════════════════════
  // 13. ENGELLEME (Sunucu tarafı)
  // ════════════════════════════════════════════
  Future<Result<bool>> blockUser(String blockerId, String blockedId) async {
    try {
      await _supabase.rpc('block_user', params: {
        'p_blocker': blockerId,
        'p_blocked': blockedId,
      });
      return const Result.success(true);
    } catch (e) {
      debugPrint("Engelleme Hatası: $e");
      return Result.failure(AppException.fromSupabase(e));
    }
  }

  Future<Result<bool>> unblockUser(String blockerId, String blockedId) async {
    try {
      await _supabase.rpc('unblock_user', params: {
        'p_blocker': blockerId,
        'p_blocked': blockedId,
      });
      return const Result.success(true);
    } catch (e) {
      return Result.failure(AppException.fromSupabase(e));
    }
  }

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
  // 14. BİLDİRİMLER
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
      final result = await _supabase.rpc('get_unread_notification_count', params: {'p_user_id': userId});
      return (result as int?) ?? 0;
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
  // 15. TRUST SCORE (Sunucu tarafı)
  // ════════════════════════════════════════════
  Future<Result<double>> updateTrustScore(String userId, int amount, String reason) async {
    try {
      final result = await _supabase.rpc('update_trust_score_v2', params: {
        'p_user_id': userId,
        'p_amount': amount,
        'p_reason': reason,
      });
      return Result.success((result as num).toDouble());
    } catch (e) {
      debugPrint("Trust Score Hatası: $e");
      return Result.failure(AppException.fromSupabase(e));
    }
  }

  // ════════════════════════════════════════════
  // 16. AKTİF OTURUMLAR
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
      debugPrint("Ziyaretler çekilirken hata: $e");
      return [];
    }
  }

  // ════════════════════════════════════════════
  // 18. MESAJ İŞLEMLERİ
  // ════════════════════════════════════════════
  Future<Result<void>> sendMessage(Map<String, dynamic> message) async {
    try {
      await _supabase.from('messages').insert(message);
      return const Result.success(null);
    } catch (e) {
      debugPrint("Mesaj gönderme hatası: $e");
      return Result.failure(AppException.fromSupabase(e));
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
        'lat': lat,
        'long': lng,
        'radius_meters': radiusKm * 1000, // km → metre dönüşümü
      });
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('getNearbyPlaces hatası: $e');
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

  Future<Result<void>> follow(String followerId, String followingId) async {
    try {
      await _supabase.from('followers').insert({
        'follower_id': followerId,
        'following_id': followingId,
      });
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AppException.fromSupabase(e));
    }
  }

  Future<Result<void>> unfollow(String followerId, String followingId) async {
    try {
      await _supabase
          .from('followers')
          .delete()
          .match({'follower_id': followerId, 'following_id': followingId});
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AppException.fromSupabase(e));
    }
  }

  Stream<List<Map<String, dynamic>>> streamFollowRequests(String userId) {
    return _supabase
        .from('friend_requests')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', userId)
        .order('created_at', ascending: false);
  }

  Future<Result<void>> sendFollowRequest(String senderId, String receiverId) async {
    try {
      await _supabase.from('friend_requests').insert({
        'sender_id': senderId,
        'receiver_id': receiverId,
      });
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AppException.fromSupabase(e));
    }
  }

  Future<Result<void>> acceptFollowRequest(String requestId, String followerId, String followingId) async {
    try {
      await _supabase.from('followers').insert({
        'follower_id': followerId,
        'following_id': followingId,
      });
      await _supabase.from('friend_requests').delete().eq('id', requestId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AppException.fromSupabase(e));
    }
  }

  Future<Result<void>> declineFollowRequest(String requestId) async {
    try {
      await _supabase.from('friend_requests').delete().eq('id', requestId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AppException.fromSupabase(e));
    }
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

  Future<void> deleteNotification(dynamic notificationId) async {
    await _supabase.from('notifications').delete().eq('id', notificationId);
  }

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

  SupabaseClient get client => _supabase;

  Future<Map<String, dynamic>?> getProfileSingle(String uid) async {
    try {
      final response = await _supabase.from('profiles').select().eq('id', uid).single();
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfileFields(String uid, String fields) async {
    try {
      final response = await _supabase.from('profiles').select(fields).eq('id', uid).single();
      return response;
    } catch (e) {
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> streamProfileAsList(String uid) {
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', uid);
  }

  Future<void> deleteProfile(String uid) async {
    await _supabase.from('profiles').delete().eq('id', uid);
  }

  Stream<List<Map<String, dynamic>>> streamPlaceMessages(String groupId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .order('created_at', ascending: false);
  }

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

  Future<void> deleteFollowRequestByMatch(String senderId, String receiverId) async {
    await _supabase.from('friend_requests').delete().match({
      'sender_id': senderId,
      'receiver_id': receiverId,
    });
  }

  Future<void> updateLocation(String uid, double lat, double lng) async {
    try {
      await _supabase.from('profiles').update({
        'latitude': lat,
        'longitude': lng,
        'last_location_update': DateTime.now().toIso8601String(),
      }).eq('id', uid);
    } catch (e) {
      debugPrint("Konum güncelleme hatası: $e");
    }
  }

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

  // ════════════════════════════════════════════
  // 29. ROZETLER & GÖREVLER & KİMLİK
  // ════════════════════════════════════════════

  // Kullanıcı rozetleri
  Future<List<Map<String, dynamic>>> getUserBadges(String uid) async {
    try {
      final response = await _supabase
          .from('user_badges')
          .select('*, badge_definitions(*)')
          .eq('user_id', uid)
          .order('earned_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) { return []; }
  }

  // Tüm rozet tanımları
  Future<List<Map<String, dynamic>>> getAllBadgeDefinitions() async {
    try {
      final response = await _supabase
          .from('badge_definitions')
          .select()
          .order('sort_order');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) { return []; }
  }

  // Aktif görevler (kullanıcı ilerlemesiyle birlikte)
  Future<List<Map<String, dynamic>>> getUserActiveQuests(String uid) async {
    try {
      final response = await _supabase
          .from('quest_definitions')
          .select('*, user_quests!left(progress, is_completed, period)')
          .order('sort_order');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) { return []; }
  }

  // Neer Kimliği istatistikleri
  Future<Map<String, dynamic>> getUserIdentityStats(String uid) async {
    try {
      final result = await _supabase.rpc('get_user_identity_stats', params: {'target_uid': uid});
      return Map<String, dynamic>.from(result as Map);
    } catch (e) { return {'total_places': 0, 'total_photos': 0, 'active_days': 0}; }
  }

  // Isı haritası noktaları
  Future<List<Map<String, dynamic>>> getUserHeatmapPoints(String uid, {String period = 'all'}) async {
    try {
      final result = await _supabase.rpc('get_user_heatmap_points', params: {
        'target_uid': uid,
        'period_filter': period,
      });
      return List<Map<String, dynamic>>.from(result);
    } catch (e) { return []; }
  }

  // Quest ilerleme güncelle
  Future<Map<String, dynamic>> updateQuestProgress(String uid, String questId, {int increment = 1}) async {
    try {
      final result = await _supabase.rpc('update_quest_progress', params: {
        'p_user_id': uid,
        'p_quest_id': questId,
        'p_increment': increment,
      });
      return Map<String, dynamic>.from(result as Map);
    } catch (e) { return {}; }
  }

  // ════════════════════════════════════════════
  // 30. MEKAN DETAY METODLARI
  // ════════════════════════════════════════════

  /// Tek bir mekanın detay bilgilerini getirir
  Future<Map<String, dynamic>?> getPlaceById(String placeId) async {
    try {
      final id = int.tryParse(placeId);
      if (id == null) return null;
      final response = await _supabase
          .from('places')
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint("getPlaceById hatası: $e");
      return null;
    }
  }

  /// Bir mekana ait review'ları getirir (en yeni önce)
  Future<List<Map<String, dynamic>>> getPlaceReviews(String placeId, {int limit = 20}) async {
    try {
      final id = int.tryParse(placeId);
      if (id == null) return [];
      final response = await _supabase
          .from('posts')
          .select('*, profiles(full_name, username, avatar_url)')
          .eq('place_id', id)
          .eq('type', 'review')
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("getPlaceReviews hatası: $e");
      return [];
    }
  }

  /// Bir mekanın ortalama detaylı puanlarını hesaplar (server-side RPC)
  Future<Map<String, double>> getPlaceRatingStats(String placeId) async {
    try {
      final id = int.tryParse(placeId);
      if (id == null) return {'taste': 0, 'service': 0, 'ambiance': 0, 'price': 0};
      final result = await _supabase.rpc('get_place_rating_stats', params: {'p_place_id': id});
      final data = Map<String, dynamic>.from(result as Map);
      return {
        'taste': (data['taste'] as num?)?.toDouble() ?? 0,
        'service': (data['service'] as num?)?.toDouble() ?? 0,
        'ambiance': (data['ambiance'] as num?)?.toDouble() ?? 0,
        'price': (data['price'] as num?)?.toDouble() ?? 0,
      };
    } catch (e) {
      debugPrint("getPlaceRatingStats hatası: $e");
      return {'taste': 0, 'service': 0, 'ambiance': 0, 'price': 0};
    }
  }

  /// Bir mekanın en çok ziyaret eden kullanıcılarını getirir (server-side RPC)
  Future<List<Map<String, dynamic>>> getPlaceTopVisitors(String placeId, {int limit = 3}) async {
    try {
      final id = int.tryParse(placeId);
      if (id == null) return [];
      final response = await _supabase.rpc('get_place_top_visitors', params: {
        'p_place_id': id,
        'p_limit': limit,
      });
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("getPlaceTopVisitors hatası: $e");
      return [];
    }
  }

  /// Bir mekanın fotoğraflarını getirir (posts tablosundan)
  Future<List<String>> getPlacePhotos(String placeId, {int limit = 15}) async {
    try {
      final id = int.tryParse(placeId);
      if (id == null) return [];
      final response = await _supabase
          .from('posts')
          .select('image_url')
          .eq('place_id', id)
          .not('image_url', 'is', null)
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response)
          .map((e) => e['image_url'] as String)
          .where((url) => url.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint("getPlacePhotos hatası: $e");
      return [];
    }
  }

  int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(startOfYear).inDays;
    return ((dayOfYear + startOfYear.weekday - 1) / 7).ceil();
  }
}
