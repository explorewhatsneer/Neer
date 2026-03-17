import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../widgets/common/glass_button.dart';
import '../services/supabase_service.dart';

// CORE
import '../core/text_styles.dart';
import '../core/app_strings.dart';
import '../core/app_router.dart';

// MODELS & SCREENS
import '../models/post_model.dart';

// WIDGETS
import '../widgets/friend/friend_profile_header.dart'; 
import '../widgets/friend/friend_action_button.dart'; 
import '../widgets/friend/friend_private_view.dart';
import '../widgets/friend/friend_profile_widgets.dart' show FriendEmptyCard, MutualHistoryList; 

// 🔥 YENİ TASARIM BİLEŞENLERİ (StackedCardCarousel, RankingPodium vb.)
import '../widgets/profile/profile_components.dart'; 
import '../widgets/feed/feed_widgets.dart';
import '../widgets/common/app_cached_image.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/common/animated_list_item.dart';

class FriendProfileScreen extends StatefulWidget {
  final String targetUserId; 

  const FriendProfileScreen({super.key, required this.targetUserId});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> with SingleTickerProviderStateMixin {
  final _service = SupabaseService();
  
  late TabController _mainTabController;
  final ScrollController _scrollController = ScrollController();
  
  late String _currentUserId;
  final String _defaultProfileUrl = "https://i.pravatar.cc/300?img=12";
  
  // Durum Değişkenleri
  bool _isFollowing = false; 
  bool _isTargetPrivate = false; 
  String? _incomingRequestId; 
  String _incomingRequestName = ""; 
  String _targetUserName = ""; 
  
  // Streams & Futures
  late Stream<List<Map<String, dynamic>>> _favoritesStream;
  late Stream<List<Map<String, dynamic>>> _notesStream;
  late Stream<List<String>> _photosStream;
  late Stream<List<PostModel>> _activityStream;
  
  late Future<List<Map<String, dynamic>>> _frequentPlacesFuture;
  late Future<List<Map<String, dynamic>>> _surveyHistoryFuture;
  late Future<List<Map<String, dynamic>>> _mutualHistoryFuture;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 3, vsync: this);
    
