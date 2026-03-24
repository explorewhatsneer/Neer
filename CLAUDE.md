# CLAUDE.md — Neer Project Context (v3.0 — 24 Mart 2026)

## Project Overview
Neer is a location-based social network and venue interaction platform for iOS.
**Slogan**: "Explore what's Neer"
**Core concept**: Users socialize based on WHERE they are and WHEN they are there, not who they follow globally.
**GitHub**: https://github.com/explorewhatsneer/Neer
**Supabase Project ID**: `celkzibnupgacoesaxse`

> **NOT**: Proje raporu PDF'i (20261901_Neer.pdf) güncel değildir. Firebase/Firestore referansları geçersizdir — backend tamamen Supabase/PostgreSQL'dir. Geliştirme sırasında PDF'te olmayan birçok özellik eklenmiştir.

## Tech Stack
- **Frontend**: Flutter (Dart) — iOS target, VS Code
- **Backend**: Supabase (PostgreSQL 15 + Realtime + Auth + Storage)
- **Map**: flutter_map + MapTiler (OpenStreetMap tiles)
- **Location**: geolocator package
- **Fonts**: SF Pro (custom, in assets/fonts)
- **Min iOS**: 15.0
- **Env**: flutter_dotenv (.env file for SUPABASE_URL & SUPABASE_ANON_KEY)

## Architecture (Güncel)
```
lib/
├── main.dart                  # App entry, Supabase init, AuthGate, global vars
├── main_layout.dart           # Bottom nav with IndexedStack (5 tabs)
│
├── core/
│   ├── constants.dart         # AppColors
│   ├── text_styles.dart       # AppTextStyles (h1-h3, bodyLarge/Small, caption, button)
│   ├── theme_styles.dart      # AppThemeStyles (shadows, radii, glassmorphism)
│   ├── theme_manager.dart     # ThemeManager (ChangeNotifier — light/dark/system)
│   ├── language_manager.dart  # LanguageManager (TR/EN toggle)
│   └── app_strings.dart       # Manual i18n (TR/EN static getters, 200+ strings)
│
├── models/
│   ├── user_model.dart        # UserModel (fromMap, toMap)
│   ├── post_model.dart        # PostModel (check-in, review, post types)
│   └── place_model.dart       # PlaceModel (venue data)
│
├── services/
│   ├── auth_service.dart      # Login, register, signOut, resetPassword
│   ├── supabase_service.dart  # Main data service (21+ sections, RPC calls, streams)
│   ├── storage_service.dart   # Image upload to Supabase Storage
│   └── fake_data_service.dart # ⚠️ Seed data generator (SİLİNMELİ)
│
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── profile_screen.dart          # ✅ YENİ TASARIM (3 tab: Profil/Aktivite/Galeri)
│   ├── edit_profile_screen.dart
│   ├── friend_profile_screen.dart   # Başka kullanıcının profili
│   ├── business_profile_screen.dart # Mekan detay (2 tab: Bilgi/Medya)
│   ├── settings_screen.dart
│   ├── account_info_screen.dart
│   ├── change_password_screen.dart
│   ├── login_methods_screen.dart
│   ├── premium_screen.dart          # Premium UI (backend yok henüz)
│   ├── blocked_users_screen.dart
│   ├── chat_screen.dart             # DM sohbet
│   ├── group_chat_screen.dart       # Mekan grup sohbeti
│   └── ... (diğer ekranlar)
│
└── widgets/
    ├── auth/                  # Login/Register form widget'ları
    ├── business/
    │   └── business_widgets.dart  # PlaceStatsRow, EventTicketCard, InteractionStatsGrid,
    │                              # VenueLeaderboard, FriendNoteBubble, DetailedRatingBars,
    │                              # LocationQrRow ⚠️ (çoğu statik mock data)
    ├── chat/
    │   ├── chat_input.dart
    │   └── group_message_bubble.dart
    ├── common/
    │   ├── glass_button.dart
    │   ├── check_in_button.dart       # Server-side geofence check-in
    │   └── active_users_sheet.dart    # Mekandaki aktif kullanıcılar
    ├── dialogs/
    │   ├── check_in_dialog.dart
    │   └── anonymous_popup.dart
    ├── feed/
    │   └── feed_widgets.dart          # FeedPostCard, FeedReviewCard
    ├── friend/
    │   ├── friend_profile_header.dart
    │   ├── friend_action_button.dart
    │   ├── friend_private_view.dart
    │   └── friend_profile_widgets.dart # FriendEmptyCard, MutualHistoryList, HistoryItemCard
    ├── map/
    │   ├── place_sheet.dart           # Mekan bottom sheet (haritadan tıklayınca)
    │   └── user_sheet.dart            # Kullanıcı bottom sheet (haritadan tıklayınca)
    ├── profile/
    │   ├── profile_header.dart        # Profil üst bölüm (avatar, stats, bio)
    │   ├── profile_components.dart    # StackedCardCarousel vb.
    │   ├── profile_cards.dart         # DynamicQuestCard (capsule badge)
    │   ├── ranking_widgets.dart       # RankingPodium, SimpleRankRow, SectionHeader
    │   └── edit_profile_widgets.dart  # EditAvatarArea
    ├── search/
    └── settings/
        └── settings_widgets.dart      # SettingsGroup, SettingsItem, SettingsSwitch
```

