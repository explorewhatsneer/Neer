# CLAUDE.md — Neer iOS Native (Swift) — Kesin Spesifikasyon
# Claude Code Direktifi — Tüm Kararlar Kesinleşti, Tartışma Yok

---

## Proje Kimliği

| Alan | Değer |
|------|-------|
| Uygulama | Neer — Konum tabanlı sosyal ağ |
| Slogan | "Explore what's Neer" |
| Platform | iOS + iPadOS (Universal) |
| Minimum OS | iOS 17.0 / iPadOS 17.0 |
| Bundle ID | `app.neer.ios` |
| Supabase URL | `https://celkzibnupgacoesaxse.supabase.co` |
| Supabase Project ID | `celkzibnupgacoesaxse` |
| Domain | `neer.app` |
| GitHub | https://github.com/explorewhatsneer/Neer |

---

## Teknoloji Yığını — KESİN, DEĞİŞMEZ

| Katman | Teknoloji | Not |
|--------|-----------|-----|
| Dil | Swift 6 | Strict concurrency aktif |
| UI | SwiftUI (iOS 17+) | UIKit sadece belirtilen yerlerde |
| Mimari | MVVM + `@Observable` | Combine YOK, async/await kullan |
| State | `@Observable`, `@Environment` | ObservableObject + @Published yok |
| Navigasyon | `NavigationStack` + `TabView` | |
| Backend | supabase-swift ^2.x | SPM ile |
| Harita | MapKit — Apple Maps native | MKMapView + UIViewRepresentable |
| Harita stil | `MKStandardMapConfiguration` dark | MapTiler YOK, tile overlay YOK |
| Realtime | Supabase Realtime → `AsyncStream` | |
| Görsel | `AsyncImage` + `NSCache` | |
| Lokasyon | CoreLocation | Background geofence, "Always" izni |
| Bildirim | APNs | FCM yok |
| IAP | StoreKit 2 | |
| Analytics | App Store Connect + MetricKit | Firebase yok |
| Crash | MetricKit + Sentry free tier | |
| Font | SF Pro — sistem fontu | Bundle'a ekleme |
| Paket Yöneticisi | SPM | CocoaPods yok |
| CI/CD | Xcode Cloud | |

### SPM Bağımlılıkları
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0"),
    .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.0.0"),
]
// Başka paket ekleme — önce sor.
```

---

## Auth — 4 Yöntem

```swift
// AuthService.swift
enum AuthMethod {
    case emailPassword(email: String, password: String)
    case phone(number: String, otp: String)      // SMS OTP — Supabase built-in
    case apple(credential: ASAuthorizationAppleIDCredential)
    case google(idToken: String)                  // Supabase OAuth, Google SDK'sız
}
```

**Supabase Dashboard'da aktif edilecekler:** Email/Password ✓ · Phone (Twilio) · Apple · Google

---

## Proje Dizin Yapısı

```
Neer/
├── NeerApp.swift
├── Info.plist
├── Secrets.xcconfig              # git'e gitme — SUPABASE_ANON_KEY, SENTRY_DSN
│
├── Core/
│   ├── SupabaseClient.swift      # Singleton
│   ├── AppColors.swift           # Brand renkleri, dark/light
│   ├── AppStrings.swift          # TR/EN — String(localized:)
│   ├── AppConstants.swift        # Sabit değerler
│   └── Extensions/
│       ├── View+Extensions.swift
│       ├── String+Extensions.swift
│       └── Date+Extensions.swift
│
├── Models/                       # Hepsi Codable + CodingKeys
│   ├── UserModel.swift           # 33 sütun — TAM LİSTE AŞAĞIDA
│   ├── PlaceModel.swift
│   ├── PostModel.swift
│   ├── MessageModel.swift
│   ├── CatchModel.swift
│   ├── StoryModel.swift
│   ├── NotificationModel.swift
│   ├── BadgeModel.swift
│   └── QuestModel.swift
│
├── Services/
│   ├── AuthService.swift         # 4 yöntem
│   ├── SupabaseService.swift     # 35 RPC + CRUD — TAM LİSTE AŞAĞIDA
│   ├── StorageService.swift
│   ├── LocationService.swift     # CoreLocation + background geofence
│   ├── RealtimeService.swift     # AsyncStream wrapper
│   ├── NotificationService.swift # APNs
│   ├── DeepLinkService.swift     # URL scheme + Universal Links
│   ├── CacheService.swift        # Offline için son state
│   └── HapticService.swift
│
├── Features/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift        # 4 slide — ZORUNLU, direkt login yok
│   │   └── OnboardingViewModel.swift
│   │
│   ├── Auth/
│   │   ├── AuthGate.swift              # Onboarding → Login → Main akışı
│   │   ├── LoginView.swift
│   │   ├── RegisterView.swift
│   │   ├── PhoneAuthView.swift         # SMS OTP
│   │   └── AuthViewModel.swift
│   │
│   ├── Map/
│   │   ├── MapView.swift
│   │   ├── MapViewModel.swift
│   │   ├── NeerMapView.swift           # UIViewRepresentable — Apple Maps
│   │   ├── PlaceAnnotationView.swift   # Density rengine göre custom pin
│   │   ├── PlaceSheetView.swift
│   │   ├── UserSheetView.swift
│   │   └── CheckInView.swift
│   │
│   ├── Feed/
│   │   ├── FeedView.swift
│   │   ├── FeedViewModel.swift
│   │   ├── PostCardView.swift
│   │   └── ReviewCardView.swift
│   │
│   ├── Story/
│   │   ├── StoryCreatorView.swift      # Sadece active_session varken açılır
│   │   ├── StoryPlayerView.swift
│   │   ├── StoryThumbnailView.swift
│   │   └── StoryViewModel.swift
│   │
│   ├── Chat/
│   │   ├── ChatListView.swift
│   │   ├── DMChatView.swift
│   │   ├── GroupChatView.swift         # Sadece check-in yapanlara açık
│   │   ├── ChatViewModel.swift
│   │   └── MessageBubbleView.swift
│   │
│   ├── Catch/
│   │   ├── CatchView.swift
│   │   ├── CatchViewModel.swift
│   │   └── StatusPickerView.swift
│   │
│   ├── Profile/
│   │   ├── ProfileView.swift           # 3 tab: Profil / Aktivite / Galeri
│   │   ├── ProfileViewModel.swift
│   │   ├── EditProfileView.swift
│   │   ├── FriendProfileView.swift
│   │   ├── BusinessProfileView.swift
│   │   └── Components/
│   │       ├── BadgeCapsuleRow.swift
│   │       ├── RankingPodiumView.swift
│   │       ├── StoryGalleryGrid.swift  # Arşivlenmiş story'ler — herkese açık
│   │       └── StackedCardCarousel.swift
│   │
│   ├── Search/
│   │   ├── SearchView.swift
│   │   └── SearchViewModel.swift
│   │
│   ├── Notifications/
│   │   ├── NotificationsView.swift
│   │   └── NotificationsViewModel.swift
│   │
│   └── Settings/
│       ├── SettingsView.swift
│       ├── AppearanceView.swift        # Dark / Light / System — kullanıcı seçer
│       ├── AccountInfoView.swift
│       ├── BlockedUsersView.swift
│       ├── PremiumView.swift
│       └── SettingsViewModel.swift
│
├── Shared/
│   ├── Components/
│   │   ├── GlassCard.swift
│   │   ├── CheckInButton.swift
│   │   ├── AvatarView.swift
│   │   ├── NeerBadge.swift
│   │   ├── EmptyStateView.swift
│   │   ├── OfflineBannerView.swift     # Bağlantı yoksa üstte banner
│   │   ├── LoadingView.swift
│   │   └── AppConfirmDialog.swift
│   └── Modifiers/
│       ├── HapticModifier.swift
│       └── ShareSheetModifier.swift
│
└── Resources/
    ├── Assets.xcassets               # dark/light karşılıklı renkler
    └── Localizable.strings           # TR (primary) + EN
