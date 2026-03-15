import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

// CORE
import '../../core/theme_styles.dart'; 
import '../../core/text_styles.dart';
import '../../core/app_strings.dart'; 

class NotificationTile extends StatelessWidget {
  final dynamic id; // int veya String gelebilir
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
    
    // ID'yi güvenli bir şekilde String'e çeviriyoruz
    final String safeId = id.toString(); 

    final unreadColor = isDark 
        ? theme.primaryColor.withValues(alpha: 0.1) 
        : const Color(0xFFE0F7FA);

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
          color: theme.colorScheme.error,
          borderRadius: AppThemeStyles.radius16,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? theme.cardColor : unreadColor, 
          borderRadius: AppThemeStyles.radius16,
          boxShadow: isDark ? [] : AppThemeStyles.shadowLow,
          border: isRead 
              ? (isDark ? Border.all(color: Colors.white12) : null)
              : Border.all(color: theme.primaryColor.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(theme),
            const SizedBox(width: 16),
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
                          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time, 
                        style: AppTextStyles.caption.copyWith(color: theme.disabledColor, fontWeight: FontWeight.w600)
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body, 
                    style: AppTextStyles.bodyLarge.copyWith(height: 1.4, fontSize: 14, fontWeight: FontWeight.w600, color: theme.textTheme.bodyMedium?.color),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    // Sistem bildirimi veya resim yoksa ikon göster
    if (type == AppStrings.system || imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.dividerColor.withValues(alpha: 0.1), 
          shape: BoxShape.circle
        ),
        child: Icon(Icons.notifications_active_rounded, color: theme.primaryColor, size: 24),
      );
    } 
    
    // Resim varsa göster
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: theme.scaffoldBackgroundColor,
            backgroundImage: NetworkImage(imageUrl!),
          ),
        ),
        // Sağ alt köşe ikonu (opsiyonel)
        Positioned(
          bottom: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.cardColor, 
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
            ),
            child: Icon(
              type == AppStrings.friendRequest ? Icons.person_add_rounded : Icons.location_on_rounded,
              size: 14,
              color: type == AppStrings.friendRequest ? Colors.blue : Colors.orange,
            ),
          ),
        )
      ],
    );
  }
}