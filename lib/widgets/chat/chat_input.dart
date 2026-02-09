import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

// CORE IMPORTLARI
import '../../core/constants.dart';
import '../../core/text_styles.dart'; 
import '../../core/app_strings.dart'; // Strings eklendi

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendPressed;
  final FocusNode? focusNode;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSendPressed,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      // Padding biraz daha ferahlatıldı
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), 
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor, 
        border: Border(
          // Core Divider rengi kullanıldı
          top: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
        ),
      ),
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
              boxShadow: isDark ? [] : [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Buraya fotoğraf/medya ekleme işlevi gelebilir
                },
                child: Padding(
                  padding: const EdgeInsets.all(10), 
                  child: Icon(Icons.add_rounded, color: theme.primaryColor, size: 24),
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
                minLines: 1,
                maxLines: 5,
                // 🔥 Core Style: Yazılan mesaj SF Pro (w400) olsun
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.darkTextHeading : AppColors.lightTextHeading
                ),
                cursorColor: theme.primaryColor,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: AppStrings.typeMessage, // 🔥 Core String
                  // Hint rengi biraz daha soluk (Caption stili)
                  hintStyle: AppTextStyles.bodyLarge.copyWith(
                    color: theme.disabledColor,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12), 
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // --- GÖNDER BUTONU ---
          Container(
            margin: const EdgeInsets.only(bottom: 3),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  if (controller.text.trim().isNotEmpty) {
                    HapticFeedback.mediumImpact();
                    onSendPressed();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(10), 
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}