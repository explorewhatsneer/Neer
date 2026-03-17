import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// CORE IMPORTLARI
import '../core/text_styles.dart';
import '../core/app_strings.dart';

// MODELLER
import '../models/post_model.dart';

// SERVİSLER
import '../services/supabase_service.dart';
import '../widgets/common/shimmer_loading.dart';

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
  
  // 🔥 FİLTRE DURUMU: 'all' (Takip Edilenler) veya 'friends' (Sadece Arkadaşlar)
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

  // Filtre Değişince
  void _onFilterChanged(String newFilter) {
    if (_selectedFilter == newFilter) return; // Aynıysa işlem yapma

    HapticFeedback.mediumImpact();
    setState(() {
      _selectedFilter = newFilter;
      _feedFuture = _fetchFeed(); // Listeyi yenile
    });
  }

  // Yenileme (Pull to Refresh)
  Future<void> _refreshFeed() async {
    HapticFeedback.lightImpact();
    setState(() {
      _feedFuture = _fetchFeed();
    });
  }

  // 🔥 FİLTRE MENÜSÜNÜ GÖSTER
  void _showFilterMenu(BuildContext context, Offset offset) async {
    final theme = Theme.of(context);
    final double left = offset.dx;
    final double top = offset.dy + 10; // Biraz aşağıda açılması için

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, left + 100, top + 100),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
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
      if (value != null) {
        _onFilterChanged(value as String);
      }
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

    // initState çalışmazsa diye güvenlik
    _feedFuture ??= _fetchFeed();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, 
      
      // --- HEADER (GÜNCELLENDİ) ---
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor, 
        surfaceTintColor: Colors.transparent, 
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16, // Sol boşluk
        
        // 🔥 LOGO + FİLTRE OKU
        title: GestureDetector(
          onTapDown: (details) => _showFilterMenu(context, details.globalPosition),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Sadece içerik kadar yer kapla
            children: [
              Text(
                AppStrings.appName, 
                style: TextStyle(
                  fontFamily: 'Visby', 
                  color: theme.primaryColor, 
                  fontWeight: FontWeight.w900, 
                  fontSize: 32, 
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded, 
                color: theme.primaryColor, 
                size: 24
              ),
            ],
          ),
        ),
        
        // Sağ taraftaki butonu kaldırdık (actions: [])
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.dividerColor.withValues(alpha: 0.1), height: 1.0), 
        ),
      ),

      // --- AKIŞ LİSTESİ ---
      body: FutureBuilder<List<PostModel>>(
        future: _feedFuture,
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerList(itemCount: 6);
          }

          // BOŞ DURUM
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshFeed,
              color: theme.primaryColor,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _buildStoryArea(theme), 
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  
                  Icon(
                    _selectedFilter == 'friends' ? Icons.star_border_rounded : Icons.diversity_1_rounded, 
                    size: 80, 
                    color: theme.disabledColor.withValues(alpha: 0.3)
                  ),
                  const SizedBox(height: 16),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      _selectedFilter == 'friends' 
                        ? "Henüz karşılıklı takipleştiğin\narkadaşın yok veya paylaşım yapmamışlar."
                        : "Akışın çok sessiz!\nArkadaşlarını takip ederek başla.", 
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.disabledColor, 
                        height: 1.5,
                        fontWeight: FontWeight.w500
                      )
                    ),
                  ),
                ],
              ),
            );
          }

          // VERİ VAR
          List<PostModel> posts = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshFeed,
            color: theme.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100), 
              itemCount: posts.length + 1, 
              physics: const BouncingScrollPhysics(), 
              itemBuilder: (context, index) {
                
                if (index == 0) {
                  return Column(
                    children: [
                      _buildStoryArea(theme),
                      Divider(height: 1, thickness: 0.5, color: theme.dividerColor.withValues(alpha: 0.1)),
                    ],
                  );
                }

                PostModel post = posts[index - 1];

                if (post.type == 'review') {
                  return FeedReviewCard(post: post);
                } else {
                  return FeedPostCard(post: post);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoryArea(ThemeData theme) {
    return Container(
      height: 128, 
      width: double.infinity,
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 1, 
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return StoryItem(index: index); 
        },
      ),
    );
  }
}