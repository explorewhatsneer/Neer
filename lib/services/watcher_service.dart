import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_exception.dart';

class WatcherService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Zil toggle: izliyorsa kaldır, izlemiyorsa ekle.
  /// Dönen bool = yeni durum (true = izliyor, false = izlemiyor)
  Future<Result<bool>> toggleWatch(String targetId) async {
    final watcherId = _supabase.auth.currentUser?.id;
    if (watcherId == null) {
      return Result.failure(const AppException('Oturum açmanız gerekiyor.', code: 'AUTH'));
    }

    try {
      final existing = await _supabase
          .from('watchers')
          .select('id, is_active')
          .eq('watcher_id', watcherId)
          .eq('target_id', targetId)
          .maybeSingle();

      if (existing == null) {
        await _supabase.from('watchers').insert({
          'watcher_id': watcherId,
          'target_id': targetId,
          'is_active': true,
        });
        return const Result.success(true);
      } else {
        final newState = !(existing['is_active'] as bool);
        await _supabase
            .from('watchers')
            .update({'is_active': newState})
            .eq('id', existing['id']);
        return Result.success(newState);
      }
    } catch (e) {
      debugPrint('Watcher toggle hatası: $e');
      return Result.failure(AppException.fromSupabase(e));
    }
  }

  /// İzlediğim kişilerin ID'lerini çek
  Future<Result<Set<String>>> getWatchedIds() async {
    final watcherId = _supabase.auth.currentUser?.id;
    if (watcherId == null) return const Result.success({});

    try {
      final response = await _supabase
          .from('watchers')
          .select('target_id')
          .eq('watcher_id', watcherId)
          .eq('is_active', true);

      final ids = (response as List)
          .map((e) => e['target_id'] as String)
          .toSet();
      return Result.success(ids);
    } catch (e) {
      debugPrint('Watched IDs hatası: $e');
      return Result.failure(AppException.fromSupabase(e));
    }
  }
}
