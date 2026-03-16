import 'package:supabase_flutter/supabase_flutter.dart';

class WatcherService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Zil toggle: izliyorsa kaldır, izlemiyorsa ekle
  Future<bool> toggleWatch(String targetId) async {
    final watcherId = _supabase.auth.currentUser?.id;
    if (watcherId == null) return false;

    try {
      // Mevcut kayıt var mı?
      final existing = await _supabase
          .from('watchers')
          .select('id, is_active')
          .eq('watcher_id', watcherId)
          .eq('target_id', targetId)
          .maybeSingle();

      if (existing == null) {
        // Yeni kayıt oluştur
        await _supabase.from('watchers').insert({
          'watcher_id': watcherId,
          'target_id': targetId,
          'is_active': true,
        });
        return true; // artık izliyor
      } else {
        // Toggle
        final newState = !(existing['is_active'] as bool);
        await _supabase
            .from('watchers')
            .update({'is_active': newState})
            .eq('id', existing['id']);
        return newState;
      }
    } catch (e) {
      print('Watcher toggle hatası: $e');
      return false;
    }
  }

  /// İzlediğim kişilerin ID'lerini çek
  Future<Set<String>> getWatchedIds() async {
    final watcherId = _supabase.auth.currentUser?.id;
    if (watcherId == null) return {};

    try {
      final response = await _supabase
          .from('watchers')
          .select('target_id')
          .eq('watcher_id', watcherId)
          .eq('is_active', true);

      return (response as List)
          .map((e) => e['target_id'] as String)
          .toSet();
    } catch (e) {
      return {};
    }
  }
}
