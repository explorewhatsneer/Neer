import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../core/neer_design_system.dart';
import '../core/app_strings.dart';
import '../services/supabase_service.dart';
import '../widgets/common/glass_panel.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/friend/friend_profile_widgets.dart' show FriendEmptyCard;

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});
  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  final _service = SupabaseService();
  final String _uid = supabase.auth.currentUser!.id;
  late Future<List<Map<String, dynamic>>> _questsFuture;
  String _filter = 'all';

  static const _filterLabels = {
    'all': 'Tümü',
    'daily': 'Günlük',
    'weekly': 'Haftalık',
    'epic': 'Epik',
    'completed': 'Tamamlanan',
  };

  @override
  void initState() {
    super.initState();
    _questsFuture = _service.getUserActiveQuests(_uid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                Text(AppStrings.questsTitle, style: NeerTypography.h3.copyWith(color: Colors.white)),
              ]),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: _filterLabels.entries.map((e) {
                final selected = _filter == e.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: GestureDetector(
                    onTap: () { HapticFeedback.lightImpact(); setState(() => _filter = e.key); },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected
                            ? theme.primaryColor.withValues(alpha: 0.22)
                            : Colors.white.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? theme.primaryColor.withValues(alpha: 0.50)
                              : Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Text(
                        e.value,
                        style: NeerTypography.caption.copyWith(
                          color: selected ? theme.primaryColor : Colors.white.withValues(alpha: 0.55),
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _questsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const ShimmerList(itemCount: 5);
                var quests = snapshot.data!;

                if (_filter != 'all') {
                  quests = quests.where((q) {
                    if (_filter == 'completed') return q['is_completed'] == true;
                    return q['type'] == _filter && q['is_completed'] != true;
                  }).toList();
                }

                if (quests.isEmpty) {
                  return Center(child: FriendEmptyCard(
                    icon: Icons.task_alt_rounded,
                    title: AppStrings.noQuests,
                    subtitle: AppStrings.noQuestsDesc,
                  ));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: quests.length,
                  itemBuilder: (context, i) => _QuestCard(quest: quests[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  final Map<String, dynamic> quest;
  const _QuestCard({required this.quest});

  Color _typeColor(String? type) {
    switch (type) {
      case 'daily': return NeerColors.success;
      case 'weekly': return NeerColors.info;
      case 'epic': return NeerColors.primary;
      default: return NeerColors.gray400;
    }
  }

  String _typeLabel(String? type) {
    switch (type) {
      case 'daily': return 'GÜNLÜK';
      case 'weekly': return 'HAFTALIK';
      case 'epic': return 'EPİK';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (quest['current_progress'] ?? 0) as int;
    final target = (quest['target_count'] ?? 1) as int;
    final isCompleted = quest['is_completed'] == true;
    final ratio = target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;
    final typeColor = _typeColor(quest['type'] as String?);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassPanel.card(
        padding: const EdgeInsets.all(14),
        child: Opacity(
          opacity: isCompleted ? 0.55 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_typeLabel(quest['type'] as String?),
                    style: NeerTypography.overline.copyWith(color: typeColor, fontSize: 8)),
                ),
                const Spacer(),
                Text('+${quest['ts_reward']} TS',
                  style: NeerTypography.caption.copyWith(
                    color: NeerColors.success.withValues(alpha: isCompleted ? 1.0 : 0.65),
                    fontWeight: FontWeight.w600, fontSize: 10,
                  )),
              ]),
              const SizedBox(height: 8),
              Text(
                quest['title_tr'] ?? quest['title_en'] ?? '',
                style: NeerTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                quest['description_tr'] ?? quest['description_en'] ?? '',
                style: NeerTypography.caption.copyWith(
                  color: theme.disabledColor, fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 3,
                      backgroundColor: Colors.white.withValues(alpha: 0.07),
                      valueColor: AlwaysStoppedAnimation(
                        isCompleted ? NeerColors.success : theme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$progress / $target',
                  style: NeerTypography.caption.copyWith(
                    color: theme.disabledColor, fontSize: 10,
                  )),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
