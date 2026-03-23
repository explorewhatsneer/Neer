import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/neer_design_system.dart';
import '../../core/app_strings.dart';
import '../common/app_cached_image.dart';

/// Glass Floating Island — notification card (VisionOS style).
///
/// Unread state: subtle primary glow indicator.
/// No dividers — cards separated by padding gaps.
class NotificationTile extends StatelessWidget {
  final dynamic id;
  final String type;
  final String title;
  final String body;
  final String time;
  final String? imageUrl;
  final bool isRead;
  final Function(String) onDismiss;

  const NotificationTile({
    super.key,
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.imageUrl,
    required this.isRead,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final String safeId = id.toString();

    return Dismissible(
      key: Key(safeId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        onDismiss(safeId);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFF453A).withValues(alpha: 0.80),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? NeerColors.darkSurface.withValues(alpha: isRead ? 0.12 : 0.18)
                  : Colors.white.withValues(alpha: isRead ? 0.18 : 0.28),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isRead
                    ? Colors.white.withValues(alpha: 0.18)
                    : theme.primaryColor.withValues(alpha: 0.25),
                width: 1,
              ),
              boxShadow: [
                ...NeerShadows.soft(),
                if (!isRead)
                  BoxShadow(
                    color: theme.primaryColor.withValues(alpha: 0.08),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unread glow dot
                if (!isRead)
                  Container(
                    margin: const EdgeInsets.only(top: 4, right: 8),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                _buildIcon(theme, isDark),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: NeerTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            time,
                            style: NeerTypography.caption.copyWith(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.4)
                                  : Colors.black.withValues(alpha: 0.35),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: NeerTypography.bodyLarge.copyWith(
                          height: 1.4,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme, bool isDark) {
    if (type == AppStrings.system || imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : theme.primaryColor.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.notifications_active_rounded, color: theme.primaryColor, size: 22),
      );
    }

    return Stack(
      children: [
        CachedAvatar(imageUrl: imageUrl!, name: '', radius: 22),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark
                  ? NeerColors.darkSurface
                  : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
            ),
            child: Icon(
              type == AppStrings.friendRequest ? Icons.person_add_rounded : Icons.location_on_rounded,
              size: 12,
              color: type == AppStrings.friendRequest ? Colors.blue : Colors.orange,
            ),
          ),
        ),
      ],
    );
  }
}
