import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';

// CORE IMPORTLARI
import '../../core/theme_styles.dart'; 
import '../../core/text_styles.dart';
import '../../core/app_strings.dart'; 

import '../../models/user_model.dart';
import 'search_widgets.dart'; 

import '../../screens/friend_profile_screen.dart';

class SearchModalContent extends StatefulWidget {
  const SearchModalContent({super.key});

  @override
  State<SearchModalContent> createState() => _SearchModalContentState();
}

class _SearchModalContentState extends State<SearchModalContent> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  
  String _query = "";
  List<UserModel> _userResults = []; 
  List<Map<String, dynamic>> _placeResults = []; 
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String val) async {
    final query = val.trim();
    
    setState(() {
      _query = query;
      _isSearching = true;
    });

    if (query.isNotEmpty) {
      try {
        // 1. KULLANICILARI ARA
        final userResponse = await _supabase
            .from('profiles')
            .select() // Tüm sütunları çekiyoruz (trust_score dahil)
            .ilike('search_key', '%${query.toLowerCase()}%') 
            .limit(10);
            
        // 2. MEKANLARI ARA
        final placeResponse = await _supabase
            .from('places')
            .select()
            .ilike('name', '%$query%') 
            .limit(10);

        if (mounted) {
          setState(() {
            _userResults = (userResponse as List)
                .map((e) => UserModel.fromMap(e))
                .toList();
            
            _placeResults = List<Map<String, dynamic>>.from(placeResponse);
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isSearching = false);
      }
    } else {
      if (mounted) {
        setState(() {
          _userResults = [];
          _placeResults = [];
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85, 
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 40, offset: const Offset(0, -10))
                ],
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1)),
              ),
              child: Column(
                children: [
                  // --- HEADER ---
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: theme.dividerColor.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  // --- ARAMA INPUT ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.cardColor, 
                        borderRadius: BorderRadius.circular(16),
                        border: isDark ? Border.all(color: Colors.white12) : null,
                        boxShadow: isDark ? [] : AppThemeStyles.shadowLow,
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true, 
                        onChanged: _performSearch,
                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                        cursorColor: theme.primaryColor,
                        decoration: InputDecoration(
                          hintText: AppStrings.searchHint, 
                          hintStyle: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor),
                          prefixIcon: Icon(Icons.search_rounded, color: theme.primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.close_rounded, color: theme.disabledColor),
                            onPressed: () => Navigator.pop(context), 
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- TAB BAR ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    height: 45,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.1), 
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      labelColor: theme.textTheme.bodyLarge?.color, 
                      unselectedLabelColor: theme.disabledColor, 
                      labelStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800, fontSize: 13),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(text: AppStrings.placesHeading),
                        Tab(text: AppStrings.peopleHeading),
                      ],
                      onTap: (_) => HapticFeedback.selectionClick(), 
                    ),
                  ),

                  const SizedBox(height: 10),

                  // --- LİSTE ---
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPlacesList(theme),
                        _buildPeopleList(theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- MEKAN LİSTESİ ---
  Widget _buildPlacesList(ThemeData theme) {
    if (_query.isEmpty) return _buildEmptyState(AppStrings.startTyping, Icons.map_rounded, theme);
    if (_isSearching) return Center(child: CircularProgressIndicator(color: theme.primaryColor));
    if (_placeResults.isEmpty) return _buildEmptyState(AppStrings.noPlaceFound, Icons.location_off_rounded, theme);

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: _placeResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        var data = _placeResults[index];
        return PlaceResultCard(
          name: data['name'] ?? 'Mekan',
          category: data['category'] ?? 'Genel',
          address: AppStrings.location,
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context, {
              'lat': data['latitude'], 'lng': data['longitude'], 'name': data['name'],
              'id': data['id'], 'type': 'place', 'data': 'data'
            });
          },
        );
      },
    );
  }

  // --- KİŞİ LİSTESİ (GÜNCELLENDİ) ---
  Widget _buildPeopleList(ThemeData theme) {
    if (_query.isEmpty) return _buildEmptyState(AppStrings.findFriends, Icons.people_alt_rounded, theme);
    if (_isSearching) return Center(child: CircularProgressIndicator(color: theme.primaryColor));
    
    final myUid = _supabase.auth.currentUser?.id;
    // Kendimi listede gösterme
    final results = _userResults.where((user) => user.uid != myUid).toList();

    if (results.isEmpty) return _buildEmptyState(AppStrings.noPersonFound, Icons.person_off_rounded, theme);

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = results[index];

        String finalImageUrl = user.profileImage;
        if (finalImageUrl.isEmpty || !finalImageUrl.startsWith('http')) {
          final encodedName = Uri.encodeComponent(user.name);
          finalImageUrl = "https://ui-avatars.com/api/?name=$encodedName&background=random&color=fff&size=200&bold=true";
        }

        return PersonResultCard(
          name: user.name,
          username: user.username,
          imageUrl: finalImageUrl,
          // 🔥 GÜNCELLEME: Buton yerine puan göstereceğimiz için puanı yolluyoruz
          trustScore: user.trustScore, 
          onTap: () {
            HapticFeedback.lightImpact();
            // Profil sayfasına git
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => FriendProfileScreen(targetUserId: user.uid))
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String text, IconData icon, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Container(
            padding: const EdgeInsets.all(20), 
            decoration: BoxDecoration(color: theme.dividerColor.withValues(alpha: 0.1), shape: BoxShape.circle), 
            child: Icon(icon, size: 40, color: theme.disabledColor)
          ), 
          const SizedBox(height: 15), 
          Text(text, style: AppTextStyles.bodyLarge.copyWith(color: theme.disabledColor, fontWeight: FontWeight.bold))
        ]
      )
    );
  }
}