import 'package:supabase_flutter/supabase_flutter.dart';

class AvailabilityService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Müsait ol (süre dakika cinsinden: 30, 60, 120, 240)
  Future<bool> setAvailable(int durationMinutes) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final until = DateTime.now().toUtc().add(Duration(minutes: durationMinutes));

    try {
      await _supabase.from('profiles').update({
        'status': 'available',
        'available_until': until.toIso8601String(),
        'pending_catch_id': null,
      }).eq('id', userId);
      return true;
    } catch (e) {
      print('Müsaitlik güncelleme hatası: $e');
      return false;
    }
  }

  /// Meşgul ol
  Future<bool> setBusy() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      await _supabase.from('profiles').update({
        'status': 'busy',
        'available_until': null,
        'pending_catch_id': null,
      }).eq('id', userId);
      return true;
    } catch (e) {
      print('Meşgul güncelleme hatası: $e');
      return false;
    }
  }

  /// Kendi durumunu realtime dinle
  Stream<Map<String, dynamic>?> streamMyStatus() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return const Stream.empty();

    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) => data.isNotEmpty ? data.first : null);
  }

  /// Arkadaşların durumlarını çek (mutual follows)
  Future<List<Map<String, dynamic>>> getFriendsWithStatus(String userId) async {
    try {
      // Karşılıklı takip = arkadaş
      // Ben takip ediyorum VE onlar beni takip ediyor
      final myFollowing = await _supabase
          .from('followers')
          .select('following_id')
          .eq('follower_id', userId);

      final myFollowingIds = (myFollowing as List)
          .map((e) => e['following_id'] as String)
          .toList();

      if (myFollowingIds.isEmpty) return [];

      final myFollowers = await _supabase
          .from('followers')
          .select('follower_id')
          .eq('following_id', userId)
          .inFilter('follower_id', myFollowingIds);

      final mutualIds = (myFollowers as List)
          .map((e) => e['follower_id'] as String)
          .toList();

      if (mutualIds.isEmpty) return [];

      // Arkadaşların profil bilgilerini çek
      final profiles = await _supabase
          .from('profiles')
          .select('id, full_name, username, avatar_url, status, available_until, phone_number, is_online')
          .inFilter('id', mutualIds);

      return List<Map<String, dynamic>>.from(profiles);
    } catch (e) {
      print('Arkadaş listesi hatası: $e');
      return [];
    }
  }

  /// Arkadaş profillerini realtime stream (status değişimlerini yakala)
  Stream<List<Map<String, dynamic>>> streamFriendsStatus(List<String> friendIds) {
    if (friendIds.isEmpty) return const Stream.empty();

    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .inFilter('id', friendIds)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }
}
