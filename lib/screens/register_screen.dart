import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../main.dart'; // 🔥 Global supabase client erişimi

// CORE IMPORTLARI
import '../core/theme_styles.dart';
import '../core/text_styles.dart';
import '../core/app_strings.dart';
import '../core/app_router.dart';
import '../core/snackbar_helper.dart';
import '../widgets/common/loading_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllerlar
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

  // --- KAYIT OLMA İŞLEMİ ---
  Future<void> _register() async {
    // Klavyeyi kapat
    FocusScope.of(context).unfocus();

    // 1. Basit Validasyon
    if (_nameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      AppSnackBar.error(context, AppStrings.fillAllFields);
      return;
    }

    try {
      // 2. Supabase Kayıt İsteği
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
              Icon(Icons.person_add_alt_1_rounded, size: 50, color: theme.primaryColor),
              const SizedBox(height: 16),
              Text(
                AppStrings.appName, // "neer"
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Visby', 
                  color: theme.primaryColor, 
                  fontSize: 40, 
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 1.0,
                )
              ),
              Text(
                AppStrings.joinUs, 
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.disabledColor,
                  fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(height: 40),

              // --- BAŞLIK ---
              Text(
                AppStrings.registerTitle, 
                style: AppTextStyles.h1.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 28
                )
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.createAccountSubtitle, 
                style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor)
              ),
              const SizedBox(height: 30),

              // --- INPUTLAR ---
              _buildPremiumInput(
                context,
                controller: _nameController,
                hint: AppStrings.fullName, 
                icon: Icons.person_outline_rounded,
                inputType: TextInputType.name,
              ),
              const SizedBox(height: 16),

              _buildPremiumInput(
                context,
                controller: _usernameController,
                hint: AppStrings.username, 
                icon: Icons.alternate_email_rounded,
                inputType: TextInputType.text,
              ),
              const SizedBox(height: 16),

              _buildPremiumInput(
                context,
                controller: _emailController,
                hint: AppStrings.emailHint,
                icon: Icons.email_outlined,
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              _buildPremiumInput(
                context,
                controller: _passwordController,
                hint: AppStrings.passwordHint,
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                isPasswordVisible: _isPasswordVisible,
                onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),

              const SizedBox(height: 40),

              // --- KAYIT OL BUTONU ---
              LoadingButton(
                onPressed: _register,
                label: AppStrings.registerTitle,
                height: 56,
              ),

              const SizedBox(height: 40),

              // --- GİRİŞ YAP ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.haveAccount, 
                    style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor)
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
    // ignore: unused_local_variable
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppThemeStyles.radius16,
        boxShadow: theme.brightness == Brightness.dark ? [] : AppThemeStyles.shadowLow,
        border: theme.brightness == Brightness.dark ? Border.all(color: Colors.white12, width: 1) : null,
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