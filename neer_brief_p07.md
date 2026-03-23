### 6.5 Görevler Preview (YENİ Widget)

```dart
class _QuestPreview extends StatelessWidget {
  final List<Map<String, dynamic>> quests;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Günlük görevler (ilk 2), en ilerlemiş haftalık (1 tane), aktif epik (1 tane)
    final dailyQuests = quests.where((q) => q['type'] == 'daily').take(2).toList();
    final weeklyTop = quests.where((q) => q['type'] == 'weekly').toList()
      ..sort((a, b) => ((b['user_quests']?.first?['progress'] ?? 0) as int)
          .compareTo((a['user_quests']?.first?['progress'] ?? 0) as int));
    final epicActive = quests.where((q) =>
        q['type'] == 'epic' &&
        (q['user_quests']?.first?['is_completed'] != true)).take(1).toList();

    return GlassPanel.card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: AppStrings.questsTitle, onActionTap: onSeeAll),
          const SizedBox(height: 8),
          // Günlük
          ...dailyQuests.map((q) => _QuestRow(quest: q, type: 'daily')),
          // Haftalık
          if (weeklyTop.isNotEmpty) _QuestRow(quest: weeklyTop.first, type: 'weekly'),
          // Epik
          if (epicActive.isNotEmpty) ...[
            const SizedBox(height: 6),
            _EpicQuestCard(quest: epicActive.first),
          ],
        ],
      ),
    );
  }
}

class _QuestRow extends StatelessWidget {
  final Map<String, dynamic> quest;
  final String type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (quest['user_quests']?.first?['progress'] ?? 0) as int;
    final target = (quest['target_count'] ?? 1) as int;
    final isCompleted = quest['user_quests']?.first?['is_completed'] == true;
    final ratio = target > 0 ? progress / target : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Check circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 18, height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? theme.primaryColor.withValues(alpha: 0.25)
                  : Colors.transparent,
              border: Border.all(
                color: isCompleted
                    ? theme.primaryColor
                    : Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: isCompleted
                ? Icon(Icons.check, size: 10, color: theme.primaryColor)
                : null,
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.lang == 'tr'
                      ? (quest['title_tr'] ?? '')
                      : (quest['title_en'] ?? ''),
                  style: NeerTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted
                        ? theme.disabledColor
                        : null,
                  ),
                ),
                const SizedBox(height: 3),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0.0, 1.0),
                    minHeight: 2,
                    backgroundColor: Colors.white.withValues(alpha: 0.07),
                    valueColor: AlwaysStoppedAnimation(
                      isCompleted ? NeerColors.success : theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // TS reward
          Text(
            isCompleted ? '+${quest['ts_reward']} ✓' : '+${quest['ts_reward']}',
            style: NeerTypography.caption.copyWith(
              color: isCompleted ? NeerColors.success : NeerColors.success.withValues(alpha: 0.65),
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _EpicQuestCard extends StatelessWidget {
  final Map<String, dynamic> quest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (quest['user_quests']?.first?['progress'] ?? 0) as int;
    final target = (quest['target_count'] ?? 1) as int;
    final ratio = target > 0 ? progress / target : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('EPİK', style: NeerTypography.overline.copyWith(
                  color: theme.primaryColor, fontSize: 9, letterSpacing: 0.8,
                )),
              ),
              const Spacer(),
              Text('+${quest['ts_reward']} TS',
                style: NeerTypography.caption.copyWith(
                  color: NeerColors.success.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                )),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.lang == 'tr' ? (quest['title_tr'] ?? '') : (quest['title_en'] ?? ''),
            style: NeerTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 3,
              backgroundColor: Colors.white.withValues(alpha: 0.07),
              valueColor: AlwaysStoppedAnimation(theme.primaryColor),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$progress / $target',
            style: NeerTypography.overline.copyWith(color: theme.disabledColor),
          ),
        ],
      ),
    );
  }
}
```

