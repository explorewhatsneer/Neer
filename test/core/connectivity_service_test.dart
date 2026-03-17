import 'package:flutter_test/flutter_test.dart';
import 'package:neer/core/connectivity_service.dart';

void main() {
  group('ConnectivityService', () {
    test('singleton instance çalışır', () {
      final a = ConnectivityService.instance;
      final b = ConnectivityService.instance;
      expect(identical(a, b), isTrue);
    });

    test('varsayılan olarak online', () {
      expect(ConnectivityService.instance.isOnline, isTrue);
    });

    test('onStatusChange stream broadcast', () {
      final stream = ConnectivityService.instance.onStatusChange;
      expect(stream.isBroadcast, isTrue);
    });
  });
}
