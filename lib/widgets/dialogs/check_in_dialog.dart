import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🔥 CORE IMPORTLARI
import '../../core/constants.dart';
import '../../core/text_styles.dart';
import '../../core/theme_styles.dart';
import '../../screens/group_chat_screen.dart'; // Chat Ekranını Import Et

class CheckInDialog extends StatefulWidget {
  final bool isSuccess;
  final String title;
  final String message;
  
  // 🔥 ARTIK FONKSİYON DEĞİL, DATA ALIYORUZ
  final String? venueId;
  final String? venueName;
  final String? venueImage;

  const CheckInDialog({
    super.key,
    required this.isSuccess,
    required this.title,
    required this.message,
    this.venueId,
    this.venueName,
    this.venueImage,
  });

  static void show(BuildContext context, {
    required bool isSuccess,
    required String title,
    required String message,
    // Opsiyonel parametreler (Sadece başarı durumunda lazım)
    String? venueId,
    String? venueName,
    String? venueImage,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Kapat",
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8 * animation.value, sigmaY: 8 * animation.value),
              child: Container(color: Colors.transparent),
            ),
            FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: curvedAnimation,
                child: CheckInDialog(
                  isSuccess: isSuccess,
                  title: title,
                  message: message,
                  venueId: venueId,
                  venueName: venueName,
                  venueImage: venueImage,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  State<CheckInDialog> createState() => _CheckInDialogState();
}

class _CheckInDialogState extends State<CheckInDialog> {
  
  // 🔥 NAVİGASYON ARTIK BURADA VE GÜVENLİ
  void _goToChat() {
    if (widget.venueId != null) {
      // Dialog'u kapatıp yerine Chat'i koyuyoruz (Replacement)
      // rootNavigator: true ile en tepeye çıkıyoruz.
      Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GroupChatScreen(
            groupId: widget.venueId!,
            groupName: widget.venueName ?? "",
            groupImage: widget.venueImage ?? "",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color iconBgColor = widget.isSuccess 
        ? AppColors.accent.withValues(alpha: 0.15) 
        : theme.colorScheme.error.withValues(alpha: 0.1);
    
    final Color iconColor = widget.isSuccess 
        ? AppColors.accent 
        : theme.colorScheme.error;

    final IconData iconData = widget.isSuccess 
        ? Icons.verified_rounded 
        : Icons.gpp_bad_rounded;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: AppThemeStyles.radius32,
            boxShadow: AppThemeStyles.shadowMedium,
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                child: Icon(iconData, color: iconColor, size: 36),
              ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.h2.copyWith(color: theme.textTheme.displayLarge?.color),
              ),
              const SizedBox(height: 12),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(color: theme.textTheme.bodyMedium?.color, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (widget.isSuccess) {
                      _goToChat(); // 🔥 Kendi içindeki fonksiyona gidiyor
                    } else {
                      Navigator.pop(context); // Hata ise sadece kapat
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isSuccess ? AppColors.primary : theme.disabledColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius16),
                  ),
                  child: Text(
                    widget.isSuccess ? "Sohbete Katıl" : "Tamam",
                    style: AppTextStyles.button.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              if (widget.isSuccess) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    "Kapat",
                    style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor, fontWeight: FontWeight.w500),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}