```

---

## Veritabanı Şeması — 22 Tablo (Supabase, Tümünde RLS Aktif)

### Core Tablolar
| Tablo | Açıklama | Notlar |
|-------|----------|--------|
| `profiles` | Kullanıcı verisi (auth.users'a trigger ile bağlı) | 33 sütun |
| `places` | Mekanlar (lat/lng, rating, live_count, density) | 153 kayıt, owner_id, pinned_message |
| `posts` | Check-in, review, sosyal post | place_id FK, detaylı rating |
| `messages` | DM (room_id) ve grup sohbet (group_id) | ⚠️ RLS düzeltilecek |
| `active_sessions` | Mekandaki aktif kullanıcılar | 30 dk auto-expire |
| `visits` | Doğrulanmış ziyaret geçmişi | is_verified flag |
| `stories` | Check-in bazlı story'ler | YENİ — SQL aşağıda |

### Sosyal Tablolar
| Tablo | Açıklama |
|-------|----------|
| `followers` | Takip ilişkileri (karşılıklı = arkadaş) |
| `friend_requests` | Bekleyen takip istekleri |
| `blocked_users` | Çift yönlü engelleme |
| `catches` | Gerçek zamanlı catch (60sn expiry, 180sn cooldown) |
| `watchers` | Profil görüntüleme takibi (stalk detector) |

### Gamification
| Tablo | Açıklama |
|-------|----------|
| `badge_definitions` | 19 rozet (common/rare/epic) |
| `user_badges` | Kazanılan rozetler |
| `quest_definitions` | 18 görev (daily/weekly/epic) |
| `user_quests` | Görev ilerleme |
| `quests` | ⚠️ ESKİ — kullanma, devre dışı bırakılacak |

### Diğer
`favorites` · `notes` · `notifications` (7 tip) · `reports` (4 hedef tip) · `trust_score_logs`

---

## Profiles Tablosu — 33 Sütunun Tamamı

```swift
// Models/UserModel.swift
struct UserModel: Codable, Identifiable {
    let id: UUID
    var fullName: String
    var username: String
    var bio: String?
    var avatarUrl: String?
    var neerScore: Double           // 0–100, başlangıç: 70.0
    var neerScoreLabel: String      // Kısıtlı / Standart / Güvenilir / Uzman / Elite
    var status: UserStatus          // available | busy | pending
    var availableUntil: Date?
    var pendingCatchId: UUID?
    var isPrivate: Bool
    var isAnonymous: Bool
    var isOnline: Bool
    var isPremium: Bool
    var followersCount: Int
    var followingCount: Int
    var totalUniquePlaces: Int
    var totalCities: Int
    var activeDays: Int
    var notificationSettings: NotificationSettings  // jsonb
    var fcmToken: String?
    var apnsToken: String?          // YENİ — APNs için
    var deviceId: String?
    var appVersion: String?
    var latitude: Double?
    var longitude: Double?
    var lastLocationUpdate: Date?
    var createdAt: Date
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, username, bio
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case neerScore = "neer_score"
        case neerScoreLabel = "neer_score_label"
        case status
        case availableUntil = "available_until"
        case pendingCatchId = "pending_catch_id"
        case isPrivate = "is_private"
        case isAnonymous = "is_anonymous"
        case isOnline = "is_online"
        case isPremium = "is_premium"
        case followersCount = "followers_count"
        case followingCount = "following_count"
        case totalUniquePlaces = "total_unique_places"
        case totalCities = "total_cities"
        case activeDays = "active_days"
        case notificationSettings = "notification_settings"
        case fcmToken = "fcm_token"
        case apnsToken = "apns_token"
        case deviceId = "device_id"
        case appVersion = "app_version"
        case latitude, longitude
        case lastLocationUpdate = "last_location_update"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum UserStatus: String, Codable { case available, busy, pending }

struct NotificationSettings: Codable {
    var dm: Bool
    var social: Bool
    var marketing: Bool
}
```

---

## Diğer Model Tanımları

```swift
// Models/PlaceModel.swift
struct PlaceModel: Codable, Identifiable {
    let id: Int
    var name: String
    var category: String
    var latitude: Double
    var longitude: Double
    var averageRating: Double
    var liveUserCount: Int
    var densityStatus: String   // "low" | "medium" | "high"
    var ownerId: UUID?
    var pinnedMessage: String?
    var imageUrl: String?
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, category, latitude, longitude
        case averageRating = "average_rating"
        case liveUserCount = "live_user_count"
        case densityStatus = "density_status"
        case ownerId = "owner_id"
        case pinnedMessage = "pinned_message"
        case imageUrl = "image_url"
        case createdAt = "created_at"
    }
}

