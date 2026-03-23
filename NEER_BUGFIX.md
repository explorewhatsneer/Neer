# NEER — Bug Fix Brief

Aşağıdaki sorunları sırayla düzelt. Her düzeltme sonrası `flutter analyze` çalıştır.

---

## BUG 1 — Header arka planı yok / bozuk görünüyor

**Sorun:** `ProfileHeader` widget'ı artık ambient blur arka plan içermiyor — sadece padding + column döndürüyor. Ama `SliverAppBar.flexibleSpace` içinde bu widget doğrudan `FlexibleSpaceBar.background` olarak kullanılıyor. Yani header'ın kendi arka planı yok, `GradientScaffold`'un arka planı transparan kalıyor.

**Düzeltme:** `FlexibleSpaceBar` içine manuel bir arka plan gradyanı ekle:

```dart
// profile_screen.dart — SliverAppBar > flexibleSpace
flexibleSpace: FlexibleSpaceBar(
  stretchModes: const [StretchMode.zoomBackground],
  background: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withValues(alpha: 0.35),
          Colors.black.withValues(alpha: 0.60),
        ],
      ),
    ),
    child: ProfileHeader(
      imageUrl: displayImage,
      name: user?.name ?? AppStrings.nameless,
      username: user?.username ?? "kullanici",
      bio: user?.bio ?? "",
      followersCount: (user?.followersCount ?? 0).toString(),
      followingCount: (user?.followingCount ?? 0).toString(),
      neerScore: (user?.neerScore ?? 5.0).toDouble(),
      checkInCount: user?.checkInCount ?? 0,
      activeDays: user?.activeDays ?? 0,
      neerScoreLabel: user?.neerScoreLabel ?? AppStrings.neerScoreStandard,
    ),
  ),
),
```

Ayrıca `SliverAppBar`'a şunu da ekle:
```dart
SliverAppBar(
  expandedHeight: 300.0,
  pinned: true,
  floating: false,
  forceElevated: false,
  backgroundColor: Colors.black.withValues(alpha: 0.40), // collapsed halde
  // ...
)
```

---

## BUG 2 — Orb'lar hala ortada

**Sorun:** `premium_background.dart` güncellenmemiş, eski `basePositions` değerleri var.

**Düzeltme:** `lib/widgets/common/premium_background.dart` içindeki `_buildOrbs()` fonksiyonunu bul ve şu iki değişkeni güncelle:

```dart
// BUNU BUL VE DEĞİŞTİR:
final basePositions = [
  const Alignment(-0.7, -0.5),
  const Alignment(0.8, -0.4),
  const Alignment(-0.4, 0.6),
  const Alignment(0.5, 0.7),
  const Alignment(0.0, 0.0),
];

// BUNUNLA DEĞİŞTİR:
final basePositions = [
  const Alignment(-1.1, -1.0),
  const Alignment(1.1, -0.9),
  const Alignment(-1.0, 1.0),
  const Alignment(1.0, 1.0),
  const Alignment(0.0, 0.1),
];

// BUNU BUL:
final dx = math.sin(phase * 2 * math.pi) * 0.18;
final dy = math.cos(phase * 2 * math.pi) * 0.12;

// BUNUNLA DEĞİŞTİR:
final dx = math.sin(phase * 2 * math.pi) * 0.35;
final dy = math.cos(phase * 2 * math.pi) * 0.30;
```

Dark mode'da orb sayısını 3'e düşür:
```dart
// _buildOrbs() fonksiyonunun başına ekle:
if (isDark && i >= 3) return const SizedBox.shrink(); // dark'ta sadece 3 orb
// veya List.generate içinde:
return List.generate(isDark ? 3 : 5, (i) { ... });
```

Dark mode alpha değerleri:
```dart
final alphas = isDark
    ? [0.26, 0.22, 0.20, 0.0, 0.0]
    : [0.55, 0.45, 0.50, 0.40, 0.42];
```

---

## BUG 3 — NavBar dot animasyonu çalışmıyor

**Sorun:** `MainLayout`'ta `CustomNavBar`'a `scrollController` geçiliyor ama `ProfileScreen` kendi `NestedScrollView` kullanıyor — dolayısıyla `MainLayout`'taki `_scrollControllers[4]` asla tetiklenmiyor. Profile ekranı kendi `_scrollController`'ını kullanıyor.

**Düzeltme:** İki adım:

**Adım 1:** `ProfileScreen` kendi ScrollController'ını `MainLayout`'taki ile senkronize etmeli. Bunun yerine daha kolay çözüm: `ProfileScreen`'deki `_scrollController`'ı dışarıdan parametre olarak al:

