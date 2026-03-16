import 'package:flutter_test/flutter_test.dart';
import 'package:neer/core/app_exception.dart';

void main() {
  group('AppException', () {
    test('temel constructor çalışır', () {
      const e = AppException('test hatası', code: 'TEST');
      expect(e.message, 'test hatası');
      expect(e.code, 'TEST');
      expect(e.original, isNull);
    });

    test('fromSupabase duplicate key algılar', () {
      final e = AppException.fromSupabase(Exception('duplicate key value'));
      expect(e.code, 'DUPLICATE');
      expect(e.message, 'Bu kayıt zaten mevcut.');
    });

    test('fromSupabase permission denied algılar', () {
      final e = AppException.fromSupabase(Exception('permission denied for table'));
      expect(e.code, 'RLS_DENIED');
    });

    test('network factory çalışır', () {
      final e = AppException.network();
      expect(e.code, 'NETWORK');
      expect(e.message, contains('İnternet'));
    });

    test('unknown factory çalışır', () {
      final e = AppException.unknown();
      expect(e.code, 'UNKNOWN');
    });

    test('toString format doğru', () {
      const e = AppException('hata', code: 'X');
      expect(e.toString(), 'AppException(X): hata');
    });
  });

  group('Result', () {
    test('success oluşturulabilir', () {
      const result = Result.success(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.data, 42);
    });

    test('failure oluşturulabilir', () {
      final result = Result<int>.failure(const AppException('hata'));
      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.error.message, 'hata');
    });

    test('when success dalı çalışır', () {
      const result = Result.success('veri');
      final output = result.when(
        success: (data) => 'başarılı: $data',
        failure: (error) => 'hata: ${error.message}',
      );
      expect(output, 'başarılı: veri');
    });

    test('when failure dalı çalışır', () {
      final result = Result<String>.failure(const AppException('sorun'));
      final output = result.when(
        success: (data) => 'başarılı: $data',
        failure: (error) => 'hata: ${error.message}',
      );
      expect(output, 'hata: sorun');
    });

    test('ifSuccess sadece başarılıysa çalışır', () {
      int counter = 0;
      const Result.success(1).ifSuccess((_) => counter++);
      Result<int>.failure(const AppException('x')).ifSuccess((_) => counter++);
      expect(counter, 1);
    });

    test('ifFailure sadece hatalıysa çalışır', () {
      int counter = 0;
      const Result.success(1).ifFailure((_) => counter++);
      Result<int>.failure(const AppException('x')).ifFailure((_) => counter++);
      expect(counter, 1);
    });

    test('void Result çalışır', () {
      const result = Result<void>.success(null);
      expect(result.isSuccess, isTrue);
    });

    test('List Result çalışır', () {
      const result = Result<List<int>>.success([1, 2, 3]);
      expect(result.data.length, 3);
    });
  });
}
