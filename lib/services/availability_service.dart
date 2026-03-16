import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_exception.dart';

class AvailabilityService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Müsait ol (süre dakika cinsinden: 30, 60, 120, 240)
  Future<Result<bool>> setAvailable(int durationMinutes) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return Result.failure(const AppException('Oturum açmanız gerekiyor.', code: 'AUTH'));
    }

    final until = DateTime.now().toUtc().add(Duration(minutes: durationMinutes));

    try {
      await _supabase.from('profiles').update({
        'status': 'available',
        'available_until': until.toIso8601String(),
        'pending_catch_id': null,
      }).eq('id', userId);
      return const Result.success(true);
    } catch (e) {
      debugPrint('Müsaitlik güncelleme hatası: $e');
      return Result.failure(AppException.fromSupabase(e));
    }
  }

  /// Meşgul ol
  Future<Result<bool>> setBusy() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return Result.failure(const AppException('Oturum açmanız gerekiyor.', code: 'AUTH'));
    }

    try {
      await _supabase.from('profiles').update({
        'status': 'busy',
        'available_until': null,
        'pending_catch_id': null,
      }).eq('id', userId);
      return const Result.success(true);
    } catch (e) {
      debugPrint('Meşgul güncelleme hatası: $e');
      return Result.failure(AppException.fromSupabase(e));
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
  Future<Result<List<Map<String, dynamic>>>> getFriendsWithStatus(String userId) async {
    try {
      final myFollowing = await _supabase
          .from('followers')
          .select('following_id')
          .eq('follower_id', userId);

      final myFollowingIds = (myFollowing as List)
          .map((e) => e['following_id'] as String)
          .toList();

      if (myFollowingIds.isEmpty) return const Result.success([]);

      final myFollowers = await _supabase
          .from('followers')
          .select('follower_id')
          .eq('following_id', userId)
          .inFilter('follower_id', myFollowingIds);

      final mutualIds = (myFollowers as List)
          .map((e) => e['follower_id'] as String)
          .toList();

      if (mutualIds.isEmpty) return const Result.success([]);

      final profiles = await _supabase
          .from('profiles')
          .select('id, full_name, username, avatar_url, status, available_until, phone_number, is_online')
          .inFilter('id', mutualIds);

      return Result.success(List<Map<String, dynamic>>.from(profiles));
    } catch (e) {
      debugPrint('Arkadaş listesi hatası: $e');
      return Result.failure(AppException.fromSupabase(e));
    }
  }

  /// Arkadaş profillerini realtime stream
  Stream<List<Map<String, dynamic>>> streamFriendsStatus(List<String> friendIds) {
    if (friendIds.isEmpty) return const Stream.empty();

    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .inFilter('id', friendIds)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }
}
