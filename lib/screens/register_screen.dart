import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';

// CORE IMPORTLARI
import '../core/constants.dart';
import '../core/text_styles.dart';
import '../core/app_strings.dart';
import '../core/app_router.dart';
import '../core/snackbar_helper.dart';
import '../widgets/common/loading_button.dart';
import '../widgets/auth/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (_nameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      AppSnackBar.error(context, AppStrings.fillAllFields);
      return;
    }

    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'full_name': _nameController.text.trim(),
          'username': _usernameController.text.trim(),
        },
      );

      if (mounted) {
        if (res.session != null) {
          HapticFeedback.mediumImpact();
          context.go(AppRoutes.home);
        } else {
          AppSnackBar.success(context, "Kayıt başarılı! Lütfen giriş yapın.");
          Navigator.pop(context);
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        AppSnackBar.error(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, "Bir hata oluştu: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- LOGO ---
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.30),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person_add_alt_1_rounded, size: 32, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Visby',
                  color: theme.primaryColor,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              Text(
                AppStrings.joinUs,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.disabledColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 36),

              // --- GLASS FORM CARD ---
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface.withValues(alpha: 0.50)
                          : Colors.white.withValues(alpha: 0.60),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.65),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppStrings.registerTitle,
                          style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.createAccountSubtitle,
                          style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor),
                        ),
                        const SizedBox(height: 24),

                        NeerAuthInput(
                          controller: _nameController,
                          hint: AppStrings.fullName,
                          icon: Icons.person_outline_rounded,
                          inputType: TextInputType.name,
                        ),
                        const SizedBox(height: 14),

                        NeerAuthInput(
                          controller: _usernameController,
                          hint: AppStrings.username,
                          icon: Icons.alternate_email_rounded,
                        ),
                        const SizedBox(height: 14),

                        NeerAuthInput(
                          controller: _emailController,
                          hint: AppStrings.emailHint,
                          icon: Icons.email_outlined,
                          inputType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),

                        NeerAuthInput(
                          controller: _passwordController,
                          hint: AppStrings.passwordHint,
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          isPasswordVisible: _isPasswordVisible,
                          onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),

                        const SizedBox(height: 28),

                        LoadingButton(
                          onPressed: _register,
                          label: AppStrings.registerTitle,
                          height: 56,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- GİRİŞ YAP ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.haveAccount,
                    style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppStrings.loginTitle,
                      style: AppTextStyles.button.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
