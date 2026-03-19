# CLAUDE.md — Neer Project Context

## Project Overview
Neer is a location-based social network and venue interaction platform for iOS.
Slogan: "Explore what's Neer"
Core concept: Users socialize based on WHERE they are and WHEN they are there, not who they follow globally.

## Tech Stack
- **Frontend**: Flutter (Dart) — iOS target, developed in VS Code
- **Backend**: Supabase (PostgreSQL + Realtime + Auth + Storage)
- **Supabase Project ID**: celkzibnupgacoesaxse
- **Map**: flutter_map + MapTiler (OpenStreetMap tiles)
- **Location**: geolocator package
- **Fonts**: SF Pro (custom, in assets)
- **Min iOS**: 15.0

## Architecture (Current State — needs refactoring)
```
lib/
├── main.dart              # App entry, Supabase init, AuthGate, global vars
├── main_layout.dart       # Bottom nav with IndexedStack (5 tabs)
├── core/
│   ├── constants.dart     # AppColors
│   ├── text_styles.dart   # AppTextStyles
│   ├── theme_styles.dart  # AppThemeStyles (shadows, radii)
│   ├── theme_manager.dart # ThemeManager (ChangeNotifier)
│   ├── language_manager.dart
│   └── app_strings.dart   # Manual i18n (TR/EN static getters)
├── models/
│   ├── user_model.dart
│   ├── post_model.dart
│   └── place_model.dart
├── services/
│   ├── supabase_service.dart  # Main data service (RPC calls)
│   ├── storage_service.dart   # Image upload to Supabase Storage
│   └── fake_data_service.dart # Seed data generator (SHOULD BE REMOVED)
├── screens/               # 15+ screens, all StatefulWidget with setState
└── widgets/               # Reusable UI components
    ├── auth/
    ├── chat/
    ├── common/
    ├── dialogs/
    ├── feed/
    ├── map/
    ├── profile/
    ├── search/
    └── settings/
```

## Database Schema (Supabase — 15 tables)
- **profiles** — user data (linked to auth.users via trigger)
- **places** — venues with lat/lng, average_rating, live_user_count, density_status
- **posts** — check-ins, reviews, and social posts
- **messages** — DMs (room_id) and group chats (group_id)
- **active_sessions** — who is currently at which venue (geofence tracking)
- **visits** — verified venue visit history
- **favorites, notes, quests** — user personal data
- **followers** — follow relationships (mutual = friends)
- **friend_requests** — pending follow requests
- **blocked_users** — bidirectional blocking
- **notifications** — in-app notification system
- **reports** — user/content reports
- **trust_score_logs** — trust score change audit trail

## Key RPC Functions (Server-side business logic)
- `check_in_to_place` — geofence validation + session + live count
- `check_out_from_place` — end session + dwell time calc
- `submit_review` — proof-of-presence validated review
- `can_send_message` — rate limiting (cooldown by trust score and anon status)
- `update_trust_score_v2` — score changes with daily cap
- `block_user` / `unblock_user` — bidirectional block + cleanup
- `cleanup_expired_content` — 7-day message TTL (runs via pg_cron at 04:00)
- `get_nearby_places` — Haversine distance query
- `get_mutual_friends_locations` — mutual follow location data
- `get_feed_posts` — paginated feed with friend filter

## Commands
```bash
flutter run                  # Run on connected iOS device/simulator
flutter analyze              # Check for errors/warnings
flutter build ios            # Production iOS build
flutter pub get              # Install dependencies
```

## Code Conventions
- Supabase column names: snake_case (e.g., full_name, avatar_url, is_anonymous)
- Dart model fields: camelCase (e.g., fullName, avatarUrl, isAnonymous)
- All user-facing strings go through AppStrings (supports TR/EN)
- Colors only from AppColors constants
- Text styles only from AppTextStyles
- Shadows/radii only from AppThemeStyles
- Dark mode must be supported everywhere

## Known Issues and Technical Debt
1. NO STATE MANAGEMENT — everything uses setState, no Provider/Riverpod
2. Global variables in main.dart (themeManager, languageManager, supabase)
3. Supabase URL and anon key hardcoded in main.dart (should use env)
4. Commented-out Firebase imports still scattered in code
5. Some screens call Supabase directly instead of going through SupabaseService
6. Duplicate widget code (glass button pattern repeated in 4+ files)
7. No navigation/routing system (direct Navigator.push everywhere)
8. fake_data_service.dart still exists (development artifact)
9. No proper error boundary or loading state pattern
10. No unit tests or widget tests
11. withOpacity() used extensively (creates new Color objects each build)

## Business Rules (from project report)
- Photos: camera-only, no gallery uploads (Zero Gallery Policy)
- Chat messages: auto-delete after 7 days (168 hours)
- Reviews: require 15+ min dwell time + GPS proof
- Anonymous mode: tiered cooldowns (30s/60s/120s based on trust score)
- Trust score: 0-100 scale, starts at 70, daily gain cap of 5 points
- Blocking: bidirectional invisibility in map, search, and chat
- Rate limiting: 3s for verified users, 20s for low trust, 30-120s for anonymous

## UI/UX Design System (Premium Glassmorphism & Bento Box)
- **Core Aesthetic:** Apple VisionOS style. High blur, extreme transparency, dynamic ambient backgrounds.
- **Glass Panel Rules:** - `blurSigma`: Minimum 45.
  - Alpha (Transparency): `0.12 - 0.25` range.
  - Borders: Always 1px frosted edges using `Colors.white.withValues(alpha: 0.18)`.
- **Micro-interactions (Haptics):** All tappable glass buttons/cards must shrink (`Scale: 0.95`) on press and trigger `HapticFeedback.lightImpact()` or `heavyImpact()` via spring animations.
- **Layout Architecture:**
  - **Profiles:** "Bento Box" asymmetrical grids. NO stacked horizontal scrolling lists (except for specific carousels).
  - **Tabs & Nav:** Floating "Pill" (Segmented Control) designs, not edge-to-edge full bars.
  - **Lists (Chat/Feed/Notifications):** "Floating Islands" (cards with `padding: 16` and `12px` gaps). ABSOLUTELY NO standard lines/dividers (`Divider`).
- **Color/Opacity Rule:** NEVER use `.withOpacity()`. Always use `.withValues(alpha: ...)` to prevent performance leaks and follow modern Flutter standards.