import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/neer_design_system.dart';
import '../core/app_strings.dart';
import '../main.dart';
import '../services/supabase_service.dart';
import '../widgets/common/glass_panel.dart';
import '../widgets/common/animated_press.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/profile/profile_header.dart';

class QuestsBadgesScreen extends StatefulWidget {
  const QuestsBadgesScreen({super.key});
  @override
  State<QuestsBadgesScreen> createState() => _QuestsBadgesScreenState();
}

class _QuestsBadgesScreenState extends State<QuestsBadgesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupabaseService _service = SupabaseService();
  final String _uid = supabase.auth.currentUser!.id;

  late Future<List<Map<String, dynamic>>> _questsFuture;
  late Future<List<Map<String, dynamic>>> _earnedFuture;
  late Future<List<Map<String, dynamic>>> _allBadgesFuture;

  String _questFilter = 'all';
  static const _filters = ['all', 'daily', 'weekly', 'epic', 'completed'];
  static const _filterLabels = {'all': 'Tümü', 'daily': 'Günlük', 'weekly': 'Haftalık', 'epic': 'Epik', 'completed': 'Tamamlanan'};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _questsFuture = _service.getUserActiveQuests(_uid);
    _earnedFuture = _service.getUserBadges(_uid);
    _allBadgesFuture = _service.getAllBadgeDefinitions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                  Text(AppStrings.questsBadgesTitle, style: NeerTypography.h3.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
          ProfileTabBar(
            controller: _tabController,
            tabs: [AppStrings.questsTitle, AppStrings.badgesTitle],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildQuestsTab(), _buildBadgesTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _questsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const ShimmerList(itemCount: 5);
        final all = snapshot.data!;
        final filtered = _questFilter == 'all'
            ? all
            : _questFilter == 'completed'
                ? all.where((q) => q['is_completed'] == true).toList()
                : all.where((q) => q['type'] == _questFilter).toList();
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Wrap(
                  spacing: 8,
                  children: _filters.map((f) => GestureDetector(
                    onTap: () => setState(() => _questFilter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _questFilter == f
                            ? NeerColors.primary.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _questFilter == f
                              ? NeerColors.primary.withValues(alpha: 0.55)
                              : Colors.white.withValues(alpha: 0.14),
                        ),
                      ),
                      child: Text(_filterLabels[f]!,
                        style: NeerTypography.caption.copyWith(
                          color: _questFilter == f ? NeerColors.primary : Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        )),
                    ),
                  )).toList(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final q = filtered[i];
                  final progress = (q['current_progress'] ?? 0) as int;
                  final target = (q['target_count'] ?? 1) as int;
                  final isCompleted = q['is_completed'] == true;
                  final ratio = target > 0 ? progress / target : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Opacity(
                      opacity: isCompleted ? 0.45 : 1.0,
                      child: GlassPanel.card(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: NeerColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    q['type'] == 'daily' ? 'Günlük' : q['type'] == 'weekly' ? 'Haftalık' : 'Epik',
                                    style: NeerTypography.caption.copyWith(color: NeerColors.primary, fontSize: 9),
                                  ),
                                ),
                                const Spacer(),
                                Text('+${q['ts_reward']} TS',
                                  style: NeerTypography.caption.copyWith(
                                    color: NeerColors.success.withValues(alpha: 0.8), fontWeight: FontWeight.w600,
                                  )),
                                if (isCompleted)
                                  const Icon(Icons.check_circle, color: Color(0xFF30D158), size: 16),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(q['title_tr'] ?? q['title_en'] ?? '',
                              style: NeerTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                              )),
                            const SizedBox(height: 4),
                            Text(q['description_tr'] ?? q['description_en'] ?? '',
                              style: NeerTypography.caption.copyWith(
                                color: Theme.of(context).disabledColor, fontSize: 12,
                              )),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: ratio.clamp(0.0, 1.0), minHeight: 4,
                                      backgroundColor: Colors.white.withValues(alpha: 0.07),
                                      valueColor: AlwaysStoppedAnimation(
                                        isCompleted ? const Color(0xFF30D158) : NeerColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text('$progress / $target',
                                  style: NeerTypography.caption.copyWith(
                                    color: Theme.of(context).disabledColor, fontSize: 11,
                                  )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }, childCount: filtered.length),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBadgesTab() {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([_earnedFuture, _allBadgesFuture]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const ShimmerList(itemCount: 6);
        final earned = snapshot.data![0] as List<Map<String, dynamic>>;
        final all = snapshot.data![1] as List<Map<String, dynamic>>;
        if (all.isEmpty) {
          return Center(child: Text(AppStrings.zeroBadges,
            style: NeerTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.5)),
            textAlign: TextAlign.center));
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85,
          ),
          itemCount: all.length,
          itemBuilder: (context, i) {
            final badge = all[i];
            final isEarned = earned.any((e) => e['badge_id'] == badge['id']);
            return AnimatedPress(
              onTap: () {
                HapticFeedback.mediumImpact();
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _BadgeDetailSheet(badge: badge, isEarned: isEarned),
                );
              },
              child: GlassPanel.bento(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: isEarned ? 1.0 : 0.3,
                      child: Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isEarned
                              ? NeerColors.primary.withValues(alpha: 0.18)
                              : Colors.white.withValues(alpha: 0.05),
                          border: Border.all(
                            color: isEarned
                                ? NeerColors.primary.withValues(alpha: 0.45)
                                : Colors.white.withValues(alpha: 0.10),
                          ),
                        ),
                        child: Center(child: Text(badge['icon'] ?? '🏅', style: const TextStyle(fontSize: 24))),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isEarned ? (badge['name_tr'] ?? '') : '???',
                      style: NeerTypography.caption.copyWith(
                        color: isEarned ? NeerColors.primary : Colors.white.withValues(alpha: 0.35),
                        fontSize: 10, fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BadgeDetailSheet extends StatelessWidget {
  final Map<String, dynamic> badge;
  final bool isEarned;
  const _BadgeDetailSheet({required this.badge, required this.isEarned});

  @override
  Widget build(BuildContext context) {
    return GlassPanel.sheet(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2),
          )),
          const SizedBox(height: 20),
          Text(badge['icon'] ?? '🏅', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(badge['name_tr'] ?? badge['name_en'] ?? '',
            style: NeerTypography.h3.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text(badge['description_tr'] ?? badge['description_en'] ?? '',
            style: NeerTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.7)),
            textAlign: TextAlign.center),
          const SizedBox(height: 20),
          if (!isEarned)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Nasıl kazanılır: ${badge['requirement_tr'] ?? badge['requirement_en'] ?? '?'}',
                style: NeerTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.65)),
                textAlign: TextAlign.center),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
