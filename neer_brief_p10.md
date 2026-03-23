## BÖLÜM 9: APPSTRINGS GÜNCELLEMELERİ

`lib/core/app_strings.dart`'a ekle/güncelle:

```dart
// Trust Score → Neer Score
static String get neerScore => lang == 'tr' ? "Neer Score" : "Neer Score";
static String get neerScoreLabel => lang == 'tr' ? "Neer Skoru" : "Neer Score";
static String get neerScoreElite => "Elite";
static String get neerScoreExpert => lang == 'tr' ? "Uzman" : "Expert";
static String get neerScoreTrusted => lang == 'tr' ? "Güvenilir" : "Trusted";
static String get neerScoreStandard => lang == 'tr' ? "Standart" : "Standard";
static String get neerScoreLimited => lang == 'tr' ? "Kısıtlı" : "Limited";

// Yeni ekranlar
static String get badgesTitle => lang == 'tr' ? "Rozetler" : "Badges";
static String get questsBadgesTitle => lang == 'tr' ? "Görevler & Rozetler" : "Quests & Badges";
static String get myNotesTitle => lang == 'tr' ? "Notlarım" : "My Notes";
static String get myReviewsTitle => lang == 'tr' ? "Puanlarım" : "My Reviews";
static String get frequentPlacesFullTitle => lang == 'tr' ? "Sık Uğradıklarım" : "My Frequent Places";
static String get cityMapTitle => lang == 'tr' ? "Şehir Haritam" : "My City Map";
static String get neerIdentityTitle => lang == 'tr' ? "Neer Kimliği" : "Neer Identity";

// Zero states
static String get zeroHeatmap => lang == 'tr' ? "Check-in yaptıkça şehirdeki ayak izin burada belirmeye başlar." : "Your city footprint will appear here as you check in.";
static String get zeroBadges => lang == 'tr' ? "Görevleri tamamla, ilk rozetini kazan." : "Complete quests to earn your first badge.";
static String get zeroQuests => lang == 'tr' ? "İlk check-in'ini yapınca günlük görevler başlıyor." : "Complete your first check-in to start daily quests.";
static String get zeroIdentity => lang == 'tr' ? "Dışarı çık, check-in yap. Bu sayılar seninle büyür." : "Go out, check in. These numbers grow with you.";
static String get zeroFrequent => lang == 'tr' ? "Bir mekana tekrar tekrar git — liste kendiliğinden oluşur." : "Visit a venue repeatedly — the list builds itself.";

// Nav bar (label kaldırıldı ama routing için)
static String get navMap => lang == 'tr' ? "Harita" : "Map";
// navChat, navFeed, navProfile zaten var
// navCatch zaten var — sıra değişti: index 3
```

---

## BÖLÜM 10: ROUTING — `app_router.dart`

Yeni route'lar ekle:

```dart
static const String questsBadges = '/quests-badges';
static const String myNotes = '/my-notes';
static const String myReviews = '/my-reviews';
static const String frequentPlacesFull = '/frequent-places';
static const String heatmapFull = '/heatmap';
```

---

