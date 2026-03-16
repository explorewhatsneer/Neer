/// Uygulama genelinde kullanılan hata tipi.
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic original;

  const AppException(this.message, {this.code, this.original});

  @override
  String toString() => 'AppException($code): $message';

  /// Supabase PostgrestException'dan dönüştür
  factory AppException.fromSupabase(dynamic e) {
    final msg = e?.toString() ?? 'Bilinmeyen hata';
    String? code;
    if (e is Exception) {
      final str = e.toString();
      // PostgrestException genelde "message" ve "code" içerir
      if (str.contains('duplicate key')) {
        return AppException('Bu kayıt zaten mevcut.', code: 'DUPLICATE', original: e);
      }
      if (str.contains('violates foreign key')) {
        return AppException('İlişkili kayıt bulunamadı.', code: 'FK_VIOLATION', original: e);
      }
      if (str.contains('permission denied') || str.contains('row-level security')) {
        return AppException('Bu işlem için yetkiniz yok.', code: 'RLS_DENIED', original: e);
      }
    }
    return AppException(msg, code: code, original: e);
  }

  /// Ağ hatasından dönüştür
  factory AppException.network([dynamic e]) {
    return AppException(
      'İnternet bağlantısı yok veya sunucuya ulaşılamıyor.',
      code: 'NETWORK',
      original: e,
    );
  }

  /// Bilinmeyen hata
  factory AppException.unknown([dynamic e]) {
    return AppException(
      'Beklenmeyen bir hata oluştu.',
      code: 'UNKNOWN',
      original: e,
    );
  }
}

/// İşlem sonucu: ya başarılı (data) ya da hatalı (error).
/// Kullanım:
/// ```dart
/// final result = await service.getUser(id);
/// result.when(
///   success: (user) => setState(() => _user = user),
///   failure: (error) => showSnackBar(error.message),
/// );
/// ```
class Result<T> {
  final T? _data;
  final AppException? _error;

  const Result.success(T data) : _data = data, _error = null;
  const Result.failure(AppException error) : _data = null, _error = error;

  bool get isSuccess => _error == null;
  bool get isFailure => _error != null;

  T get data => _data as T;
  AppException get error => _error!;

  /// Pattern matching
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) {
    if (isSuccess) return success(_data as T);
    return failure(_error!);
  }

  /// Sadece başarılıysa çalıştır
  void ifSuccess(void Function(T data) action) {
    if (isSuccess) action(_data as T);
  }

  /// Sadece hatalıysa çalıştır
  void ifFailure(void Function(AppException error) action) {
    if (isFailure) action(_error!);
  }
}