    final user = _service.client.auth.currentUser;
    if (user != null) {
      _currentUserId = user.id;
      _initProfileData();
    } else {
      _currentUserId = "";
    }
    _initStreams();
  }

  // --- VERİ ÇEKME ---
  Future<void> _initProfileData() async {
    try {
      final profileData = await _service.getProfileFields(
        widget.targetUserId,
        'is_private, full_name, followers_count, following_count, check_in_count, photo_count, trust_score',
      );
      if (profileData == null) return;

      if (mounted) {
        setState(() {
          _isTargetPrivate = profileData['is_private'] ?? false;
          _targetUserName = profileData['full_name'] ?? "Kullanıcı";
        });
      }

      final isFollowingResult = await _service.isFollowing(_currentUserId, widget.targetUserId);

      if (mounted) {
        setState(() => _isFollowing = isFollowingResult);
      }

      final req = await _service.getIncomingFollowRequest(widget.targetUserId, _currentUserId);

      if (req != null && mounted) {
        setState(() {
          _incomingRequestId = req['id'].toString();
          _incomingRequestName = _targetUserName;
        });
      }
    } catch (e) {
      debugPrint("Profil Yükleme Hatası: $e");
    }
  }

  // --- YENİ VERİ FONKSİYONLARI ---
  Future<List<Map<String, dynamic>>> _getFrequentPlaces() async {
    return _service.getFrequentPlaces(widget.targetUserId);
  }

  Future<List<Map<String, dynamic>>> _getReviews() async {
    return _service.getUserPosts(
      userId: widget.targetUserId,
      type: 'review',
      selectFields: 'location_name, rating, review_comment, created_at',
      limit: 10,
    );
  }

  Future<List<Map<String, dynamic>>> _getMutualHistory() async {
    try {
      final myPlaces = await _service.getUserPostsNotNull(userId: _currentUserId, notNullField: 'location_name', selectFields: 'location_name', limit: 50);
      final theirPlaces = await _service.getUserPostsNotNull(userId: widget.targetUserId, notNullField: 'location_name', selectFields: 'location_name', limit: 50);

      Set<String> myLocs = myPlaces.map((e) => e['location_name'].toString()).toSet();
      Set<String> theirLocs = theirPlaces.map((e) => e['location_name'].toString()).toSet();
      final common = myLocs.intersection(theirLocs).toList();

      if (common.isEmpty) return [];

      return common.map((loc) => {
        'type': 'place', 'title': loc, 'description': AppStrings.mutualHistory, 'date': ''
      }).toList();
    } catch (e) { return []; }
  }

  void _initStreams() {
    _favoritesStream = _service.getUserFavorites(widget.targetUserId);
    _notesStream = _service.getUserNotes(widget.targetUserId);
    _activityStream = _service.getUserActivityFeed(widget.targetUserId);
    _photosStream = _service.getUserPhotos(widget.targetUserId);
    
    _frequentPlacesFuture = _getFrequentPlaces();
    _surveyHistoryFuture = _getReviews();
    _mutualHistoryFuture = _getMutualHistory();
  }

  Future<void> _handleIncomingRequest(bool accept) async {
    HapticFeedback.mediumImpact();
    final reqId = _incomingRequestId;
    setState(() => _incomingRequestId = null);
    if (reqId == null) return;

    if (accept) {
      final result = await _service.acceptFollowRequest(reqId, widget.targetUserId, _currentUserId);
      if (result.isFailure && mounted) {
        setState(() => _incomingRequestId = reqId);
      }
    } else {
      final result = await _service.declineFollowRequest(reqId);
      if (result.isFailure && mounted) {
        setState(() => _incomingRequestId = reqId);
      }
    }
  }

  // --- UI HELPER FONKSİYONLARI ---
  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(color: theme.cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2))),
              _buildOptionItem(context, Icons.ios_share_rounded, "Profili Paylaş", () {}),
              _buildOptionItem(context, Icons.flag_rounded, "Şikayet Et", () {}, isDestructive: true),
              _buildOptionItem(context, Icons.block_rounded, "Engelle", () {}, isDestructive: true),
            ],
          ),
        );
      }
    );
  }

  Widget _buildOptionItem(BuildContext context, IconData icon, String text, VoidCallback onTap, {bool isDestructive = false}) {
    final theme = Theme.of(context);
    final color = isDestructive ? Colors.redAccent : theme.textTheme.bodyLarge?.color;
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: (isDestructive ? Colors.red : theme.primaryColor).withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: isDestructive ? Colors.red : theme.primaryColor, size: 20)),
      title: Text(text, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: color)),
      onTap: () { Navigator.pop(context); onTap(); },
    );
  }


  void _genericBottomSheet(BuildContext context, String title, Widget content) { 
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => DraggableScrollableSheet(initialChildSize: 0.6, builder: (_, c) => Container(decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))), child: Column(children: [const SizedBox(height: 10), Padding(padding: const EdgeInsets.all(20), child: Text(title, style: AppTextStyles.h3)), Expanded(child: content)])))); 
  }
  
  void _showAllMutualHistory(BuildContext context) => _genericBottomSheet(context, AppStrings.mutualHistory, FutureBuilder(future: _mutualHistoryFuture, builder: (c, s) => MutualHistoryList(items: s.data ?? [])));
  
  // Detay sayfaları için placeholderlar (Tıklandığında açılacak sayfalar)
  void _showAllFrequentPlaces(BuildContext context) { /* BottomSheet Açılabilir */ }
  void _showAllFavorites(BuildContext context) { /* BottomSheet Açılabilir */ }
  void _showAllNotes(BuildContext context) { /* BottomSheet Açılabilir */ }
  void _showAllSurveys(BuildContext context) { /* BottomSheet Açılabilir */ }

  String _findPlaceId(Map<String, dynamic> data) {
    if (data['placeId'] != null) return data['placeId'].toString();
    if (data['venueId'] != null) return data['venueId'].toString();
    if (data['id'] != null) return data['id'].toString();
    return (data['place_name'] ?? data['location_name'] ?? data['name'] ?? "").toString().toLowerCase().replaceAll(' ', '_');
  }

  // --- TAB 1: GENEL BAKIŞ (YENİLENMİŞ TASARIM) ---
  Widget _buildGeneralTab(BuildContext context, Map<String, dynamic> userData, ThemeData theme) {
    bool canViewContent = !_isTargetPrivate || _isFollowing;
    
    return Builder(builder: (BuildContext innerContext) {
      return CustomScrollView(
        key: const PageStorageKey<String>('friendTab1'),
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(innerContext)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 120), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // Takip/Mesaj Butonları
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(children: [
                        Expanded(child: FriendActionButton(targetUserId: widget.targetUserId, currentUserId: _currentUserId, isTargetPrivate: _isTargetPrivate, onStatusChanged: (status) => setState(() => _isFollowing = (status == 'following' || status == 'friend')))),
                        if (canViewContent) ...[const SizedBox(width: 10), Expanded(child: SizedBox(height: 45, child: OutlinedButton.icon(onPressed: () => context.push(AppRoutes.chat, extra: {'userId': widget.targetUserId, 'userName': userData['full_name'], 'userImage': userData['avatar_url']}), icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20), label: Text(AppStrings.message), style: OutlinedButton.styleFrom(foregroundColor: theme.textTheme.bodyLarge?.color, side: BorderSide(color: theme.dividerColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))))]
                    ]),
                  ),
                  const SizedBox(height: 30),

                  if (canViewContent) ...[
                      // 1. ORTAK GEÇMİŞ
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SectionHeader(title: AppStrings.mutualHistory, icon: Icons.history_edu_rounded, onActionTap: () => _showAllMutualHistory(context)),
                      ),
                      FutureBuilder<List<Map<String, dynamic>>>(future: _mutualHistoryFuture, builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) return Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: MutualHistoryList(items: snapshot.data!.take(2).toList()));
                          return Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: FriendEmptyCard(icon: Icons.timeline_rounded, title: "Henüz Ortak Anı Yok", subtitle: "Birlikte keşfettiğiniz mekanlar burada listelenecek."));
                      }),
                      const SizedBox(height: 30),

                      // 2. SIK UĞRANANLAR (Podyum)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SectionHeader(title: AppStrings.theirFrequentPlaces, icon: Icons.place_rounded, onActionTap: () => _showAllFrequentPlaces(context)),
                      ),
                      FutureBuilder<List<Map<String, dynamic>>>(future: _frequentPlacesFuture, builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) return Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: FriendEmptyCard(icon: Icons.explore_off_rounded, title: "Henüz Mekan Yok", subtitle: "Sık ziyaret ettiği mekanlar oluştuğunda burada görünecek."));
                          
                          var places = snapshot.data!;
                          var top3 = places.take(3).toList();
                          var others = places.skip(3).toList();

                          return Column(
                            children: [
                              RankingPodium(
                                top3Places: top3, 
                                onTap: (id, name, img) => context.push('/venue/$id', extra: {'venueName': name, 'imageUrl': img})
                              ),
                              if (others.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    children: others.asMap().entries.map((entry) => SimpleRankRow(
                                      rank: entry.key + 4,
                                      name: entry.value['place_name'] ?? "Bilinmeyen",
                                      count: (entry.value['visit_count'] as num?)?.toInt() ?? 0,
                                      imgUrl: entry.value['image_url'] ?? "https://picsum.photos/200",
                                      onTap: () => context.push('/venue/${_findPlaceId(entry.value)}', extra: {'venueName': entry.value['place_name'] ?? "Mekan", 'imageUrl': entry.value['image_url'] ?? "https://picsum.photos/200"})
                                    )).toList(),
                                  ),
                                )
                              ]
                            ],
                          );
                      }),
                      const SizedBox(height: 30),

                      // 3. FAVORİLER (StackedCardCarousel)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SectionHeader(title: AppStrings.theirFavorites, icon: Icons.favorite_rounded, onActionTap: () => _showAllFavorites(context)),
                      ),
                      StreamBuilder<List<Map<String, dynamic>>>(stream: _favoritesStream, builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) return Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: FriendEmptyCard(icon: Icons.favorite_border_rounded, title: "Favori Listesi Boş", subtitle: "Henüz favorilerine eklediği bir mekan bulunmuyor."));
                          
                          return StackedCardCarousel(
                            itemCount: snapshot.data!.length,
                            height: 300, 
                            itemBuilder: (context, index) {
                              var fav = snapshot.data![index];
                              return VerticalPlaceCard(
                                name: fav['name'] ?? 'Mekan',
                                rating: (fav['rating'] is num) ? (fav['rating'] as num).toStringAsFixed(1) : "0.0",
                                imgUrl: fav['image'] ?? "https://picsum.photos/400",
                                onTap: () => context.push('/venue/${_findPlaceId(fav)}', extra: {'venueName': fav['name'] ?? 'Mekan', 'imageUrl': fav['image'] ?? "https://picsum.photos/400"})
                              );
                            },
                          );
                      }),
                      const SizedBox(height: 30),

                      // 4. NOTLAR (StackedCardCarousel + PP)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SectionHeader(title: AppStrings.theirNotes, icon: Icons.edit_note_rounded, onActionTap: () => _showAllNotes(context)),
                      ),
                      StreamBuilder<List<Map<String, dynamic>>>(stream: _notesStream, builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) return Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: FriendEmptyCard(icon: Icons.note_alt_rounded, title: "Not Paylaşılmamış", subtitle: "Henüz herhangi bir mekana not bırakmamış."));
                          
                          return StackedCardCarousel(
                            itemCount: snapshot.data!.length,
                            height: 280, 
                            itemBuilder: (context, index) {
                              var note = snapshot.data![index];
                              return VerticalNoteCard(
                                placeName: note['place_name'] ?? "Mekan",
                                note: note['content'] ?? "",
                                date: _formatDate(note['date']),
                                profileImg: userData['avatar_url'] ?? _defaultProfileUrl,
                                onTap: () => context.push('/venue/${_findPlaceId(note)}', extra: {'venueName': note['place_name'] ?? "Mekan", 'imageUrl': "https://picsum.photos/200"})
                              );
                            },
                          );
                      }),
                      const SizedBox(height: 30),

                      // 5. DEĞERLENDİRMELER (StackedCardCarousel)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SectionHeader(title: AppStrings.theirSurveys, icon: Icons.star_rate_rounded, onActionTap: () => _showAllSurveys(context)),
                      ),
                      FutureBuilder<List<Map<String, dynamic>>>(future: _surveyHistoryFuture, builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) return Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: FriendEmptyCard(icon: Icons.rate_review_outlined, title: "Değerlendirme Yapılmamış", subtitle: "Henüz hiçbir mekana puan veya yorum bırakmamış."));
                          
                          return StackedCardCarousel(
                            itemCount: snapshot.data!.length,
                            height: 240, // Yatay kart olduğu için kısa
                            itemBuilder: (context, index) {
                              var rev = snapshot.data![index];
                              return DetailedReviewCard(
                                placeName: rev['location_name'] ?? "Mekan", 
                                score: (rev['rating'] is num) ? (rev['rating'] as num).toDouble() : 0.0, 
                                date: _formatDate(rev['created_at']), 
                                onTap: () => context.push('/venue/${_findPlaceId(rev)}', extra: {'venueName': rev['location_name'] ?? "Mekan", 'imageUrl': "https://picsum.photos/200"})
                              );
                            },
                          );
                      }),
                    
                  ] else ...[const SizedBox(height: 50), const FriendPrivateView()]
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  // --- TAB 2: AKTİVİTE ---
  Widget _buildActivityTab(ThemeData theme) {
    return Builder(builder: (BuildContext context) {
      if (!canViewContent) return CustomScrollView(slivers: [SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)), SliverFillRemaining(child: const FriendPrivateView())]);
      return CustomScrollView(
        key: const PageStorageKey<String>('friendTab2'),
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          StreamBuilder<List<PostModel>>(
            stream: _activityStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const SliverToBoxAdapter(child: ShimmerList(itemCount: 4));
              if (!snapshot.hasData || snapshot.data!.isEmpty) return SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(top: 80), child: FriendEmptyCard(title: AppStrings.noActivity, subtitle: AppStrings.noActivityDesc, icon: Icons.local_activity_rounded)));
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

  // --- TAB 3: GALERİ ---
  Widget _buildGalleryTab(ThemeData theme) {
    return Builder(builder: (BuildContext context) {
      if (!canViewContent) return CustomScrollView(slivers: [SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)), SliverFillRemaining(child: const FriendPrivateView())]);
      return CustomScrollView(
        key: const PageStorageKey<String>('friendTab3'),
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          StreamBuilder<List<String>>(
            stream: _photosStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) return SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(top: 80), child: FriendEmptyCard(title: AppStrings.galleryEmpty, subtitle: AppStrings.galleryEmptyDesc, icon: Icons.photo_library_rounded)));
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
                    return AppCachedImage.cover(
                      imageUrl: photos[index],
                      borderRadius: 12,
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

  // --- 🔥 ANA BUILD METHODU ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _service.streamProfileAsList(widget.targetUserId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const ShimmerList(itemCount: 5);
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Kullanıcı bulunamadı"));
              }

              var userData = snapshot.data!.first;
              if (_targetUserName.isEmpty) _targetUserName = userData['full_name'] ?? "";

              return NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                    sliver: SliverAppBar(
                      expandedHeight: 300.0,
                      pinned: true,
                      backgroundColor: theme.scaffoldBackgroundColor,
                      automaticallyImplyLeading: false, 
                      
                      leading: Center(child: GlassButton.appBar(icon: Icons.arrow_back, onTap: () => Navigator.pop(context))),
                      actions: [Center(child: Padding(padding: const EdgeInsets.only(right: 16.0), child: GlassButton.appBar(icon: Icons.more_horiz_rounded, onTap: () => _showProfileOptions(context))))],

                      flexibleSpace: FlexibleSpaceBar(
                        background: FriendProfileHeader(
                          imageUrl: userData['avatar_url'] ?? _defaultProfileUrl, 
                          name: _targetUserName, 
                          username: userData['username'] ?? "", 
                          bio: userData['bio'] ?? "", 
                          isOnline: false,
                          followersCount: userData['followers_count'] ?? 0,
                          followingCount: userData['following_count'] ?? 0,
                          friendsCount: userData['friends_count'] ?? 0,
                          trustScore: (userData['trust_score'] ?? 5.0).toDouble(),
                        )
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
                            decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(30)),
                            child: TabBar(
                              controller: _mainTabController, 
                              indicator: BoxDecoration(borderRadius: BorderRadius.circular(30), color: theme.primaryColor, boxShadow: [BoxShadow(color: theme.primaryColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]),
                              indicatorSize: TabBarIndicatorSize.tab, 
                              dividerColor: Colors.transparent, 
                              labelColor: Colors.white, 
                              unselectedLabelColor: theme.disabledColor, 
                              labelStyle: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w800, fontSize: 13),
                              unselectedLabelStyle: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                              overlayColor: WidgetStateProperty.all(Colors.transparent),
                              tabs: [Tab(text: AppStrings.navProfile), Tab(text: AppStrings.activity), Tab(text: AppStrings.gallery)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                body: TabBarView(
                  controller: _mainTabController,
                  physics: const BouncingScrollPhysics(), 
                  children: [
                    _buildGeneralTab(context, userData, theme),
                    _buildActivityTab(theme),
                    _buildGalleryTab(theme),
                  ],
                ),
              );
            }
          ),

          if (_incomingRequestId != null)
            Positioned(
              left: 20, right: 20, bottom: 30,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: isDark ? Colors.black.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9), border: Border.all(color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 5))]),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("$_incomingRequestName seni takip etmek istiyor.", style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Row(children: [
                            Expanded(child: SizedBox(height: 40, child: ElevatedButton(onPressed: () => _handleIncomingRequest(true), style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(AppStrings.accept, style: const TextStyle(fontWeight: FontWeight.bold))))),
                            const SizedBox(width: 12),
                            Expanded(child: SizedBox(height: 40, child: OutlinedButton(onPressed: () => _handleIncomingRequest(false), style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error, side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.3)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(AppStrings.decline, style: const TextStyle(fontWeight: FontWeight.bold))))),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- Getters & Helpers ---
  bool get canViewContent => !_isTargetPrivate || _isFollowing;

  @override
  void dispose() {
    _mainTabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDate(dynamic date) {
    if (date == null) return "";
    try {
      DateTime dt = DateTime.parse(date.toString());
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return "";
    }
  }
}