import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../main.dart';

// CORE
import '../core/neer_design_system.dart';
import '../core/app_strings.dart';
import '../core/app_router.dart';

// MODELS & SERVICES
import '../models/post_model.dart';
import '../services/supabase_service.dart';
import '../providers/profile_provider.dart';

// WIDGETS
import '../widgets/profile/profile_components.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/feed/feed_widgets.dart';
import '../widgets/common/glass_panel.dart';
import '../widgets/common/animated_press.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/common/animated_list_item.dart';
import '../widgets/common/masonry_gallery.dart';
import '../widgets/friend/friend_profile_widgets.dart' show FriendEmptyCard;
import '../widgets/common/app_cached_image.dart';
import '../widgets/common/heatmap_widget.dart';

class ProfileScreen extends StatefulWidget {
  final ScrollController? externalScrollController;
  const ProfileScreen({super.key, this.externalScrollController});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();
  final String _uid = supabase.auth.currentUser!.id;

  late TabController _mainTabController;
  late ScrollController _scrollController;

  // Streams & Futures
  late Stream<List<Map<String, dynamic>>> _favoritesStream;
  late Stream<List<Map<String, dynamic>>> _notesStream;
  late Stream<List<String>> _photosStream;
  late Stream<List<PostModel>> _activityStream;

  late Future<List<Map<String, dynamic>>> _questsFuture;
  late Future<List<Map<String, dynamic>>> _frequentPlacesFuture;
  late Future<List<Map<String, dynamic>>> _surveyHistoryFuture;

  late Future<List<Map<String, dynamic>>> _badgesFuture;
  late Future<List<Map<String, dynamic>>> _allBadgeDefsFuture;
  late Future<Map<String, dynamic>> _identityStatsFuture;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.externalScrollController ?? ScrollController();
    _mainTabController = TabController(length: 3, vsync: this);
    context.read<ProfileProvider>().loadProfile(_uid);

    _favoritesStream = _supabaseService.getUserFavorites(_uid);
    _notesStream = _supabaseService.getUserNotes(_uid);
    _photosStream = _supabaseService.getUserPhotos(_uid);
    _activityStream = _supabaseService.getUserActivityFeed(_uid);

    _questsFuture = _supabaseService.getUserQuests(_uid);
    _frequentPlacesFuture = _supabaseService.getFrequentPlaces(_uid);
    _surveyHistoryFuture = _supabaseService.getSurveyHistory(_uid);

