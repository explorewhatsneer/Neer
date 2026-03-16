import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:intl/intl.dart';

// CORE IMPORTLARI
import '../../core/theme_styles.dart';
import '../../core/text_styles.dart';
import '../../core/constants.dart';
import '../../core/app_strings.dart';

import '../../models/post_model.dart';
import '../../services/supabase_service.dart';

// ==========================================
// YARDIMCI: AKILLI ZAMAN FORMATLAYICI ⏰
// ==========================================
String _formatTimeAgo(DateTime date) {
  final localDate = date.toLocal(); 
  final now = DateTime.now();
  final difference = now.difference(localDate);

  if (difference.inSeconds < 60) {
    return AppStrings.justNow;
  } else if (difference.inMinutes < 60) {
    return "${difference.inMinutes} ${AppStrings.minAgo}";
  } else if (difference.inHours < 24) {
    return "${difference.inHours} ${AppStrings.hourAgo}";
  } else if (difference.inDays < 7) {
    return "${difference.inDays} ${AppStrings.dayAgo}";
  } else {
    return DateFormat('dd MMM').format(localDate); 
  }
}

// ==========================================
// 1. STORY WIDGET (PREMIUM)
// ==========================================
class StoryItem extends StatelessWidget {
  final int index;
  const StoryItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    bool isMe = index == 0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Auth kullanıcısı resmini al
    final user = SupabaseService().client.auth.currentUser;
    final userImage = user?.userMetadata?['avatar_url'] ?? "https://i.pravatar.cc/150?img=1";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8), 
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Dış Halka (Gradient)
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isMe 
                    ? null 
                    : const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark], 
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                  border: isMe ? Border.all(color: theme.dividerColor.withValues(alpha: 0.2), width: 1.5) : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.5), 
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor, 
                      shape: BoxShape.circle
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: CircleAvatar(
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        backgroundImage: NetworkImage(isMe ? userImage : "https://i.pravatar.cc/150?img=${index + 15}"),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Ekle Butonu (+)
              if (isMe)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor, 
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.scaffoldBackgroundColor, width: 2.5), 
                    ),
                    child: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6), 
          
          // İsim
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 74),
            child: Text(
              isMe ? AppStrings.yourStory : "${AppStrings.user} $index",
              maxLines: 1, 
              overflow: TextOverflow.ellipsis, 
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 2. ORTAK AKSİYON SATIRI (Like, Comment, Share)
// ==========================================
class FeedActionRow extends StatelessWidget {
  final String likes;
  final String comments;
  final bool isLiked;
  final Function(String) onAction;

  const FeedActionRow({
    super.key, 
    required this.likes, 
    required this.comments,
    required this.isLiked,
    required this.onAction
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, 
        children: [
          _buildButton(
            context,
            isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded, 
            likes, 
            () => onAction("like"),
            color: isLiked ? Colors.redAccent : theme.iconTheme.color!
          ),
          const SizedBox(width: 24),
          _buildButton(context, Icons.chat_bubble_outline_rounded, comments, () => onAction("comment"), color: theme.iconTheme.color!),
          const SizedBox(width: 24),
          _buildButton(context, Icons.send_rounded, null, () => onAction("share"), color: theme.iconTheme.color!), 
          const Spacer(), 
          _buildButton(context, Icons.bookmark_border_rounded, null, () => onAction("save"), color: theme.iconTheme.color!),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, IconData icon, String? label, VoidCallback onTap, {required Color color}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, 
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 26, color: color), 
          if (label != null) ...[
            const SizedBox(width: 6),
            Text(
              label, 
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700)
            ),
          ]
        ],
      ),
    );
  }
}

// ==========================================
// 3. KART BAŞLIĞI (Header)
// ==========================================
class FeedCardHeader extends StatelessWidget {
  final String avatarUrl;
  final String userName;
  final String actionText;
  final String venueName;
  final String time;

  const FeedCardHeader({
    super.key,
    required this.avatarUrl,
    required this.userName,
    required this.actionText,
    required this.venueName,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20, 
            backgroundImage: NetworkImage(avatarUrl.isNotEmpty ? avatarUrl : "https://i.pravatar.cc/150"),
            backgroundColor: theme.cardColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis, 
                  text: TextSpan(
                    style: AppTextStyles.bodySmall.copyWith(
                        color: theme.textTheme.bodyLarge?.color 
                    ),
                    children: [
                      TextSpan(text: userName, style: const TextStyle(fontWeight: FontWeight.w700)), // Bold
                      TextSpan(text: " $actionText ", style: TextStyle(color: theme.disabledColor)),
                      if (venueName.isNotEmpty)
                        TextSpan(text: venueName, style: TextStyle(fontWeight: FontWeight.w700, color: theme.primaryColor)),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time, 
                  style: AppTextStyles.caption.copyWith(color: theme.disabledColor)
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.more_horiz_rounded, color: theme.disabledColor),
        ],
      ),
    );
  }
}

