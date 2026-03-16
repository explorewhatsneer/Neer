import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  StreamSubscription<AuthState>? _authSub;

  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get userId => _user?.id;

  AuthProvider() {
    _user = _supabase.auth.currentUser;
    _isLoading = false;

    _authSub = _supabase.auth.onAuthStateChange.listen((data) {
      final newUser = data.session?.user;
      if (newUser?.id != _user?.id) {
        _user = newUser;
        notifyListeners();
      }
    });
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
