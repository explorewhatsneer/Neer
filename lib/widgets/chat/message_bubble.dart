import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants.dart';
import '../../core/text_styles.dart';

/// Glass Morphism Message Bubble — VisionOS style.
///
/// Sender (isMe): primary-tinted glass capsule with higher alpha.
/// Receiver: frosted glass capsule with sigma 45 backdrop blur.
class MessageBubble extends StatelessWidget {
  final String message;
  final DateTime? timestamp;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String time = "";
    if (timestamp != null) {
      time = DateFormat('HH:mm').format(timestamp!);
    }

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(6),
      bottomRight: isMe ? const Radius.circular(6) : const Radius.circular(20),
    );

    // Glass colors
    final bgColor = isMe
        ? (isDark
            ? AppColors.primary.withValues(alpha: 0.25)
            : AppColors.primary.withValues(alpha: 0.18))
        : (isDark
            ? AppColors.darkSurface.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.28));

    final textColor = isDark ? Colors.white : (isMe ? Colors.white : Colors.black87);
    final timeColor = isMe
        ? Colors.white.withValues(alpha: 0.6)
        : (isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.35));

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: borderRadius,
                border: Border.all(
                  color: isMe
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.18),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: textColor,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: AppTextStyles.caption.copyWith(
                          color: timeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all_rounded,
                          size: 15,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
