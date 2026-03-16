import 'package:flutter_test/flutter_test.dart';
import 'package:neer/models/catch_request.dart';

void main() {
  group('CatchRequest', () {
    final sampleMap = {
      'id': 'catch-001',
      'sender_id': 'user-a',
      'receiver_id': 'user-b',
      'status': 'pending',
      'created_at': '2026-03-16T12:00:00.000Z',
      'expires_at': '2026-03-16T12:01:00.000Z',
    };

    test('fromMap doğru parse eder', () {
      final c = CatchRequest.fromMap(sampleMap);
      expect(c.id, 'catch-001');
      expect(c.senderId, 'user-a');
      expect(c.receiverId, 'user-b');
      expect(c.status, 'pending');
      expect(c.isPending, isTrue);
    });

    test('fromMap sender profil bilgisi ile çalışır', () {
      final mapWithProfile = {
        ...sampleMap,
        'profiles': {
          'full_name': 'Ali',
          'avatar_url': 'https://example.com/a.jpg',
        },
      };
      final c = CatchRequest.fromMap(mapWithProfile);
      expect(c.senderName, 'Ali');
      expect(c.senderAvatar, 'https://example.com/a.jpg');
    });

    test('isExpired süresi geçmiş catch için true döner', () {
      final expired = CatchRequest.fromMap({
        ...sampleMap,
        'expires_at': '2020-01-01T00:00:00.000Z',
      });
      expect(expired.isExpired, isTrue);
    });

    test('isExpired gelecekteki catch için false döner', () {
      final future = CatchRequest.fromMap({
        ...sampleMap,
        'expires_at': '2099-01-01T00:00:00.000Z',
      });
      expect(future.isExpired, isFalse);
    });

    test('isPending status kontrolleri', () {
      expect(CatchRequest.fromMap({...sampleMap, 'status': 'pending'}).isPending, isTrue);
      expect(CatchRequest.fromMap({...sampleMap, 'status': 'accepted'}).isPending, isFalse);
      expect(CatchRequest.fromMap({...sampleMap, 'status': 'rejected'}).isPending, isFalse);
    });
  });
}
