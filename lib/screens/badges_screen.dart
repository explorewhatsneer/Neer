import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../core/neer_design_system.dart';
import '../core/app_strings.dart';
import '../services/supabase_service.dart';
import '../widgets/common/glass_panel.dart';
import '../widgets/common/shimmer_loading.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});
  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  final _service = SupabaseService();
  final String _uid = supabase.auth.currentUser!.id;
  late Future<List<dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = Future.wait([
      _service.getUserBadges(_uid),
      _service.getAllBadgeDefinitions(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      animate: true,
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(AppStrings.badgesTitle, style: NeerTypography.h3.copyWith(color: Colors.white)),
              ]),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const ShimmerList(itemCount: 6);
                final earned = (snapshot.data![0] as List).cast<Map<String, dynamic>>();
                final all = (snapshot.data![1] as List).cast<Map<String, dynamic>>();

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: all.length,
                  itemBuilder: (context, i) {
                    final badge = all[i];
                    final isEarned = earned.any((e) => e['badge_id'] == badge['id']);
                    return GestureDetector(
                      onTap: () { HapticFeedback.lightImpact(); _showDetail(context, badge, isEarned); },
                      child: GlassPanel.card(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            isEarned
                                ? Text(badge['icon'] ?? '🏅', style: const TextStyle(fontSize: 28))
                                : ColorFiltered(
                                    colorFilter: const ColorFilter.matrix([
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0, 0, 0, 0.28, 0,
                                    ]),
                                    child: Text(badge['icon'] ?? '🏅', style: const TextStyle(fontSize: 28)),
                                  ),
                            const SizedBox(height: 6),
                            Text(
                              badge['name_tr'] ?? '',
                              style: NeerTypography.caption.copyWith(
                                color: isEarned
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).disabledColor.withValues(alpha: 0.45),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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

  void _showDetail(BuildContext context, Map<String, dynamic> badge, bool isEarned) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => GlassPanel.sheet(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            )),
            const SizedBox(height: 20),
            isEarned
                ? Text(badge['icon'] ?? '', style: const TextStyle(fontSize: 48))
                : ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0, 0, 0, 0.35, 0,
                    ]),
                    child: Text(badge['icon'] ?? '', style: const TextStyle(fontSize: 48)),
                  ),
            const SizedBox(height: 12),
            Text(badge['name_tr'] ?? '', style: NeerTypography.h2.copyWith(color: Colors.white)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isEarned
                    ? NeerColors.success.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isEarned ? 'Kazanıldı ✓' : 'Kilitli',
                style: NeerTypography.caption.copyWith(
                  color: isEarned ? NeerColors.success : Theme.of(context).disabledColor,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              badge['description_tr'] ?? badge['description_en'] ?? '',
              style: NeerTypography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.72), height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
