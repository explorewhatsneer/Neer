### 6.6 Sık Uğrananlar — A Tasarımı

```dart
class _FrequentPlacesSection extends StatelessWidget {
  final List<Map<String, dynamic>> places;
  final VoidCallback onSeeAll;
  final Function(String id, String name, String img) onTap;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) return FriendEmptyCard(
      icon: Icons.explore_off_rounded,
      title: 'Henüz mekan yok',
      subtitle: 'Sık ziyaretler burada listelenir.',
    );

    return Column(
      children: [
        SectionHeader(title: AppStrings.frequentPlacesTitle, onActionTap: onSeeAll),
        _FrequentCard(place: places[0], rank: 1, height: 72),
        const SizedBox(height: 5),
        if (places.length > 1) _FrequentCard(place: places[1], rank: 2, height: 52),
        if (places.length > 2) ...[
          const SizedBox(height: 5),
          _FrequentCard(place: places[2], rank: 3, height: 52),
        ],
      ],
    );
  }
}

class _FrequentCard extends StatelessWidget {
  final Map<String, dynamic> place;
  final int rank;
  final double height;

  @override
  Widget build(BuildContext context) {
    final name = place['place_name'] ?? place['name'] ?? '';
    final img = place['image_url'] ?? place['image'] ?? '';
    final visits = (place['visit_count'] as num?)?.toInt() ?? 0;

    return AnimatedPress(
      onTap: () {},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(rank == 1 ? 14 : 12),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Arka plan fotoğraf veya gradient
              img.isNotEmpty
                  ? AppCachedImage.cover(imageUrl: img)
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _rankGradient(rank),
                        ),
                      ),
                    ),
              // Overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xAA000000), Color(0x22000000)],
                  ),
                ),
              ),
              // İçerik
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: rank == 1 ? 14 : 10,
                ),
                child: Row(
                  children: [
                    // Rank
                    Text(
                      rank == 1 ? '1' : rank.toString(),
                      style: TextStyle(
                        color: rank == 1
                            ? const Color(0xFFFFD700).withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.4),
                        fontSize: rank == 1 ? 22 : 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Thumbnail
                    if (img.isNotEmpty)
                      Container(
                        width: rank == 1 ? 36 : 28,
                        height: rank == 1 ? 36 : 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: AppCachedImage.cover(imageUrl: img),
                        ),
                      ),
                    const SizedBox(width: 8),
                    // İsim + ziyaret
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: rank == 1 ? 0.9 : 0.8),
                              fontSize: rank == 1 ? 14 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (rank == 1) ...[
                            const SizedBox(height: 2),
                            Text('$visits ziyaret',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Visit pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: rank == 1
                            ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.11),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: rank == 1
                              ? const Color(0xFFFFD700).withValues(alpha: 0.28)
                              : Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Text(
                        visits.toString(),
                        style: TextStyle(
                          color: rank == 1
                              ? const Color(0xFFFFD700).withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.65),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _rankGradient(int rank) {
    switch (rank) {
      case 1: return [const Color(0xFF8B5CF6).withValues(alpha: 0.55), const Color(0xFFEC4899).withValues(alpha: 0.38)];
      case 2: return [const Color(0xFF3B82F6).withValues(alpha: 0.42), const Color(0xFF8B5CF6).withValues(alpha: 0.28)];
      default: return [const Color(0xFFEC4899).withValues(alpha: 0.38), const Color(0xFFFF8C42).withValues(alpha: 0.25)];
    }
  }
}
```

---

