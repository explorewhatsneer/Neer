# P4 — Görevler + Rozetler Ayrı Ekranlar

P1–P3 tamamlandıktan sonra uygula.

---

## 1. app_router.dart — route güncelle

```dart
// AppRoutes class içinde — EKLE:
static const String quests = '/quests';
static const String badges = '/badges';

// Eski questsBadges route'u kaldır veya yorum satırı yap:
// static const String questsBadges = '/quests-badges';
```

GoRouter `routes` listesine ekle:
```dart
GoRoute(
  path: AppRoutes.quests,
  pageBuilder: (context, state) =>
      buildSlideTransition(context, state, const QuestsScreen()),
),
GoRoute(
  path: AppRoutes.badges,
  pageBuilder: (context, state) =>
      buildSlideTransition(context, state, const BadgesScreen()),
),
```

---

## 2. profile_screen.dart — navigasyon güncelle

```dart
// _QuestPreview içinde onSeeAll:
onSeeAll: () => context.push(AppRoutes.quests),

// _BadgeVitrin içinde onSeeAll:
onSeeAll: () => context.push(AppRoutes.badges),
```

---

## 3. lib/screens/quests_screen.dart — YENİ DOSYA OLUŞTUR

```dart
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
          // Header
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
          // Filtre pills
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
          // Liste
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _questsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const ShimmerList(itemCount: 5);
                var quests = snapshot.data!;

                // Filtrele
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

  Color _typeColor(BuildContext ctx, String? type) {
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
    final typeColor = _typeColor(context, quest['type'] as String?);

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
```

---

## 4. lib/screens/badges_screen.dart — YENİ DOSYA OLUŞTUR

```dart
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
                      onTap: () => _showDetail(context, badge, isEarned),
                      child: GlassPanel.card(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            isEarned
                                ? Text(badge['icon'] ?? '🏅', style: const TextStyle(fontSize: 28))
                                : ColorFiltered(
                                    colorFilter: const ColorFilter.matrix([
                                      0.2126,0.7152,0.0722,0,0,
                                      0.2126,0.7152,0.0722,0,0,
                                      0.2126,0.7152,0.0722,0,0,
                                      0,0,0,0.28,0,
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
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: 20),
            isEarned
                ? Text(badge['icon'] ?? '', style: const TextStyle(fontSize: 48))
                : ColorFiltered(
                    colorFilter: const ColorFilter.matrix([0.2126,0.7152,0.0722,0,0,0.2126,0.7152,0.0722,0,0,0.2126,0.7152,0.0722,0,0,0,0,0,0.35,0]),
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
```

---

## KONTROL
- [ ] `flutter analyze` — sıfır hata
- [ ] `AppRoutes.quests` ve `AppRoutes.badges` eklendi
- [ ] `quests_screen.dart` oluşturuldu, görevler listeleniyor
- [ ] `badges_screen.dart` oluşturuldu, 3 sütun grid
- [ ] Profilde "Görevler" → QuestsScreen açılıyor
- [ ] Profilde "Rozetler" → BadgesScreen açılıyor
- [ ] Rozet detay bottom sheet çalışıyor
