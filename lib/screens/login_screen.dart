import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// CORE IMPORTLARI
import '../core/constants.dart';
import '../core/text_styles.dart';
import '../core/app_strings.dart';
import '../core/app_router.dart';
import '../core/snackbar_helper.dart';
import '../widgets/common/loading_button.dart';
import '../widgets/auth/auth_widgets.dart';

import 'package:neer/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      AppSnackBar.error(context, AppStrings.fillAllFields);
      return;
    }

    String? error = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (mounted) {
      if (error == null) {
        HapticFeedback.mediumImpact();
        context.go(AppRoutes.home);
      } else {
        HapticFeedback.heavyImpact();
        AppSnackBar.error(context, error);
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
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.location_on_rounded, size: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Visby',
                  color: theme.primaryColor,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2.0,
                  height: 1.0,
                ),
              ),
              Text(
                AppStrings.slogan,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.disabledColor,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 50),

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
                          AppStrings.loginTitle,
                          style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.loginSubtitle,
                          style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor),
                        ),
                        const SizedBox(height: 28),

                        NeerAuthInput(
                          controller: _emailController,
                          hint: AppStrings.emailHint,
                          icon: Icons.alternate_email_rounded,
                          inputType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        NeerAuthInput(
                          controller: _passwordController,
                          hint: AppStrings.passwordHint,
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          isPasswordVisible: _isPasswordVisible,
                          onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => HapticFeedback.selectionClick(),
                            child: Text(
                              AppStrings.forgotPassword,
                              style: AppTextStyles.caption.copyWith(
                                color: theme.primaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        LoadingButton(
                          onPressed: _login,
                          label: AppStrings.loginTitle,
                          height: 56,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- KAYIT OL ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.noAccount,
                    style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      context.push(AppRoutes.register);
                    },
                    child: Text(
                      AppStrings.signUp,
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
