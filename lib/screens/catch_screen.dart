import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/text_styles.dart';
import '../core/theme_styles.dart';
import '../core/app_strings.dart';
import '../services/catch_service.dart';
import '../services/availability_service.dart';
import '../services/watcher_service.dart';
import 'friend_profile_screen.dart';
import 'chat_screen.dart';

class CatchScreen extends StatefulWidget {
  const CatchScreen({super.key});

  @override
  State<CatchScreen> createState() => _CatchScreenState();
}

class _CatchScreenState extends State<CatchScreen> {
  final _supabase = Supabase.instance.client;
  final _catchService = CatchService();
  final _availabilityService = AvailabilityService();
  final _watcherService = WatcherService();

  String _myStatus = 'busy';
  DateTime? _availableUntil;
  List<Map<String, dynamic>> _friends = [];
  Set<String> _watchedIds = {};
  Map<String, int> _cooldowns = {}; // friendId -> remaining seconds
  Timer? _cooldownTimer;
  Timer? _statusTimer;
  bool _isLoading = true;

  // Realtime subscriptions
  StreamSubscription? _profileSub;
  StreamSubscription? _catchesSub;

  // Catch onay animasyonu
  String? _acceptedCatchReceiverId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Paralel yükleme
    await Future.wait([
      _loadFriends(userId),
      _loadWatchedIds(),
      _loadMyStatus(userId),
    ]);

