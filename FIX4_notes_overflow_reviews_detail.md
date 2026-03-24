# FIX 4 — Notes overflow + Değerlendirme detaylı puanlar

---

## 4.1 Notes overflow düzeltme

**Sorun:** `NotesScreen`'de `GlassPanel.sheet` içindeki bottom sheet'te uzun içerik overflow veriyor.

**`lib/screens/notes_screen.dart`** içinde `_showNoteDetail`:

```dart
void _showNoteDetail(BuildContext context, Map<String, dynamic> note) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,  // YENİ — tam yükseklik kontrolü
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, scrollController) => GlassPanel.sheet(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            // Scrollable içerik
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mekan adı
                    Builder(builder: (ctx) {
                      final pn = (note['places'] as Map?)?['name'] as String?
                          ?? note['place_name'] as String? ?? '';
                      if (pn.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(children: [
                          Icon(Icons.location_on_rounded, size: 14,
                            color: Colors.white.withValues(alpha: 0.55)),
                          const SizedBox(width: 4),
                          Text(pn, style: NeerTypography.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.6))),
                        ]),
                      );
                    }),
                    // Not içeriği
                    Text(
                      note['content'] as String?
                          ?? note['note'] as String? ?? '',
                      style: NeerTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.6,
                      ),
                    ),
                    // Tarih
                    const SizedBox(height: 16),
                    Text(
                      note['created_at'] != null
                          ? _formatDate(note['created_at'].toString())
                          : '',
                      style: NeerTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
```

Liste item'ındaki overflow için de content satırını düzelt:

```dart
// itemBuilder içinde GlassPanel.card child'ında:
// Text widget'ının parent'ına Flexible ekle:
Flexible(
  child: Text(
    content,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: NeerTypography.bodySmall.copyWith(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.82)),
  ),
),
```

---

## 4.2 PostModel — detaylı puan alanları ekle

**`lib/models/post_model.dart`** içine yeni alanlar:

```dart
// class PostModel içine alan ekle:
final double? ratingTaste;
final double? ratingService;
final double? ratingAmbiance;
final double? ratingPrice;
final List<String> highlights;

// Constructor'a ekle:
this.ratingTaste,
this.ratingService,
this.ratingAmbiance,
this.ratingPrice,
this.highlights = const [],

// fromMap içine ekle:
ratingTaste: map['rating_taste'] != null
    ? (map['rating_taste'] as num).toDouble() : null,
ratingService: map['rating_service'] != null
    ? (map['rating_service'] as num).toDouble() : null,
ratingAmbiance: map['rating_ambiance'] != null
    ? (map['rating_ambiance'] as num).toDouble() : null,
ratingPrice: map['rating_price'] != null
    ? (map['rating_price'] as num).toDouble() : null,
highlights: List<String>.from(map['highlights'] ?? []),

// toMap içine ekle:
'rating_taste': ratingTaste,
'rating_service': ratingService,
'rating_ambiance': ratingAmbiance,
'rating_price': ratingPrice,
'highlights': highlights,
```

---

## 4.3 getSurveyHistory — detaylı alanları çek

**`lib/services/supabase_service.dart`** içinde:

```dart
Future<List<Map<String, dynamic>>> getSurveyHistory(String uid) async {
  try {
    final response = await _supabase
        .from('posts')
        .select(
          'id, user_id, user_name, user_image, content, image_url, type, '
          'location_name, location_id, rating, review_comment, '
          'rating_taste, rating_service, rating_ambiance, rating_price, '  // YENİ
          'highlights, like_count, comment_count, likes, created_at, place_id'  // YENİ
        )
        .eq('user_id', uid)
        .eq('type', 'review')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    return [];
  }
}
```

---

## 4.4 DetailedReviewCard — yeni widget

`lib/widgets/feed/feed_widgets.dart` içine `FeedReviewCard`'ın hemen altına ekle:

```dart
/// Profil sayfası için detaylı review kartı — kategori puanları gösterir
class DetailedReviewCard extends StatelessWidget {
  final PostModel post;
  const DetailedReviewCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final int starRating = (post.rating ?? 0).toInt();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? NeerColors.darkSurface.withValues(alpha: 0.42)
                : Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.14)
                  : Colors.black.withValues(alpha: 0.07),
              width: 0.8,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mekan adı + tarih
              Row(
                children: [
                  Icon(Icons.place_rounded, size: 14,
                    color: theme.primaryColor.withValues(alpha: 0.8)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      post.locationName.isNotEmpty
                          ? post.locationName : 'Mekan',
                      style: NeerTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatTimeAgo(post.createdAt),
                    style: NeerTypography.caption.copyWith(
                      color: theme.disabledColor, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Genel yıldız puanı
              Row(
                children: [
                  ...List.generate(5, (i) => Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: i < starRating
                          ? NeerColors.warning
                          : theme.disabledColor.withValues(alpha: 0.2),
                    ),
                  )),
                  const SizedBox(width: 6),
                  Text(
                    (post.rating ?? 0).toStringAsFixed(1),
                    style: NeerTypography.h3.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: NeerColors.warning,
                    ),
                  ),
                ],
              ),

              // Kategori puanları (varsa)
              if (_hasDetailedRatings(post)) ...[
                const SizedBox(height: 10),
                _DetailRatingBar(
                  label: AppStrings.taste,
                  value: post.ratingTaste,
                  theme: theme,
                ),
                _DetailRatingBar(
                  label: AppStrings.service,
                  value: post.ratingService,
                  theme: theme,
                ),
                _DetailRatingBar(
                  label: AppStrings.atmosphere,
                  value: post.ratingAmbiance,
                  theme: theme,
                ),
                _DetailRatingBar(
                  label: AppStrings.pricePerf,
                  value: post.ratingPrice,
                  theme: theme,
                ),
              ],

              // Highlights (varsa)
              if (post.highlights.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: post.highlights.map((h) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.primaryColor.withValues(alpha: 0.20)),
                    ),
                    child: Text(h, style: NeerTypography.caption.copyWith(
                      color: theme.primaryColor, fontSize: 10)),
                  )).toList(),
                ),
              ],

              // Yorum (varsa)
              if (post.reviewComment != null &&
                  post.reviewComment!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  post.reviewComment!,
                  style: NeerTypography.bodySmall.copyWith(
                    height: 1.5,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _hasDetailedRatings(PostModel p) =>
      p.ratingTaste != null || p.ratingService != null ||
      p.ratingAmbiance != null || p.ratingPrice != null;
}

class _DetailRatingBar extends StatelessWidget {
  final String label;
  final double? value;
  final ThemeData theme;
  const _DetailRatingBar({required this.label, required this.value, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (value == null || value == 0) return const SizedBox.shrink();
    final ratio = (value! / 5.0).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: NeerTypography.caption.copyWith(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            )),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 4,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation(NeerColors.warning),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(value!.toStringAsFixed(1),
            style: NeerTypography.caption.copyWith(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: NeerColors.warning,
            )),
        ],
      ),
    );
  }
}
```

---

## 4.5 ReviewsScreen — DetailedReviewCard kullan

**`lib/screens/reviews_screen.dart`** içinde:

```dart
// ESKİ:
itemBuilder: (context, i) => FeedReviewCard(post: reviews[i]),

// YENİ:
itemBuilder: (context, i) => DetailedReviewCard(post: reviews[i]),
```

---

## KONTROL
- [ ] Notes bottom sheet scroll ediliyor, overflow yok
- [ ] PostModel'de ratingTaste, ratingService, ratingAmbiance, ratingPrice, highlights var
- [ ] getSurveyHistory bu alanları çekiyor
- [ ] ReviewsScreen'de DetailedReviewCard kullanılıyor
- [ ] Puanlar varsa kategori barları görünüyor
- [ ] `flutter analyze` — sıfır hata
