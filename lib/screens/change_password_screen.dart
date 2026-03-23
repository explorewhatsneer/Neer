import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:supabase_flutter/supabase_flutter.dart';

// CORE IMPORTLARI
import '../core/neer_design_system.dart';
import '../core/app_strings.dart';
import '../core/snackbar_helper.dart';

import '../services/supabase_service.dart';
import '../widgets/common/loading_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _service = SupabaseService();
  
  final _formKey = GlobalKey<FormState>();
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  // Şifrelerin görünürlüğünü kontrol eden değişkenler
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // --- ŞİFRE DEĞİŞTİRME MANTIĞI ---
  Future<void> _changePassword() async {
    // Klavyeyi kapat
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact(); 

    if (!_formKey.currentState!.validate()) return;

    try {
      final user = _service.client.auth.currentUser;
      String email = user?.email ?? "";

      // 1. ADIM: Kullanıcıyı "Mevcut Şifre" ile doğrula (Re-Auth Simülasyonu)
      // Supabase'de signIn çağrısı yaparak şifrenin doğruluğunu test edebiliriz.
      // Not: Bu işlem yeni bir oturum açar ve mevcut session'ı yeniler.
      final AuthResponse res = await _service.client.auth.signInWithPassword(
        email: email,
        password: _currentPassController.text.trim(),
      );

      if (res.user == null) {
        throw const AuthException("Mevcut şifre hatalı.");
      }

      // 2. ADIM: Doğrulama başarılıysa şifreyi güncelle
      await _service.client.auth.updateUser(
        UserAttributes(
          password: _newPassController.text.trim(),
        ),
      );

      if (mounted) {
        AppSnackBar.success(context, AppStrings.passwordUpdated);
        Navigator.pop(context);
      }

    } on AuthException catch (e) {
      // Supabase Auth Hataları
      String errorMessage = AppStrings.cameraError; // Default hata mesajı
      
      // Hata mesajlarını analiz et (Supabase mesajları İngilizce döner, Türkçeye çevirebiliriz)
      if (e.message.toLowerCase().contains('invalid login')) {
        errorMessage = AppStrings.errorWrongPassword;
      } else if (e.message.toLowerCase().contains('password')) {
        errorMessage = AppStrings.errorWeakPassword; // Genelde zayıf şifre uyarısı
      } else {
        errorMessage = e.message; // Diğer hatalar
      }

      if (mounted) {
        AppSnackBar.error(context, errorMessage);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, "Hata: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.changePasswordTitle, 
          style: NeerTypography.h3.copyWith(fontSize: 20)
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- PREMIUM BİLGİ KARTI ---
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: isDark ? 0.2 : 0.08),
                  borderRadius: NeerRadius.buttonRadius,
                  border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_reset_rounded, color: theme.primaryColor, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        AppStrings.passwordInfo, 
                        style: NeerTypography.bodySmall.copyWith(
                          color: isDark ? Colors.white70 : NeerColors.primaryDark,
                          height: 1.4,
                          fontSize: 13
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 1. Mevcut Şifre
              _buildPremiumPasswordField(
                context,
                controller: _currentPassController,
                label: AppStrings.currentPassword,
                isObscure: _obscureCurrent,
                onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                validator: (val) => val!.isEmpty ? AppStrings.enterCurrentPass : null,
              ),
              const SizedBox(height: 20),

              // 2. Yeni Şifre
              _buildPremiumPasswordField(
                context,
                controller: _newPassController,
                label: AppStrings.newPassword,
                isObscure: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                validator: (val) => (val!.length < 6) ? AppStrings.errorWeakPassword : null,
              ),
              const SizedBox(height: 20),

              // 3. Yeni Şifre Tekrar
              _buildPremiumPasswordField(
                context,
                controller: _confirmPassController,
                label: AppStrings.confirmPassword,
                isObscure: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (val) {
                  if (val!.isEmpty) return AppStrings.enterCurrentPass; 
                  if (val != _newPassController.text) return AppStrings.errorMismatch;
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // Kaydet Butonu
              LoadingButton(
                onPressed: _changePassword,
                label: AppStrings.updatePasswordBtn,
                height: 56,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- REUSABLE PREMIUM PASSWORD FIELD ---
  Widget _buildPremiumPasswordField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required bool isObscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: NeerRadius.buttonRadius,
        boxShadow: isDark ? [] : NeerShadows.soft(),
        border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        validator: validator,
        style: NeerTypography.bodyLarge.copyWith(color: theme.textTheme.bodyLarge?.color),
        cursorColor: theme.primaryColor,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: NeerTypography.bodySmall.copyWith(color: theme.disabledColor),
          floatingLabelStyle: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600),
          prefixIcon: Icon(Icons.lock_outline_rounded, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
          suffixIcon: IconButton(
            icon: Icon(
              isObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: theme.disabledColor,
            ),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        ),
      ),
    );
  }
}