// Models/PostModel.swift
struct PostModel: Codable, Identifiable {
    let id: UUID
    var userId: UUID
    var placeId: Int?
    var postType: PostType          // checkin | review | post
    var content: String?
    var imageUrls: [String]
    var rating: Double?
    var likesCount: Int
    var commentsCount: Int
    var isAnonymous: Bool
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case placeId = "place_id"
        case postType = "post_type"
        case content
        case imageUrls = "image_urls"
        case rating
        case likesCount = "likes_count"
        case commentsCount = "comments_count"
        case isAnonymous = "is_anonymous"
        case createdAt = "created_at"
    }
}

enum PostType: String, Codable { case checkin, review, post }

// Models/MessageModel.swift
struct MessageModel: Codable, Identifiable {
    let id: UUID
    var senderId: UUID
    var roomId: String?             // DM için
    var groupId: String?            // Mekan grubu için
    var content: String
    var imageUrl: String?
    var isAnonymous: Bool
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, content
        case senderId = "sender_id"
        case roomId = "room_id"
        case groupId = "group_id"
        case imageUrl = "image_url"
        case isAnonymous = "is_anonymous"
        case createdAt = "created_at"
    }
}

// Models/CatchModel.swift
struct CatchModel: Codable, Identifiable {
    let id: UUID
    var senderId: UUID
    var receiverId: UUID
    var status: CatchStatus         // pending | accepted | rejected | expired
    var expiresAt: Date             // 60 saniye sonra
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, status
        case senderId = "sender_id"
        case receiverId = "receiver_id"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
    }
}

enum CatchStatus: String, Codable { case pending, accepted, rejected, expired }

// Models/StoryModel.swift
struct StoryModel: Codable, Identifiable {
    let id: UUID
    var userId: UUID
    var placeId: Int?
    var mediaUrl: String
    var isActive: Bool              // 24 saat sonra false
    var showOnVenue: Bool           // Kullanıcı seçti mi?
    var expiresAt: Date             // created_at + 24 saat
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case placeId = "place_id"
        case mediaUrl = "media_url"
        case isActive = "is_active"
        case showOnVenue = "show_on_venue"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
    }
}

// Models/NotificationModel.swift
// 7 bildirim tipi:
enum NotificationType: String, Codable {
    case dm             // Yeni DM
    case friendRequest  // Arkadaşlık isteği
    case catchRequest   // Catch isteği
    case newFollower    // Yeni takipçi
    case postLike       // Post beğeni
    case checkInBadge   // Yeni rozet kazanıldı
    case system         // Sistem mesajı
}

