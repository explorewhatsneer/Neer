import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// CORE IMPORTLARI
import '../../core/constants.dart';
import '../../core/text_styles.dart';
import '../../core/app_strings.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendPressed;
  final FocusNode? focusNode;
  final bool enabled; // 🔥 YENİ: Rate limiting için aktif/pasif kontrolü

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSendPressed,
    this.focusNode,
    this.enabled = true, // Varsayılan: aktif
  });

  // Eski parametre uyumluluğu için factory constructor
  factory ChatInput.withOnSend({
    Key? key,
    required TextEditingController controller,
    required VoidCallback onSend,
    FocusNode? focusNode,
    bool enabled = true,
  }) {
    return ChatInput(
      key: key,
      controller: controller,
      onSendPressed: onSend,
      focusNode: focusNode,
      enabled: enabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
        ),
      ),
      // Alt güvenli alan (Home Indicator)
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1.0 : 0.5,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // --- (+) BUTONU ---
              Container(
                margin: const EdgeInsets.only(right: 8, bottom: 3),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  shape: BoxShape.circle,
                  border: isDark ? Border.all(color: Colors.white12) : null,
                  boxShadow: isDark
                      ? []
                      : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: enabled
                        ? () {
                            HapticFeedback.lightImpact();
                            // Fotoğraf/medya ekleme işlevi
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(Icons.add_rounded, color: enabled ? theme.primaryColor : theme.disabledColor, size: 24),
                    ),
                  ),
                ),
              ),

              // --- YAZI ALANI ---
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 100),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: isDark ? Border.all(color: Colors.white12, width: 0.5) : null,
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    enabled: enabled,
                    minLines: 1,
                    maxLines: 5,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                    ),
                    cursorColor: theme.primaryColor,
                    textInputAction: TextInputAction.send,
                    onSubmitted: enabled ? (_) => onSendPressed() : null,
                    decoration: InputDecoration(
                      hintText: enabled ? AppStrings.typeMessage : "Bekle...",
                      hintStyle: AppTextStyles.bodyLarge.copyWith(color: theme.disabledColor.withValues(alpha: 0.6)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

              // --- GÖNDER BUTONU ---
              Container(
                margin: const EdgeInsets.only(left: 8, bottom: 3),
                decoration: BoxDecoration(
                  color: enabled ? AppColors.primary : theme.disabledColor,
                  shape: BoxShape.circle,
                  boxShadow: enabled
                      ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]
                      : [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: enabled ? onSendPressed : null,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}