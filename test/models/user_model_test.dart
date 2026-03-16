import 'package:flutter_test/flutter_test.dart';
import 'package:neer/models/user_model.dart';

void main() {
  group('UserModel', () {
    final sampleMap = {
      'id': 'abc-123',
      'email': 'test@neer.app',
      'full_name': 'Ali Veli',
      'username': 'aliveli',
      'bio': 'Merhaba dünya',
      'avatar_url': 'https://example.com/avatar.jpg',
      'is_anonymous': false,
      'is_online': true,
      'check_in_count': 5,
      'photo_count': 3,
      'trust_score': 85.5,
      'is_private': false,
      'followers_count': 10,
      'following_count': 20,
      'latitude': 41.0082,
      'longitude': 28.9784,
      'status': 'available',
      'available_until': '2026-03-16T18:00:00.000Z',
      'pending_catch_id': null,
      'phone_number': '+905559876543',
    };

    test('fromMap doğru parse eder', () {
      final user = UserModel.fromMap(sampleMap);
      expect(user.uid, 'abc-123');
      expect(user.email, 'test@neer.app');
      expect(user.name, 'Ali Veli');
      expect(user.username, 'aliveli');
      expect(user.bio, 'Merhaba dünya');
      expect(user.profileImage, 'https://example.com/avatar.jpg');
      expect(user.isAnonymous, false);
      expect(user.isOnline, true);
      expect(user.checkInCount, 5);
      expect(user.photoCount, 3);
      expect(user.trustScore, 85.5);
      expect(user.isPrivate, false);
      expect(user.followersCount, 10);
      expect(user.followingCount, 20);
      expect(user.latitude, 41.0082);
      expect(user.longitude, 28.9784);
      expect(user.catchStatus, 'available');
      expect(user.phoneNumber, '+905559876543');
      expect(user.availableUntil, isNotNull);
      expect(user.pendingCatchId, isNull);
    });

    test('fromMap eksik alanlarla çalışır', () {
      final user = UserModel.fromMap({'id': 'x'});
      expect(user.uid, 'x');
      expect(user.name, '');
      expect(user.email, '');
      expect(user.username, '');
      expect(user.catchStatus, 'busy');
      expect(user.trustScore, 5.0);
      expect(user.isAnonymous, false);
      expect(user.followersCount, 0);
    });

    test('toMap doğru serialize eder', () {
      final user = UserModel.fromMap(sampleMap);
      final map = user.toMap();
      expect(map['id'], 'abc-123');
      expect(map['full_name'], 'Ali Veli');
      expect(map['avatar_url'], 'https://example.com/avatar.jpg');
      expect(map['status'], 'available');
      expect(map['phone_number'], '+905559876543');
      expect(map['is_anonymous'], false);
      expect(map['trust_score'], 85.5);
    });

    test('copyWith alanları günceller', () {
      final user = UserModel.fromMap(sampleMap);
      final updated = user.copyWith(
        name: 'Yeni İsim',
        catchStatus: 'busy',
        trustScore: 90.0,
      );
      expect(updated.name, 'Yeni İsim');
      expect(updated.catchStatus, 'busy');
      expect(updated.trustScore, 90.0);
      expect(updated.email, user.email); // değişmedi
      expect(updated.uid, user.uid); // değişmedi
    });

    test('copyWith null alanları korur', () {
      final user = UserModel.fromMap(sampleMap);
      final same = user.copyWith();
      expect(same.name, user.name);
      expect(same.catchStatus, user.catchStatus);
      expect(same.uid, user.uid);
      expect(same.trustScore, user.trustScore);
    });

    test('fromMap alternatif alan isimlerini destekler', () {
      final user = UserModel.fromMap({
        'uid': 'alt-id',
        'name': 'Alt Name',
        'profile_image': 'https://example.com/alt.jpg',
      });
      expect(user.uid, 'alt-id');
      expect(user.name, 'Alt Name');
      expect(user.profileImage, 'https://example.com/alt.jpg');
    });
  });
}