> **NOT**: Bu ağaç project knowledge'dan türetilmiştir. Tam güncel yapı VS Code'da `find lib -type f -name "*.dart" | sort` ile alınmalıdır.

## Commands
```bash
flutter run                  # Run on connected iOS device/simulator
flutter analyze              # Check for errors/warnings
flutter build ios            # Production iOS build
flutter pub get              # Install dependencies
```

## Code Conventions
- Supabase column names: `snake_case` (e.g., full_name, avatar_url)
- Dart model fields: `camelCase` (e.g., fullName, avatarUrl)
- All user-facing strings → `AppStrings` (TR/EN)
- Colors → `AppColors` constants only
- Text styles → `AppTextStyles` only
- Shadows/radii → `AppThemeStyles` only
- Dark mode must be supported everywhere
- Haptic feedback on user interactions (HapticFeedback.lightImpact/mediumImpact)

---

## Database Schema (Supabase — 22 Tables, ALL RLS Enabled)

### Core Tables
| Table | Purpose | Rows | Notes |
|-------|---------|------|-------|
| `profiles` | User data (FK→auth.users via trigger) | 2 | 33 columns |
| `places` | Venues (lat/lng, rating, live_count, density) | 153 | owner_id, pinned_message |
| `posts` | Check-ins, reviews, social posts | 0 | place_id FK, detailed ratings |
| `messages` | DMs (room_id) ve grup sohbet (group_id) | 1 | ⚠️ RLS açığı |
| `active_sessions` | Mekandaki aktif kullanıcılar | 0 | 30dk auto-expire |
| `visits` | Doğrulanmış ziyaret geçmişi | 0 | is_verified flag |

### Social Tables
| Table | Purpose |
|-------|---------|
| `followers` | Takip ilişkileri (karşılıklı = arkadaş) |
| `friend_requests` | Bekleyen takip istekleri |
| `blocked_users` | Çift yönlü engelleme |
| `catches` | Gerçek zamanlı catch/poke (60sn expiry, 180sn cooldown) |
| `watchers` | Profil görüntüleme takibi (stalk detector) |

### Gamification
| Table | Purpose |
|-------|---------|
| `badge_definitions` | 19 rozet tanımı (common/rare/epic) |
| `user_badges` | Kazanılan rozetler (unique: user+badge+period) |
| `quest_definitions` | 18 görev şablonu (daily/weekly/epic) |
| `user_quests` | Görev ilerleme takibi |
| `quests` | ⚠️ ESKİ — quest_definitions/user_quests ile değiştirildi |

### User Data & System
`favorites` · `notes` · `notifications` (7 tip) · `reports` (4 target type) · `trust_score_logs`

### Profiles — Önemli Sütunlar
```
neer_score (numeric, default: 70.0)     ← ANA KULLANICI SKORU
neer_score_label (default: 'Standart')
status ('available'|'busy'|'pending', default: 'busy')
available_until, pending_catch_id
is_private, is_anonymous, is_online
followers_count, following_count
total_unique_places, total_cities, active_days
notification_settings (jsonb: {dm, social, marketing})
fcm_token, device_id, app_version
latitude, longitude, last_location_update
```

---

## Neer Score Sistemi
- **Skor aralığı**: 0–100, başlangıç: 70.0
- **Label**: neer_score_label (Standart, Güvenilir, vb.)
- **Günlük kazanım limiti**: 5 puan
- **Güncelleme**: `update_trust_score_v2` RPC
- **Senkronizasyon**: `sync_neer_score` trigger (profiles INSERT/UPDATE)
- **Audit trail**: trust_score_logs tablosu
- **Etki**: Mesaj cooldown süresi, anonim mod izinleri, rozet erişimi

---

## RPC Functions (35 toplam)

### Check-in/Out & Mekan
`check_in_to_place` · `check_out_from_place` · `submit_review` · `get_nearby_places` · `get_place_rating_stats` · `get_place_top_visitors`

### Sosyal & Mesajlaşma
`block_user` · `unblock_user` · `can_send_message` · `get_user_chat_list` · `get_user_group_chats` · `get_mutual_friends_locations` · `get_catch_cooldown_remaining` · `get_unread_counts` · `get_unread_notification_count`

### Profil & İstatistikler
`update_trust_score_v2` · `get_top_places` · `get_user_recent_visits` · `get_user_heatmap_points` · `get_user_identity_stats` · `increment_check_in_count`

### Feed & Gamification
`get_feed_posts` ⚠️ · `update_quest_progress`

