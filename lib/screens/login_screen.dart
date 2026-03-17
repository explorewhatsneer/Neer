import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:go_router/go_router.dart';

// CORE IMPORTLARI
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
    // Klavyeyi kapat
    FocusScope.of(context).unfocus();

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      AppSnackBar.error(context, AppStrings.fillAllFields);
      return;
    }

    // Servis Kullanımı
    String? error = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (mounted) {
      if (error == null) {
        // Başarılı Giriş
        HapticFeedback.mediumImpact();
        context.go(AppRoutes.home);
      } else {
        // Hata
        HapticFeedback.heavyImpact();
        AppSnackBar.error(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- HEADER ---
              const SizedBox(height: 40),
              Icon(Icons.location_on_rounded, size: 60, color: theme.primaryColor),
              const SizedBox(height: 20),
              Text(
                AppStrings.appName, // "neer"
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Visby', // Projende bu font varsa kullan
                  color: theme.primaryColor, 
                  fontSize: 48, 
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2.0,
                  height: 1.0,
                )
              ),
              Text(
                AppStrings.slogan, 
                textAlign: TextAlign.center,
                // 🔥 Core Style: BodyMedium (Medium Spaced)
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.disabledColor,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(height: 60),
              
              // --- BAŞLIK ---
              Text(
                AppStrings.loginTitle, 
                // 🔥 Core Style: DisplaySmall (Bold)
                style: AppTextStyles.h1.copyWith( // veya h2
                  fontWeight: FontWeight.w800,
                  fontSize: 28
                )
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.loginSubtitle, 
                // 🔥 Core Style: BodyMedium
                style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor)
              ),
              const SizedBox(height: 30),

              // --- INPUTLAR ---
              NeerAuthInput(
                controller: _emailController,
                hint: AppStrings.emailHint,
                icon: Icons.alternate_email_rounded,
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              NeerAuthInput(
                controller: _passwordController,
                hint: AppStrings.passwordHint,
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                isPasswordVisible: _isPasswordVisible,
                onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              
              // Şifremi Unuttum
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    // Şifre sıfırlama rotası eklenebilir
                  }, 
                  child: Text(
                    AppStrings.forgotPassword, 
                    style: AppTextStyles.caption.copyWith(
                      color: theme.disabledColor, 
                      fontSize: 13, 
                      fontWeight: FontWeight.w600
                    )
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- GİRİŞ BUTONU ---
              LoadingButton(
                onPressed: _login,
                label: AppStrings.loginTitle,
                height: 56,
              ),

              const SizedBox(height: 40),

              // --- KAYIT OL ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.noAccount, 
                    style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor)
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
                        fontWeight: FontWeight.bold
                      )
                    )
                  )
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