struct NotificationModel: Codable, Identifiable {
    let id: Int
    var userId: UUID
    var type: NotificationType
    var title: String
    var body: String
    var isRead: Bool
    var relatedId: String?          // İlgili entity ID
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, type, title, body
        case userId = "user_id"
        case isRead = "is_read"
        case relatedId = "related_id"
        case createdAt = "created_at"
    }
}
```

---

## RPC Fonksiyonları — 35 Adet, Tüm Swift İmzaları

```swift
// Services/SupabaseService.swift
actor SupabaseService {
    static let shared = SupabaseService()
    private let db = SupabaseClient.shared

    // ── CHECK-IN / MEKAN ──────────────────────────────────────────

    func checkIn(placeId: Int, lat: Double, lng: Double) async throws -> CheckInResult {
        try await db.rpc("check_in_to_place", params: [
            "p_place_id": placeId, "p_latitude": lat, "p_longitude": lng
        ]).execute().value
    }

    func checkOut() async throws {
        try await db.rpc("check_out_from_place", params: [:]).execute()
    }

    func submitReview(placeId: Int, rating: Double, content: String) async throws {
        try await db.rpc("submit_review", params: [
            "p_place_id": placeId, "p_rating": rating, "p_content": content
        ]).execute()
    }

    func getNearbyPlaces(lat: Double, lng: Double, radius: Int = 1000) async throws -> [PlaceModel] {
        try await db.rpc("get_nearby_places", params: [
            "p_lat": lat, "p_lng": lng, "p_radius": radius
        ]).execute().value
    }

    func getPlaceRatingStats(placeId: Int) async throws -> PlaceRatingStats {
        try await db.rpc("get_place_rating_stats", params: ["p_place_id": placeId]).execute().value
    }

    func getPlaceTopVisitors(placeId: Int) async throws -> [UserModel] {
        try await db.rpc("get_place_top_visitors", params: ["p_place_id": placeId]).execute().value
    }

    // ── SOSYAL / MESAJLAŞMA ──────────────────────────────────────

    func blockUser(blockedId: UUID) async throws {
        try await db.rpc("block_user", params: ["p_blocker": currentUID, "p_blocked": blockedId]).execute()
    }

    func unblockUser(blockedId: UUID) async throws {
        try await db.rpc("unblock_user", params: ["p_blocker": currentUID, "p_blocked": blockedId]).execute()
    }

    func canSendMessage(groupId: String) async throws -> MessagePermission {
        try await db.rpc("can_send_message", params: [
            "p_user_id": currentUID, "p_group_id": groupId
        ]).execute().value
    }

    func getUserChatList() async throws -> [ChatRoom] {
        try await db.rpc("get_user_chat_list", params: ["p_user_id": currentUID]).execute().value
    }

    func getUserGroupChats() async throws -> [GroupChat] {
        try await db.rpc("get_user_group_chats", params: ["p_user_id": currentUID]).execute().value
    }

    func getMutualFriendsLocations() async throws -> [FriendLocation] {
        try await db.rpc("get_mutual_friends_locations", params: ["p_user_id": currentUID]).execute().value
    }

    func getCatchCooldownRemaining() async throws -> Int {
        try await db.rpc("get_catch_cooldown_remaining", params: ["p_user_id": currentUID]).execute().value
    }

    func getUnreadCounts() async throws -> UnreadCounts {
        try await db.rpc("get_unread_counts", params: ["p_user_id": currentUID]).execute().value
    }

    func getUnreadNotificationCount() async throws -> Int {
        try await db.rpc("get_unread_notification_count", params: ["p_user_id": currentUID]).execute().value
    }

    // ── PROFİL / İSTATİSTİK ──────────────────────────────────────

    func updateTrustScore(amount: Int, reason: String) async throws -> Double {
        try await db.rpc("update_trust_score_v2", params: [
            "p_user_id": currentUID, "p_amount": amount, "p_reason": reason
        ]).execute().value
    }

    func getTopPlaces(limit: Int = 10) async throws -> [PlaceModel] {
        try await db.rpc("get_top_places", params: ["p_limit": limit]).execute().value
    }

    func getRecentVisits(userId: UUID) async throws -> [Visit] {
        try await db.rpc("get_user_recent_visits", params: ["target_uid": userId]).execute().value
    }

    func getHeatmapPoints(userId: UUID) async throws -> [HeatmapPoint] {
        try await db.rpc("get_user_heatmap_points", params: ["p_user_id": userId]).execute().value
    }

    func getIdentityStats(userId: UUID) async throws -> IdentityStats {
        try await db.rpc("get_user_identity_stats", params: ["p_user_id": userId]).execute().value
    }

    func incrementCheckInCount(placeId: Int) async throws {
        try await db.rpc("increment_check_in_count", params: ["p_place_id": placeId]).execute()
    }

    // ── FEED / GAMİFİKASYON ──────────────────────────────────────

    // ⚠️ Flutter'da kırıktı — DOĞRU parametreler bunlar:
    func getFeedPosts(filter: FeedFilter, page: Int = 0, pageSize: Int = 20) async throws -> [PostModel] {
        try await db.rpc("get_feed_posts", params: [
            "page_number": page,        // p_user_id DEĞİL
            "page_size": pageSize,      // p_limit DEĞİL
            "filter_mode": filter.rawValue
        ]).execute().value
    }

    func updateQuestProgress(questId: UUID, progress: Int) async throws {
        try await db.rpc("update_quest_progress", params: [
            "p_quest_id": questId, "p_progress": progress
        ]).execute()
    }

    // ── SEARCH ───────────────────────────────────────────────────

    func searchPlaces(query: String) async throws -> [PlaceModel] {
        try await db.from("places")
            .select()
            .textSearch("name", query: query)
            .execute().value
    }

    func searchUsers(query: String) async throws -> [UserModel] {
        try await db.from("profiles")
            .select()
            .textSearch("username", query: query)
            .execute().value
    }

    // ── CRUD ──────────────────────────────────────────────────────

    func getProfile(userId: UUID) async throws -> UserModel {
        try await db.from("profiles").select().eq("id", value: userId).single().execute().value
    }

    func updateProfile(_ fields: [String: Any]) async throws {
        try await db.from("profiles").update(fields).eq("id", value: currentUID).execute()
    }

    func getActiveSession() async throws -> ActiveSession? {
        try await db.from("active_sessions")
            .select("*, places(name, image_url)")
            .eq("user_id", value: currentUID)
            .eq("is_active", value: true)
            .maybeSingle()
            .execute().value
    }

    func getActiveUsersAtPlace(placeId: Int) async throws -> [UserModel] {
        try await db.from("active_sessions")
            .select("user_id, profiles(full_name, username, avatar_url)")
            .eq("place_id", value: placeId)
            .eq("is_active", value: true)
            .execute().value
    }

    func markNotificationsRead() async throws {
        try await db.from("notifications")
            .update(["is_read": true])
            .eq("user_id", value: currentUID)
            .eq("is_read", value: false)
            .execute()
    }

    private var currentUID: UUID {
        SupabaseClient.shared.auth.currentUser!.id
    }
}

