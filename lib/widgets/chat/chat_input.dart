import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/neer_design_system.dart';
import '../../core/app_strings.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendPressed;
  final FocusNode? focusNode;
  final bool enabled;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSendPressed,
    this.focusNode,
    this.enabled = true,
  });

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.5,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // (+) Button
            Container(
              margin: const EdgeInsets.only(right: 8, bottom: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.35),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.5),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: enabled
                      ? () {
                          HapticFeedback.lightImpact();
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.add_rounded,
                      color: enabled ? theme.primaryColor : theme.disabledColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),

            // Text field — glass capsule
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 100),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.30),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: enabled,
                  minLines: 1,
                  maxLines: 5,
                  style: NeerTypography.bodyLarge.copyWith(
                    color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                  ),
                  cursorColor: theme.primaryColor,
                  textInputAction: TextInputAction.send,
                  onSubmitted: enabled ? (_) => onSendPressed() : null,
                  decoration: InputDecoration(
                    hintText: enabled ? AppStrings.typeMessage : "Bekle...",
                    hintStyle: NeerTypography.bodyLarge.copyWith(
                      color: theme.disabledColor.withValues(alpha: 0.6),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // Send button
            Container(
              margin: const EdgeInsets.only(left: 8, bottom: 3),
              decoration: BoxDecoration(
                color: enabled ? NeerColors.primary : theme.disabledColor,
                shape: BoxShape.circle,
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: NeerColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
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
    );
  }
}
