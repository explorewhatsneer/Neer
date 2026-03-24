# FIX 3 — Bento düzeltmeleri

---

## 3.1 Bento'da 2 görev çıkıyor — QuestPreview section'ı kaldır

**Sorun:** `_BentoDashboard` içindeki görev kartı + ayrı `_QuestPreview` section'ı ikisi birden render ediliyor.

**`profile_screen.dart`** içinde Tab 1 içerik listesinden `_QuestPreview` bloğunu tamamen kaldır:

```dart
// BU BLOĞU SİL (D. GÖREVLER PREVİEW):
// ==========================================
// D. GÖREVLER PREVİEW
// ==========================================
FutureBuilder<List<Map<String, dynamic>>>(
  future: _activeQuestsFuture,
  builder: (context, snapshot) {
    if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
    return _QuestPreview(
      quests: snapshot.data!,
      onSeeAll: () => context.push(AppRoutes.quests),
    );
  },
),
const SizedBox(height: 28),
// ↑↑↑ BU BLOĞU SİL ↑↑↑
```

Görevler sadece Bento'da kalacak. Bento'daki görev kartına tıklayınca `QuestsScreen`'e gidecek.

---

## 3.2 Bento görev kartına ilerleme barı + başlık + ok ekle

`_BentoDashboard` içindeki sol kart (görev kartı) güncelleme:

```dart
// Sol kart — görev progress:
Expanded(
  child: FutureBuilder<List<Map<String, dynamic>>>(
    future: questsFuture,
    builder: (context, snapshot) {
      final quest = (snapshot.hasData && snapshot.data!.isNotEmpty)
          ? snapshot.data!.first : null;
      final progress = quest != null && quest['progress'] is num
          ? (quest['progress'] as num).toDouble() / 100 : 0.0;
      final title = quest?['title_tr'] ?? quest?['title'] ?? AppStrings.comingSoon;
      final theme = Theme.of(context);

      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(AppRoutes.quests);
        },
        child: GlassPanel.bento(
          height: 170,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık satırı + ok
              Row(
                children: [
                  Text(
                    AppStrings.questsTitle,
                    style: NeerTypography.overline.copyWith(
                      color: theme.primaryColor,
                      fontSize: 10,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: theme.primaryColor.withValues(alpha: 0.6),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Circular progress
              SizedBox(
                width: 46,
                height: 46,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0, strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(
                        isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    CircularProgressIndicator(
                      value: progress, strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                      strokeCap: StrokeCap.round,
                    ),
                    Icon(
                      progress >= 1.0
                          ? Icons.emoji_events_rounded
                          : Icons.flag_rounded,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Görev adı
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: NeerTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              // İlerleme barı
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${(progress * 100).toInt()}%",
                style: NeerTypography.caption.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),
),
```

---

## 3.3 Bento not ve değerlendirme kartlarına başlık + ok ekle

Sağ sütundaki her iki karta da başlık + chevron ekle. `_BentoDashboard` içinde:

```dart
// ÜSTE — Değerlendirmeler:
AnimatedPress(
  onTap: () => context.push(AppRoutes.myReviews),
  child: GlassPanel.bento(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Başlık + ok
        Row(children: [
          Icon(Icons.star_rounded, size: 13, color: NeerColors.warning),
          const SizedBox(width: 4),
          Text(AppStrings.myReviewsTitle,
            style: NeerTypography.overline.copyWith(
              color: NeerColors.warning, fontSize: 9, letterSpacing: 0.6)),
          const Spacer(),
          Icon(Icons.chevron_right_rounded, size: 13,
            color: NeerColors.warning.withValues(alpha: 0.6)),
        ]),
        const SizedBox(height: 5),
        Row(children: [
          Icon(Icons.star_rounded, size: 14, color: NeerColors.warning),
          const SizedBox(width: 4),
          Text(
            score > 0 ? score.toStringAsFixed(1) : "-",
            style: NeerTypography.h3.copyWith(
              fontSize: 15, fontWeight: FontWeight.w800, color: NeerColors.warning)),
        ]),
        const SizedBox(height: 4),
        Text(placeName, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: NeerTypography.caption.copyWith(
            fontWeight: FontWeight.w500, fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
      ],
    ),
  ),
),

// ALTA — Notlar:
AnimatedPress(
  onTap: () => context.push(AppRoutes.myNotes),
  child: GlassPanel.bento(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Başlık + ok
        Row(children: [
          Icon(Icons.edit_note_rounded, size: 13,
            color: Theme.of(context).primaryColor),
          const SizedBox(width: 4),
          Text(AppStrings.myNotes,
            style: NeerTypography.overline.copyWith(
              color: Theme.of(context).primaryColor, fontSize: 9, letterSpacing: 0.6)),
          const Spacer(),
          Icon(Icons.chevron_right_rounded, size: 13,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.6)),
        ]),
        const SizedBox(height: 5),
        Text(noteText, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: NeerTypography.caption.copyWith(
            fontStyle: FontStyle.italic, fontSize: 11, height: 1.3,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.70))),
      ],
    ),
  ),
),
```

---

## KONTROL
- [ ] Bento'da tek görev kartı var (QuestPreview section silindi)
- [ ] Görev kartında ilerleme barı + yüzde görünüyor
- [ ] Görev kartına tıklanınca QuestsScreen açılıyor
- [ ] Not ve değerlendirme kartlarında başlık + > ok var
- [ ] Tüm bento kartlarında tıklanabilir his var
- [ ] `flutter analyze` — sıfır hata
