import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback

// CORE IMPORTLARI 
import '../core/neer_design_system.dart';
import '../core/app_strings.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/animated_list_item.dart';

// 🔥 MODÜLER WIDGETLAR
import '../widgets/polls/review_card.dart';
import '../widgets/polls/rating_bottom_sheet.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key});

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- MOCK DATA ---
  final List<Map<String, dynamic>> _pendingReviews = [
    {
      "id": "1",
      "placeName": "Thru Koşuyolu",
      "category": "Kafe & Çalışma",
      "image": "https://picsum.photos/200?img=1",
      "date": "Dün, 19:30",
      "desc": "Check-in yaptın. Deneyimin nasıldı?",
    },
    {
      "id": "2",
      "placeName": "Voi Coffee Company",
      "category": "Kahve Dükkanı",
      "image": "https://picsum.photos/200?img=2",
      "date": "18 Haziran, 14:00",
      "desc": "Kahve molan bitti. Puanlamak ister misin?",
    }
  ];

  final List<Map<String, dynamic>> _completedReviews = [
    {
      "id": "101",
      "placeName": "Paolina Cocktail & Kitchen",
      "image": "https://picsum.photos/200?img=3",
      "date": "10 Haziran 2025",
      "rating": 4.8,
      "comment": "Kokteyller harikaydı, servis biraz yavaştı ama ortam çok iyi.",
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openRatingSheet(BuildContext context, String placeName) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RatingBottomSheet(placeName: placeName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GradientScaffold(

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppStrings.reviewsTitle, // 🔥 Core String
          // 🔥 Core Style: H3
          style: NeerTypography.h3.copyWith(fontSize: 20)
        ),
        leading: Center(
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: theme.cardColor, 
              shape: BoxShape.circle,
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5))
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(), 
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        
        // --- PREMIUM TAB BAR ---
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey.shade200, 
              borderRadius: BorderRadius.circular(25)
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: theme.cardColor, 
                borderRadius: BorderRadius.circular(25), 
                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
              ),
              labelColor: theme.textTheme.bodyLarge?.color,
              unselectedLabelColor: theme.disabledColor,
              // 🔥 Core Style: Caption (Bold)
              labelStyle: NeerTypography.caption.copyWith(fontWeight: FontWeight.w800, fontSize: 13),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              onTap: (index) => HapticFeedback.selectionClick(),
              tabs: [
                Tab(text: AppStrings.pendingTab), // 🔥 Core String
                Tab(text: AppStrings.historyTab), // 🔥 Core String
              ],
            ),
          ),
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(isPending: true, theme: theme),
          _buildList(isPending: false, theme: theme),
        ],
      ),
    );
  }

  // --- LİSTE OLUŞTURUCU ---
  Widget _buildList({required bool isPending, required ThemeData theme}) {
    List data = isPending ? _pendingReviews : _completedReviews;
    
    if (data.isEmpty) {
      return EmptyState(
        icon: isPending ? Icons.rate_review_outlined : Icons.check_circle_outline_rounded,
        title: AppStrings.listEmpty,
        description: isPending ? "Değerlendirme bekleyen mekan yok." : "Henüz değerlendirme yapmadın.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), 
      physics: const BouncingScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        var item = data[index];

        return AnimatedListItem(
          index: index,
          child: ReviewCard(
          placeName: item['placeName'],
          imageUrl: item['image'],
          date: item['date'],
          desc: isPending ? item['desc'] : item['comment'],
          category: isPending ? item['category'] : null,
          rating: isPending ? null : item['rating'],
          isCompleted: !isPending,
          onTap: isPending ? () => _openRatingSheet(context, item['placeName']) : null,
        ),
        );
      },
    );
  }
}