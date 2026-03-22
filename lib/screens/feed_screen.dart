import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// CORE IMPORTLARI
import '../core/constants.dart';
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

  Future<List<PostModel>>? _feedFuture;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _feedFuture = _fetchFeed();
  }

  Future<List<PostModel>> _fetchFeed() async {
    try {
      final uid = _service.client.auth.currentUser?.id ?? '';
      final response = await _service.getFeedPosts(
        userId: uid,
        filterMode: _selectedFilter,
        limit: 50,
        offset: 0,
      );
      return response.map((e) => PostModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint("Feed Hatasi: $e");
      return [];
    }
  }

  void _onFilterChanged(String newFilter) {
    if (_selectedFilter == newFilter) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedFilter = newFilter;
      _feedFuture = _fetchFeed();
    });
  }

  Future<void> _refreshFeed() async {
    HapticFeedback.lightImpact();
    setState(() {
      _feedFuture = _fetchFeed();
    });
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
          ? AppColors.darkSurface.withValues(alpha: 0.90)
          : Colors.white.withValues(alpha: 0.92),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      shadowColor: AppColors.primary.withValues(alpha: 0.15),
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

    _feedFuture ??= _fetchFeed();

    return Scaffold(
      backgroundColor: Colors.transparent, // Gradient arka plan MainLayout'tan gelir

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

      // --- AKIŞ LİSTESİ ---
      body: FutureBuilder<List<PostModel>>(
        future: _feedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerList(itemCount: 6);
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return RefreshIndicator(
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
            );
          }

          List<PostModel> posts = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshFeed,
            color: theme.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 120),
              itemCount: posts.length + 1,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildStoryArea(theme, isDark);
                }

                PostModel post = posts[index - 1];

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
          );
        },
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
