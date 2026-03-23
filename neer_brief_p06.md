### 6.3 Neer Kimliği Kartı (YENİ Widget)

```dart
class _NeerIdentityCard extends StatelessWidget {
  final Future<Map<String, dynamic>> statsFuture;
  final int photoCount;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: statsFuture,
      builder: (context, snapshot) {
        final stats = snapshot.data;
        return AnimatedPress(
          onTap: () {},
          child: GlassPanel.card(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Neer Kimliği',
                  style: NeerTypography.overline.copyWith(
                    color: Theme.of(context).disabledColor,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _IdentityStat(
                      value: stats?['total_places']?.toString() ?? '—',
                      label: 'mekan',
                    ),
                    _IdentityStat(
                      value: photoCount.toString(),
                      label: 'kare',
                    ),
                    _IdentityStat(
                      value: stats?['total_cities']?.toString() ?? '—',
                      label: 'şehir',
                    ),
                    _IdentityStat(
                      value: stats?['active_days']?.toString() ?? '—',
                      label: 'gün',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _IdentityStat extends StatelessWidget {
  final String value, label;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: NeerTypography.h2.copyWith(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: NeerTypography.overline.copyWith(color: Theme.of(context).disabledColor)),
        ],
      ),
    );
  }
}
```

### 6.4 Rozet Vitrini (YENİ Widget)

```dart
class _BadgeVitrin extends StatelessWidget {
  final List<Map<String, dynamic>> earnedBadges;
  final List<Map<String, dynamic>> allBadges;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return GlassPanel.card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Rozetler', onActionTap: onSeeAll),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: allBadges.map((badge) {
                final isEarned = earnedBadges.any((e) => e['badge_id'] == badge['id']);
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _BadgePill(badge: badge, isEarned: isEarned),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  final Map<String, dynamic> badge;
  final bool isEarned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedPress(
      onTap: () => _showBadgeDetail(context),
      child: Column(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEarned
                  ? theme.primaryColor.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.04),
              border: Border.all(
                color: isEarned
                    ? theme.primaryColor.withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                badge['icon'] ?? '🏅',
                style: TextStyle(
                  fontSize: 20,
                  color: isEarned ? null : Colors.transparent,
                ).merge(isEarned ? null : const TextStyle()),
              ),
            ),
          ).also((_) => isEarned ? null : ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0, 0, 0, 0.3, 0,
            ]),
          )),
          const SizedBox(height: 4),
          Text(
            isEarned ? (badge['name_tr'] ?? '') : '???',
            style: NeerTypography.overline.copyWith(
              color: isEarned
                  ? theme.primaryColor
                  : theme.disabledColor,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetail(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BadgeDetailSheet(badge: badge, isEarned: isEarned),
    );
  }
}
```

