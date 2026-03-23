# NEER — Profil Yeniden Tasarım Brief v2.0

Bu doküman Claude Code'a verilecek tek referans kaynaktır. Tüm kararlar burada yazılı olduğu şekilde uygulanacaktır. Kodlamaya başlamadan önce bu dokümanı tamamen oku.

---

## GENEL KURALLAR

- Flutter + Dart, iOS hedefli
- Backend: Supabase (proje ID: `celkzibnupgacoesaxse`)
- Tasarım sistemi: `lib/core/neer_design_system.dart` — tek referans
- `.withOpacity()` **ASLA** kullanma → her zaman `.withValues(alpha: ...)`
- `GlassCard` ve `NeerGlass.card()` artık **kullanılmıyor** → her yerde `GlassPanel` kullan
- Tüm string değişiklikleri `lib/core/app_strings.dart` üzerinden

---

## BÖLÜM 1: ARKA PLAN SİSTEMİ — `premium_background.dart`

### 1.1 Orb Pozisyonları (KRİTİK)
Mevcut `basePositions` değerleri orb'ları merkeze sıkıştırıyor. Düzelt:

```dart
// ESKİ
final basePositions = [
  const Alignment(-0.7, -0.5),
  const Alignment(0.8, -0.4),
  const Alignment(-0.4, 0.6),
  const Alignment(0.5, 0.7),
  const Alignment(0.0, 0.0),
];

// YENİ — köşelere yay
final basePositions = [
  const Alignment(-1.1, -1.0),  // sol üst köşe dışı
  const Alignment(1.1, -0.9),   // sağ üst köşe dışı
  const Alignment(-1.0, 1.0),   // sol alt köşe dışı
  const Alignment(1.0, 1.0),    // sağ alt köşe dışı
  const Alignment(0.0, 0.1),    // merkez (sabit)
];

// ESKİ hareket — çok dar
final dx = math.sin(phase * 2 * math.pi) * 0.18;
final dy = math.cos(phase * 2 * math.pi) * 0.12;

// YENİ hareket — geniş, hissedilir
final dx = math.sin(phase * 2 * math.pi) * 0.35;
final dy = math.cos(phase * 2 * math.pi) * 0.30;
```

### 1.2 Dark Mode Orb Sayısı ve Alpha
Dark mode'da 5 orb yerine 3 orb, alpha değerleri düşük:

```dart
// _buildOrbs() içinde isDark kontrolü ekle
if (isDark) {
  // Sadece ilk 3 orb — alpha 0.20-0.28
  final darkAlphas = [0.26, 0.22, 0.20];
  // i > 2 ise skip
}

// Dark mode alpha değerleri
final alphas = isDark
    ? [0.26, 0.22, 0.20, 0.0, 0.0]   // 3 orb
    : [0.55, 0.45, 0.50, 0.40, 0.42]; // 5 orb
```

### 1.3 Ekrana Göre animate Parametresi
`GradientScaffold` çağrılarını güncelle:

| Ekran | animate |
|-------|---------|
| profile_screen | `true` |
| settings_screen | `true` |
| premium_screen | `true` |
| onboarding | `true` |
| chat_screen, group_chat_screen | `false` |
| feed_screen | `false` |
| notifications_screen | `false` |
| map_screen | arka plan **yok** — transparent scaffold |

---

