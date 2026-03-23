import 'package:flutter/material.dart';
import '../core/neer_design_system.dart';
import '../core/app_strings.dart';
import '../main.dart';
import '../services/supabase_service.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/feed/feed_widgets.dart';
import '../widgets/friend/friend_profile_widgets.dart' show FriendEmptyCard;
import '../models/post_model.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});
  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final SupabaseService _service = SupabaseService();
  final String _uid = supabase.auth.currentUser!.id;
  late Future<List<Map<String, dynamic>>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _service.getSurveyHistory(_uid);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(AppStrings.myReviewsTitle, style: NeerTypography.h3.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _reviewsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ShimmerList(itemCount: 5);
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: FriendEmptyCard(
                      icon: Icons.star_outline_rounded,
                      title: AppStrings.noSurveys,
                      subtitle: AppStrings.noSurveysDesc,
                    ),
                  );
                }
                final reviews = snapshot.data!
                    .map((r) => PostModel.fromMap({...r, 'type': 'review', 'user_id': _uid}))
                    .toList();
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => FeedReviewCard(post: reviews[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