```dart
// profile_screen.dart
class ProfileScreen extends StatefulWidget {
  final ScrollController? externalScrollController; // YENİ
  const ProfileScreen({super.key, this.externalScrollController});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> ... {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Dışarıdan verilmişse onu kullan, yoksa kendi oluştur
    _scrollController = widget.externalScrollController ?? ScrollController();
    // ...
  }

  @override
  void dispose() {
    // Sadece kendi oluşturduğumuzu dispose et
    if (widget.externalScrollController == null) {
      _scrollController.dispose();
    }
    // ...
  }
}
```

**Adım 2:** `MainLayout`'ta `ProfileScreen`'e controller'ı ver:
```dart
// main_layout.dart — _screens listesi
_screens = [
  const MapScreen(),
  const ChatListScreen(),
  const FeedScreen(),
  const CatchScreen(),
  ProfileScreen(externalScrollController: _scrollControllers[4]), // YENİ
];
```

---

## BUG 4 — Overflow hataları

**Sorun:** `ProfileHeader` içindeki `Column` widget'ı `FlexibleSpaceBar.background` içinde sınırsız yükseklikte çalışıyor, dolayısıyla Spacer veya Expanded kullanımında taşma oluyor.

**Düzeltme:** `profile_header.dart`'taki `build` metodunu şöyle güncelle — `Column`'u `SafeArea` + `Align` ile sar:

```dart
@override
Widget build(BuildContext context) {
  return Align(
    alignment: Alignment.bottomLeft, // İçeriği alta hizala
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 72), // alta tab bar için boşluk
      child: Column(
        mainAxisSize: MainAxisSize.min, // KRİTİK — min kullan, expand değil
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ROW 1: Avatar + Meta + NeerScore
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [ ... ],
          ),
          // ROW 2: Bio
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(bio, ...),
          ],
          // ROW 3: Stat pills
          const SizedBox(height: 10),
          Wrap(spacing: 6, children: [ ... ]),
        ],
      ),
    ),
  );
}
```

---

## BUG 5 — Rozetler ve altındaki içerikler gözükmüyor / "Bad State: No element"

**Sorun 1:** `getUserActiveQuests()` metodu `quest_definitions` tablosundan veri çekiyor ama `user_quests!left(...)` join'i çalışırken tüm kullanıcıların quest kayıtlarını getiriyor, filtreleme yapmıyor. Bu nedenle `user_quests` listesi yanlış kullanıcıya ait olabiliyor.

**Düzeltme:** `supabase_service.dart`'taki `getUserActiveQuests` metodunu düzelt:

```dart
Future<List<Map<String, dynamic>>> getUserActiveQuests(String uid) async {
  try {
    // Önce tüm quest tanımlarını çek
    final questDefs = await _supabase
        .from('quest_definitions')
        .select()
        .order('sort_order');

    // Sonra bu kullanıcının ilerlemelerini çek
    final userProgress = await _supabase
        .from('user_quests')
        .select()
        .eq('user_id', uid);

    // Manuel olarak birleştir
    final progressMap = <String, Map<String, dynamic>>{};
    for (final p in userProgress) {
      final key = '${p['quest_id']}_${p['period'] ?? ''}';
      progressMap[key] = p;
    }

    return (questDefs as List).map((quest) {
      final questId = quest['id'] as String;
      // Period hesapla
      final now = DateTime.now();
      String period = '';
      if (quest['type'] == 'daily') {
        period = '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
      } else if (quest['type'] == 'weekly') {
        final weekNum = _getWeekNumber(now);
        period = '${now.year}-W${weekNum.toString().padLeft(2,'0')}';
      }

      final key = '${questId}_$period';
      final progress = progressMap[key];

      return {
        ...Map<String, dynamic>.from(quest as Map),
        'user_progress': progress, // tek map, liste değil
        'current_progress': progress?['progress'] ?? 0,
        'is_completed': progress?['is_completed'] ?? false,
      };
    }).toList();
  } catch (e) {
    debugPrint('getUserActiveQuests hatası: $e');
    return [];
  }
}
```

**Sorun 2:** `_QuestPreview` ve `_QuestRow` widget'larında `quest['user_quests']?.first` kullanılıyor ama artık `user_quests` liste değil. Bunları güncelle:

```dart
// _QuestRow'da şunu değiştir:
// ESKİ:
final userQuests = quest['user_quests'];
final first = (userQuests is List && userQuests.isNotEmpty) ? userQuests.first : null;
final progress = (first?['progress'] ?? 0) as int;
final isCompleted = first?['is_completed'] == true;

// YENİ:
final progress = (quest['current_progress'] ?? 0) as int;
final isCompleted = quest['is_completed'] == true;
```

