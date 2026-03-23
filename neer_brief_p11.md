## BÖLÜM 11: USERMODEL GÜNCELLEMESİ

`lib/models/user_model.dart`'a ekle:

```dart
// Yeni alanlar
final String neerScoreLabel;
final int totalUniquePlaces;
final int totalCities;
final int activeDays;

// fromMap içine
neerScoreLabel: map['neer_score_label'] ?? 'Standart',
totalUniquePlaces: map['total_unique_places'] ?? 0,
totalCities: map['total_cities'] ?? 0,
activeDays: map['active_days'] ?? 0,
```

---

## KONTROL LİSTESİ

Kodlamayı bitirdikten sonra her maddeyi kontrol et:

- [ ] `premium_background.dart` — orb pozisyonları güncellendi, dark mode 3 orb
- [ ] `glass_panel.dart` — blur/alpha değerleri güncellendi
- [ ] `GlassCard` / `NeerGlass.card()` kullanımları `GlassPanel` ile replace edildi
- [ ] `custom_navbar.dart` — tab sırası, gradient bar, dot animasyonu, label kaldırıldı
- [ ] `profile_header.dart` — Compact Identity C, NeerScoreRing küçülme
- [ ] `profile_screen.dart` — Tab 1 hiyerarşisi 1→6 sıralaması
- [ ] `_NeerIdentityCard` widget yazıldı
- [ ] `_BadgeVitrin` widget yazıldı
- [ ] `_QuestPreview` widget yazıldı
- [ ] `_FrequentPlacesSection` A tasarımı yazıldı
- [ ] `HeatmapWidget` MapTiler ile yazıldı
- [ ] `quests_badges_screen.dart` oluşturuldu (2 tab)
- [ ] `notes_screen.dart` oluşturuldu
- [ ] `reviews_screen.dart` oluşturuldu
- [ ] `frequent_places_screen.dart` oluşturuldu
- [ ] `SectionHeader` widget güncellendi (gradient accent çizgi)
- [ ] `supabase_service.dart` yeni metodlar eklendi
- [ ] `app_strings.dart` Neer Score + yeni string'ler eklendi
- [ ] `user_model.dart` yeni alanlar eklendi
- [ ] `app_router.dart` yeni route'lar eklendi
- [ ] `flutter analyze` — sıfır hata
- [ ] Zero state'ler tüm bölümlerde mevcut

---

## ÖNEMLİ NOTLAR

1. **Neer Score**: `trust_score` alanı DB'de kaldı, `neer_score` sync trigger ile güncelleniyor. Flutter'da hem `trustScore` hem `neerScore` model alanı var — UI'da sadece `neerScore` ve `neerScoreLabel` kullan.

2. **DB Migration**: `badge_quest_heatmap_system` migration zaten uygulandı. `badge_definitions`, `user_badges`, `quest_definitions`, `user_quests` tabloları ve RPC fonksiyonları (`get_user_heatmap_points`, `get_user_identity_stats`, `update_quest_progress`) hazır.

3. **MapTiler key**: `lib/core/constants.dart` veya `.env`'den alınacak — hardcode etme.

4. **GradientTabIndicator**: `profile_header.dart` içinde tanımla — ayrı dosya gerekmez.

5. **`RankingPodium` kaldırıldı**: `ranking_widgets.dart`'tan `RankingPodium` ve `_RankAvatar` class'ları silinecek. `SimpleRankRow` da kaldırılacak. Bunların yerine yeni `_FrequentCard` kullanılıyor.

6. **main_layout.dart**: `activeIndex` referansları güncellenmeli — eski `0=Profil` artık `4=Profil`.
