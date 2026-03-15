import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// CORE IMPORTLARI
import '../../core/text_styles.dart'; 

class MessageBubble extends StatelessWidget {
  final String message;
  // 🔥 GÜNCELLEME: Firebase Timestamp yerine standart DateTime
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

    // Zamanı formatla
    String time = "";
    if (timestamp != null) {
      // .toDate() kaldırıldı çünkü artık zaten DateTime
      time = DateFormat('HH:mm').format(timestamp!);
    }

    // Renk Tanımları
    final bubbleColor = isMe 
        ? theme.primaryColor 
        : (isDark ? const Color(0xFF262628) : Colors.white); 
    
    final textColor = isMe 
        ? Colors.white 
        : theme.textTheme.bodyLarge?.color; 

    final timeColor = isMe 
        ? Colors.white.withOpacity(0.7)
        : theme.disabledColor;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8), 
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), 
        decoration: BoxDecoration(
          color: bubbleColor, 
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
          ),
          // Sadece karşı tarafın mesajı ve dark modda sınır çizgisi olsun
          border: (!isMe && isDark) ? Border.all(color: Colors.white12, width: 0.5) : null,
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), 
              blurRadius: 4, 
              offset: const Offset(0, 2)
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end, 
          children: [
            // --- MESAJ METNİ ---
            Text(
              message,
              // 🔥 Core Style: bodyLarge
              style: AppTextStyles.bodyLarge.copyWith(
                color: textColor,
                height: 1.35 // Satır aralığı
              ),
            ),
            
            const SizedBox(height: 4),
            
            // --- ZAMAN VE TİK ---
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  // 🔥 Core Style: Caption
                  style: AppTextStyles.caption.copyWith(
                    color: timeColor,
                    fontSize: 11, 
                    fontWeight: FontWeight.w500
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all_rounded, 
                    size: 15, 
                    color: Colors.white.withOpacity(0.9)
                  )
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}