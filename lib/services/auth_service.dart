import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_strings.dart';
import '../main.dart'; // supabase nesnesine erişim için

class AuthService {
  // Mevcut Oturum
  User? get currentUser => supabase.auth.currentUser;

  // Stream
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  // --- GİRİŞ YAP (LOGIN) ---
  Future<String?> login({required String email, required String password}) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Başarılı
    } on AuthException catch (e) {
      // Supabase'in kendi hata mesajları oldukça nettir
      return e.message; 
    } catch (e) {
      return AppStrings.unknownError;
    }
  }

  // --- KAYIT OL (REGISTER) ---
  Future<String?> register({
    required String email,
    required String password,
    required String name,
    required String username,
  }) async {
    try {
      // Verileri 'data' parametresiyle gönderiyoruz.
      // SQL Trigger'ımız bunları yakalayıp 'profiles' tablosuna yazacak.
      await supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {
          'full_name': name.trim(),
          'username': username.trim().toLowerCase(),
        },
      );
      return null; // Başarılı
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "${AppStrings.unknownError}: $e";
    }
  }

  // --- ÇIKIŞ YAP ---
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // --- ŞİFRE SIFIRLAMA ---
  Future<String?> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email.trim());
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return AppStrings.resetEmailFailed;
    }
  }
}