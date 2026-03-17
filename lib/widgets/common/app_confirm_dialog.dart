import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/text_styles.dart';
import '../../core/theme_styles.dart';

/// Shows a themed confirmation dialog and returns true/false.
///
/// ```dart
/// final confirmed = await AppConfirmDialog.show(
///   context: context,
///   title: 'Arkadaşı Sil',
///   content: 'Ali adlı kişiyi silmek istiyor musunuz?',
///   confirmText: 'Sil',
///   isDestructive: true,
/// );
/// ```
class AppConfirmDialog {
  AppConfirmDialog._();

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String content,
    String? cancelText,
    String confirmText = 'Onayla',
    bool isDestructive = false,
    bool haptic = true,
  }) async {
    if (haptic) HapticFeedback.mediumImpact();
    final theme = Theme.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius24),
        title: Text(title, style: AppTextStyles.h3),
        content: Text(content, style: AppTextStyles.bodySmall),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              cancelText ?? 'İptal',
              style: AppTextStyles.button.copyWith(color: theme.disabledColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              confirmText,
              style: AppTextStyles.button.copyWith(
                color: isDestructive ? Colors.redAccent : theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