```dart
// _EpicQuestCard'da da aynı değişikliği yap:
// ESKİ:
final userQuests = quest['user_quests'];
final first = (userQuests is List && userQuests.isNotEmpty) ? userQuests.first : null;
final progress = (first?['progress'] ?? 0) as int;

// YENİ:
final progress = (quest['current_progress'] ?? 0) as int;
```

```dart
// _QuestPreview'daki sort ve filter mantığını da güncelle:
final weeklyTop = quests.where((q) => q['type'] == 'weekly').toList()
  ..sort((a, b) => ((b['current_progress'] ?? 0) as int)
      .compareTo((a['current_progress'] ?? 0) as int));

final epicActive = quests.where((q) =>
    q['type'] == 'epic' &&
    (q['is_completed'] != true)).take(1).toList();
```

**Sorun 3:** `_BadgeVitrin` sadece `getAllBadgeDefinitions()` dolu olduğunda çalışıyor ama `badge_definitions` tablosu boş olunca `SizedBox.shrink()` dönüyor. Rozet tanımları DB'de mevcut — ama tabloya erişim sorunu olabilir. Bunun için hata kontrolü ekle:

```dart
// profile_screen.dart — C bölümünde
FutureBuilder<List<dynamic>>(
  future: Future.wait([_badgesFuture, _allBadgeDefsFuture]),
  builder: (context, snapshot) {
    // Loading state göster
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox(height: 80);
    }
    // Hata varsa logla ama crash etme
    if (snapshot.hasError) {
      debugPrint('Badge error: ${snapshot.error}');
      return const SizedBox.shrink();
    }
    if (!snapshot.hasData) return const SizedBox.shrink();
    final earned = (snapshot.data![0] as List).cast<Map<String, dynamic>>();
    final all = (snapshot.data![1] as List).cast<Map<String, dynamic>>();
    if (all.isEmpty) return const SizedBox.shrink();
    return _BadgeVitrin(
      earnedBadges: earned,
      allBadges: all,
      onSeeAll: () => context.push(AppRoutes.questsBadges),
    );
  },
),
```

---

## BUG 6 — Puana basınca ReviewsScreen değil FeedWidgets açılıyor

**Sorun:** Bento'daki "son yorum" kartı `onTap: () => context.push(AppRoutes.myReviews)` ile ayarlanmış. Ancak `AppRoutes.myReviews = '/my-reviews'` route'u `ReviewsScreen()`'e gidiyor. `ReviewsScreen`'in kendisi muhtemelen `FeedReviewCard` yerine başka bir widget kullanan `PollsScreen`'e yönlendiriyor.

**Düzeltme:** `lib/screens/reviews_screen.dart` dosyasını aç ve içeriğinin `ReviewsScreen` class'ı olduğunu doğrula. Eğer `PollsScreen`'i import ediyorsa veya ona yönlendiriyorsa kaldır.

`reviews_screen.dart` şöyle olmalı:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../core/neer_design_system.dart';
import '../core/app_strings.dart';
import '../services/supabase_service.dart';
import '../widgets/feed/feed_widgets.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/friend/friend_profile_widgets.dart' show FriendEmptyCard;

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});
  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _service = SupabaseService();
  final String _uid = supabase.auth.currentUser!.id;
  late Future<List<Map<String, dynamic>>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _service.getSurveyHistory(_uid);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppStrings.myReviewsTitle,
          style: NeerTypography.h2.copyWith(color: Colors.white)),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerList(itemCount: 4);
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: FriendEmptyCard(
                icon: Icons.star_border_rounded,
                title: AppStrings.noSurveys,
                subtitle: AppStrings.noSurveysDesc,
              ),
            );
          }
          final reviews = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final r = reviews[index];
              // PostModel'e dönüştür
              final post = PostModel.fromMap({
                ...r,
                'type': 'review',
                'user_id': _uid,
              });
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FeedReviewCard(post: post),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

## BUG 7 — Notlarım okunmuyor (NotesScreen sorunu)

**Sorun:** `notes` tablosundaki `content` alanı ile NotesScreen'in beklediği alan uyuşmuyor olabilir.

