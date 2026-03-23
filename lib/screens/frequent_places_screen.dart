import 'package:flutter/material.dart';
import '../core/neer_design_system.dart';
import '../core/app_strings.dart';
import '../main.dart';
import '../services/supabase_service.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/common/animated_press.dart';
import '../widgets/common/app_cached_image.dart';
import '../widgets/friend/friend_profile_widgets.dart' show FriendEmptyCard;

class FrequentPlacesScreen extends StatefulWidget {
  const FrequentPlacesScreen({super.key});
  @override
  State<FrequentPlacesScreen> createState() => _FrequentPlacesScreenState();
}

class _FrequentPlacesScreenState extends State<FrequentPlacesScreen> {
  final SupabaseService _service = SupabaseService();
  final String _uid = supabase.auth.currentUser!.id;
  late Future<List<Map<String, dynamic>>> _placesFuture;

  @override
  void initState() {
    super.initState();
    _placesFuture = _service.getFrequentPlaces(_uid);
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
                  Text(AppStrings.frequentPlacesFullTitle, style: NeerTypography.h3.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _placesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const ShimmerList(itemCount: 6);
                final places = snapshot.data!;
                if (places.isEmpty) {
                  return Center(
                    child: FriendEmptyCard(
                      icon: Icons.explore_off_rounded,
                      title: 'Mekan Yok',
                      subtitle: AppStrings.zeroFrequent,
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: places.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final p = places[i];
                    final rank = i + 1;
                    final name = p['place_name'] ?? p['name'] ?? '';
                    final img = p['image_url'] ?? p['image'] ?? '';
                    final visits = (p['visit_count'] as num?)?.toInt() ?? 0;
                    final opacity = rank <= 3 ? 1.0 : (1.0 - ((rank - 3) * 0.07)).clamp(0.4, 1.0);
                    return Opacity(
                      opacity: opacity,
                      child: AnimatedPress(
                        onTap: () {},
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(rank == 1 ? 16 : 12),
                          child: SizedBox(
                            height: rank == 1 ? 80 : 60,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                img.isNotEmpty
                                    ? AppCachedImage.cover(imageUrl: img)
                                    : Container(color: NeerColors.primary.withValues(alpha: 0.3)),
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [Color(0xBB000000), Color(0x33000000)],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        rank.toString(),
                                        style: TextStyle(
                                          color: rank == 1
                                              ? const Color(0xFFFFD700).withValues(alpha: 0.9)
                                              : Colors.white.withValues(alpha: 0.4),
                                          fontSize: rank == 1 ? 24 : 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(name,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.9),
                                            fontSize: rank == 1 ? 15 : 13,
                                            fontWeight: FontWeight.w600,
                                          )),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text('$visits', style: const TextStyle(
                                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600,
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
