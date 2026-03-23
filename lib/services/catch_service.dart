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
  /// Sunucu saati kullanır — telefon saati manipüle edilemez
  Future<int> getCooldownRemaining(String receiverId) async {
    final senderId = _supabase.auth.currentUser?.id;
    if (senderId == null) return 0;

    try {
      final result = await _supabase.rpc('get_catch_cooldown_remaining', params: {
        'p_sender_id': senderId,
        'p_receiver_id': receiverId,
        'p_cooldown_seconds': cooldownSeconds,
      });
      return (result as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Gelen pending catch'leri dinle (realtime)
  /// NOT: Supabase stream tek .eq() destekler — 'status' filtresi client tarafında zorunlu
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
