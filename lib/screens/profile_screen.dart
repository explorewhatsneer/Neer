import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // supabase nesnesi için

// CORE
import '../core/theme_styles.dart';
import '../core/text_styles.dart';
import '../core/app_strings.dart';
import '../core/app_router.dart';

// MODELLER & SERVİSLER
import '../models/post_model.dart';
import '../services/supabase_service.dart';
import '../providers/profile_provider.dart';

// WIDGETLAR
// 🔥 YENİ TASARIM COMPONENTLERİ (StackedCardCarousel, RankingPodium vb.)
import '../widgets/profile/profile_components.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/feed/feed_widgets.dart';
import '../widgets/common/glass_button.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/common/animated_list_item.dart';

// Import Çakışmasını Önleme
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

  // Streams & Futures (profil verisi hariç — o ProfileProvider'da)
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

    // Profil verisi Provider'dan yükleniyor
    context.read<ProfileProvider>().loadProfile(_uid);

    _favoritesStream = _supabaseService.getUserFavorites(_uid);
    _notesStream = _supabaseService.getUserNotes(_uid);
    _photosStream = _supabaseService.getUserPhotos(_uid);
    _activityStream = _supabaseService.getUserActivityFeed(_uid);

    _questsFuture = _supabaseService.getUserQuests(_uid);
    _frequentPlacesFuture = _supabaseService.getFrequentPlaces(_uid);
    _surveyHistoryFuture = _supabaseService.getSurveyHistory(_uid);
  }

  // --- YARDIMCI: ID BULUCU ---
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

  // --- POPUP FONKSİYONLARI ---
  void _showAllQuests(BuildContext context) { /* Gerekirse detay sayfası */ }
  void _showAllFavorites(BuildContext context) { /* Gerekirse detay sayfası */ }
  void _showAllFrequentPlaces(BuildContext context) { /* Gerekirse detay sayfası */ }
  void _showAllNotes(BuildContext context) { /* Gerekirse detay sayfası */ }
  void _showAllSurveys(BuildContext context) { /* Gerekirse detay sayfası */ }

  // --- ANA BUILD METHODU ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileProvider = context.watch<ProfileProvider>();
    final _user = profileProvider.profile;

    if (profileProvider.isLoading) {
      return Scaffold(backgroundColor: theme.scaffoldBackgroundColor, body: const ShimmerList(itemCount: 5));
    }

    final String displayImage = (_user?.profileImage != null && _user!.profileImage.isNotEmpty)
        ? _user.profileImage
        : "https://i.pravatar.cc/150?img=60";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                automaticallyImplyLeading: false, 
                
                actions: [
                  Center(
                    child: GlassButton.appBar(
                      icon: Icons.edit_rounded,
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        await context.push(AppRoutes.editProfile);
                        // ProfileProvider realtime stream otomatik güncelleyecek
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // AYARLAR BUTONU
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
                    name: _user?.name ?? AppStrings.nameless,
                    username: _user?.username ?? "kullanici",
                    bio: _user?.bio ?? "",
                    followersCount: (_user?.followersCount ?? 0).toString(),
                    followingCount: (_user?.followingCount ?? 0).toString(),
                    friendsCount: "42",
                    trustScore: (_user?.trustScore ?? 5.0).toDouble(),
                  ),
                ),
                
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor, 
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      boxShadow: [BoxShadow(color: Colors.transparent, blurRadius: 0)], 
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor, 
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TabBar(
                        controller: _mainTabController, 
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: theme.primaryColor, 
                          boxShadow: [BoxShadow(color: theme.primaryColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab, 
                        dividerColor: Colors.transparent, 
                        labelColor: Colors.white, 
                        unselectedLabelColor: theme.disabledColor, 
                        labelStyle: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w800, fontSize: 13),
                        unselectedLabelStyle: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                        onTap: (index) => HapticFeedback.selectionClick(),
                        tabs: [
                          Tab(text: AppStrings.profileTab), 
                          Tab(text: AppStrings.activityTab), 
                          Tab(text: AppStrings.galleryTab), 
                        ],
                      ),
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
            _buildProfileTab(theme, _user),
            _buildActivityTab(theme),
            _buildGalleryTab(theme),
          ],
        ),
      ),
    );
  }

