import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:go_router/go_router.dart';

// CORE IMPORTLARI
import '../core/theme_styles.dart';
import '../core/text_styles.dart';
import '../core/app_strings.dart';
import '../core/app_router.dart';

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
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _login() async {
    // Klavyeyi kapat ve titreşim ver
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.fillAllFields, // 🔥 Core String
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white)
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius16),
        )
      );
      return;
    }

    setState(() => _isLoading = true);

    // Servis Kullanımı
    String? error = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (error == null) {
        // Başarılı Giriş
        HapticFeedback.mediumImpact();
        context.go(AppRoutes.home);
      } else {
        // Hata
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: AppTextStyles.bodySmall.copyWith(color: Colors.white)), 
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius16),
          )
        );
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
              _buildPremiumInput(
                context,
                controller: _emailController,
                hint: AppStrings.emailHint,
                icon: Icons.alternate_email_rounded,
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              
              _buildPremiumInput(
                context,
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
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: _isLoading ? 0 : 8,
                    shadowColor: theme.primaryColor.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius16),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text(
                        AppStrings.loginTitle, // "Giriş Yap"
                        style: AppTextStyles.button.copyWith(fontSize: 16)
                      ),
                ),
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

  // --- REUSABLE PREMIUM INPUT ---
  Widget _buildPremiumInput(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppThemeStyles.radius16,
        boxShadow: isDark ? [] : AppThemeStyles.shadowLow,
        border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: inputType,
        style: AppTextStyles.bodyLarge.copyWith(color: theme.textTheme.bodyLarge?.color),
        cursorColor: theme.primaryColor,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor.withValues(alpha: 0.7)),
          icon: Icon(icon, color: theme.primaryColor.withValues(alpha: 0.8)),
          border: InputBorder.none,
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: theme.disabledColor,
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
        ),
      ),
    );
  }
}