    _startRealtimeListeners(userId);
    _startCooldownTimer();

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadMyStatus(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('status, available_until')
          .eq('id', userId)
          .single();
      _myStatus = data['status'] ?? 'busy';
      _availableUntil = data['available_until'] != null
          ? DateTime.tryParse(data['available_until'])
          : null;
    } catch (_) {}
  }

  Future<void> _loadFriends(String userId) async {
    _friends = await _availabilityService.getFriendsWithStatus(userId);
    // Her arkadaş için cooldown kontrol et
    for (final f in _friends) {
      final remaining = await _catchService.getCooldownRemaining(f['id']);
      if (remaining > 0) _cooldowns[f['id']] = remaining;
    }
  }

  Future<void> _loadWatchedIds() async {
    _watchedIds = await _watcherService.getWatchedIds();
  }

  void _startRealtimeListeners(String userId) {
    // Kendi profil değişimlerini dinle
    _profileSub = _availabilityService.streamMyStatus().listen((data) {
      if (data != null && mounted) {
        setState(() {
          _myStatus = data['status'] ?? 'busy';
          _availableUntil = data['available_until'] != null
              ? DateTime.tryParse(data['available_until'])
              : null;
        });
      }
    });

    // Gelen catch'leri dinle
    _catchesSub = _catchService.streamIncomingCatches(userId).listen((catches) {
      if (catches.isNotEmpty && mounted) {
        _showIncomingCatchSheet(catches.first);
      }
    });

    // Gönderilen catch'lerin durumunu dinle (onay animasyonu)
    _catchService.streamSentCatches(userId).listen((catches) {
      if (catches.isNotEmpty && mounted) {
        final latest = catches.first;
        if (latest['status'] == 'accepted') {
          setState(() => _acceptedCatchReceiverId = latest['receiver_id']);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _acceptedCatchReceiverId = null);
          });
        }
      }
    });

    // Arkadaş profillerinin status değişimlerini dinle
    final friendIds = _friends.map((f) => f['id'] as String).toList();
    if (friendIds.isNotEmpty) {
      _availabilityService.streamFriendsStatus(friendIds).listen((profiles) {
        if (mounted) {
          setState(() {
            for (final profile in profiles) {
              final idx = _friends.indexWhere((f) => f['id'] == profile['id']);
              if (idx != -1) _friends[idx] = profile;
            }
          });
        }
      });
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        final expired = <String>[];
        _cooldowns.forEach((id, remaining) {
          if (remaining <= 1) {
            expired.add(id);
          } else {
            _cooldowns[id] = remaining - 1;
          }
        });
        for (final id in expired) {
          _cooldowns.remove(id);
        }
      });
    });

    // Status kalan süre timer
    _statusTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _statusTimer?.cancel();
    _profileSub?.cancel();
    _catchesSub?.cancel();
    super.dispose();
  }

  // ═══════════════════════════════════════════
  // ACTIONS
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
        await _availabilityService.setAvailable(minutes);
        if (mounted) {
          setState(() {
            _myStatus = 'available';
            _availableUntil = DateTime.now().add(Duration(minutes: minutes));
          });
        }
      },
    );
  }

  Future<void> _handleBusy() async {
    HapticFeedback.mediumImpact();
    await _availabilityService.setBusy();
    if (mounted) {
      setState(() {
        _myStatus = 'busy';
        _availableUntil = null;
      });
    }
  }

  Future<void> _sendCatch(String receiverId) async {
    HapticFeedback.mediumImpact();
    final result = await _catchService.sendCatch(receiverId);
    if (result != null && mounted) {
      setState(() {
        _cooldowns[receiverId] = CatchService.cooldownSeconds;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.catchSent, style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius16),
        ),
      );
    }
  }

  Future<void> _toggleWatch(String targetId) async {
    HapticFeedback.selectionClick();
    final isNowWatching = await _watcherService.toggleWatch(targetId);
    if (mounted) {
      setState(() {
        if (isNowWatching) {
          _watchedIds.add(targetId);
        } else {
          _watchedIds.remove(targetId);
        }
      });
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
    // Sender bilgilerini çek
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
              // Sender avatar
              CircleAvatar(
                radius: 40,
                backgroundImage: senderAvatar.isNotEmpty ? NetworkImage(senderAvatar) : null,
                child: senderAvatar.isEmpty
                    ? Text(senderName[0].toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold))
                    : null,
              ),
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
                          await _catchService.rejectCatch(catchId);
                          if (ctx.mounted) Navigator.pop(ctx);
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
                          await _catchService.acceptCatch(catchId);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.catchAccepted, style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                                backgroundColor: const Color(0xFF22C55E),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius16),
                              ),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : Column(
              children: [
                // ═══ DURUM KARTI ═══
                _buildStatusCard(theme, isDark),

                // ═══ ARKADAŞ LİSTESİ ═══
                Expanded(
                  child: _friends.isEmpty
                      ? _buildEmptyState(theme)
                      : _buildFriendGrid(theme, isDark),
                ),
              ],
            ),
    );
  }

  // ═══════════════════════════════════════════
  // STATUS CARD (Kendi durumun)
  // ═══════════════════════════════════════════

  Widget _buildStatusCard(ThemeData theme, bool isDark) {
    final isAvailable = _myStatus == 'available';
    final statusColor = isAvailable ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    String remainingText = '';
    if (isAvailable && _availableUntil != null) {
      final diff = _availableUntil!.difference(DateTime.now());
      if (diff.isNegative) {
        remainingText = '';
      } else if (diff.inHours > 0) {
        remainingText = '${diff.inHours}s ${diff.inMinutes % 60}dk';
      } else {
        remainingText = '${diff.inMinutes}dk';
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
          // Status dot
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

          // Text
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

          // Toggle button
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

  Widget _buildFriendGrid(ThemeData theme, bool isDark) {
    // Sırala: available > pending > busy
    final sorted = List<Map<String, dynamic>>.from(_friends);
    sorted.sort((a, b) {
      const order = {'available': 0, 'pending': 1, 'busy': 2};
      return (order[a['status']] ?? 2).compareTo(order[b['status']] ?? 2);
    });

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
      itemBuilder: (context, index) => _buildFriendCard(sorted[index], theme, isDark),
    );
  }

  Widget _buildFriendCard(Map<String, dynamic> friend, ThemeData theme, bool isDark) {
    final friendId = friend['id'] as String;
    final name = friend['full_name'] ?? AppStrings.nameless;
    // final username = friend['username'] ?? '';
    final avatar = friend['avatar_url'] ?? '';
    final status = friend['status'] ?? 'busy';
    final phoneNumber = friend['phone_number']?.toString();
    final isAvailable = status == 'available';
    final isPending = status == 'pending';
    final isWatched = _watchedIds.contains(friendId);
    final cooldown = _cooldowns[friendId] ?? 0;
    final showAcceptedAnim = _acceptedCatchReceiverId == friendId;

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
                ? Image.network(
                    avatar,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(name, theme),
                  )
                : _buildAvatarPlaceholder(name, theme),

            // ═══ ALT GRADIENT (daha uzun, butonlar için alan) ═══
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

            // ═══ ÜST SOL: TELEFON (sadece available) ═══
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
                    // İsim
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

                    // Durum yazısı
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
                        // Profil butonu
                        Expanded(
                          child: _buildCardAction(
                            icon: Icons.person_rounded,
                            color: Colors.white,
                            bgColor: Colors.white.withValues(alpha: 0.15),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => FriendProfileScreen(targetUserId: friendId),
                              ));
                            },
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Mesaj butonu
                        Expanded(
                          child: _buildCardAction(
                            icon: Icons.chat_bubble_rounded,
                            color: Colors.white,
                            bgColor: Colors.white.withValues(alpha: 0.15),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.push(context, MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  userId: friendId,
                                  userName: name,
                                  userImage: avatar.isNotEmpty ? avatar : null,
                                ),
                              ));
                            },
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Catch butonu / Cooldown
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 80, color: theme.disabledColor.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          Text(
            AppStrings.noFriendsForCatch,
            style: AppTextStyles.h3.copyWith(color: theme.disabledColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.noFriendsForCatchDesc,
            style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor),
          ),
        ],
      ),
    );
  }
}
