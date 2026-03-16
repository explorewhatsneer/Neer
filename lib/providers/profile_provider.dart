import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class ProfileProvider with ChangeNotifier {
  final SupabaseService _service = SupabaseService();
  StreamSubscription? _profileSub;

  UserModel? _profile;
  bool _isLoading = false;

  UserModel? get profile => _profile;
  bool get isLoading => _isLoading;

  /// Profili yükle ve realtime dinle
  void loadProfile(String userId) {
    _isLoading = true;
    notifyListeners();

    // İlk yükleme
    _service.getUser(userId).then((result) {
      if (result.isSuccess) {
        _profile = result.data;
      }
      _isLoading = false;
      notifyListeners();
    });

    // Realtime stream
    _profileSub?.cancel();
    _profileSub = _service.streamProfile(userId).listen((data) {
      if (data != null) {
        _profile = UserModel.fromMap(data);
        notifyListeners();
      }
    });
  }

  /// Profili güncelle
  Future<void> updateProfile(Map<String, dynamic> data) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    await _service.updateProfile(userId, data);
    // Realtime stream otomatik güncelleyecek
  }

  void clear() {
    _profileSub?.cancel();
    _profile = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    super.dispose();
  }
}