### Bakım
`cleanup_expired_content` · `expire_availability` · `expire_pending_catches`

### Trigger Functions
`handle_new_user` · `handle_new_follow` · `trigger_notify_friend_request` · `trigger_notify_new_dm` · `trigger_update_place_rating` · `sync_neer_score` · `update_trust_score` · `on_catch_created` · `on_catch_resolved`

---

## Cron Jobs (4 aktif)
| Schedule | Purpose |
|----------|---------|
| Her gün 04:00 | 7 günlük mesaj temizliği |
| Her 5 dk | 30dk'dan eski aktif oturumları kapat |
| Her dakika | Müsaitlik süresini kontrol et |
| Her dakika | 60sn'den eski catch isteklerini expire et |

---

## Storage Buckets
| Bucket | Size Limit | MIME |
|--------|------------|------|
| `profile_images` | ⚠️ Limitsiz | ⚠️ Kısıtlama yok |
| `stories` | ⚠️ Limitsiz | ⚠️ Kısıtlama yok |
| `venue_photos` | 5 MB | jpeg, png, webp |

---

## 🔴 BROKEN — Çalışmayan Özellikler

1. **Feed RPC parametre uyumsuzluğu** — Flutter `(p_user_id, p_filter, p_limit, p_offset)` gönderiyor, Supabase `(page_number, page_size, filter_mode)` bekliyor
2. **Messages RLS güvenlik açığı** — `SELECT qual: true` → herkes tüm mesajları okuyabiliyor
3. **Business profile widget'ları mock data** — VenueLeaderboard, InteractionStatsGrid, EventTicketCard, FriendNoteBubble hep hardcoded
4. **Stalk Detector çalışmıyor** — Watchers SELECT policy hedef kullanıcının görmesine izin vermiyor
5. **Mesaj okundu çalışmıyor** — Messages UPDATE RLS policy yok
6. **Quest sistemi çift katmanlı** — Eski `quests` tablosu hala duruyor

---

## 🟡 Eksik Özellikler (Sosyal Platform İçin Gerekli)

1. **Push Notifications** — fcm_token var, gerçek push gönderimi yok
2. **Yorum sistemi** — comments tablosu yok, post'lara yorum yapılamıyor
3. **Story/Highlights** — stories bucket var, sistem geliştirilmemiş
4. **Premium/Ödeme** — UI var, backend (IAP, is_premium) yok
5. **Search RPC** — Full-text index var, search backend bağlantısı eksik
6. **Post paylaşımı / Repost** — yok
7. **@mention etiketleme** — yok
8. **Image moderation** — yok
9. **Offline cache** — yok

---

## ✅ TAMAMLANAN

- ✅ 22 tablo, hepsinde RLS aktif, 35 RPC, 10 trigger, 4 cron job, 28+ index
- ✅ Sunucu tarafı geofence, review doğrulama, rate limiting, Neer Score
- ✅ Gamification (19 rozet, 18 görev, heatmap)
- ✅ Catch & Status sistemi (60sn expiry, 180sn cooldown)
- ✅ Auth akışı, 5 tab navigasyon, dark/light mode, TR/EN
- ✅ Profil ekranı YENİ TASARIM (rozet capsule, podyum, kartlar)
- ✅ Mekan detay, DM/grup sohbet, harita bottom sheet'leri

---

## 🎨 Tasarım Referansı — Profil Ekranı (Yeni Standart)

Profil ekranı en son güncellenen ve diğer ekranlar için referans alınması gereken tasarımdır:

**Tab 1 — Profil**: Rozet capsule (yatay) → Podyum (RankingPodium 3D) → Favori kartlar (StackedCardCarousel) → Notlar → Değerlendirme geçmişi

**Tab 2 — Aktivite**: FeedPostCard / FeedReviewCard listesi

**Tab 3 — Galeri**: 3 sütun grid

**Güncellenecek ekranlar**: friend_profile, business_profile, chat, settings, feed, harita

---

## 📋 TODO

### P0 — Güvenlik (Acil)
- [ ] Messages RLS → SELECT'i katılımcılara kısıtla
- [ ] Storage bucket'lara limit ekle
- [ ] Feed RPC parametre fix

### P1 — Kırık Özellikler
- [ ] Business widget'ları gerçek veriyle besle
- [ ] Watchers policy → target görebilsin
- [ ] Messages UPDATE policy
- [ ] Eski quests tablosunu kaldır

### P2 — UI Tutarlılığı
- [ ] Diğer ekranları profil tasarımına uyarla
- [ ] Hardcoded string'leri AppStrings'e taşı
- [ ] fake_data_service.dart sil

### P3 — Eksik Temel Özellikler
- [ ] Push notification (FCM)
- [ ] Comments tablosu + yorum sistemi
- [ ] Story sistemi
- [ ] Search RPC

### P4 — Gelişmiş
- [ ] Premium/IAP backend
- [ ] State management (Riverpod)
- [ ] go_router
- [ ] Testler + CI/CD