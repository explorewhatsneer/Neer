import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/catch_request.dart';

class CatchService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const int cooldownSeconds = 180; // 3 dakika

  /// Catch gönder (sadece available olanlara)
  Future<CatchRequest?> sendCatch(String receiverId) async {
    final senderId = _supabase.auth.currentUser?.id;
    if (senderId == null) return null;

    // Cooldown kontrolü
    final remaining = await getCooldownRemaining(receiverId);
    if (remaining > 0) return null;

    try {
      final response = await _supabase
          .from('catches')
          .insert({
            'sender_id': senderId,
            'receiver_id': receiverId,
          })
          .select()
          .single();

      return CatchRequest.fromMap(response);
    } catch (e) {
      print('Catch gönderme hatası: $e');
      return null;
    }
  }

  /// Catch'i kabul et
  Future<bool> acceptCatch(String catchId) async {
    try {
      await _supabase
          .from('catches')
          .update({'status': 'accepted'})
          .eq('id', catchId);
      return true;
    } catch (e) {
      print('Catch kabul hatası: $e');
      return false;
    }
  }

  /// Catch'i reddet
  Future<bool> rejectCatch(String catchId) async {
    try {
      await _supabase
          .from('catches')
          .update({'status': 'rejected'})
          .eq('id', catchId);
      return true;
    } catch (e) {
      print('Catch reddetme hatası: $e');
      return false;
    }
  }

  /// Cooldown kontrolü: aynı kişiye son 3dk içinde catch atılmış mı?
  /// Kalan süreyi saniye olarak döndürür (0 = atılabilir)
  Future<int> getCooldownRemaining(String receiverId) async {
    final senderId = _supabase.auth.currentUser?.id;
    if (senderId == null) return 0;

    try {
      final response = await _supabase
          .from('catches')
          .select('created_at')
          .eq('sender_id', senderId)
          .eq('receiver_id', receiverId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return 0;

      final lastCatchTime = DateTime.parse(response['created_at']);
      final elapsed = DateTime.now().toUtc().difference(lastCatchTime).inSeconds;
      final remaining = cooldownSeconds - elapsed;

      return remaining > 0 ? remaining : 0;
    } catch (e) {
      return 0;
    }
  }

  /// Gelen pending catch'leri dinle (realtime)
  Stream<List<Map<String, dynamic>>> streamIncomingCatches(String userId) {
    return _supabase
        .from('catches')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.where((c) => c['status'] == 'pending').toList());
  }

  /// Gönderilen catch'leri dinle (onay animasyonu için)
  Stream<List<Map<String, dynamic>>> streamSentCatches(String userId) {
    return _supabase
        .from('catches')
        .stream(primaryKey: ['id'])
        .eq('sender_id', userId)
        .order('created_at', ascending: false);
  }
}
