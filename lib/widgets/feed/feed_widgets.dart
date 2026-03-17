import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// CORE IMPORTLARI
import '../../core/theme_styles.dart';
import '../../core/text_styles.dart';
import '../../core/constants.dart';
import '../../core/app_strings.dart';

import '../../models/post_model.dart';
import '../../services/supabase_service.dart';
import '../common/app_cached_image.dart';

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
// 1. STORY WIDGET (Glass Morphism - Rounded Square)
// ==========================================
class StoryItem extends StatelessWidget {
  final int index;
  const StoryItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    bool isMe = index == 0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final user = SupabaseService().client.auth.currentUser;
    final userImage = user?.userMetadata?['avatar_url'] ?? "https://i.pravatar.cc/150?img=1";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Glass Story Container (Rounded Square)
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              // Dashed border effect via gradient border
              gradient: isMe
                  ? null
                  : const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              border: isMe
                  ? Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.25),
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    )
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.all(isMe ? 0 : 2.5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isMe ? 22 : 19),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Avatar Image
                    AppCachedImage.cover(
                      imageUrl: isMe ? userImage : "https://i.pravatar.cc/150?img=${index + 15}",
                      borderRadius: 0,
                    ),
                    // Glass overlay for "add" story
                    if (isMe)
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.20)
                              : Colors.white.withValues(alpha: 0.15),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withValues(alpha: 0.40),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // İsim
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 74),
            child: Text(
              isMe ? AppStrings.yourStory : "${AppStrings.user} $index",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 2. ORTAK AKSİYON SATIRI (Glass Style)
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
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _buildButton(
            context,
            isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            likes,
            () => onAction("like"),
            color: isLiked ? AppColors.error : theme.textTheme.bodyLarge?.color ?? Colors.grey,
          ),
          const SizedBox(width: 20),
          _buildButton(
            context,
            Icons.chat_bubble_outline_rounded,
            comments,
            () => onAction("comment"),
            color: theme.textTheme.bodyLarge?.color ?? Colors.grey,
          ),
          const SizedBox(width: 20),
          _buildButton(
            context,
            Icons.send_rounded,
            null,
            () => onAction("share"),
            color: theme.textTheme.bodyLarge?.color ?? Colors.grey,
          ),
          const Spacer(),
          _buildButton(
            context,
            Icons.bookmark_border_rounded,
            null,
            () => onAction("save"),
            color: theme.textTheme.bodyLarge?.color ?? Colors.grey,
          ),
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
          Icon(icon, size: 24, color: color),
          if (label != null) ...[
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ]
        ],
      ),
    );
  }
}

// ==========================================
// 3. KART BAŞLIĞI (Glass Header)
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
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Row(
        children: [
          CachedAvatar(imageUrl: avatarUrl, name: userName, radius: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: AppTextStyles.caption.copyWith(
                    color: theme.disabledColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.more_horiz_rounded, color: theme.disabledColor, size: 18),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. 🔥 GLASS POST KARTI (CHECK-IN)
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    String timeAgo = _formatTimeAgo(widget.post.createdAt);

    String displayImage = (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty)
        ? widget.post.imageUrl!
        : "https://picsum.photos/600/400?blur=2";

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.50)
                : Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.70),
              width: 1,
            ),
            boxShadow: AppColors.adaptiveShadow(isDark, blur: 20, alpha: 0.06),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FeedCardHeader(
                avatarUrl: widget.post.userImage,
                userName: widget.post.userName,
                actionText: AppStrings.checkedInAction,
                venueName: widget.post.locationName,
                time: timeAgo,
              ),

              // Görsel (Rounded)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AppCachedImage.cover(imageUrl: displayImage, height: 280, borderRadius: 0),
                ),
              ),

              FeedActionRow(
                likes: "${widget.post.likeCount + (isLiked && !widget.post.likes.contains(currentUid) ? 1 : 0)}",
                comments: "${widget.post.commentCount}",
                isLiked: isLiked,
                onAction: _onAction,
              ),

              if (widget.post.content.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: RichText(
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: AppTextStyles.bodySmall.copyWith(
                        height: 1.4,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      children: [
                        TextSpan(text: widget.post.userName, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const TextSpan(text: " "),
                        TextSpan(text: widget.post.content),
                      ],
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

// ==========================================
// 5. 🔥 GLASS REVIEW KARTI (DEĞERLENDİRME)
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    String timeAgo = _formatTimeAgo(widget.post.createdAt);
    int rating = (widget.post.rating ?? 0).toInt();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.50)
                : Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.70),
              width: 1,
            ),
            boxShadow: AppColors.adaptiveShadow(isDark, blur: 20, alpha: 0.06),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FeedCardHeader(
                avatarUrl: widget.post.userImage,
                userName: widget.post.userName,
                actionText: AppStrings.reviewedAction,
                venueName: widget.post.locationName,
                time: timeAgo,
              ),

              // Review Container (Glass içinde glass)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppColors.gradientStart.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.white.withValues(alpha: 0.50),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) => Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Icon(
                            Icons.star_rounded,
                            color: index < rating ? AppColors.warning : theme.disabledColor.withValues(alpha: 0.2),
                            size: 20,
                          ),
                        )),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.post.reviewComment ?? AppStrings.noComment,
                        style: AppTextStyles.bodySmall.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              FeedActionRow(
                likes: "${widget.post.likeCount + (isLiked && !widget.post.likes.contains(currentUid) ? 1 : 0)}",
                comments: "${widget.post.commentCount}",
                isLiked: isLiked,
                onAction: _onAction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