enum FeedFilter: String { case nearby, friends, trending }
```

---

## Supabase Singleton + Başlatma

```swift
// Core/SupabaseClient.swift
import Supabase

extension SupabaseClient {
    static let shared = SupabaseClient(
        supabaseURL: URL(string: "https://celkzibnupgacoesaxse.supabase.co")!,
        supabaseKey: Secrets.supabaseAnonKey
    )
}

// NeerApp.swift
@main
struct NeerApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("colorScheme") private var colorScheme: AppColorScheme = .dark
    @State private var authService = AuthService.shared

    init() {
        // Sentry başlat
        SentrySDK.start { options in
            options.dsn = Secrets.sentryDSN
            options.environment = isDebug ? "development" : "production"
            options.tracesSampleRate = 0.1
        }
        // MetricKit
        MXMetricManager.shared.add(self as! MXMetricManagerSubscriber)
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if !hasSeenOnboarding {
                    OnboardingView()
                } else if authService.isAuthenticated {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
            .preferredColorScheme(colorScheme.swiftUIValue)
            .environment(authService)
        }
    }
}

enum AppColorScheme: String, CaseIterable {
    case system, dark, light
    var swiftUIValue: ColorScheme? {
        switch self {
        case .dark: return .dark
        case .light: return .light
        case .system: return nil
        }
    }
}
```

---

## Auth Servisi — 4 Yöntem

```swift
// Services/AuthService.swift
@Observable
final class AuthService {
    static let shared = AuthService()
    var currentUser: UserModel?
    var isAuthenticated = false

    private let client = SupabaseClient.shared

    func signIn(email: String, password: String) async throws {
        let session = try await client.auth.signIn(email: email, password: password)
        await loadProfile(userId: session.user.id)
    }

    func signUp(email: String, password: String, username: String, fullName: String) async throws {
        let session = try await client.auth.signUp(email: email, password: password, data: [
            "username": .string(username), "full_name": .string(fullName)
        ])
        await loadProfile(userId: session.user.id)
    }

    // Telefon: 2 adım — OTP gönder, sonra doğrula
    func sendOTP(phone: String) async throws {
        try await client.auth.signInWithOTP(phone: phone)
    }

    func verifyOTP(phone: String, token: String) async throws {
        let session = try await client.auth.verifyOTP(phone: phone, token: token, type: .sms)
        await loadProfile(userId: session.user.id)
    }

    // Apple Sign In
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else { return }
        let session = try await client.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: tokenString)
        )
        await loadProfile(userId: session.user.id)
    }

    // Google Sign In — Supabase OAuth (Google SDK kullanmadan)
    func signInWithGoogle() async throws {
        let url = try await client.auth.getOAuthSignInURL(provider: .google, redirectTo: URL(string: "neer://auth")!)
        await UIApplication.shared.open(url)
        // OAuth callback: DeepLinkService'de handle edilir
    }

    func handleOAuthCallback(url: URL) async throws {
        let session = try await client.auth.session(from: url)
        await loadProfile(userId: session.user.id)
    }

    func signOut() async throws {
        try await client.auth.signOut()
        currentUser = nil
        isAuthenticated = false
    }

    private func loadProfile(userId: UUID) async {
        currentUser = try? await SupabaseService.shared.getProfile(userId: userId)
        isAuthenticated = currentUser != nil
    }
}
```

---

## Apple Maps Kurulumu

```swift
// Features/Map/NeerMapView.swift
struct NeerMapView: UIViewRepresentable {
    @Binding var places: [PlaceModel]
    @Binding var selectedPlace: PlaceModel?
    @Environment(\.colorScheme) var colorScheme

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = true
        map.showsCompass = false

        // Dark Apple Maps — MapTiler YOK
        let config = MKStandardMapConfiguration(elevationStyle: .realistic)
        config.pointOfInterestFilter = .init(including: [
            .restaurant, .cafe, .bar, .nightlife, .bakery
        ])
        map.preferredConfiguration = config
        map.overrideUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        map.removeAnnotations(map.annotations.compactMap { $0 as? PlaceAnnotation })
        map.addAnnotations(places.map { PlaceAnnotation(place: $0) })
    }
}

final class PlaceAnnotation: NSObject, MKAnnotation {
    let place: PlaceModel
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
    }
    var title: String? { place.name }

    var pinColor: UIColor {
        switch place.densityStatus {
        case "low":    return UIColor(red: 0.20, green: 0.82, blue: 0.35, alpha: 1) // Yeşil
        case "medium": return UIColor(red: 1.00, green: 0.58, blue: 0.00, alpha: 1) // Turuncu
        case "high":   return UIColor(red: 1.00, green: 0.23, blue: 0.19, alpha: 1) // Kırmızı
        default:       return .systemGray
        }
    }
    init(place: PlaceModel) { self.place = place }
}
```

---

## Lokasyon Servisi

```swift
// Services/LocationService.swift
@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    var currentLocation: CLLocationCoordinate2D?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
    }

    func requestAlwaysAuthorization() {
        manager.requestAlwaysAuthorization()
    }

    func currentLocation() async throws -> CLLocationCoordinate2D {
        try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }

    // Mekan geofence izleme — 100m radius
    func startMonitoring(place: PlaceModel) {
        let region = CLCircularRegion(
            center: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude),
            radius: 100,
            identifier: "place-\(place.id)"
        )
        region.notifyOnEntry = true
        region.notifyOnExit = true
        manager.startMonitoring(for: region)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        currentLocation = loc.coordinate
        locationContinuation?.resume(returning: loc.coordinate)
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
}
```

---

## Realtime — AsyncStream Pattern

```swift
// Services/RealtimeService.swift
final class RealtimeService {
    static let shared = RealtimeService()
    private let client = SupabaseClient.shared

