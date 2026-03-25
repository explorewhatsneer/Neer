import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import '../core/neer_design_system.dart';
import '../core/app_strings.dart';
import '../core/app_router.dart';
import '../core/snackbar_helper.dart';
import '../providers/catch_provider.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/animated_list_item.dart';
import '../widgets/common/app_cached_image.dart';
import '../widgets/common/glass_panel.dart';
import '../widgets/common/animated_press.dart';

class CatchScreen extends StatefulWidget {
  const CatchScreen({super.key});

  @override
  State<CatchScreen> createState() => _CatchScreenState();
}

class _CatchScreenState extends State<CatchScreen> {
  final _supabase = Supabase.instance.client;
  StreamSubscription? _incomingCatchSub;
  bool _initialized = false;
  String _statusFilter = 'all'; // 'all', 'available', 'pending', 'busy'

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
              Text(AppStrings.selectDuration, style: NeerTypography.h3),
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
      title: Text(label, style: NeerTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
      leading: Icon(Icons.timer_outlined, color: theme.primaryColor),
      shape: RoundedRectangleBorder(borderRadius: NeerRadius.buttonRadius),
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
              Text(AppStrings.incomingCatch, style: NeerTypography.h2),
              const SizedBox(height: 8),
              Text(
                '$senderName ${AppStrings.wantsToMeet}',
                style: NeerTypography.bodyLarge.copyWith(color: theme.disabledColor),
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
                        label: Text(AppStrings.decline, style: NeerTypography.button.copyWith(color: const Color(0xFFEF4444))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          shape: RoundedRectangleBorder(borderRadius: NeerRadius.buttonRadius),
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
                        label: Text(AppStrings.accept, style: NeerTypography.button),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          shape: RoundedRectangleBorder(borderRadius: NeerRadius.buttonRadius),
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

    return GradientScaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(AppStrings.catchTitle, style: NeerTypography.h1.copyWith(fontSize: 32)),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: provider.isLoading
          ? Column(
              children: [
                _buildStatusPanel(theme, isDark, provider),
                _buildFilterRow(theme, isDark, provider),
                const Expanded(child: ShimmerGrid(itemCount: 4)),
              ],
            )
          : provider.friends.isEmpty
              ? Column(
                  children: [
                    _buildStatusPanel(theme, isDark, provider),
                    Expanded(
                      child: EmptyState(
                        icon: Icons.people_outline_rounded,
                        title: AppStrings.noFriendsForCatch,
                        description: AppStrings.noFriendsForCatchDesc,
                      ),
                    ),
                  ],
                )
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildStatusPanel(theme, isDark, provider)),
                    SliverToBoxAdapter(child: _buildFilterRow(theme, isDark, provider)),
                    _buildFilteredGrid(isDark, provider),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
                  ],
                ),
    );
  }

  // ═══════════════════════════════════════════
  // STATUS PANEL — interactive, dynamic
  // ═══════════════════════════════════════════

  Widget _buildStatusPanel(ThemeData theme, bool isDark, CatchProvider provider) {
    final isAvailable = provider.myStatus == 'available';
    final statusColor = isAvailable ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    String remainingText = '';
    double remainingRatio = 0;
    if (isAvailable && provider.availableUntil != null) {
      final diff = provider.availableUntil!.difference(DateTime.now());
      if (!diff.isNegative) {
        if (diff.inHours > 0) {
          remainingText = '${diff.inHours}s ${diff.inMinutes % 60}dk';
        } else {
          remainingText = '${diff.inMinutes}dk';
        }
        // Approximate ratio assuming max 4h availability
        remainingRatio = (diff.inMinutes / 240).clamp(0.0, 1.0);
      }
    }

    return AnimatedPress(
      onTap: isAvailable ? _handleBusy : _showDurationPicker,
      useHeavyHaptic: true,
      child: GlassPanel(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  // Animated status ring
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(
                              isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            value: isAvailable ? remainingRatio : 0,
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(statusColor),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: statusColor.withValues(alpha: 0.5), blurRadius: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAvailable ? AppStrings.youAreAvailable : AppStrings.youAreBusy,
                          style: NeerTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 17),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isAvailable
                              ? (remainingText.isNotEmpty
                                  ? '${AppStrings.remainingTime}: $remainingText'
                                  : AppStrings.youAreAvailable)
                              : AppStrings.beAvailable,
                          style: NeerTypography.caption.copyWith(
                            color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                          : const Color(0xFF22C55E).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isAvailable ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: isAvailable ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            // Progress bar at bottom
            if (isAvailable && remainingRatio > 0)
              Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  child: LinearProgressIndicator(
                    value: remainingRatio,
                    backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                    valueColor: AlwaysStoppedAnimation(statusColor.withValues(alpha: 0.70)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // FILTER ROW — tappable chips
  // ═══════════════════════════════════════════

  Widget _buildFilterRow(ThemeData theme, bool isDark, CatchProvider provider) {
    final friends = provider.friends;
    final availableCount = friends.where((f) => f['status'] == 'available').length;
    final pendingCount = friends.where((f) => f['status'] == 'pending').length;
    final busyCount = friends.where((f) => f['status'] != 'available' && f['status'] != 'pending').length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          _FilterChip(
            label: AppStrings.all,
            count: friends.length,
            isSelected: _statusFilter == 'all',
            color: NeerColors.primary,
            isDark: isDark,
            onTap: () => _setFilter('all'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: AppStrings.available,
            count: availableCount,
            isSelected: _statusFilter == 'available',
            color: const Color(0xFF22C55E),
            isDark: isDark,
            onTap: () => _setFilter('available'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: AppStrings.pendingStatus,
            count: pendingCount,
            isSelected: _statusFilter == 'pending',
            color: const Color(0xFFFBBF24),
            isDark: isDark,
            onTap: () => _setFilter('pending'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: AppStrings.busy,
            count: busyCount,
            isSelected: _statusFilter == 'busy',
            color: const Color(0xFFEF4444),
            isDark: isDark,
            onTap: () => _setFilter('busy'),
          ),
        ],
      ),
    );
  }

  void _setFilter(String filter) {
    if (_statusFilter == filter) return;
    HapticFeedback.selectionClick();
    setState(() => _statusFilter = filter);
  }

  // ═══════════════════════════════════════════
  // FILTERED GRID
  // ═══════════════════════════════════════════

  Widget _buildFilteredGrid(bool isDark, CatchProvider provider) {
    final sorted = provider.sortedFriends;
    final filtered = _statusFilter == 'all'
        ? sorted
        : _statusFilter == 'busy'
            ? sorted.where((f) => f['status'] != 'available' && f['status'] != 'pending').toList()
            : sorted.where((f) => f['status'] == _statusFilter).toList();

    if (filtered.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          icon: Icons.filter_list_off_rounded,
          title: AppStrings.noFriendsForCatch,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => AnimatedListItem(
            index: index,
            child: _CatchCapsule(
              friend: filtered[index],
              provider: provider,
              isDark: isDark,
              onSendCatch: _sendCatch,
              onToggleWatch: _toggleWatch,
              onCallFriend: _callFriend,
            ),
          ),
          childCount: filtered.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.75,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// FILTER CHIP — tappable status filter
// ═══════════════════════════════════════════════════════

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPress(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.18)
              : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.45)
                : (isDark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.08)),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: NeerTypography.caption.copyWith(
                color: isSelected ? color : (isDark ? Colors.white70 : Colors.black54),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.25)
                    : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: NeerTypography.caption.copyWith(
                  color: isSelected ? color : (isDark ? Colors.white54 : Colors.black45),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// CATCH CAPSULE — Glass card with neon aura for available
// ═══════════════════════════════════════════════════════

class _CatchCapsule extends StatefulWidget {
  final Map<String, dynamic> friend;
  final CatchProvider provider;
  final bool isDark;
  final Future<void> Function(String) onSendCatch;
  final Future<void> Function(String) onToggleWatch;
  final Future<void> Function(String?) onCallFriend;

  const _CatchCapsule({
    required this.friend,
    required this.provider,
    required this.isDark,
    required this.onSendCatch,
    required this.onToggleWatch,
    required this.onCallFriend,
  });

  @override
  State<_CatchCapsule> createState() => _CatchCapsuleState();
}

class _CatchCapsuleState extends State<_CatchCapsule>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _glowAnimation = Tween<double>(begin: 0.15, end: 0.45).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    final status = widget.friend['status'] ?? 'busy';
    if (status == 'available') {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _CatchCapsule oldWidget) {
    super.didUpdateWidget(oldWidget);
    final status = widget.friend['status'] ?? 'busy';
    if (status == 'available' && !_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    } else if (status != 'available' && _glowController.isAnimating) {
      _glowController.stop();
      _glowController.value = 0;
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendId = widget.friend['id'] as String;
    final name = widget.friend['full_name'] ?? AppStrings.nameless;
    final avatar = widget.friend['avatar_url'] ?? '';
    final status = widget.friend['status'] ?? 'busy';
    final phoneNumber = widget.friend['phone_number']?.toString();
    final isAvailable = status == 'available';
    final isPending = status == 'pending';
    final isWatched = widget.provider.watchedIds.contains(friendId);
    final cooldown = widget.provider.cooldowns[friendId] ?? 0;
    final showAcceptedAnim = widget.provider.acceptedCatchReceiverId == friendId;

    Color statusColor;
    if (isAvailable) {
      statusColor = const Color(0xFF22C55E);
    } else if (isPending) {
      statusColor = const Color(0xFFFBBF24);
    } else {
      statusColor = const Color(0xFFEF4444);
    }

    return ListenableBuilder(
      listenable: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: isAvailable
                ? [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withValues(alpha: _glowAnimation.value),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: const Color(0xFF22C55E).withValues(alpha: _glowAnimation.value * 0.4),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ]
                : showAcceptedAnim
                    ? [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.35),
                          blurRadius: 20,
                        ),
                      ]
                    : [],
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: widget.isDark
                  ? NeerColors.darkSurface.withValues(alpha: 0.14)
                  : Colors.white.withValues(alpha: 0.22),
              border: Border.all(
                color: isAvailable
                    ? const Color(0xFF22C55E).withValues(alpha: 0.50)
                    : Colors.white.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ═══ AVATAR BACKGROUND ═══
                if (avatar.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: avatar,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _buildAvatarPlaceholder(name),
                    errorWidget: (_, __, ___) => _buildAvatarPlaceholder(name),
                  )
                else
                  _buildAvatarPlaceholder(name),

                // ═══ GRADIENT SHIELD ═══
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.50),
                        Colors.black.withValues(alpha: 0.80),
                      ],
                      stops: const [0.0, 0.3, 0.65, 1.0],
                    ),
                  ),
                ),

                // ═══ ACCEPTED OVERLAY ═══
                if (showAcceptedAnim)
                  Container(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.25),
                    child: const Center(
                      child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 52),
                    ),
                  ),

                // ═══ TOP RIGHT: WATCH BELL ═══
                Positioned(
                  top: 8,
                  right: 8,
                  child: _GlassIconButton(
                    icon: isWatched ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                    color: isWatched ? const Color(0xFFFBBF24) : Colors.white,
                    onTap: () => widget.onToggleWatch(friendId),
                  ),
                ),

                // ═══ TOP LEFT: PHONE (available only) ═══
                if (isAvailable && phoneNumber != null && phoneNumber.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _GlassIconButton(
                      icon: Icons.phone_rounded,
                      color: const Color(0xFF22C55E),
                      onTap: () => widget.onCallFriend(phoneNumber),
                    ),
                  ),

                // ═══ BOTTOM: NAME + STATUS + ACTIONS ═══
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
                          style: NeerTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.white,
                            shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 6)],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: statusColor.withValues(alpha: 0.5), blurRadius: 4)],
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isAvailable
                                  ? AppStrings.available
                                  : (isPending ? AppStrings.pendingStatus : AppStrings.busy),
                              style: NeerTypography.caption.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // ═══ 3 ACTION BUTTONS ═══
                        Row(
                          children: [
                            Expanded(
                              child: _GlassActionButton(
                                icon: Icons.person_rounded,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  context.push('/profile/$friendId');
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _GlassActionButton(
                                icon: Icons.chat_bubble_rounded,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  context.push(AppRoutes.chat, extra: {
                                    'userId': friendId,
                                    'userName': name,
                                    'userImage': avatar.isNotEmpty ? avatar : null,
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: cooldown > 0 && !showAcceptedAnim
                                  ? _GlassActionButton(
                                      label: '${cooldown ~/ 60}:${(cooldown % 60).toString().padLeft(2, '0')}',
                                      color: Colors.white54,
                                      isTimer: true,
                                      onTap: () {},
                                    )
                                  : _GlassActionButton(
                                      icon: Icons.bolt_rounded,
                                      color: isAvailable ? Colors.white : Colors.white38,
                                      bgColor: isAvailable
                                          ? const Color(0xFF22C55E).withValues(alpha: 0.80)
                                          : null,
                                      glowColor: isAvailable ? const Color(0xFF22C55E) : null,
                                      onTap: isAvailable && !showAcceptedAnim
                                          ? () => widget.onSendCatch(friendId)
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
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    return Container(
      color: NeerColors.darkSurface.withValues(alpha: 0.30),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 48,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// GLASS ICON BUTTON — frosted circle overlay
// ═══════════════════════════════════════════════════════

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPress(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 0.5),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// GLASS ACTION BUTTON — bottom action row in capsule
// ═══════════════════════════════════════════════════════

class _GlassActionButton extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final Color color;
  final Color? bgColor;
  final Color? glowColor;
  final VoidCallback onTap;
  final bool isTimer;

  const _GlassActionButton({
    this.icon,
    this.label,
    this.color = Colors.white,
    this.bgColor,
    this.glowColor,
    required this.onTap,
    this.isTimer = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPress(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 0.5),
          boxShadow: glowColor != null
              ? [BoxShadow(color: glowColor!.withValues(alpha: 0.30), blurRadius: 8)]
              : [],
        ),
        child: Center(
          child: label != null
              ? Text(
                  label!,
                  style: NeerTypography.caption.copyWith(
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
}
