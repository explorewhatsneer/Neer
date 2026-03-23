import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// CORE IMPORTLARI
import '../core/neer_design_system.dart';
import '../core/app_strings.dart';

// MODELLER
import '../models/post_model.dart';

// SERVİSLER
import '../services/supabase_service.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/animated_list_item.dart';

// WIDGETLAR
import '../widgets/feed/feed_widgets.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _service = SupabaseService();
  final ScrollController _scrollController = ScrollController();

  final List<PostModel> _posts = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isInitialLoading = true;
  static const int _pageSize = 20;

  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchFeed();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _fetchFeed() async {
    try {
      final uid = _service.client.auth.currentUser?.id ?? '';
      final response = await _service.getFeedPosts(
        userId: uid,
        filterMode: _selectedFilter,
        limit: _pageSize,
        offset: 0,
      );
      if (mounted) {
        setState(() {
          _posts.clear();
          _posts.addAll(response.map((e) => PostModel.fromMap(e)));
          _hasMore = response.length >= _pageSize;
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Feed Hatasi: $e");
      if (mounted) setState(() => _isInitialLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;

    try {
      final uid = _service.client.auth.currentUser?.id ?? '';
      final response = await _service.getFeedPosts(
        userId: uid,
        filterMode: _selectedFilter,
        limit: _pageSize,
        offset: _posts.length,
      );
      if (mounted) {
        setState(() {
          _posts.addAll(response.map((e) => PostModel.fromMap(e)));
          _hasMore = response.length >= _pageSize;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      debugPrint("Feed loadMore hatası: $e");
      _isLoadingMore = false;
    }
  }

  void _onFilterChanged(String newFilter) {
    if (_selectedFilter == newFilter) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedFilter = newFilter;
      _isInitialLoading = true;
      _hasMore = true;
    });
    _fetchFeed();
  }

  Future<void> _refreshFeed() async {
    HapticFeedback.lightImpact();
    _hasMore = true;
    await _fetchFeed();
  }

  void _showFilterMenu(BuildContext context, Offset offset) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final double left = offset.dx;
    final double top = offset.dy + 10;

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, left + 100, top + 100),
      color: isDark
          ? NeerColors.darkSurface.withValues(alpha: 0.90)
          : Colors.white.withValues(alpha: 0.92),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      shadowColor: NeerColors.primary.withValues(alpha: 0.15),
      items: [
        PopupMenuItem(
          value: 'all',
          child: _buildMenuItem(theme, "Takip Edilenler", Icons.people_outline_rounded, _selectedFilter == 'all'),
        ),
        PopupMenuItem(
          value: 'friends',
          child: _buildMenuItem(theme, "Sadece Arkadaşlar", Icons.star_border_rounded, _selectedFilter == 'friends'),
        ),
      ],
    ).then((value) {
      if (value != null) _onFilterChanged(value);
    });
  }

  Widget _buildMenuItem(ThemeData theme, String text, IconData icon, bool isSelected) {
    return Row(
      children: [
        Icon(icon, color: isSelected ? theme.primaryColor : theme.disabledColor, size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? theme.primaryColor : theme.textTheme.bodyLarge?.color,
          ),
        ),
        if (isSelected) ...[
          const Spacer(),
          Icon(Icons.check_rounded, color: theme.primaryColor, size: 18),
        ]
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GradientScaffold(
      // --- GLASS HEADER ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
            child: AppBar(
              backgroundColor: isDark
                  ? Colors.black.withValues(alpha: 0.30)
                  : Colors.white.withValues(alpha: 0.40),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              titleSpacing: 20,
              title: GestureDetector(
                onTapDown: (details) => _showFilterMenu(context, details.globalPosition),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontFamily: 'Visby',
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                        letterSpacing: -1.5,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, color: theme.primaryColor, size: 22),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      // --- AKIŞ LİSTESİ (infinite scroll) ---
      body: _isInitialLoading
          ? const ShimmerList(itemCount: 6)
          : _posts.isEmpty
              ? RefreshIndicator(
                  onRefresh: _refreshFeed,
                  color: theme.primaryColor,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      _buildStoryArea(theme, isDark),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                      EmptyState(
                        icon: _selectedFilter == 'friends' ? Icons.star_border_rounded : Icons.diversity_1_rounded,
                        title: _selectedFilter == 'friends'
                            ? "Henüz karşılıklı takipleştiğin arkadaşın yok"
                            : "Akışın çok sessiz!",
                        description: _selectedFilter == 'friends'
                            ? "Arkadaşların paylaşım yapmamışlar."
                            : "Arkadaşlarını takip ederek başla.",
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshFeed,
                  color: theme.primaryColor,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 120),
                    itemCount: _posts.length + 2, // +1 story area, +1 loading indicator
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildStoryArea(theme, isDark);
                      }

                      // Son eleman: loading indicator veya boş
                      if (index == _posts.length + 1) {
                        if (_isLoadingMore) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }

                      final post = _posts[index - 1];

                      return AnimatedListItem(
                        index: index - 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: post.type == 'review'
                              ? FeedReviewCard(post: post)
                              : FeedPostCard(post: post),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildStoryArea(ThemeData theme, bool isDark) {
    return Container(
      height: 128,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 1,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return StoryItem(index: index);
        },
      ),
    );
  }
}