    _badgesFuture = _supabaseService.getUserBadges(_uid);
    _allBadgeDefsFuture = _supabaseService.getAllBadgeDefinitions();
    _identityStatsFuture = _supabaseService.getUserIdentityStats(_uid);
  }

  String _findPlaceId(Map<String, dynamic> data) {
    if (data['placeId'] != null && data['placeId'].toString().isNotEmpty) return data['placeId'];
    if (data['venueId'] != null && data['venueId'].toString().isNotEmpty) return data['venueId'];
    if (data['businessId'] != null && data['businessId'].toString().isNotEmpty) return data['businessId'];
    if (data['id'] != null && data['id'].toString().isNotEmpty) return data['id'];
    if (data['place_name'] != null && data['place_name'].toString().isNotEmpty) {
      return data['place_name'].toString().toLowerCase().replaceAll(' ', '_');
    }
    if (data['location_name'] != null && data['location_name'].toString().isNotEmpty) {
      return data['location_name'].toString().toLowerCase().replaceAll(' ', '_');
    }
    if (data['name'] != null && data['name'].toString().isNotEmpty) {
      return data['name'].toString().toLowerCase().replaceAll(' ', '_');
    }
    return "";
  }

  void _showAllFavorites(BuildContext context) {}

  Color? _extractedBgColor;

  void _showFollowersList(BuildContext context, String tab, String userName) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FollowersScreen(uid: _uid, userName: userName, initialTab: tab),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileProvider = context.watch<ProfileProvider>();
    final user = profileProvider.profile;

    if (profileProvider.isLoading) {
      return GradientScaffold(animate: true, body: const ShimmerList(itemCount: 5));
    }

    final String displayImage = (user?.profileImage != null && user!.profileImage.isNotEmpty)
        ? user.profileImage
        : "https://i.pravatar.cc/150?img=60";

    return GradientScaffold(
      animate: true,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                expandedHeight: 235,
                pinned: true,
                floating: false,
                backgroundColor: _extractedBgColor
                    ?? (isDark ? const Color(0xFF1A0F1A) : const Color(0xFFFDFBFF)),
                elevation: 0,
                automaticallyImplyLeading: false,

                // Collapsed header — avatar + name when scrolled
                title: AnimatedOpacity(
                  opacity: innerBoxIsScrolled ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: innerBoxIsScrolled
                          ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
                          : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child: Row(
                        children: [
                          _AvatarRingSmall(imageUrl: displayImage),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(user?.name ?? '',
                              style: NeerTypography.bodySmall.copyWith(
                                color: Colors.white, fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _NeerScoreRingSmall(
                            score: user?.neerScore ?? 5.0,
                            label: user?.neerScoreLabel ?? 'Standart',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: FlexibleSpaceBar(
                      stretchModes: const [StretchMode.zoomBackground],
                      background: ProfileHeaderBackground(
                        imageUrl: displayImage,
                        isDark: isDark,
                        onColorExtracted: (c) {
                          if (mounted) setState(() => _extractedBgColor = c);
                        },
                        child: ProfileHeader(
                          imageUrl: displayImage,
                          name: user?.name ?? AppStrings.nameless,
                          username: user?.username ?? '',
                          bio: user?.bio ?? '',
                          followersCount: (user?.followersCount ?? 0).toString(),
                          followingCount: (user?.followingCount ?? 0).toString(),
                          neerScore: (user?.neerScore ?? 5.0).toDouble(),
                          neerScoreLabel: user?.neerScoreLabel ?? AppStrings.neerScoreStandard,
                          onEditTap: () async {
                            HapticFeedback.lightImpact();
                            await context.push(AppRoutes.editProfile);
                          },
                          onSettingsTap: () {
                            HapticFeedback.lightImpact();
                            context.push(AppRoutes.settings);
                          },
                          onFollowersTap: () => _showFollowersList(context, 'followers', user?.name ?? ''),
                          onFollowingTap: () => _showFollowersList(context, 'following', user?.name ?? ''),
                          onFriendsTap: () => _showFollowersList(context, 'friends', user?.name ?? ''),
                        ),
                      ),
                    ),
                  ),
                ),

                // GRADIENT TAB BAR — sol hizalı
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(44),
                  child: ProfileTabBar(
                    controller: _mainTabController,
                    tabs: [AppStrings.profileTab, AppStrings.activityTab, AppStrings.galleryTab],
                    onTap: (_) => HapticFeedback.selectionClick(),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _mainTabController,
          physics: const BouncingScrollPhysics(),
          children: [
            _buildProfileTab(theme, user),
            _buildActivityTab(theme),
            _buildGalleryTab(theme),
          ],
        ),
      ),
    );
  }

  // ======================
  // TAB 1: PROFIL — Bento Box Architecture
  // ======================
  Widget _buildProfileTab(ThemeData theme, dynamic user) {
    final isDark = theme.brightness == Brightness.dark;

    return Builder(builder: (BuildContext context) {
      return CustomScrollView(
        key: const PageStorageKey<String>('tab1'),
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ==========================================
                  // A. BENTO DASHBOARD (Asymmetric Grid)
                  // ==========================================
                  _BentoDashboard(
                    isDark: isDark,
                    questsFuture: _questsFuture,
                    notesStream: _notesStream,
                    surveyHistoryFuture: _surveyHistoryFuture,
                  ),

                  const SizedBox(height: 16),

                  // ==========================================
                  // B. NEER KİMLİĞİ KARTI
                  // ==========================================
                  StreamBuilder<List<String>>(
                    stream: _photosStream,
                    builder: (context, photoSnap) {
                      final photoCount = photoSnap.data?.length ?? 0;
                      return _NeerIdentityCard(
                        statsFuture: _identityStatsFuture,
                        photoCount: photoCount,
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ==========================================
                  // C. ROZET VİTRİNİ
                  // ==========================================
                  FutureBuilder<List<dynamic>>(
                    future: Future.wait([_badgesFuture, _allBadgeDefsFuture]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(height: 80);
                      }
                      if (snapshot.hasError) {
                        debugPrint('Badge error: ${snapshot.error}');
                        return const SizedBox.shrink();
                      }
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      final earned = (snapshot.data![0] as List).cast<Map<String, dynamic>>();
                      final all = (snapshot.data![1] as List).cast<Map<String, dynamic>>();
                      if (all.isEmpty) return const SizedBox.shrink();
                      return _BadgeVitrin(
                        earnedBadges: earned,
                        allBadges: all,
                        onSeeAll: () => context.push(AppRoutes.badges),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // ==========================================
                  // D. SPOTLIGHT — Single Carousel (Favorites Only)
                  // ==========================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SectionHeader(
                      title: AppStrings.favoritesTitle,
                      onActionTap: () => _showAllFavorites(context),
                    ),
                  ),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _favoritesStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FriendEmptyCard(
                            title: AppStrings.noFavorites,
                            subtitle: AppStrings.noFavoritesDesc,
                            icon: Icons.favorite_border_rounded,
                          ),
                        );
                      }
                      return StackedCardCarousel(
                        itemCount: snapshot.data!.length,
                        height: 300,
                        itemBuilder: (context, index) {
                          var fav = snapshot.data![index];
                          return VerticalPlaceCard(
                            name: fav['place_name'] ?? 'Mekan',
                            rating: (fav['rating'] is num)
                                ? (fav['rating'] as num).toStringAsFixed(1)
                                : "0.0",
                            imgUrl: fav['image'] ?? "https://picsum.photos/400",
                            onTap: () => context.push(
                              '/venue/${_findPlaceId(fav)}',
                              extra: {
                                'venueName': fav['place_name'] ?? 'Mekan',
                                'imageUrl': fav['image'] ?? "https://picsum.photos/400",
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // ==========================================
                  // F. SIK UĞRANANLAR
                  // ==========================================
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _frequentPlacesFuture,
                    builder: (context, snapshot) {
                      final places = snapshot.data ?? [];
                      return _FrequentPlacesSection(
                        places: places.take(3).toList(),
                        onSeeAll: () => context.push(AppRoutes.frequentPlacesFull),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // ==========================================
                  // G. ISI HARİTASI
                  // ==========================================
                  HeatmapWidget(userId: _uid),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  // ======================
  // TAB 2: ACTIVITY
  // ======================
  Widget _buildActivityTab(ThemeData theme) {
    return Builder(builder: (BuildContext context) {
      return CustomScrollView(
        key: const PageStorageKey<String>('tabActivity'),
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          StreamBuilder<List<PostModel>>(
            stream: _activityStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: ShimmerList(itemCount: 4));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: FriendEmptyCard(
                      title: AppStrings.noActivity,
                      subtitle: AppStrings.noActivityUser,
                      icon: Icons.local_activity_rounded,
                    ),
                  ),
                );
              }
              var posts = snapshot.data!;
              return SliverPadding(
                padding: const EdgeInsets.only(top: 10, bottom: 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    var post = posts[index];
                    return AnimatedListItem(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: post.type == 'review'
                            ? FeedReviewCard(post: post)
                            : FeedPostCard(post: post),
                      ),
                    );
                  }, childCount: posts.length),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  // ======================
  // TAB 3: GALLERY (Masonry)
  // ======================
  Widget _buildGalleryTab(ThemeData theme) {
    return Builder(builder: (BuildContext context) {
      return CustomScrollView(
        key: const PageStorageKey<String>('tabGallery'),
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          StreamBuilder<List<String>>(
            stream: _photosStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: FriendEmptyCard(
                      title: AppStrings.galleryEmpty,
                      subtitle: AppStrings.galleryEmptyUser,
                      icon: Icons.photo_library_rounded,
                    ),
                  ),
                );
              }
              var photos = snapshot.data!;
              return SliverMasonryGallery(
                photos: photos,
                padding: const EdgeInsets.all(12),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      );
    });
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    if (widget.externalScrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

}

// ==========================================
// NEER KİMLİĞİ KARTI
// ==========================================
class _NeerIdentityCard extends StatelessWidget {
  final Future<Map<String, dynamic>> statsFuture;
  final int photoCount;
  const _NeerIdentityCard({required this.statsFuture, required this.photoCount});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: statsFuture,
      builder: (context, snapshot) {
        final stats = snapshot.data;
        return AnimatedPress(
          onTap: () {},
          child: GlassPanel.card(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: AppStrings.neerIdentityTitle),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _IdentityStat(value: stats?['total_places']?.toString() ?? '—', label: 'mekan'),
                    _IdentityStat(value: photoCount.toString(), label: 'fotoğraf'),
                    _IdentityStat(value: stats?['total_cities']?.toString() ?? '—', label: 'şehir'),
                    _IdentityStat(value: stats?['active_days']?.toString() ?? '—', label: 'gün'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _IdentityStat extends StatelessWidget {
  final String value, label;
  const _IdentityStat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Text(value, style: NeerTypography.h2.copyWith(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: cs.onSurface,
          )),
          const SizedBox(height: 2),
          Text(label, style: NeerTypography.caption.copyWith(
            color: cs.onSurface.withValues(alpha: 0.45), fontSize: 10,
          )),
        ],
      ),
    );
  }
}

// ==========================================
// ROZET VİTRİNİ
// ==========================================
class _BadgeVitrin extends StatelessWidget {
  final List<Map<String, dynamic>> earnedBadges;
  final List<Map<String, dynamic>> allBadges;
  final VoidCallback onSeeAll;
  const _BadgeVitrin({required this.earnedBadges, required this.allBadges, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final earned = earnedBadges;
    final all = allBadges;
        return GlassPanel.card(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: AppStrings.badgesTitle, onActionTap: onSeeAll),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: all.map((badge) {
                    final isEarned = earned.any((e) => e['badge_id'] == badge['id']);
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isEarned
                                  ? Theme.of(context).primaryColor.withValues(alpha: 0.18)
                                  : Colors.white.withValues(alpha: 0.04),
                              border: Border.all(
                                color: isEarned
                                    ? Theme.of(context).primaryColor.withValues(alpha: 0.45)
                                    : Colors.white.withValues(alpha: 0.08),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: isEarned
                                  ? Text(badge['icon'] ?? '🏅', style: const TextStyle(fontSize: 17))
                                  : ColorFiltered(
                                      colorFilter: const ColorFilter.matrix([
                                        0.2126, 0.7152, 0.0722, 0, 0,
                                        0.2126, 0.7152, 0.0722, 0, 0,
                                        0.2126, 0.7152, 0.0722, 0, 0,
                                        0, 0, 0, 0.30, 0,
                                      ]),
                                      child: Text(badge['icon'] ?? '🏅', style: const TextStyle(fontSize: 17)),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            badge['name_tr'] ?? badge['name_en'] ?? '',
                            style: NeerTypography.caption.copyWith(
                              color: isEarned
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).disabledColor.withValues(alpha: 0.45),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
  }
}

// ==========================================
// SIK UĞRANANLAR — A TASARIMI
// ==========================================
class _FrequentPlacesSection extends StatelessWidget {
  final List<Map<String, dynamic>> places;
  final VoidCallback onSeeAll;
  const _FrequentPlacesSection({required this.places, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return FriendEmptyCard(
        icon: Icons.explore_off_rounded,
        title: 'Henüz mekan yok',
        subtitle: AppStrings.zeroFrequent,
      );
    }
    return Column(
      children: [
        SectionHeader(title: AppStrings.frequentPlacesTitle, onActionTap: onSeeAll),
        _FrequentCard(place: places[0], rank: 1, height: 72),
        if (places.length > 1) ...[
          const SizedBox(height: 5),
          _FrequentCard(place: places[1], rank: 2, height: 52),
        ],
        if (places.length > 2) ...[
          const SizedBox(height: 5),
          _FrequentCard(place: places[2], rank: 3, height: 52),
        ],
      ],
    );
  }
}

class _FrequentCard extends StatelessWidget {
  final Map<String, dynamic> place;
  final int rank;
  final double height;
  const _FrequentCard({required this.place, required this.rank, required this.height});

  List<Color> _rankGradient() {
    switch (rank) {
      case 1: return [const Color(0xFF8B5CF6).withValues(alpha: 0.55), const Color(0xFFEC4899).withValues(alpha: 0.38)];
      case 2: return [const Color(0xFF3B82F6).withValues(alpha: 0.42), const Color(0xFF8B5CF6).withValues(alpha: 0.28)];
      default: return [const Color(0xFFEC4899).withValues(alpha: 0.38), const Color(0xFFFF8C42).withValues(alpha: 0.25)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = place['place_name'] ?? place['name'] ?? '';
    final img = place['image_url'] ?? place['image'] ?? '';
    final visits = (place['visit_count'] as num?)?.toInt() ?? 0;

    return AnimatedPress(
      onTap: () {
        final placeId = place['id']?.toString() ?? place['place_id']?.toString() ?? '';
        if (placeId.isNotEmpty) {
          context.push('/venue/$placeId', extra: {'venueName': name, 'imageUrl': img});
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(rank == 1 ? 14 : 12),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              img.isNotEmpty
                  ? AppCachedImage.cover(imageUrl: img)
                  : Container(decoration: BoxDecoration(gradient: LinearGradient(colors: _rankGradient()))),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xAA000000), Color(0x22000000)],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: rank == 1 ? 14 : 10),
                child: Row(
                  children: [
                    Text(
                      rank.toString(),
                      style: TextStyle(
                        color: rank == 1 ? const Color(0xFFFFD700).withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.4),
                        fontSize: rank == 1 ? 22 : 16, fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (img.isNotEmpty)
                      Container(
                        width: rank == 1 ? 36 : 28,
                        height: rank == 1 ? 36 : 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: AppCachedImage.cover(imageUrl: img),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: rank == 1 ? 0.9 : 0.8),
                              fontSize: rank == 1 ? 14 : 12, fontWeight: FontWeight.w600,
                            )),
                          if (rank == 1) ...[
                            const SizedBox(height: 2),
                            Text('$visits ziyaret',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11)),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: rank == 1
                            ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.11),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: rank == 1
                              ? const Color(0xFFFFD700).withValues(alpha: 0.28)
                              : Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Text(
                        visits.toString(),
                        style: TextStyle(
                          color: rank == 1
                              ? const Color(0xFFFFD700).withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.65),
                          fontSize: 10, fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
// TAKİPÇİ / TAKİP / ARKADAŞ TAM EKRAN
// ==========================================
class FollowersScreen extends StatefulWidget {
  final String uid;
  final String userName;
  final String initialTab;
  const FollowersScreen({
    super.key,
    required this.uid,
    required this.userName,
    required this.initialTab,
  });

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tc;
  late final Map<String, Future<List<Map<String, dynamic>>>> _futures;

  @override
  void initState() {
    super.initState();
    final idx = widget.initialTab == 'following'
        ? 1
        : widget.initialTab == 'friends'
            ? 2
            : 0;
    _tc = TabController(length: 3, vsync: this, initialIndex: idx);
    _futures = {
      'followers': _fetch('followers'),
      'following': _fetch('following'),
      'friends': _fetch('friends'),
    };
  }

  Future<List<Map<String, dynamic>>> _fetch(String type) async {
    try {
      if (type == 'followers') {
        final data = await supabase
            .from('followers')
            .select('profiles!followers_follower_id_fkey(id, full_name, username, avatar_url)')
            .eq('following_id', widget.uid);
        return (data as List)
            .map((e) => (e['profiles'] ?? <String, dynamic>{}) as Map<String, dynamic>)
            .where((p) => p.isNotEmpty)
            .toList();
      } else if (type == 'following') {
        final data = await supabase
            .from('followers')
            .select('profiles!followers_following_id_fkey(id, full_name, username, avatar_url)')
            .eq('follower_id', widget.uid);
        return (data as List)
            .map((e) => (e['profiles'] ?? <String, dynamic>{}) as Map<String, dynamic>)
            .where((p) => p.isNotEmpty)
            .toList();
      } else {
        final data = await supabase
            .rpc('get_mutual_friends', params: {'uid': widget.uid})
            .catchError((_) => <dynamic>[]);
        return (data as List).cast<Map<String, dynamic>>();
      }
    } catch (_) {
      return [];
    }
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black.withValues(alpha: 0.87);
    final subColor = isDark ? Colors.white.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.40);

    return GradientScaffold(
      body: Column(
        children: [
          // ── Üst başlık ──
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  // Geri butonu
                  GestureDetector(
                    onTap: () { HapticFeedback.lightImpact(); Navigator.of(context).pop(); },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.10)
                            : Colors.black.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.16)
                              : Colors.black.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 15,
                        color: isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black.withValues(alpha: 0.75)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Başlık = kullanıcı adı
                  Expanded(
                    child: Text(
                      widget.userName,
                      style: NeerTypography.h3.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Arkadaş Bul butonu
                  GestureDetector(
                    onTap: () { HapticFeedback.lightImpact(); },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: NeerGradients.purplePink,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: NeerColors.primary.withValues(alpha: 0.30),
                            blurRadius: 12, offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_add_rounded, size: 13, color: Colors.white),
                          const SizedBox(width: 5),
                          Text('Arkadaş Bul',
                            style: NeerTypography.caption.copyWith(
                              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12,
                            )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // ── TabBar ──
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 0.5,
                ),
              ),
            ),
            child: TabBar(
              controller: _tc,
              tabs: [
                Tab(text: AppStrings.followers),
                const Tab(text: 'Takip'),
                const Tab(text: 'Arkadaş'),
              ],
              labelStyle: NeerTypography.bodySmall.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
              unselectedLabelStyle: NeerTypography.bodySmall.copyWith(fontWeight: FontWeight.w500, fontSize: 14),
              labelColor: isDark ? Colors.white : NeerColors.primary,
              unselectedLabelColor: subColor,
              indicatorColor: NeerColors.primary,
              dividerColor: Colors.transparent,
            ),
          ),
          // ── İçerik ──
          Expanded(
            child: TabBarView(
              controller: _tc,
              children: [
                _UserList(future: _futures['followers']!),
                _UserList(future: _futures['following']!),
                _UserList(future: _futures['friends']!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> future;
  const _UserList({required this.future});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = snap.data ?? [];
        if (users.isEmpty) {
          return Center(
            child: Text('Henüz kimse yok',
              style: NeerTypography.bodySmall.copyWith(color: theme.disabledColor)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: users.length,
          itemBuilder: (context, i) {
            final u = users[i];
            final avatarUrl = u['avatar_url'] as String?;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 22,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                backgroundColor: NeerColors.primary.withValues(alpha: 0.15),
                child: avatarUrl == null
                    ? Icon(Icons.person, size: 18, color: NeerColors.primary)
                    : null,
              ),
              title: Text(
                u['full_name'] as String? ?? '',
                style: NeerTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '@${u['username'] as String? ?? ''}',
                style: NeerTypography.caption.copyWith(color: theme.disabledColor),
              ),
            );
          },
        );
      },
    );
  }
}

// ==========================================
// BENTO DASHBOARD — Asymmetric Glass Grid
// ==========================================
class _BentoDashboard extends StatelessWidget {
  final bool isDark;
  final Future<List<Map<String, dynamic>>> questsFuture;
  final Stream<List<Map<String, dynamic>>> notesStream;
  final Future<List<Map<String, dynamic>>> surveyHistoryFuture;

  const _BentoDashboard({
    required this.isDark,
    required this.questsFuture,
    required this.notesStream,
    required this.surveyHistoryFuture,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 192,
      child: Row(
        children: [
          // LEFT SQUARE — Quest / Badge
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: questsFuture,
              builder: (context, snapshot) {
                final quest = (snapshot.hasData && snapshot.data!.isNotEmpty)
                    ? snapshot.data!.first
                    : null;
                final progress = quest != null && quest['progress'] is num
                    ? (quest['progress'] as num).toDouble() / 100
                    : 0.0;
                final title = quest?['title_tr'] ?? quest?['title'] ?? AppStrings.comingSoon;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push(AppRoutes.quests);
                  },
                  child: GlassPanel.bento(
                    height: 170,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Başlık + ok
                        Row(
                          children: [
                            Text(
                              AppStrings.questsTitle,
                              style: NeerTypography.overline.copyWith(
                                color: theme.primaryColor,
                                fontSize: 10,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.chevron_right_rounded, size: 16,
                              color: theme.primaryColor.withValues(alpha: 0.6)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Circular progress
                        SizedBox(
                          width: 46,
                          height: 46,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: 1.0,
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation(
                                  isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.06),
                                ),
                              ),
                              CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                                strokeCap: StrokeCap.round,
                              ),
                              Icon(
                                progress >= 1.0
                                    ? Icons.emoji_events_rounded
                                    : Icons.flag_rounded,
                                color: theme.primaryColor,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Görev adı
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: NeerTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // İlerleme barı
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: 3,
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                            valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: NeerTypography.caption.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 10),

          // RIGHT COLUMN — Two stacked rectangles
          Expanded(
            child: Column(
              children: [
                // Top card — Last Review (üste)
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: surveyHistoryFuture,
                    builder: (context, snapshot) {
                      final review = (snapshot.hasData && snapshot.data!.isNotEmpty)
                          ? snapshot.data!.first
                          : null;
                      final score = review != null && review['rating'] is num
                          ? (review['rating'] as num).toDouble()
                          : 0.0;
                      final placeName = review?['location_name'] ?? AppStrings.noReviewsYet;

                      return AnimatedPress(
                        onTap: () => context.push(AppRoutes.myReviews),
                        child: GlassPanel.bento(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Başlık + ok
                              Row(children: [
                                Icon(Icons.star_rounded, size: 13, color: NeerColors.warning),
                                const SizedBox(width: 4),
                                Text(AppStrings.myReviewsTitle,
                                  style: NeerTypography.overline.copyWith(
                                    color: NeerColors.warning, fontSize: 9, letterSpacing: 0.6)),
                                const Spacer(),
                                Icon(Icons.chevron_right_rounded, size: 13,
                                  color: NeerColors.warning.withValues(alpha: 0.6)),
                              ]),
                              const SizedBox(height: 5),
                              Row(children: [
                                Icon(Icons.star_rounded, size: 14, color: NeerColors.warning),
                                const SizedBox(width: 4),
                                Flexible(child: Text(
                                  score > 0 ? score.toStringAsFixed(1) : "-",
                                  style: NeerTypography.h3.copyWith(
                                    fontSize: 15, fontWeight: FontWeight.w800,
                                    color: NeerColors.warning,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                )),
                              ]),
                              const SizedBox(height: 4),
                              Text(placeName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: NeerTypography.caption.copyWith(
                                  fontWeight: FontWeight.w500, fontSize: 11,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                                )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Bottom card — Last Note (alta)
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: notesStream,
                    builder: (context, snapshot) {
                      final note = (snapshot.hasData && snapshot.data!.isNotEmpty)
                          ? snapshot.data!.first
                          : null;
                      final noteText = note?['content'] ?? note?['text'] ?? AppStrings.noNotesYet;

                      return AnimatedPress(
                        onTap: () => context.push(AppRoutes.myNotes),
                        child: GlassPanel.bento(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Başlık + ok
                              Row(children: [
                                Icon(Icons.edit_note_rounded, size: 13,
                                  color: theme.primaryColor),
                                const SizedBox(width: 4),
                                Text(AppStrings.myNotes,
                                  style: NeerTypography.overline.copyWith(
                                    color: theme.primaryColor, fontSize: 9, letterSpacing: 0.6)),
                                const Spacer(),
                                Icon(Icons.chevron_right_rounded, size: 13,
                                  color: theme.primaryColor.withValues(alpha: 0.6)),
                              ]),
                              const SizedBox(height: 5),
                              Text(noteText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: NeerTypography.caption.copyWith(
                                  fontStyle: FontStyle.italic, fontSize: 11, height: 1.3,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.70),
                                )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// COLLAPSED HEADER HELPERS
// ==========================================
class _AvatarRingSmall extends StatelessWidget {
  final String imageUrl;
  const _AvatarRingSmall({required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
      ),
      child: ClipOval(
        child: Image.network(imageUrl, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Colors.white.withValues(alpha: 0.2))),
      ),
    );
  }
}

class _NeerScoreRingSmall extends StatelessWidget {
  final double score;
  final String label;
  const _NeerScoreRingSmall({required this.score, required this.label});
  @override
  Widget build(BuildContext context) {
    final color = score >= 8.0 ? NeerColors.success : score >= 5.0 ? NeerColors.warning : NeerColors.error;
    return SizedBox(
      width: 32, height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 1.0, strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.10)),
          ),
          CircularProgressIndicator(
            value: (score / 10.0).clamp(0.0, 1.0), strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(color),
            strokeCap: StrokeCap.round,
          ),
          Text(score.toStringAsFixed(1),
            style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
