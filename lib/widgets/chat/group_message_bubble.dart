import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// CORE IMPORTLARI
import '../../core/text_styles.dart';
import '../common/app_cached_image.dart';

class GroupMessageBubble extends StatelessWidget {
  final String message;
  final String senderName;
  final String senderImage; // Avatar URL
  // 🔥 GÜNCELLEME: Firebase Timestamp yerine standart DateTime
  final DateTime? timestamp; 
  final bool isMe;

  const GroupMessageBubble({
    super.key,
    required this.message,
    required this.senderName,
    required this.senderImage,
    required this.timestamp,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Zamanı formatla
    String time = "";
    if (timestamp != null) {
      // .toDate() kaldırıldı çünkü artık zaten DateTime
      time = DateFormat('HH:mm').format(timestamp!);
    }

    // Renkler
    final bubbleColor = isMe 
        ? theme.primaryColor 
        : (isDark ? const Color(0xFF2C2C2E) : Colors.white);
    
    final textColor = isMe 
        ? Colors.white 
        : theme.textTheme.bodyLarge?.color;
        
    final timeColor = isMe 
        ? Colors.white70 
        : theme.disabledColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end, 
        children: [
          
          // 🔥 BAŞKASIYSA: SOLDA AVATAR GÖSTER
          if (!isMe) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CachedAvatar(imageUrl: senderImage, name: senderName, radius: 16),
            ),
          ],

          // BALONCUK
          Flexible(
            fit: FlexFit.loose, 
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bubbleColor, 
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: isDark ? [] : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05), 
                    blurRadius: 5, 
                    offset: const Offset(0, 2)
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, 
                children: [
                  
                  // 🔥 BAŞKASIYSA: İSMİ RENKLİ YAZ
                  if (!isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        senderName,
                        style: AppTextStyles.caption.copyWith(
                          color: theme.primaryColor, // Temanın ana rengi
                          fontWeight: FontWeight.w700, // Kalın olsun ki isim olduğu belli olsun
                          fontSize: 12
                        ),
                      ),
                    ),
                  
                  // MESAJ METNİ
                  Text(
                    message,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: textColor,
                      height: 1.4 // Satır aralığı
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // SAAT VE TİK
                  Row(
                    mainAxisSize: MainAxisSize.min, 
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        time,
                        style: AppTextStyles.caption.copyWith(
                          color: timeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all_rounded, 
                          size: 14, 
                          color: Colors.white.withValues(alpha: 0.9)
                        )
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}