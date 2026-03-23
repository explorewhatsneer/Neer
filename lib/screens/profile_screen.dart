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
import '../widgets/common/glass_button.dart';
import '../widgets/common/glass_panel.dart';
import '../widgets/common/animated_press.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/common/animated_list_item.dart';
import '../widgets/common/masonry_gallery.dart';
import '../widgets/friend/friend_profile_widgets.dart' show FriendEmptyCard;
import '../widgets/common/app_cached_image.dart';

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

  late Future<List<Map<String, dynamic>>> _badgesFuture;
  late Future<List<Map<String, dynamic>>> _allBadgeDefsFuture;
  late Future<List<Map<String, dynamic>>> _activeQuestsFuture;
  late Future<Map<String, dynamic>> _identityStatsFuture;

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

    _badgesFuture = _supabaseService.getUserBadges(_uid);
    _allBadgeDefsFuture = _supabaseService.getAllBadgeDefinitions();
    _activeQuestsFuture = _supabaseService.getUserActiveQuests(_uid);
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
      return GradientScaffold(body: const ShimmerList(itemCount: 5));
    }

    final String displayImage = (user?.profileImage != null && user!.profileImage.isNotEmpty)
        ? user.profileImage
        : "https://i.pravatar.cc/150?img=60";

    return GradientScaffold(
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
                    friendsCount: "0",
                    trustScore: (user?.trustScore ?? 5.0).toDouble(),
                    checkInCount: user?.checkInCount ?? 0,
                    activeDays: user?.activeDays ?? 0,
                    neerScoreLabel: user?.neerScoreLabel ?? AppStrings.neerScoreStandard,
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
                  _BadgeVitrin(
                    earnedFuture: _badgesFuture,
                    allFuture: _allBadgeDefsFuture,
                    onSeeAll: () {},
                  ),

                  const SizedBox(height: 16),

                  // ==========================================
                  // D. GÖREVLER PREVİEW
                  // ==========================================
                  _QuestPreviewWidget(
                    questsFuture: _activeQuestsFuture,
                    onSeeAll: () => _showAllQuests(context),
                  ),

                  const SizedBox(height: 28),

                  // ==========================================
                  // E. SPOTLIGHT — Single Carousel (Favorites Only)
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
                  // F. SIK UĞRANANLAR
                  // ==========================================
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _frequentPlacesFuture,
                    builder: (context, snapshot) {
                      final places = snapshot.data ?? [];
                      return _FrequentPlacesSection(
                        places: places.take(3).toList(),
                        onSeeAll: () => _showAllFrequentPlaces(context),
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
                Text(AppStrings.neerIdentityTitle,
                  style: NeerTypography.caption.copyWith(
                    color: Theme.of(context).disabledColor, letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _IdentityStat(value: stats?['total_places']?.toString() ?? '—', label: 'mekan'),
                    _IdentityStat(value: photoCount.toString(), label: 'kare'),
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
    return Expanded(
      child: Column(
        children: [
          Text(value, style: NeerTypography.h2.copyWith(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: NeerTypography.caption.copyWith(color: Theme.of(context).disabledColor, fontSize: 10)),
        ],
      ),
    );
  }
}

// ==========================================
// ROZET VİTRİNİ
// ==========================================
class _BadgeVitrin extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> earnedFuture;
  final Future<List<Map<String, dynamic>>> allFuture;
  final VoidCallback onSeeAll;
  const _BadgeVitrin({required this.earnedFuture, required this.allFuture, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([earnedFuture, allFuture]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final earned = snapshot.data![0] as List<Map<String, dynamic>>;
        final all = snapshot.data![1] as List<Map<String, dynamic>>;
        if (all.isEmpty) return const SizedBox.shrink();
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
                            width: 44, height: 44,
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
                              child: Text(
                                isEarned ? (badge['icon'] ?? '🏅') : '?',
                                style: TextStyle(
                                  fontSize: isEarned ? 20 : 14,
                                  color: isEarned ? null : Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEarned ? (badge['name_tr'] ?? '') : '???',
                            style: NeerTypography.caption.copyWith(
                              color: isEarned ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
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
      },
    );
  }
}

// ==========================================
// GÖREVLER PREVİEW
// ==========================================
class _QuestPreviewWidget extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> questsFuture;
  final VoidCallback onSeeAll;
  const _QuestPreviewWidget({required this.questsFuture, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: questsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
        final quests = snapshot.data!;
        final daily = quests.where((q) => q['type'] == 'daily').take(2).toList();
        final weeklyList = quests.where((q) => q['type'] == 'weekly').toList();
        final epic = quests.where((q) =>
            q['type'] == 'epic' && (q['user_quests']?.first?['is_completed'] != true)).take(1).toList();
        return GlassPanel.card(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: AppStrings.questsTitle, onActionTap: onSeeAll),
              const SizedBox(height: 8),
              ...daily.map((q) => _QuestRow(quest: q)),
              if (weeklyList.isNotEmpty) _QuestRow(quest: weeklyList.first),
              if (epic.isNotEmpty) ...[
                const SizedBox(height: 6),
                _EpicQuestCard(quest: epic.first),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _QuestRow extends StatelessWidget {
  final Map<String, dynamic> quest;
  const _QuestRow({required this.quest});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userQuests = quest['user_quests'];
    final first = (userQuests is List && userQuests.isNotEmpty) ? userQuests.first : null;
    final progress = (first?['progress'] ?? 0) as int;
    final target = (quest['target_count'] ?? 1) as int;
    final isCompleted = first?['is_completed'] == true;
    final ratio = target > 0 ? progress / target : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 18, height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? theme.primaryColor.withValues(alpha: 0.25) : Colors.transparent,
              border: Border.all(
                color: isCompleted ? theme.primaryColor : Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: isCompleted ? Icon(Icons.check, size: 10, color: theme.primaryColor) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest['title_tr'] ?? quest['title_en'] ?? '',
                  style: NeerTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? theme.disabledColor : null,
                  ),
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0.0, 1.0), minHeight: 2,
                    backgroundColor: Colors.white.withValues(alpha: 0.07),
                    valueColor: AlwaysStoppedAnimation(isCompleted ? NeerColors.success : theme.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isCompleted ? '+${quest['ts_reward']} ✓' : '+${quest['ts_reward']}',
            style: NeerTypography.caption.copyWith(
              color: NeerColors.success.withValues(alpha: isCompleted ? 1.0 : 0.65),
              fontWeight: FontWeight.w600, fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _EpicQuestCard extends StatelessWidget {
  final Map<String, dynamic> quest;
  const _EpicQuestCard({required this.quest});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userQuests = quest['user_quests'];
    final first = (userQuests is List && userQuests.isNotEmpty) ? userQuests.first : null;
    final progress = (first?['progress'] ?? 0) as int;
    final target = (quest['target_count'] ?? 1) as int;
    final ratio = target > 0 ? progress / target : 0.0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('EPİK', style: NeerTypography.caption.copyWith(
                  color: theme.primaryColor, fontSize: 9, letterSpacing: 0.8,
                )),
              ),
              const Spacer(),
              Text('+${quest['ts_reward']} TS',
                style: NeerTypography.caption.copyWith(
                  color: NeerColors.success.withValues(alpha: 0.8), fontWeight: FontWeight.w600,
                )),
            ],
          ),
          const SizedBox(height: 8),
          Text(quest['title_tr'] ?? quest['title_en'] ?? '',
            style: NeerTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0), minHeight: 3,
              backgroundColor: Colors.white.withValues(alpha: 0.07),
              valueColor: AlwaysStoppedAnimation(theme.primaryColor),
            ),
          ),
          const SizedBox(height: 4),
          Text('$progress / $target',
            style: NeerTypography.caption.copyWith(color: theme.disabledColor, fontSize: 10)),
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
      onTap: () {},
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
                          style: NeerTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: NeerTypography.caption.copyWith(
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
                                    style: NeerTypography.caption.copyWith(
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
                                style: NeerTypography.caption.copyWith(
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
                                    color: NeerColors.warning,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    score > 0
                                        ? score.toStringAsFixed(1)
                                        : "-",
                                    style: NeerTypography.h3.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: NeerColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                placeName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: NeerTypography.caption.copyWith(
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