// ... (Importlar aynı kalacak, sadece build metodunun içindeki sıralamayı değiştiriyoruz)

// ======================
// 🟢 TAB 1: PROFİL (YENİ SIRALAMA & GÖRÜNÜM)
// ======================
Widget _buildProfileTab(ThemeData theme, dynamic _user) {
  return Builder(builder: (BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey<String>('tab1'),
      slivers: [
        SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // 1. BAŞARI ROZETLERİ (GÖREVLER) - En Üstte, Kompakt
                SizedBox(
                  height: 60, // Rozet yüksekliği
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _questsFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink(); // Boşsa gösterme
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var q = snapshot.data![index];
                          return DynamicQuestCard(
                            title: q['title'] ?? 'Görev',
                            subtitle: q['subtitle'] ?? '',
                            progress: (q['progress'] is num) ? (q['progress'] as num).toDouble() : 0.0,
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

// 2. SIK UĞRANILANLAR (Podyum + Scrollable Mini Liste)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionHeader(title: AppStrings.frequentPlacesTitle, icon: Icons.emoji_events_rounded, onActionTap: () => _showAllFrequentPlaces(context)),
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _frequentPlacesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) return const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: FriendEmptyCard(icon: Icons.explore_off_rounded, title: "Henüz Mekan Yok", subtitle: "Sık ziyaretler burada listelenir."));
                    
                    var places = snapshot.data!;
                    var top3 = places.take(3).toList();
                    // 4. sıradan başla, en fazla 10. sıraya kadar al (toplam 7 eleman: 4,5,6,7,8,9,10)
                    var others = places.skip(3).take(7).toList(); 

                    return Column(
                      children: [
                        // PODYUM (1, 2, 3)
                        RankingPodium(
                          top3Places: top3, 
                          onTap: (id, name, img) => context.push('/venue/$id', extra: {'venueName': name, 'imageUrl': img})
                        ),
                        
                        // LİSTE (4 - 10 Arası)
                        if (others.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          // 🔥 KRİTİK NOKTA: Sadece 2 satır gösterecek yükseklik (yaklaşık 150-160px)
                          Container(
                            height: 160, 
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ListView.builder(
                              // İçerideki kaydırma fiziği
                              physics: const BouncingScrollPhysics(), 
                              padding: EdgeInsets.zero,
                              itemCount: others.length,
                              itemBuilder: (context, index) {
                                var entry = others[index];
                                return SimpleRankRow(
                                  rank: index + 4, // 4'ten başla
                                  name: entry['place_name'] ?? "",
                                  count: (entry['visit_count'] as num).toInt(),
                                  imgUrl: entry['image_url'] ?? "",
                                  onTap: () => context.push('/venue/${_findPlaceId(entry)}', extra: {'venueName': entry['place_name']??"", 'imageUrl': entry['image_url']??""}),
                                );
                              },
                            ),
                          )
                        ]
                      ],
                    );
                  },
                ),
                const SizedBox(height: 30),

                // 3. FAVORİ MEKANLAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionHeader(title: AppStrings.favoritesTitle, icon: Icons.favorite_rounded, onActionTap: () => _showAllFavorites(context)),
                ),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _favoritesStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) return Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: FriendEmptyCard(title: AppStrings.noFavorites, subtitle: AppStrings.noFavoritesDesc, icon: Icons.favorite_border_rounded));
                    
                    return StackedCardCarousel(
                      itemCount: snapshot.data!.length,
                      height: 300, 
                      itemBuilder: (context, index) {
                        var fav = snapshot.data![index];
                        return VerticalPlaceCard(
                          name: fav['place_name'] ?? 'Mekan',
                          rating: (fav['rating'] is num) ? (fav['rating'] as num).toStringAsFixed(1) : "0.0",
                          imgUrl: fav['image'] ?? "https://picsum.photos/400",
                          onTap: () => context.push('/venue/${_findPlaceId(fav)}', extra: {'venueName': fav['place_name'] ?? 'Mekan', 'imageUrl': fav['image'] ?? "https://picsum.photos/400"}),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 30),

                // 4. NOTLARIM (Yeni Sticky Note Tasarımı)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionHeader(title: AppStrings.myNotes, icon: Icons.edit_note_rounded, onActionTap: () => _showAllNotes(context)),
                ),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _notesStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) return Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: FriendEmptyCard(title: AppStrings.notebookEmpty, subtitle: AppStrings.notebookEmptyDesc, icon: Icons.note_alt_rounded));
                    
                    return StackedCardCarousel(
                      itemCount: snapshot.data!.length,
                      height: 280, 
                      itemBuilder: (context, index) {
                        var note = snapshot.data![index];
                        return VerticalNoteCard(
                          placeName: note['place_name'] ?? "Mekan",
                          note: note['content'] ?? "",
                          date: _formatDate(note['date']),
                          profileImg: _user?.profileImage ?? "https://i.pravatar.cc/150",
                          onTap: () => context.push('/venue/${_findPlaceId(note)}', extra: {'venueName': note['place_name'] ?? "Mekan", 'imageUrl': "https://picsum.photos/200"}),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 30),

                // 5. DEĞERLENDİRME GEÇMİŞİ (Yeni Kartlar)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SectionHeader(title: AppStrings.surveyHistoryTitle, icon: Icons.poll_rounded, onActionTap: () => _showAllSurveys(context)),
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _surveyHistoryFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) return Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: FriendEmptyCard(title: AppStrings.noSurveys, subtitle: AppStrings.noSurveysDesc, icon: Icons.analytics_outlined));                    
                    return StackedCardCarousel(
                      itemCount: snapshot.data!.length,
                      height: 240, // Daha kompakt
                      itemBuilder: (context, index) {
                        var survey = snapshot.data![index];
                        return DetailedReviewCard(
                          placeName: survey['location_name'] ?? 'Mekan', 
                          score: (survey['rating'] is num) ? (survey['rating'] as num).toDouble() : 0.0,
                          date: _formatDate(survey['created_at']),
                          onTap: () => context.push('/venue/${_findPlaceId(survey)}', extra: {'venueName': survey['location_name'] ?? "Mekan", 'imageUrl': "https://picsum.photos/200"}),
                        );
                      },
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
  // 🔵 TAB 2: AKTİVİTE
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
              if (snapshot.connectionState == ConnectionState.waiting) return const SliverToBoxAdapter(child: ShimmerList(itemCount: 4));
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(top: 80), child: FriendEmptyCard(title: AppStrings.noActivity, subtitle: AppStrings.noActivityUser, icon: Icons.local_activity_rounded)));
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
                        child: post.type == 'review' ? FeedReviewCard(post: post) : FeedPostCard(post: post),
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
  // 🟠 TAB 3: GALERİ
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
                return SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(top: 80), child: FriendEmptyCard(title: AppStrings.galleryEmpty, subtitle: AppStrings.galleryEmptyUser, icon: Icons.photo_library_rounded)));
              }
              var photos = snapshot.data!;
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, 
                    crossAxisSpacing: 10, 
                    mainAxisSpacing: 10, 
                    childAspectRatio: 1.0
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        photos[index], 
                        fit: BoxFit.cover,
                        loadingBuilder: (c, child, p) => p == null ? child : Container(color: theme.dividerColor.withValues(alpha: 0.1)),
                        errorBuilder: (c, e, s) => Container(color: theme.dividerColor, child: const Icon(Icons.error_outline)),
                      ),
                    );
                  }, childCount: photos.length),
                ),
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