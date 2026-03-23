# P5 — Küçük Düzeltmeler

P1–P4 tamamlandıktan sonra uygula.

---

## 1. Bento — Değerlendirmeler üste, Notlar alta

`profile_screen.dart` içindeki `_BentoDashboard` sağ sütunda kart sırasını değiştir:

```dart
// Sağ sütun içinde:
Column(children: [
  // ÜSTE — Değerlendirmeler (surveyHistoryFuture)
  Expanded(
    child: FutureBuilder<List<Map<String, dynamic>>>(
      future: surveyHistoryFuture,
      builder: (context, snapshot) {
        final review = (snapshot.hasData && snapshot.data!.isNotEmpty) ? snapshot.data!.first : null;
        final score = review != null && review['rating'] is num
            ? (review['rating'] as num).toDouble() : 0.0;
        final placeName = review?['location_name'] ?? AppStrings.noReviewsYet;
        return AnimatedPress(
          onTap: () => context.push(AppRoutes.myReviews),
          child: GlassPanel.bento(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(children: [
                  Icon(Icons.star_rounded, size: 16, color: NeerColors.warning),
                  const SizedBox(width: 6),
                  Text(
                    score > 0 ? score.toStringAsFixed(1) : "-",
                    style: NeerTypography.h3.copyWith(fontSize: 16, fontWeight: FontWeight.w800, color: NeerColors.warning),
                  ),
                ]),
                const SizedBox(height: 6),
                Text(placeName, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: NeerTypography.caption.copyWith(fontWeight: FontWeight.w600, fontSize: 12,
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7))),
              ],
            ),
          ),
        );
      },
    ),
  ),
  const SizedBox(height: 10),
  // ALTA — Notlar (notesStream)
  Expanded(
    child: StreamBuilder<List<Map<String, dynamic>>>(
      stream: notesStream,
      builder: (context, snapshot) {
        final note = (snapshot.hasData && snapshot.data!.isNotEmpty) ? snapshot.data!.first : null;
        final noteText = note?['content'] ?? AppStrings.notebookEmpty;
        return AnimatedPress(
          onTap: () => context.push(AppRoutes.myNotes),
          child: GlassPanel.bento(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(children: [
                  Icon(Icons.edit_note_rounded, size: 16, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 6),
                  Text(AppStrings.myNotes, style: NeerTypography.caption.copyWith(
                    fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor, fontSize: 11)),
                ]),
                const SizedBox(height: 6),
                Text(noteText, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: NeerTypography.caption.copyWith(fontStyle: FontStyle.italic, fontSize: 12, height: 1.3,
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7))),
              ],
            ),
          ),
        );
      },
    ),
  ),
])
```

---

## 2. ReviewsScreen — başlık ekle

`lib/screens/reviews_screen.dart` içinde header satırında başlık yoksa ekle:

```dart
// Mevcut header'da sadece back button varsa yanına başlık ekle:
Row(children: [
  GestureDetector(
    onTap: () => Navigator.pop(context),
    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
  ),
  const SizedBox(width: 12),
  Text(AppStrings.myReviewsTitle,  // ← bu satır eksikse ekle
    style: NeerTypography.h3.copyWith(color: Colors.white)),
]),
```

---

## 3. Neer Kimliği — "kare" → "fotoğraf"

`profile_screen.dart` içinde `_NeerIdentityCard` içindeki `_IdentityStat`:

```dart
// BUL:
_IdentityStat(value: photoCount.toString(), label: 'kare'),

// DEĞİŞTİR:
_IdentityStat(value: photoCount.toString(), label: 'fotoğraf'),
```

---

## 4. app_strings.dart — eksik string'leri ekle (yoksa)

```dart
// Yoksa ekle:
static String get myReviewsTitle => lang == 'tr' ? "Puanlarım" : "My Reviews";
static String get badgesTitle => lang == 'tr' ? "Rozetler" : "Badges";
static String get neerScoreStandard => lang == 'tr' ? "Standart" : "Standard";
static String get neerIdentityTitle => lang == 'tr' ? "Neer Kimliği" : "Neer Identity";
static String get zeroFrequent => lang == 'tr' ? "Bir mekana tekrar tekrar git — liste kendiliğinden oluşur." : "Visit a venue repeatedly — the list builds itself.";
```

---

## KONTROL
- [ ] `flutter analyze` — sıfır hata
- [ ] Bento'da değerlendirme üstte, not altta
- [ ] ReviewsScreen başlığı var ("Puanlarım")
- [ ] Neer Kimliği'nde "fotoğraf" yazıyor
- [ ] String'ler tanımlı, eksik yok