// ==========================================
// 4. 🔥 AKILLI POST KARTI (CHECK-IN)
// ==========================================
class FeedPostCard extends StatefulWidget {
  final PostModel post; 

  const FeedPostCard({super.key, required this.post});

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  final String currentUid = SupabaseService().client.auth.currentUser?.id ?? "";
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.likes.contains(currentUid);
  }

  void _onAction(String type) {
    if (type == "like") {
      HapticFeedback.lightImpact(); 
      setState(() => isLiked = !isLiked);
      // TODO: SQL 'likes' update eklenecek
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String timeAgo = _formatTimeAgo(widget.post.createdAt);
    
    String displayImage = (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty) 
        ? widget.post.imageUrl! 
        : "https://picsum.photos/600/400?blur=2";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FeedCardHeader(
          avatarUrl: widget.post.userImage, 
          userName: widget.post.userName, 
          actionText: AppStrings.checkedInAction, 
          venueName: widget.post.locationName, 
          time: timeAgo
        ),
        
        // Görsel
        Image.network(displayImage, height: 400, width: double.infinity, fit: BoxFit.cover),

        FeedActionRow(
          likes: "${widget.post.likeCount + (isLiked && !widget.post.likes.contains(currentUid) ? 1 : 0)}", 
          comments: "${widget.post.commentCount}", 
          isLiked: isLiked, 
          onAction: _onAction
        ),

        if (widget.post.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: RichText(
              maxLines: 3, 
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: AppTextStyles.bodyLarge.copyWith(
                  height: 1.4, 
                  color: theme.textTheme.bodyLarge?.color
                ),
                children: [
                  TextSpan(text: widget.post.userName, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const TextSpan(text: " "),
                  TextSpan(text: widget.post.content),
                ],
              ),
            ),
          ),

        Divider(height: 1, thickness: 0.5, color: theme.dividerColor.withValues(alpha: 0.2)),
      ],
    );
  }
}

// ==========================================
// 5. 🔥 AKILLI REVIEW KARTI (DEĞERLENDİRME)
// ==========================================
class FeedReviewCard extends StatefulWidget {
  final PostModel post;

  const FeedReviewCard({super.key, required this.post});

  @override
  State<FeedReviewCard> createState() => _FeedReviewCardState();
}

class _FeedReviewCardState extends State<FeedReviewCard> {
  final String currentUid = SupabaseService().client.auth.currentUser?.id ?? "";
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.likes.contains(currentUid);
  }

  void _onAction(String type) {
    if (type == "like") {
      HapticFeedback.lightImpact();
      setState(() => isLiked = !isLiked);
      // TODO: SQL 'likes' update eklenecek
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    String timeAgo = _formatTimeAgo(widget.post.createdAt);
    int rating = (widget.post.rating ?? 0).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FeedCardHeader(
          avatarUrl: widget.post.userImage, 
          userName: widget.post.userName, 
          actionText: AppStrings.reviewedAction, 
          venueName: widget.post.locationName,
          time: timeAgo
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.cardColor, 
              borderRadius: BorderRadius.circular(16),
              border: isDark ? Border.all(color: Colors.white12) : null,
              boxShadow: isDark ? [] : AppThemeStyles.shadowLow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (index) => Icon(
                    Icons.star_rounded, 
                    color: index < rating ? const Color(0xFFFFB400) : theme.disabledColor.withValues(alpha: 0.3), 
                    size: 22
                  )),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.post.reviewComment ?? AppStrings.noComment, 
                  style: AppTextStyles.bodyLarge.copyWith(height: 1.4)
                ),
              ],
            ),
          ),
        ),

        FeedActionRow(
          likes: "${widget.post.likeCount + (isLiked && !widget.post.likes.contains(currentUid) ? 1 : 0)}", 
          comments: "${widget.post.commentCount}", 
          isLiked: isLiked, 
          onAction: _onAction
        ),

        Divider(height: 1, thickness: 0.5, color: theme.dividerColor.withValues(alpha: 0.2)),
      ],
    );
  }
}