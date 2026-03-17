import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// CORE IMPORTLARI
import '../core/theme_styles.dart'; 
import '../core/text_styles.dart'; 
import '../core/app_strings.dart'; 

// WIDGETLAR
import '../widgets/business/business_widgets.dart'; // venue klasörüne taşınmıştı
import '../widgets/common/active_users_sheet.dart'; // venue klasörüne taşınmıştı (Check et) veya common
import '../widgets/common/check_in_button.dart'; // venue klasörüne taşınmıştı
import '../widgets/common/glass_button.dart';
import '../widgets/common/app_cached_image.dart';

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
  bool isFavorite = false;
  late TabController _mainTabController;
  late TabController _mediaTabController;
  final ScrollController _scrollController = ScrollController();
  late String safeVenueId;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _mediaTabController = TabController(length: 2, vsync: this);
    safeVenueId = widget.venueId.isNotEmpty ? widget.venueId : "unknown_venue_123";
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _mediaTabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      
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
            // Yol Tarifi Butonu
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey[100], 
                borderRadius: AppThemeStyles.radius16
              ),
              child: IconButton(
                icon: Icon(Icons.navigation_rounded, color: theme.iconTheme.color), 
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  // Navigasyon başlat
                }
              ),
            ),
            const SizedBox(width: 16),
            
            // CHECK-IN BUTONU
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
              expandedHeight: 300.0,
              pinned: true,
              stretch: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
              
              // Geri Butonu (Glass)
              leading: Center(
                child: GlassButton.medium(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
              ),

              // Sağ Aksiyonlar (Glass)
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
                      builder: (context) => ActiveUsersSheet(
                        chatId: widget.venueId,
                      ),
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
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppCachedImage.cover(imageUrl: widget.imageUrl, height: 300),
                    // Gradyan Gölge (Yazı Okunurluğu İçin)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.1),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                            Colors.black.withValues(alpha: 0.9),
                          ],
                          stops: const [0.0, 0.4, 0.7, 1.0],
                        ),
                      ),
                    ),
                    
                    // İçerik
                    Positioned(
                      bottom: 70, 
                      left: 20, right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: theme.primaryColor, 
                              borderRadius: BorderRadius.circular(8)
                            ),
                            child: Text(
                              AppStrings.popular, // 🔥 Core String
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold, 
                                letterSpacing: 0.5
                              )
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.venueName, 
                            // 🔥 Core Style: H1/H2 (White)
                            style: AppTextStyles.h2.copyWith(
                              color: Colors.white, 
                              fontSize: 32, 
                              fontWeight: FontWeight.w900, 
                              height: 1.1
                            )
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.white70, size: 16),
                              SizedBox(width: 4),
                              Text("Koşuyolu, İstanbul", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // TAB BAR
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor, // Dinamik arka plan
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Center(
                    child: TabBar(
                      controller: _mainTabController,
                      labelColor: theme.primaryColor,
                      unselectedLabelColor: theme.disabledColor,
                      indicatorColor: theme.primaryColor,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorPadding: const EdgeInsets.only(bottom: 10),
                      // 🔥 Core Style: BodyMedium (Bold)
                      labelStyle: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w800, fontSize: 15),
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(text: AppStrings.overview), // 🔥 Core String
                        Tab(text: AppStrings.mediaGallery), // 🔥 Core String
                      ],
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PlaceStatsRow(),
          SectionHeader(title: AppStrings.upcomingEvents, icon: Icons.event_available_rounded),
          const EventTicketCard(),
          const SizedBox(height: 30),
          SectionHeader(title: AppStrings.historyWithPlace, icon: Icons.insights_rounded),
          const InteractionStatsGrid(),
          const SizedBox(height: 30),
          SectionHeader(title: AppStrings.regulars, icon: Icons.emoji_events_rounded),
          const VenueLeaderboard(),
          const SizedBox(height: 30),
          SectionHeader(title: AppStrings.friendsSay, icon: Icons.chat_bubble_rounded),
          const FriendNoteBubble(),
          const SizedBox(height: 30),
          SectionHeader(title: AppStrings.detailedRatings, icon: Icons.tune_rounded),
          const DetailedRatingBars(),
          const SizedBox(height: 30),
          const LocationQrRow(),
          const SizedBox(height: 20),
          
          Center(
            child: TextButton.icon(
              onPressed: (){
                HapticFeedback.lightImpact();
              }, 
              icon: Icon(Icons.flag_rounded, color: theme.disabledColor, size: 18),
              label: Text(AppStrings.reportIssue, style: TextStyle(color: theme.disabledColor)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- TAB 2: MEDYA ---
  Widget _buildMediaTab(ThemeData theme) {
    bool isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          height: 45,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.grey[200], // Dinamik renk
            borderRadius: BorderRadius.circular(25),
          ),
          child: TabBar(
            controller: _mediaTabController,
            indicator: BoxDecoration(
              color: theme.cardColor, // Kart rengi (Beyaz/Siyah)
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
              _buildPhotoGrid(isUser: false, theme: theme),
              _buildPhotoGrid(isUser: true, theme: theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoGrid({required bool isUser, required ThemeData theme}) {
    return GridView.builder(
      padding: const EdgeInsets.all(15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: 15,
      itemBuilder: (context, index) {
        return AppCachedImage.cover(
          imageUrl: "https://picsum.photos/300?random=${isUser ? index + 50 : index}",
          borderRadius: 15,
        );
      },
    );
  }
}