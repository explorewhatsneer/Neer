import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_exception.dart';
import '../models/catch_request.dart';

class CatchService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const int cooldownSeconds = 180; // 3 dakika

  /// Catch gönder (sadece available olanlara)
  Future<Result<CatchRequest>> sendCatch(String receiverId) async {
    final senderId = _supabase.auth.currentUser?.id;
    if (senderId == null) {
      return Result.failure(const AppException('Oturum açmanız gerekiyor.', code: 'AUTH'));
    }

    final remaining = await getCooldownRemaining(receiverId);
    if (remaining > 0) {
      return Result.failure(AppException('$remaining saniye beklemeniz gerekiyor.', code: 'COOLDOWN'));
    }

    try {
      final response = await _supabase
          .from('catches')
          .insert({
            'sender_id': senderId,
            'receiver_id': receiverId,
          })
          .select()
          .single();

      return Result.success(CatchRequest.fromMap(response));
    } catch (e) {
      debugPrint('Catch gönderme hatası: $e');
      return Result.failure(AppException.fromSupabase(e));
    }
  }

  /// Catch'i kabul et
  Future<Result<bool>> acceptCatch(String catchId) async {
    try {
      await _supabase
          .from('catches')
          .update({'status': 'accepted'})
          .eq('id', catchId);
      return const Result.success(true);
    } catch (e) {
      debugPrint('Catch kabul hatası: $e');
      return Result.failure(AppException.fromSupabase(e));
    }
  }

  /// Catch'i reddet
  Future<Result<bool>> rejectCatch(String catchId) async {
    try {
      await _supabase
          .from('catches')
          .update({'status': 'rejected'})
          .eq('id', catchId);
      return const Result.success(true);
    } catch (e) {
      debugPrint('Catch reddetme hatası: $e');
      return Result.failure(AppException.fromSupabase(e));
    }
  }

  /// Cooldown kontrolü: kalan süreyi saniye olarak döndürür (0 = atılabilir)
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
