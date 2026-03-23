## BÖLÜM 7: YENİ EKRANLAR

### 7.1 Quest + Rozet Ekranı — `quests_badges_screen.dart`
Profildeki "Tümünü gör" / "Tümü" tıklamalarından açılır. 2 tab:

**Tab 1 — Görevler:**
- Filtre pill'leri: Tümü, Günlük, Haftalık, Epik, Tamamlanan
- Her quest kartı: İsim, açıklama, progress bar, `X / Y` sayaç, TS ödülü, rozet bağlantısı
- Tamamlananlar soluk (opacity: 0.45)
- Epik → aktif olan vurgulu (primary color border), diğerleri kilitli

**Tab 2 — Rozetler:**
- 3 sütun grid
- Kazanılmış: renkli, border primary
- Kilitli: grayscale, opacity 0.3, isim "???"
- Tıklanınca `showModalBottomSheet` — rozet adı, açıklama, nasıl kazanılır, kategori (kalıcı/haftalık/epik/trust)

### 7.2 Notlarım Ekranı — `notes_screen.dart`
Bento'daki "son not" kartına tıklanınca açılır.
- Liste: Tarih + mekan adı + not içeriği (ilk 2 satır)
- Tıklanınca full not görünür (bottom sheet)
- Boşsa zero state: "Not Defteri Boş"

### 7.3 Puanlarım Ekranı — `reviews_screen.dart`
Bento'daki "son yorum" kartına tıklanınca açılır.
- Her kart: `DetailedReviewCard` (zaten genişleyip kapanabiliyor)
- Skor rengi (yeşil/sarı/kırmızı) ile sıralama
- Boşsa zero state: "Değerlendirme Yok"

### 7.4 Sık Uğrananlar Tam Ekran — `frequent_places_screen.dart`
- Aynı A tasarımı — 1. kart büyük, 2-10 orta boy, opacity soluklaşıyor
- Sağ üstte toplam sayı: "10 mekan"

### 7.5 Isı Haritası Widget — `heatmap_widget.dart`
Profile Tab 1'de Sık Uğrananlar'ın altına eklenir.

```dart
class HeatmapWidget extends StatefulWidget {
  final String userId;
}

class _HeatmapWidgetState extends State<HeatmapWidget> {
  String _period = '30d';
  final _periods = ['7d', '30d', '6m', 'all'];
  final _periodLabels = {'7d': '7 gün', '30d': '30 gün', '6m': '6 ay', 'all': 'Tümü'};

  @override
  Widget build(BuildContext context) {
    return GlassPanel.card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + filtre pills
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                Text('Şehir Haritam', style: NeerTypography.h3),
                const Spacer(),
                ..._periods.map((p) => GestureDetector(
                  onTap: () => setState(() => _period = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _period == p
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _period == p
                            ? Theme.of(context).primaryColor.withValues(alpha: 0.45)
                            : Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text(
                      _periodLabels[p]!,
                      style: NeerTypography.overline.copyWith(
                        color: _period == p
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor,
                        fontSize: 10,
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
          // Harita
          FutureBuilder<List<Map<String, dynamic>>>(
            future: SupabaseService().getUserHeatmapPoints(widget.userId, period: _period),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _HeatmapEmpty();
              }
              return _HeatmapMap(points: snapshot.data!);
            },
          ),
        ],
      ),
    );
  }
}

// flutter_map ile MapTiler üzerinde çizim
class _HeatmapMap extends StatelessWidget {
  final List<Map<String, dynamic>> points;

  @override
  Widget build(BuildContext context) {
    // En yoğun mekan center olarak kullan
    final center = points.first;
    final maxVisit = points.map((p) => (p['visit_count'] as num).toInt()).reduce(math.max);

    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(
              (center['latitude'] as num).toDouble(),
              (center['longitude'] as num).toDouble(),
            ),
            initialZoom: 13,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://api.maptiler.com/maps/dataviz-dark/{z}/{x}/{y}.png?key={api_key}',
              additionalOptions: const {'api_key': 'YOUR_MAPTILER_KEY'},
            ),
            // Isı noktaları — büyüklük visit_count'a göre
            CircleLayer(
              circles: points.map((p) {
                final visits = (p['visit_count'] as num).toInt();
                final intensity = visits / maxVisit;
                return CircleMarker(
                  point: LatLng(
                    (p['latitude'] as num).toDouble(),
                    (p['longitude'] as num).toDouble(),
                  ),
                  radius: 15 + (intensity * 35),
                  color: Color.lerp(
                    const Color(0x448B5CF6),
                    const Color(0xCC8B5CF6),
                    intensity,
                  )!,
                  borderColor: const Color(0x668B5CF6),
                  borderStrokeWidth: 1,
                  useRadiusInMeter: true,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## BÖLÜM 8: ZERO STATES

Her bölüm için zero state mesajları (AppStrings'e ekle):

| Bölüm | TR | EN |
|-------|----|----|
| Isı haritası | Check-in yaptıkça şehirdeki ayak izin burada belirmeye başlar. | Your city footprint will appear here as you check in. |
| Rozetler | Görevleri tamamla, ilk rozetini kazan. | Complete quests to earn your first badge. |
| Görevler | İlk check-in'ini yapınca günlük görevler başlıyor. | Complete your first check-in to start daily quests. |
| Neer Kimliği | Dışarı çık, check-in yap. Bu sayılar seninle büyür. | Go out, check in. These numbers grow with you. |
| Favoriler | Gittiğin yerlerden favori ekle, burada saklansın. | Add favorites from venues you visit. |
| Sık Gidilenler | Bir mekana tekrar tekrar git — liste kendiliğinden oluşur. | Visit a venue repeatedly — the list builds itself. |

---