**Düzeltme:** `lib/screens/notes_screen.dart` dosyasını kontrol et. Notes tablosundaki kolonlar: `id`, `user_id`, `content`, `created_at`. `NotesScreen`'in doğru şekilde yazıldığından emin ol:

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../core/neer_design_system.dart';
import '../core/app_strings.dart';
import '../services/supabase_service.dart';
import '../widgets/common/glass_panel.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/friend/friend_profile_widgets.dart' show FriendEmptyCard;

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _service = SupabaseService();
  final String _uid = supabase.auth.currentUser!.id;
  late Stream<List<Map<String, dynamic>>> _notesStream;

  @override
  void initState() {
    super.initState();
    _notesStream = _service.getUserNotes(_uid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppStrings.myNotesTitle,
          style: NeerTypography.h2.copyWith(color: Colors.white)),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _notesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerList(itemCount: 4);
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: FriendEmptyCard(
                icon: Icons.edit_note_rounded,
                title: AppStrings.notebookEmpty,
                subtitle: AppStrings.notebookEmptyDesc,
              ),
            );
          }
          final notes = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              // notes tablosu kolonları: id, user_id, content, created_at, place_id (opsiyonel)
              final content = note['content'] as String? ?? note['text'] as String? ?? '';
              final createdAt = note['created_at'] != null
                  ? DateTime.tryParse(note['created_at'].toString())
                  : null;
              final dateStr = createdAt != null
                  ? DateFormat('d MMM y', 'tr').format(createdAt)
                  : '';
              final placeName = note['place_name'] as String? ??
                  note['location_name'] as String? ?? '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassPanel.card(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (placeName.isNotEmpty) ...[
                            Icon(Icons.place_rounded,
                              size: 14, color: theme.primaryColor),
                            const SizedBox(width: 4),
                            Text(placeName,
                              style: NeerTypography.caption.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              )),
                            const Spacer(),
                          ] else
                            const Spacer(),
                          Text(dateStr,
                            style: NeerTypography.caption.copyWith(
                              color: theme.disabledColor, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(content,
                        style: NeerTypography.bodySmall.copyWith(
                          fontStyle: FontStyle.italic, height: 1.5)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

**Not:** `intl` paketi zaten `pubspec.yaml`'da varsa kullan. Yoksa date'i manuel formatla:
```dart
// intl yerine:
final dateStr = createdAt != null
    ? '${createdAt.day}.${createdAt.month}.${createdAt.year}'
    : '';
```

---

## BUG 8 — SectionHeader icon parametresi kaldırıldı ama eski kullanım var

**Sorun:** Brief'te `SectionHeader`'dan `icon` parametresi kaldırıldı ama `profile_screen.dart`'ta eski kullanım hâlâ var:
```dart
SectionHeader(
  title: AppStrings.favoritesTitle,
  icon: Icons.favorite_rounded, // HATA — bu parametre artık yok
  onActionTap: () => _showAllFavorites(context),
),
```

**Düzeltme:** `profile_screen.dart` içindeki tüm `SectionHeader` çağrılarından `icon:` parametresini kaldır:
```dart
// ÖNCE
SectionHeader(
  title: AppStrings.favoritesTitle,
  icon: Icons.favorite_rounded,
  onActionTap: () => _showAllFavorites(context),
),

// SONRA
SectionHeader(
  title: AppStrings.favoritesTitle,
  onActionTap: () => _showAllFavorites(context),
),
```

---

## BUG 9 — notes tablosunda `place_name` kolonu yok

**Sorun:** `notes` tablosu schema'sında `place_name` kolonu olmayabilir. Supabase'den `notes` tablosunun kolonlarını kontrol et:

Muhtemelen `notes` tablosu: `id`, `user_id`, `content`, `created_at`, `place_id` kolonlarına sahip. `place_name` yok.

**Düzeltme:** `getUserNotes` metodunu `places` tablosuyla join yapacak şekilde güncelle:

```dart
// supabase_service.dart
Stream<List<Map<String, dynamic>>> getUserNotes(String uid) {
  return _supabase
      .from('notes')
      .stream(primaryKey: ['id'])
      .eq('user_id', uid)
      .order('created_at', ascending: false)
      .map((data) => List<Map<String, dynamic>>.from(data));
}

// Ayrıca Future versiyonu — join ile
Future<List<Map<String, dynamic>>> getUserNotesWithPlace(String uid) async {
  try {
    // place_id varsa join, yoksa direkt
    final response = await _supabase
        .from('notes')
        .select('*, places(name)')  // places join
        .eq('user_id', uid)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    // join başarısız olursa direkt çek
    try {
      final response = await _supabase
          .from('notes')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e2) {
      return [];
    }
  }
}
```

`NotesScreen`'de `place_name` erişimini şöyle güvenli hale getir:
```dart
final placeName = (note['places'] as Map?)?['name'] as String? ??
    note['place_name'] as String? ?? '';
```

---

## KONTROL LİSTESİ

Her düzeltme sonrası:
- [ ] `flutter analyze` — sıfır hata
- [ ] Header arka planı var mı?
- [ ] Orb'lar köşelerde mi?
- [ ] NavBar scroll'da dot'a dönüşüyor mu?
- [ ] Overflow hatası yok mu?
- [ ] Rozetler görünüyor mu?
- [ ] Görevler preview çalışıyor mu?
- [ ] Puana basınca ReviewsScreen açılıyor mu?
- [ ] Notlar okunuyor mu?
- [ ] SectionHeader `icon` parametresi kaldırıldı mı?