    func streamDMMessages(roomId: String) -> AsyncStream<MessageModel> {
        AsyncStream { continuation in
            let channel = client.realtimeV2.channel("room-\(roomId)")
            channel.onPostgresChange(InsertAction.self, table: "messages",
                filter: "room_id=eq.\(roomId)") { change in
                if let msg = try? change.decodeRecord(as: MessageModel.self) {
                    continuation.yield(msg)
                }
            }
            Task { await channel.subscribe() }
            continuation.onTermination = { _ in Task { await channel.unsubscribe() } }
        }
    }

    func streamGroupMessages(groupId: String) -> AsyncStream<MessageModel> {
        AsyncStream { continuation in
            let channel = client.realtimeV2.channel("group-\(groupId)")
            channel.onPostgresChange(InsertAction.self, table: "messages",
                filter: "group_id=eq.\(groupId)") { change in
                if let msg = try? change.decodeRecord(as: MessageModel.self) {
                    continuation.yield(msg)
                }
            }
            Task { await channel.subscribe() }
            continuation.onTermination = { _ in Task { await channel.unsubscribe() } }
        }
    }

    func streamLiveCount(placeId: Int) -> AsyncStream<Int> {
        AsyncStream { continuation in
            let channel = client.realtimeV2.channel("place-\(placeId)")
            channel.onPostgresChange(UpdateAction.self, table: "places",
                filter: "id=eq.\(placeId)") { change in
                if let place = try? change.decodeRecord(as: PlaceModel.self) {
                    continuation.yield(place.liveUserCount)
                }
            }
            Task { await channel.subscribe() }
            continuation.onTermination = { _ in Task { await channel.unsubscribe() } }
        }
    }
}
```

---

## Story Sistemi

### İş Kuralları
1. `active_sessions`'da aktif kayıt yoksa story oluşturulamaz
2. Story oluşturulurken: "Bu fotoğrafı [Mekan Adı] profilinde göster" — opsiyonel checkbox
3. 24 saat sonra `is_active = false`, profil galerisine arşivlenir
4. Galeri herkese açık (private profilde bile)
5. Story grup sohbetiyle bağlantısı yok — sadece profil ve mekan profilinde

### Supabase SQL (Faz 1'den önce çalıştır)
```sql
CREATE TABLE stories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    place_id INT REFERENCES places(id),
    media_url TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    show_on_venue BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    expires_at TIMESTAMPTZ DEFAULT now() + INTERVAL '24 hours'
);

ALTER TABLE stories ENABLE ROW LEVEL SECURITY;

-- Herkese açık okuma
CREATE POLICY "stories_select" ON stories FOR SELECT USING (true);

-- Sadece active check-in varken oluştur
CREATE POLICY "stories_insert" ON stories FOR INSERT WITH CHECK (
    user_id = auth.uid() AND
    EXISTS (
        SELECT 1 FROM active_sessions
        WHERE user_id = auth.uid() AND is_active = true
    )
);

CREATE POLICY "stories_delete" ON stories FOR DELETE USING (user_id = auth.uid());

