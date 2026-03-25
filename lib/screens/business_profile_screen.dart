import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// CORE
import '../core/neer_design_system.dart';
import '../core/app_strings.dart';

// SERVICES
import '../services/supabase_service.dart';

// WIDGETS
import '../widgets/business/business_widgets.dart';
import '../widgets/common/active_users_sheet.dart';
import '../widgets/common/check_in_button.dart';
import '../widgets/common/glass_button.dart';
import '../widgets/common/glass_panel.dart';
import '../widgets/common/animated_press.dart';
import '../widgets/common/app_cached_image.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/masonry_gallery.dart';
import '../widgets/profile/profile_header.dart' show PillTabBar;

class BusinessProfileScreen extends StatefulWidget {
  final String venueId;
  final String venueName;
  final String imageUrl;

  const BusinessProfileScreen({
    super.key,
    required this.venueId,
    required this.venueName,
    required this.imageUrl,
  });

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> with TickerProviderStateMixin {
  final _service = SupabaseService();

  bool isFavorite = false;
  late TabController _mainTabController;
  late TabController _mediaTabController;
  final ScrollController _scrollController = ScrollController();
  late String safeVenueId;

  // Gerçek veriler
  Map<String, dynamic>? _placeData;
  List<Map<String, dynamic>> _reviews = [];
  List<Map<String, dynamic>> _topVisitors = [];
  Map<String, double> _ratingStats = {};
  List<String> _placePhotos = [];
  int _liveUserCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _mediaTabController = TabController(length: 2, vsync: this);
    safeVenueId = widget.venueId.isNotEmpty ? widget.venueId : "unknown_venue_123";
    _loadPlaceData();
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _mediaTabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPlaceData() async {
    final results = await Future.wait([
      _service.getPlaceById(safeVenueId),
      _service.getPlaceReviews(safeVenueId),
      _service.getPlaceTopVisitors(safeVenueId),
      _service.getPlaceRatingStats(safeVenueId),
      _service.getPlacePhotos(safeVenueId),
      _loadLiveUsers(),
    ]);

    if (!mounted) return;
    setState(() {
      _placeData = results[0] as Map<String, dynamic>?;
      _reviews = results[1] as List<Map<String, dynamic>>;
      _topVisitors = results[2] as List<Map<String, dynamic>>;
      _ratingStats = results[3] as Map<String, double>;
      _placePhotos = results[4] as List<String>;
      _isLoading = false;
    });
  }

  Future<int> _loadLiveUsers() async {
    try {
      final id = int.tryParse(safeVenueId);
      if (id == null) return 0;
      final users = await _service.getActiveUsersAtPlace(id);
      _liveUserCount = users.length;
      return _liveUserCount;
    } catch (_) {
      return 0;
    }
  }

  // Veri alanlarına güvenli erişim
  double get _rating => (_placeData?['average_rating'] as num?)?.toDouble() ?? 0.0;
  String get _category => _placeData?['category'] ?? '';
  double? get _latitude => (_placeData?['latitude'] as num?)?.toDouble();
  double? get _longitude => (_placeData?['longitude'] as num?)?.toDouble();

  // İlk review'ı bul (arkadaş notu olarak göster)
  Map<String, dynamic>? get _firstReviewWithComment {
    for (final r in _reviews) {
      final comment = r['comment'] ?? r['content'] ?? '';
      if (comment.toString().isNotEmpty) return r;
    }
    return null;
  }

  // ═══════════════════════════════════════════
  // VENUE HEADER — ProfileHeaderBackground style
  // ═══════════════════════════════════════════

  Widget _buildVenueHeader(bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black.withValues(alpha: 0.87);
    final subTextColor = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : Colors.black.withValues(alpha: 0.50);
    final textShadows = isDark
        ? [Shadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 8, offset: const Offset(0, 2))]
        : <Shadow>[];

    return Stack(
      fit: StackFit.expand,
      children: [
        // Blurred venue image
        AppCachedImage.cover(imageUrl: widget.imageUrl, height: 235),
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
            child: Container(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.62)
                  : Colors.white.withValues(alpha: 0.52),
            ),
          ),
        ),
        // Content
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Venue image (circle) | Name + Category | Rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Venue avatar
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: AppCachedImage.cover(
                          imageUrl: widget.imageUrl,
                          height: 56,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name + Category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.venueName,
                            style: NeerTypography.h2.copyWith(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              shadows: textShadows,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_category.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              _category,
                              style: NeerTypography.caption.copyWith(
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Rating ring
                    if (_rating > 0)
                      _VenueRatingRing(rating: _rating),
                  ],
                ),

                const SizedBox(height: 10),

                // Row 2: Stats chips
                Row(
                  children: [
                    if (_liveUserCount > 0) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF30D158),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: const Color(0xFF30D158).withValues(alpha: 0.5), blurRadius: 6)],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "$_liveUserCount ${AppStrings.peopleCount}",
                        style: NeerTypography.caption.copyWith(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.80)
                              : Colors.black.withValues(alpha: 0.70),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          shadows: textShadows,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (_reviews.isNotEmpty)
                      Text(
                        '${_reviews.length} ${AppStrings.reviews}',
                        style: NeerTypography.caption.copyWith(
                          color: subTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GradientScaffold(

      // SABİT ALT AKSİYON BARI (DOCK)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5)
            )
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.1),
                borderRadius: NeerRadius.buttonRadius
              ),
              child: IconButton(
                icon: Icon(Icons.navigation_rounded, color: theme.iconTheme.color),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                }
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CheckInButton(
                venueId: safeVenueId,
                venueName: widget.venueName,
                venueImage: widget.imageUrl,
                onCheckInSuccess: () {},
              ),
            ),
          ],
        ),
      ),

      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 235.0,
              pinned: true,
              stretch: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
              leading: Center(
                child: GlassButton.medium(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              actions: [
                GlassButton.medium(
                  icon: Icons.groups_rounded,
                  iconColor: theme.primaryColor,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => ActiveUsersSheet(chatId: widget.venueId),
                    );
                  },
                ),
                const SizedBox(width: 8),
                GlassButton.medium(
                  icon: isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => isFavorite = !isFavorite);
                  },
                  iconColor: isFavorite ? Colors.redAccent : null,
                ),
                const SizedBox(width: 16),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: _buildVenueHeader(isDark),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                  child: PillTabBar(
                    controller: _mainTabController,
                    tabs: [AppStrings.overview, AppStrings.mediaGallery],
                    onTap: (_) => HapticFeedback.selectionClick(),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _mainTabController,
          children: [
            _buildGeneralTab(theme),
            _buildMediaTab(theme),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: GENEL BAKIŞ ---
  Widget _buildGeneralTab(ThemeData theme) {
    if (_isLoading) {
      return const ShimmerList(itemCount: 5);
    }

    final review = _firstReviewWithComment;
    final reviewProfiles = review?['profiles'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // BENTO DASHBOARD (Venue-specific)
          // ==========================================
          SizedBox(
            height: 170,
            child: Row(
              children: [
                // LEFT: Live Density
                Expanded(
                  child: AnimatedPress(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => ActiveUsersSheet(chatId: widget.venueId),
                      );
                    },
                    useHeavyHaptic: true,
                    child: GlassPanel.bento(
                      height: 170,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: (_liveUserCount > 0 ? const Color(0xFF30D158) : theme.disabledColor).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.people_alt_rounded,
                              color: _liveUserCount > 0 ? const Color(0xFF30D158) : theme.disabledColor,
                              size: 22,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "$_liveUserCount",
                            style: NeerTypography.h1.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: _liveUserCount > 0 ? const Color(0xFF30D158) : theme.disabledColor,
                            ),
                          ),
                          Text(
                            AppStrings.peopleCount,
                            style: NeerTypography.caption.copyWith(
                              color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // RIGHT: Check-in + Rating
                Expanded(
                  child: Column(
                    children: [
                      // Check-in card
                      Expanded(
                        child: AnimatedPress(
                          onTap: () {},
                          child: GlassPanel.bento(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on_rounded, color: theme.primaryColor, size: 20),
                                const SizedBox(height: 6),
                                Text(
                                  AppStrings.checkInShort,
                                  style: NeerTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Rating card
                      Expanded(
                        child: AnimatedPress(
                          onTap: () {},
                          child: GlassPanel.bento(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Icon(Icons.star_rounded, color: NeerColors.warning, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  _rating > 0 ? _rating.toStringAsFixed(1) : "-",
                                  style: NeerTypography.h2.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: NeerColors.warning,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "${_reviews.length}",
                                  style: NeerTypography.caption.copyWith(
                                    color: theme.disabledColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Rest of content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: AppStrings.upcomingEvents, icon: Icons.event_available_rounded),
                const EventTicketCard(),
                const SizedBox(height: 30),
                SectionHeader(title: AppStrings.regulars, icon: Icons.emoji_events_rounded),
                VenueLeaderboard(topVisitors: _topVisitors),
                const SizedBox(height: 30),
                SectionHeader(title: AppStrings.friendsSay, icon: Icons.chat_bubble_rounded),
                FriendNoteBubble(
                  comment: review != null ? (review['comment'] ?? review['content'] ?? '').toString() : null,
                  authorName: reviewProfiles is Map ? (reviewProfiles['full_name'] ?? reviewProfiles['username']) : null,
                  authorAvatar: reviewProfiles is Map ? reviewProfiles['avatar_url'] : null,
                ),
                const SizedBox(height: 30),
                SectionHeader(title: AppStrings.detailedRatings, icon: Icons.tune_rounded),
                DetailedRatingBars(ratings: _ratingStats),
                const SizedBox(height: 30),
                LocationQrRow(latitude: _latitude, longitude: _longitude),
                const SizedBox(height: 20),
                Center(
                  child: TextButton.icon(
                    onPressed: () => HapticFeedback.lightImpact(),
                    icon: Icon(Icons.flag_rounded, color: theme.disabledColor, size: 18),
                    label: Text(AppStrings.reportIssue, style: TextStyle(color: theme.disabledColor)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: MEDYA ---
  Widget _buildMediaTab(ThemeData theme) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          height: 45,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.dividerColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(25),
          ),
          child: TabBar(
            controller: _mediaTabController,
            indicator: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]
            ),
            labelColor: theme.textTheme.bodyLarge?.color,
            unselectedLabelColor: theme.disabledColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: AppStrings.businessPhotos),
              Tab(text: AppStrings.userPhotos),
            ],
            onTap: (_) => HapticFeedback.selectionClick(),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _mediaTabController,
            children: [
              _buildPhotoGrid(photos: _placePhotos),
              _buildPhotoGrid(photos: _placePhotos), // Henüz business/user ayrımı yok
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoGrid({required List<String> photos}) {
    if (photos.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.photo_library_outlined,
          title: AppStrings.noPhotosYet,
        ),
      );
    }

    return MasonryGallery(
      photos: photos,
      padding: const EdgeInsets.all(12),
    );
  }
}

// ═══════════════════════════════════════════════════════
// VENUE RATING RING — matches NeerScore ring style
// ═══════════════════════════════════════════════════════

class _VenueRatingRing extends StatelessWidget {
  final double rating;
  const _VenueRatingRing({required this.rating});

  Color _color() {
    if (rating >= 4.0) return const Color(0xFF30D158);
    if (rating >= 2.5) return const Color(0xFFFF9F0A);
    return const Color(0xFFFF453A);
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return SizedBox(
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
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.12)),
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              value: (rating / 5.0).clamp(0.0, 1.0),
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, size: 10, color: color),
              Text(
                rating.toStringAsFixed(1),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                  shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
