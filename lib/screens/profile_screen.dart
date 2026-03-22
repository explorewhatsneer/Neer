import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../main.dart';

// CORE
import '../core/text_styles.dart';
import '../core/app_strings.dart';
import '../core/app_router.dart';
import '../core/constants.dart';

// MODELS & SERVICES
import '../models/post_model.dart';
import '../services/supabase_service.dart';
import '../providers/profile_provider.dart';

// WIDGETS
import '../widgets/profile/profile_components.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/feed/feed_widgets.dart';
import '../widgets/common/glass_button.dart';
import '../widgets/common/glass_panel.dart';
import '../widgets/common/animated_press.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/common/animated_list_item.dart';
import '../widgets/common/masonry_gallery.dart';
import '../widgets/friend/friend_profile_widgets.dart' show FriendEmptyCard;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();
  final String _uid = supabase.auth.currentUser!.id;

  late TabController _mainTabController;
  final ScrollController _scrollController = ScrollController();

  // Streams & Futures
  late Stream<List<Map<String, dynamic>>> _favoritesStream;
  late Stream<List<Map<String, dynamic>>> _notesStream;
  late Stream<List<String>> _photosStream;
  late Stream<List<PostModel>> _activityStream;

  late Future<List<Map<String, dynamic>>> _questsFuture;
  late Future<List<Map<String, dynamic>>> _frequentPlacesFuture;
  late Future<List<Map<String, dynamic>>> _surveyHistoryFuture;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 3, vsync: this);
    context.read<ProfileProvider>().loadProfile(_uid);

    _favoritesStream = _supabaseService.getUserFavorites(_uid);
    _notesStream = _supabaseService.getUserNotes(_uid);
    _photosStream = _supabaseService.getUserPhotos(_uid);
    _activityStream = _supabaseService.getUserActivityFeed(_uid);

    _questsFuture = _supabaseService.getUserQuests(_uid);
    _frequentPlacesFuture = _supabaseService.getFrequentPlaces(_uid);
    _surveyHistoryFuture = _supabaseService.getSurveyHistory(_uid);
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

  void _showAllQuests(BuildContext context) {}
  void _showAllFavorites(BuildContext context) {}
  void _showAllFrequentPlaces(BuildContext context) {}
  void _showAllNotes(BuildContext context) {}
  void _showAllSurveys(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileProvider = context.watch<ProfileProvider>();
    final user = profileProvider.profile;

    if (profileProvider.isLoading) {
      return Scaffold(backgroundColor: Colors.transparent, body: const ShimmerList(itemCount: 5));
    }

    final String displayImage = (user?.profileImage != null && user!.profileImage.isNotEmpty)
        ? user.profileImage
        : "https://i.pravatar.cc/150?img=60";

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                expandedHeight: 340.0,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,

                actions: [
                  Center(
                    child: GlassButton.appBar(
                      icon: Icons.edit_rounded,
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await context.push(AppRoutes.editProfile);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: GlassButton.appBar(
                        icon: Icons.settings_rounded,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push(AppRoutes.settings);
                        },
                      ),
                    ),
                  ),
                ],

                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: ProfileHeader(
                    imageUrl: displayImage,
                    name: user?.name ?? AppStrings.nameless,
                    username: user?.username ?? "kullanici",
                    bio: user?.bio ?? "",
                    followersCount: (user?.followersCount ?? 0).toString(),
                    followingCount: (user?.followingCount ?? 0).toString(),
                    friendsCount: "42",
                    trustScore: (user?.trustScore ?? 5.0).toDouble(),
                  ),
                ),

                // PILL TABS
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    child: PillTabBar(
                      controller: _mainTabController,
                      tabs: [AppStrings.profileTab, AppStrings.activityTab, AppStrings.galleryTab],
                      onTap: (_) => HapticFeedback.selectionClick(),
                    ),
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

                  const SizedBox(height: 28),

                  // ==========================================
                  // B. SPOTLIGHT — Single Carousel (Favorites Only)
                  // ==========================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SectionHeader(
                      title: AppStrings.favoritesTitle,
                      icon: Icons.favorite_rounded,
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
                  // C. VERTICAL FLOW — Frequent Places
                  // ==========================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SectionHeader(
                      title: AppStrings.frequentPlacesTitle,
                      icon: Icons.emoji_events_rounded,
                      onActionTap: () => _showAllFrequentPlaces(context),
                    ),
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _frequentPlacesFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FriendEmptyCard(
                            icon: Icons.explore_off_rounded,
                            title: "Henüz Mekan Yok",
                            subtitle: "Sık ziyaretler burada listelenir.",
                          ),
                        );
                      }

                      var places = snapshot.data!;
                      var top3 = places.take(3).toList();
                      var others = places.skip(3).take(7).toList();

                      return Column(
                        children: [
                          // Podium (1, 2, 3)
                          RankingPodium(
                            top3Places: top3,
                            onTap: (id, name, img) => context.push(
                              '/venue/$id',
                              extra: {'venueName': name, 'imageUrl': img},
                            ),
                          ),

                          // Vertical list (4+) — glass rank rows
                          if (others.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ...others.asMap().entries.map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: SimpleRankRow(
                                rank: entry.key + 4,
                                name: entry.value['place_name'] ?? "",
                                count: (entry.value['visit_count'] as num).toInt(),
                                imgUrl: entry.value['image_url'] ?? "",
                                onTap: () => context.push(
                                  '/venue/${_findPlaceId(entry.value)}',
                                  extra: {
                                    'venueName': entry.value['place_name'] ?? "",
                                    'imageUrl': entry.value['image_url'] ?? "",
                                  },
                                ),
                              ),
                            )),
                          ],
                        ],
                      );
                    },
                  ),

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
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDate(dynamic date) {
    if (date == null) return "";
    if (date is DateTime) return "${date.day}.${date.month}.${date.year}";
    if (date is String) {
      try {
        final dt = DateTime.parse(date);
        return "${dt.day}.${dt.month}.${dt.year}";
      } catch (e) {
        return date;
      }
    }
    return "";
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
      height: 170,
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
                final title = quest?['title'] ?? AppStrings.comingSoon;

                return AnimatedPress(
                  onTap: () {},
                  useHeavyHaptic: true,
                  child: GlassPanel.bento(
                    height: 170,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Circular progress
                        SizedBox(
                          width: 52,
                          height: 52,
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
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: AppTextStyles.caption.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w800,
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
                // Top card — Last Note
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: notesStream,
                    builder: (context, snapshot) {
                      final note = (snapshot.hasData && snapshot.data!.isNotEmpty)
                          ? snapshot.data!.first
                          : null;
                      final noteText = note?['content'] ?? AppStrings.notebookEmpty;

                      return AnimatedPress(
                        onTap: () {},
                        child: GlassPanel.bento(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.edit_note_rounded,
                                    size: 16,
                                    color: theme.primaryColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppStrings.myNotes,
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: theme.primaryColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                noteText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                  height: 1.3,
                                  color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Bottom card — Last Review
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
                        onTap: () {},
                        child: GlassPanel.bento(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    score > 0
                                        ? score.toStringAsFixed(1)
                                        : "-",
                                    style: AppTextStyles.h3.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                placeName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                                ),
                              ),
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