-- Cron: Her saat expire et (Supabase cron extensions'da)
SELECT cron.schedule('expire-stories', '0 * * * *',
    $$UPDATE stories SET is_active = false
      WHERE expires_at < now() AND is_active = true$$);
```

---

## Catch Sistemi — İş Kuralları

```swift
// Catch zaman sabitleri — AppConstants.swift
enum CatchConstants {
    static let expirySeconds = 60       // Gönderilen catch 60sn içinde kabul edilmezse expire
    static let cooldownSeconds = 180    // Aynı kişiye tekrar catch atmak için 3dk bekle
    static let maxPendingCatches = 1    // Aynı anda sadece 1 pending catch
}

// CatchViewModel — cooldown kontrolü
func sendCatch(to userId: UUID) async throws {
    let remaining = try await SupabaseService.shared.getCatchCooldownRemaining()
    guard remaining == 0 else {
        throw CatchError.cooldown(secondsLeft: remaining)
    }
    // catch gönder
}
```

---

## Anonim Mod — 3 Seviye

```swift
// Anonim mod kuralları — PDF Tablo 4.1'den
enum AnonLevel: Int {
    case rookie  = 1   // İlk 24 saat veya düşük skor → 120sn cooldown, 1 mekan
    case regular = 2   // 1 hafta sorunsuz → 60sn cooldown, yakın mekanlar
    case trusted = 3   // 1 ay + skor >80 → 30sn cooldown, öncelikli mesaj

    static func current(neerScore: Double, activeDays: Int) -> AnonLevel {
        if neerScore > 80 && activeDays > 30 { return .trusted }
        if activeDays > 7 { return .regular }
        return .rookie
    }

    var messageCooldown: Int {
        switch self { case .rookie: return 120; case .regular: return 60; case .trusted: return 30 }
    }
}
```

---

## Neer Score Sistemi

| Eylem | Puan | Limit |
|-------|------|-------|
| Sisteme kayıt | +70 başlangıç | Tek seferlik |
| Faydalı mesaj | +1 | Günlük max 5 |
| Onaylanan anket | +2 | — |
| Arkadaşlık kabulü | +2 | — |
| Onaylanmış şikayet | -5 | — |
| Spam tespiti | -3 | — |

| Etiket | TR | EN | Eşik |
|--------|----|----|------|
| Kısıtlı | Kısıtlı | Limited | 0–? |
| Standart | Standart | Standard | Başlangıç: 70 |
| Güvenilir | Güvenilir | Trusted | >80 |
| Uzman | Uzman | Expert | ? |
| Elite | Elite | Elite | ? |

> ⚠️ Tam eşikler: Supabase → Database → Functions → `sync_neer_score`

---

## Premium vs Free

| Özellik | Free | Premium |
|---------|------|---------|
| Anonim mod | Süre + cooldown limiti | Sınırsız |
| Harita pini | Standart avatar | Neon çerçeveli |
| Profil fotosu | Statik | Hareketli (GIF/Video) |
| DM sıralama | Standart | Öncelikli (en üstte) |
| Filtreler | Temel | Pro (sadece dolu, arkadaş) |
| Reklam | Var | Yok |
| İAP ID'leri | — | `app.neer.premium.monthly`, `app.neer.premium.yearly` |

---

## Storage Bucket Detayları

Supabase'den doğrulandı — tüm bucket'lar tam konfigüre edilmiş, Swift'te ek limit gerekmez.

| Bucket | Limit | MIME Tipleri | Not |
|--------|-------|-------------|-----|
| `profile_images` | 5 MB | jpeg, png, webp | ✅ Konfigüre edilmiş |
| `stories` | 10 MB | jpeg, png, webp, **mp4, quicktime** | ✅ Video story destekli |
| `venue_photos` | 5 MB | jpeg, png, webp | ✅ Konfigüre edilmiş |

> **Video story notu:** `stories` bucket'ı video kabul ediyor.
> `StoryCreatorView`'da hem fotoğraf hem video kaydı sunulabilir.
> `PHPickerViewController` veya `UIImagePickerController` ile video seçimi ekle.

---

## Cron Jobs (4 Aktif)

| Zamanlama | Görev |
|-----------|-------|
| Her gün 04:00 | 7 günlük mesajları sil |
| Her 5 dakika | 30 dk'dan eski active_sessions'ı kapat |
| Her dakika | Müsaitlik süresi kontrolü |
| Her dakika | 60sn'den eski catch'leri expire et |
| Her saat | ⭐ YENİ — Story expire (stories tablosu) |

---

## Universal Links + Deep Link

```swift
// Services/DeepLinkService.swift
enum NeerDeepLink {
    case place(id: Int)
    case profile(username: String)
    case story(id: UUID)

    static func parse(url: URL) -> NeerDeepLink? {
        let path = url.pathComponents.filter { $0 != "/" }
        guard path.count >= 2 else { return nil }
        switch path[0] {
        case "place":   return Int(path[1]).map { .place(id: $0) }
        case "profile": return .profile(username: path[1])
        case "story":   return UUID(uuidString: path[1]).map { .story(id: $0) }
        default:        return nil
        }
    }
}
// Info.plist'e CFBundleURLSchemes: ["neer"] ekle
// neer.app/.well-known/apple-app-site-association dosyası deploy et
```

---

## Offline Davranış

```swift
// V1: Graceful degradation
// V2: Sync queue (kapsam dışı)

// NWPathMonitor ile bağlantı izle
// Bağlantı yoksa → OfflineBannerView göster
// Son yüklenen places/feed → CacheService'te sakla
// Write işlemleri → "İnternet bağlantısı gerekli" uyarısı
```

---

## iPad Desteği

```swift
// MainTabView.swift
@Environment(\.horizontalSizeClass) var sizeClass

var body: some View {
    if sizeClass == .regular {
        // iPad: NavigationSplitView
        NavigationSplitView {
            SidebarView()
        } detail: {
            MapView()
        }
    } else {
        // iPhone: TabView
        TabView { /* 5 tab */ }
    }
}
```

---

## Onboarding

```swift
// 4 slide içeriği:
// 1. "Explore what's Neer" — harita pin animasyonu
// 2. "Gerçekten orada ol" — check-in, Proof of Presence
// 3. "Catch & bağlan" — catch sistemi, anlık etkileşim
// 4. "Mekanı hisset" — sohbet + galeri + atmosfer

// @AppStorage("hasSeenOnboarding") false → OnboardingView
// Son slide "Başla" → hasSeenOnboarding = true → LoginView
```

---

## Info.plist İzinleri

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Neer, yakındaki mekanları göstermek için konumunu kullanır.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Mekana girip çıktığında otomatik check-in için arka planda konum gereklidir.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Geofence bildirimleri için arka plan konumu gereklidir.</string>
<key>NSCameraUsageDescription</key>
<string>Story ve fotoğraf çekmek için kamera erişimi gereklidir.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Profil fotoğrafı seçmek için galeri erişimi gereklidir.</string>
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>remote-notification</string>
    <string>fetch</string>
</array>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array><string>neer</string></array>
    </dict>
</array>
```

---

## Supabase — Başlamadan Önce Çalıştırılacak SQL

```sql
-- 1. Messages RLS açığını kapat
DROP POLICY IF EXISTS "messages_select" ON messages;
CREATE POLICY "messages_select" ON messages FOR SELECT USING (
    sender_id = auth.uid() OR
    room_id IN (SELECT id FROM rooms WHERE user1_id = auth.uid() OR user2_id = auth.uid())
);

-- 2. Messages UPDATE policy
CREATE POLICY IF NOT EXISTS "messages_update" ON messages
    FOR UPDATE USING (sender_id = auth.uid());

-- 3. Watchers — hedef görebilsin
DROP POLICY IF EXISTS "watchers_select" ON watchers;
CREATE POLICY "watchers_select" ON watchers FOR SELECT
    USING (watcher_id = auth.uid() OR target_id = auth.uid());

-- 4. APNs token
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS apns_token TEXT;

-- 5. Stories tablosu (yukarıda tanımlandı)

-- 6. Eski quests devre dışı
REVOKE ALL ON quests FROM authenticated;
```

---

## Faz Sırası

### Faz 1 — İskelet
1. Xcode projesi: `app.neer.ios`, iOS 17.0, Universal
2. SPM: supabase-swift + sentry-cocoa
3. `Secrets.xcconfig`
4. `Core/` + tüm `Models/` (bu dosyadaki tam tanımlarla)
5. `AuthService` — 4 yöntem
6. `OnboardingView` — 4 slide
7. `AuthGate` akışı
8. `MainTabView` — iPhone TabView + iPad NavigationSplitView

### Faz 2 — Harita
1. `LocationService` + geofence
2. `NeerMapView` — Apple Maps dark config
3. `PlaceAnnotationView` — density rengi
4. `MapViewModel` + `getNearbyPlaces`
5. `PlaceSheetView` + `CheckInView`
6. `CacheService` + `OfflineBannerView`

### Faz 3 — Feed, Story, Profil
1. `FeedView` — DÜZELTILMIŞ RPC parametreleri
2. `StoryCreatorView` + `StoryPlayerView`
3. `ProfileView` — 3 tab + `StoryGalleryGrid`
4. `AppearanceView` — dark/light/system
5. `StorageService` — avatar + story upload

### Faz 4 — Sosyal
1. `ChatListView` + `DMChatView` + `GroupChatView`
2. `RealtimeService` — AsyncStream
3. `CatchView` — 60sn/180sn kuralları
4. `FriendProfileView` + takip sistemi
5. `NotificationsView` + APNs

### Faz 5 — Bağlantı & Platform
1. `DeepLinkService` + `ShareSheetModifier`
2. `apple-app-site-association` → neer.app'e deploy
3. Supabase Edge Function → FCM'den APNs'e güncelle

### Faz 6 — Gelişmiş
1. `SearchView` — full-text RPC
2. `PremiumView` — StoreKit 2
3. `BusinessProfileView` — gerçek veri
4. Gamification — rozetler + görevler
5. MetricKit + Sentry final config

---

## Bekleyen Kararlar

| Konu | Durum |
|------|-------|
| Dynamic Island / Live Activity | Ayrı tartışılacak |
| Neer Score eşikleri | `sync_neer_score` trigger'dan al |
| App icon | Yeniden tasarlanacak |
| Business akışı | V2 |
| Offline sync queue | V2 |

---

## Kod Kuralları

1. Tüm async işlemler `async/await` — closure callback yok
2. ViewModel → `@Observable`, servis → `actor`
3. Model → `Codable` + `CodingKeys` (snake_case ↔ camelCase)
4. Renkler → `AppColors`, hardcoded hex yasak
5. String → `String(localized:)`, hardcoded TR/EN yasak
6. Haptic → Her aksiyonda `HapticService.shared.impact(.light)`
7. Hata → `AppError` enum, production'da print/debugPrint yasak
8. Mock/fake data → YASAK, her şey Supabase'den gerçek veri
9. Eski `quests` tablosu → kullanma
10. SF Pro font → bundle'a ekleme, sistem sağlar

---

## Flutter → Swift Karşılık Tablosu

| Flutter | Swift |
|---------|-------|
| `StatefulWidget` + `setState` | `@Observable` ViewModel + `@State` |
| `Provider` | `@Environment` + `@Observable` |
| `Navigator.push` | `NavigationStack` + `.navigationDestination` |
| `showModalBottomSheet` | `.sheet()` + `.presentationDetents` |
| `BottomNavigationBar` | `TabView` |
| `StreamBuilder<T>` | `AsyncStream<T>` + `.task {}` |
| `FutureBuilder<T>` | `async/await` + `@State var isLoading` |
| `ListView.builder` | `List` / `LazyVStack` |
| `flutter_map` | `MKMapView` via `UIViewRepresentable` |
| `CachedNetworkImage` | `AsyncImage` + `NSCache` |
| `HapticFeedback.lightImpact()` | `UIImpactFeedbackGenerator(style:.light).impactOccurred()` |
| `showGeneralDialog` | `.overlay` + custom dialog |
| `go_router` | `NavigationStack` + `NavigationPath` |
| `ThemeManager` | `@AppStorage("colorScheme")` + `.preferredColorScheme` |
| `LanguageManager` | `@AppStorage("language")` + `String(localized:)` |
| `IndexedStack` | `TabView` (state korunur otomatik) |
| `StreamSubscription` | `AsyncStream` + `Task` |
| `Supabase.rpc(name, params)` | `client.rpc(name, params:).execute().value` |
