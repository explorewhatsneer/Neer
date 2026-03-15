import 'package:flutter/material.dart';
import '../../core/theme_styles.dart'; // Stil dosyası

// 1. PREMIUM AUTH HEADER (Logo ve Başlık)
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        const SizedBox(height: 40),
        // Logo İkonu
        Icon(
          Icons.location_on_rounded, 
          size: 60, 
          color: theme.primaryColor
        ),
        const SizedBox(height: 20),
        // Marka İsmi
        Text(
          title, 
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.primaryColor, 
            fontSize: 48, 
            fontWeight: FontWeight.w900,
            letterSpacing: -2.0,
            height: 1.0,
          )
        ),
        // Alt Başlık
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.disabledColor,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w500
          ),
        ),
      ],
    );
  }
}

// 2. NEER AUTH INPUT (Premium Stil)
class NeerAuthInput extends StatelessWidget {
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onVisibilityToggle;
  final TextInputType inputType;

  const NeerAuthInput({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onVisibilityToggle,
    this.inputType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppThemeStyles.radius16,
        // Karanlık modda gölge yok, aydınlıkta var
        boxShadow: isDark ? [] : AppThemeStyles.shadowLow,
        // Karanlık modda ince çerçeve
        border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: inputType,
        style: theme.textTheme.bodyLarge, // Dinamik yazı rengi
        cursorColor: theme.primaryColor,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: theme.disabledColor.withValues(alpha: 0.7)),
          icon: Icon(icon, color: theme.primaryColor.withValues(alpha: 0.8)),
          border: InputBorder.none,
          // Şifre alanı ise göz ikonunu göster
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

// 3. AUTH BUTTON (Ana Aksiyon Butonu)
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 56, // Standart mobil yükseklik
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: isLoading ? 0 : 8,
          shadowColor: theme.primaryColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius16),
        ),
        onPressed: isLoading ? null : onTap,
        child: isLoading 
          ? const SizedBox(
              height: 24, 
              width: 24, 
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
            )
          : Text(
              text, 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
            ),
      ),
    );
  }
}