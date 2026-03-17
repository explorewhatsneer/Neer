import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import '../core/text_styles.dart';
import '../core/theme_styles.dart';
import '../core/app_strings.dart';
import '../core/app_router.dart';
import '../core/snackbar_helper.dart';
import '../providers/catch_provider.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/animated_list_item.dart';
import '../widgets/common/app_cached_image.dart';

class CatchScreen extends StatefulWidget {
  const CatchScreen({super.key});

  @override
  State<CatchScreen> createState() => _CatchScreenState();
}

class _CatchScreenState extends State<CatchScreen> {
  final _supabase = Supabase.instance.client;
  StreamSubscription? _incomingCatchSub;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  Future<void> _initProvider() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final provider = context.read<CatchProvider>();
    if (!_initialized) {
      await provider.init(userId);
      _initialized = true;
    }

    // Gelen catch'leri dinle (bottom sheet göstermek için — UI sorumluluğu)
    _incomingCatchSub = provider.streamIncomingCatches(userId).listen((catches) {
      if (catches.isNotEmpty && mounted) {
        _showIncomingCatchSheet(catches.first);
      }
    });
  }

  @override
  void dispose() {
    _incomingCatchSub?.cancel();
    super.dispose();
  }

  // ═══════════════════════════════════════════
  // ACTIONS (UI → Provider)
  // ═══════════════════════════════════════════

  void _showDurationPicker() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppStrings.selectDuration, style: AppTextStyles.h3),
              const SizedBox(height: 20),
              _durationOption(ctx, AppStrings.min30, 30),
              _durationOption(ctx, AppStrings.hour1, 60),
              _durationOption(ctx, AppStrings.hour2, 120),
              _durationOption(ctx, AppStrings.hour4, 240),
            ],
          ),
        ),
      ),
    );
  }

  Widget _durationOption(BuildContext ctx, String label, int minutes) {
    final theme = Theme.of(ctx);
    return ListTile(
      title: Text(label, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
      leading: Icon(Icons.timer_outlined, color: theme.primaryColor),
      shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius16),
      onTap: () async {
        Navigator.pop(ctx);
        HapticFeedback.mediumImpact();
        final result = await context.read<CatchProvider>().setAvailable(minutes);
        if (mounted) {
          result.ifFailure((e) => AppSnackBar.error(context, e.message));
        }
      },
    );
  }

  Future<void> _handleBusy() async {
    HapticFeedback.mediumImpact();
    final result = await context.read<CatchProvider>().setBusy();
    if (mounted) {
      result.ifFailure((e) => AppSnackBar.error(context, e.message));
    }
  }

  Future<void> _sendCatch(String receiverId) async {
    HapticFeedback.mediumImpact();
    final result = await context.read<CatchProvider>().sendCatch(receiverId);
    if (!mounted) return;
    result.when(
      success: (_) => AppSnackBar.success(context, AppStrings.catchSent),
      failure: (error) => AppSnackBar.error(context, error.message),
    );
  }

  Future<void> _toggleWatch(String targetId) async {
    HapticFeedback.selectionClick();
    final result = await context.read<CatchProvider>().toggleWatch(targetId);
    if (mounted) {
      result.ifFailure((e) => AppSnackBar.error(context, e.message));
    }
  }

  Future<void> _callFriend(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    HapticFeedback.mediumImpact();
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showIncomingCatchSheet(Map<String, dynamic> catchData) async {
    final senderId = catchData['sender_id'];
    Map<String, dynamic>? senderProfile;
    try {
      senderProfile = await _supabase
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('id', senderId)
          .single();
    } catch (_) {}

    if (!mounted) return;

    final theme = Theme.of(context);
    final senderName = senderProfile?['full_name'] ?? 'Biri';
    final senderAvatar = senderProfile?['avatar_url'] ?? '';
    final catchId = catchData['id'];
    final provider = context.read<CatchProvider>();

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedAvatar(imageUrl: senderAvatar, name: senderName, radius: 40),
              const SizedBox(height: 16),
              Text(AppStrings.incomingCatch, style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text(
                '$senderName ${AppStrings.wantsToMeet}',
                style: AppTextStyles.bodyLarge.copyWith(color: theme.disabledColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Reddet
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          HapticFeedback.mediumImpact();
                          final r = await provider.rejectCatch(catchId);
                          if (ctx.mounted) Navigator.pop(ctx);
                          r.ifFailure((e) {
                            if (mounted) AppSnackBar.error(context, e.message);
                          });
                        },
                        icon: const Icon(Icons.close_rounded, color: Color(0xFFEF4444)),
                        label: Text(AppStrings.decline, style: AppTextStyles.button.copyWith(color: const Color(0xFFEF4444))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Kabul et
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          HapticFeedback.heavyImpact();
                          final r = await provider.acceptCatch(catchId);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            r.when(
                              success: (_) => AppSnackBar.success(context, AppStrings.catchAccepted),
                              failure: (e) => AppSnackBar.error(context, e.message),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_rounded, color: Colors.white),
                        label: Text(AppStrings.accept, style: AppTextStyles.button),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<CatchProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(AppStrings.catchTitle, style: AppTextStyles.h1.copyWith(fontSize: 32)),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
      ),
      body: provider.isLoading
          ? Column(
              children: [
                _buildStatusCard(theme, isDark, provider),
                const Expanded(child: ShimmerGrid(itemCount: 4)),
              ],
            )
          : Column(
              children: [
                _buildStatusCard(theme, isDark, provider),
                Expanded(
                  child: provider.friends.isEmpty
                      ? _buildEmptyState(theme)
                      : _buildFriendGrid(theme, isDark, provider),
                ),
              ],
            ),
    );
  }

  // ═══════════════════════════════════════════
  // STATUS CARD
  // ═══════════════════════════════════════════

  Widget _buildStatusCard(ThemeData theme, bool isDark, CatchProvider provider) {
    final isAvailable = provider.myStatus == 'available';
    final statusColor = isAvailable ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    String remainingText = '';
    if (isAvailable && provider.availableUntil != null) {
      final diff = provider.availableUntil!.difference(DateTime.now());
      if (!diff.isNegative) {
        if (diff.inHours > 0) {
          remainingText = '${diff.inHours}s ${diff.inMinutes % 60}dk';
        } else {
          remainingText = '${diff.inMinutes}dk';
        }
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppThemeStyles.radius24,
        boxShadow: isDark ? [] : AppThemeStyles.shadowLow,
        border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: statusColor.withValues(alpha: 0.4), blurRadius: 8)],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAvailable ? AppStrings.youAreAvailable : AppStrings.youAreBusy,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 17),
                ),
                if (remainingText.isNotEmpty)
                  Text(
                    '${AppStrings.remainingTime}: $remainingText',
                    style: AppTextStyles.caption.copyWith(color: theme.disabledColor),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: isAvailable ? _handleBusy : _showDurationPicker,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAvailable ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
                shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius16),
                elevation: 0,
              ),
              child: Text(
                isAvailable ? AppStrings.goBusy : AppStrings.beAvailable,
                style: AppTextStyles.button.copyWith(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // FRIEND GRID
  // ═══════════════════════════════════════════

  Widget _buildFriendGrid(ThemeData theme, bool isDark, CatchProvider provider) {
    final sorted = provider.sortedFriends;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.75,
      ),
      itemCount: sorted.length,
      itemBuilder: (context, index) => AnimatedListItem(
        index: index,
        child: _buildFriendCard(sorted[index], theme, isDark, provider),
      ),
    );
  }

  Widget _buildFriendCard(Map<String, dynamic> friend, ThemeData theme, bool isDark, CatchProvider provider) {
    final friendId = friend['id'] as String;
    final name = friend['full_name'] ?? AppStrings.nameless;
    final avatar = friend['avatar_url'] ?? '';
    final status = friend['status'] ?? 'busy';
    final phoneNumber = friend['phone_number']?.toString();
    final isAvailable = status == 'available';
    final isPending = status == 'pending';
    final isWatched = provider.watchedIds.contains(friendId);
    final cooldown = provider.cooldowns[friendId] ?? 0;
    final showAcceptedAnim = provider.acceptedCatchReceiverId == friendId;

    Color statusColor;
    if (isAvailable) {
      statusColor = const Color(0xFF22C55E);
    } else if (isPending) {
      statusColor = const Color(0xFFFBBF24);
    } else {
      statusColor = const Color(0xFFEF4444);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: showAcceptedAnim
              ? const Color(0xFF22C55E)
              : statusColor.withValues(alpha: isAvailable ? 1.0 : 0.5),
          width: isAvailable ? 3.5 : 2.5,
        ),
        boxShadow: isAvailable
            ? [BoxShadow(color: statusColor.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 4))]
            : (isDark ? [] : AppThemeStyles.shadowLow),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ═══ BÜYÜK PROFİL FOTOĞRAFI ═══
            avatar.isNotEmpty
                ? AppCachedImage(
                    imageUrl: avatar,
                    fit: BoxFit.cover,
                    errorWidget: _buildAvatarPlaceholder(name, theme),
                  )
                : _buildAvatarPlaceholder(name, theme),

            // ═══ ALT GRADIENT ═══
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),

            // ═══ ACCEPTED ANİMASYON OVERLAY ═══
            if (showAcceptedAnim)
              Container(
                color: const Color(0xFF22C55E).withValues(alpha: 0.25),
                child: const Center(
                  child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 52),
                ),
              ),

            // ═══ ÜST SAĞ: ZİL ═══
            Positioned(
              top: 8,
              right: 8,
              child: _buildCardIcon(
                icon: isWatched ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                color: isWatched ? const Color(0xFFFBBF24) : Colors.white,
                onTap: () => _toggleWatch(friendId),
              ),
            ),

            // ═══ ÜST SOL: TELEFON ═══
            if (isAvailable && phoneNumber != null && phoneNumber.isNotEmpty)
              Positioned(
                top: 8,
                left: 8,
                child: _buildCardIcon(
                  icon: Icons.phone_rounded,
                  color: const Color(0xFF22C55E),
                  onTap: () => _callFriend(phoneNumber),
                ),
              ),

            // ═══ ALT KISIM: İSİM + DURUM + 3 BUTON ═══
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAvailable
                          ? AppStrings.available
                          : (isPending ? AppStrings.pendingStatus : AppStrings.busy),
                      style: AppTextStyles.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ═══ 3 BUTON SATIRI ═══
                    Row(
                      children: [
                        Expanded(
                          child: _buildCardAction(
                            icon: Icons.person_rounded,
                            color: Colors.white,
                            bgColor: Colors.white.withValues(alpha: 0.15),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              context.push('/profile/$friendId');
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildCardAction(
                            icon: Icons.chat_bubble_rounded,
                            color: Colors.white,
                            bgColor: Colors.white.withValues(alpha: 0.15),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              context.push(AppRoutes.chat, extra: {'userId': friendId, 'userName': name, 'userImage': avatar.isNotEmpty ? avatar : null});
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: cooldown > 0 && !showAcceptedAnim
                              ? _buildCardAction(
                                  label: '${cooldown ~/ 60}:${(cooldown % 60).toString().padLeft(2, '0')}',
                                  color: Colors.white54,
                                  bgColor: Colors.white.withValues(alpha: 0.1),
                                  onTap: () {},
                                  isTimer: true,
                                )
                              : _buildCardAction(
                                  icon: Icons.bolt_rounded,
                                  color: isAvailable ? Colors.white : Colors.white38,
                                  bgColor: isAvailable
                                      ? const Color(0xFF22C55E)
                                      : Colors.white.withValues(alpha: 0.08),
                                  onTap: isAvailable && !showAcceptedAnim
                                      ? () => _sendCatch(friendId)
                                      : () {},
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardAction({
    IconData? icon,
    String? label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
    bool isTimer = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: label != null
              ? Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    fontFeatures: isTimer ? const [FontFeature.tabularFigures()] : null,
                  ),
                )
              : Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  Widget _buildCardIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name, ThemeData theme) {
    return Container(
      color: theme.disabledColor.withValues(alpha: 0.15),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: theme.disabledColor.withValues(alpha: 0.5),
            fontSize: 48,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════

  Widget _buildEmptyState(ThemeData theme) {
    return EmptyState(
      icon: Icons.people_outline_rounded,
      title: AppStrings.noFriendsForCatch,
      description: AppStrings.noFriendsForCatchDesc,
    );
  }
}
