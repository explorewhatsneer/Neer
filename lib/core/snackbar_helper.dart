import 'package:flutter/material.dart';
import 'text_styles.dart';
import 'theme_styles.dart';

/// Tek satırda SnackBar gösterme utility'si.
/// ```dart
/// AppSnackBar.success(context, 'Kaydedildi!');
/// AppSnackBar.error(context, 'Bir hata oluştu.');
/// AppSnackBar.info(context, 'Bilgi mesajı');
/// ```
class AppSnackBar {
  AppSnackBar._();

  static void success(BuildContext context, String message) {
    _show(context, message, const Color(0xFF22C55E), Icons.check_circle_rounded);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, const Color(0xFFEF4444), Icons.error_rounded);
  }

  static void warning(BuildContext context, String message) {
    _show(context, message, const Color(0xFFFBBF24), Icons.warning_rounded);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, const Color(0xFF3B82F6), Icons.info_rounded);
  }

  static void _show(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius16),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
