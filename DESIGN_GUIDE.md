# Neer — Tasarım Sistemi Uygulama Rehberi
# Bu dosyayı Claude Code'a ver, tüm ekranları yeni tasarıma geçirsin.

## Tasarım Felsefesi

Referans: Glassmorphism + Soft Gradient + Premium iOS
- Arka planlar: Yumuşak lavanta → pembe → kayısı gradient
- Kartlar: Yarı şeffaf cam efekti (backdrop blur + beyaz overlay)
- Köşeler: 24px kartlar, 16px butonlar, pill shape chip'ler
- Gölgeler: Renkli-tinted, çok yumuşak, yayılmış
- Tipografi: SF Pro Display, -0.5 letter spacing başlıklarda
- Animasyonlar: Bouncy curves (easeOutBack), scale transitions

## Claude Code'a Verilecek Komut

```
Uygulamanın tüm ekranlarını yeni tasarım sistemine geçir. 

ADIM 1: lib/core/neer_design_system.dart dosyasını oku. Bu dosya tüm renkleri, gradientleri, cam efektlerini, tipografiyi ve yeniden kullanılabilir widget'ları içeriyor (GlassCard, GradientScaffold, GradientButton, NeerAvatar).

ADIM 2: main.dart'taki ThemeManager'ı güncelle — NeerTheme.light() ve NeerTheme.dark() kullan:
- themeManager.lightTheme yerine NeerTheme.light()
- themeManager.darkTheme yerine NeerTheme.dark()

ADIM 3: Her ekranı sırayla güncelle. Aşağıdaki kuralları takip et:

### Genel Kurallar
1. Scaffold yerine GradientScaffold kullan (gradient arka plan)
2. Container kartları yerine GlassCard kullan (cam efekti)
3. ElevatedButton yerine GradientButton kullan (ana aksiyonlar için)
4. CircleAvatar yerine NeerAvatar kullan (profil fotoları)
5. BoxDecoration'lardaki sabit renkler yerine NeerGlass.card() kullan
6. Eski AppColors, AppTextStyles referanslarını NeerColors, NeerTypography ile değiştir
7. withOpacity kullanımlarını referans görsellerdeki şeffaflık oranlarıyla güncelle

### AppBar Kuralları
- backgroundColor: Colors.transparent
- flexibleSpace: ClipRect + BackdropFilter (blur: 20) + gradient overlay
- Başlık: NeerTypography.h2, bold
- Leading/Actions: GlassCard circular buton (40x40, borderRadius: 14)

### Kart Kuralları
- Tüm kartlar: GlassCard widget'ı veya NeerGlass.card(isDark: isDark) decoration
- borderRadius: 24 (her kart)
- İç padding: 16-20
- Kartlar arası spacing: 16
- ASLA opak beyaz/siyah arka plan kullanma — hep yarı şeffaf

### Buton Kuralları
- Ana aksiyon (Check-in, Gönder): GradientButton (mor→pembe gradient)
- İkincil aksiyon: OutlinedButton, NeerColors.primary border
- İkon butonlar: NeerGlass.circleButton(isDark: isDark) decoration
- Tıklanabilir kartlar: GlassCard(onTap: ...)

### Bottom Navigation Bar
- ClipRRect + BackdropFilter(blur: 20)
- Background: NeerGradients.navbarLight veya navbarDark
- Border-top: glassBorder
- Seçili ikon: NeerColors.primary, küçük gradient dot altında
- Seçilmemiş ikon: NeerColors.gray400

### Chat Ekranları
- Mesaj balonları: GlassCard benzeri cam efekt
- Kendi mesajın: NeerGradients.purplePink gradient arka plan, beyaz yazı
- Gelen mesaj: NeerGlass.card(isDark) ile yarı şeffaf
- Input alanı: NeerGlass.input(isDark) decoration, backdrop blur

### Profil Ekranı  
- Header: Büyük gradient arka plan (mor→pembe), avatar üstte, cam efektli stat kartları
- Stat kartları (Takipçi, Takip, Arkadaş): 3'lü Row, GlassCard, ortada büyük sayı
- Tab bar: Pill şeklinde segmented control, seçili tab'da cam efekt

### Premium Ekranı
- Siyah gradient arka plan üzerine gold/turuncu vurgular
- Feature kartları: GlassCard, mor glow efekti
- Fiyat kartları: Seçili olanda NeerGradients.purplePink border
- CTA butonu: GradientButton

### Harita Ekranı
- Üstteki filtre çipleri: NeerGlass.chip() ile cam efektli pill'ler
- Sol üst profil butonu: NeerAvatar (GlassCard circular)
- Sağ alt FAB: Gradient arka plan, gölge efekti
- Bottom Sheet (mekan kartı): NeerGlass.panel(isDark) + BackdropFilter
- Mekan başlığı: NeerTypography.h2
- "Check-in" butonu: GradientButton (pembe→turuncu)

### Bildirimler
- Her bildirim satırı: Okunmamışta çok hafif primary tint, GlassCard
- Bildirim ikonu: NeerGlass.chip tarzı yuvarlak arka plan
- Zaman: NeerTypography.caption, gray400

### Ayarlar
- Grup başlıkları: NeerTypography.overline, uppercase, gray400
- Satırlar: GlassCard içinde, aralarında ince divider
- Toggle'lar: NeerColors.primary renginde

ADIM 4: Her dosyayı değiştirdikten sonra flutter analyze çalıştır.

ÖNEMLİ: Eski core dosyalarını (constants.dart, text_styles.dart, theme_styles.dart) 
HEMEN SİLME — önce tüm referansları neer_design_system.dart'a taşı, 
sonra import'ları güncelle, en son eski dosyaları sil.
```

## Renk Dönüşüm Tablosu

| Eski (AppColors/Constants)    | Yeni (NeerColors)              |
|-------------------------------|-------------------------------|
| AppColors.primary             | NeerColors.primary            |
| AppColors.accent              | NeerColors.accent             |
| Colors.black87                | Theme text color              |
| Colors.white                  | NeerGlass card + transparent  |
| Color(0xFF34C759)             | NeerColors.success            |
| Colors.redAccent              | NeerColors.error              |
| theme.cardColor               | GlassCard (şeffaf)           |
| theme.scaffoldBackgroundColor | GradientScaffold              |

## Stil Dönüşüm Tablosu

| Eski (AppTextStyles)          | Yeni (NeerTypography)          |
|-------------------------------|-------------------------------|
| AppTextStyles.h1              | NeerTypography.h1             |
| AppTextStyles.h2              | NeerTypography.h2             |
| AppTextStyles.h3              | NeerTypography.h3             |
| AppTextStyles.bodyLarge       | NeerTypography.bodyLarge      |
| AppTextStyles.bodySmall       | NeerTypography.bodySmall      |
| AppTextStyles.caption         | NeerTypography.caption        |
| AppTextStyles.button          | NeerTypography.button         |

## Decoration Dönüşüm Tablosu

| Eski Kullanım                                  | Yeni Kullanım                        |
|------------------------------------------------|--------------------------------------|
| BoxDecoration(color: theme.cardColor, ...)     | NeerGlass.card(isDark: isDark)       |
| BoxDecoration(color: isDark ? ... : ..., ...)  | NeerGlass.card(isDark: isDark)       |
| AppThemeStyles.shadowLow                       | NeerShadows.soft()                   |
| AppThemeStyles.shadowMedium                    | NeerShadows.medium()                 |
| AppThemeStyles.shadowHigh                      | NeerShadows.elevated()               |
| AppThemeStyles.radius16                        | NeerRadius.buttonRadius              |
| AppThemeStyles.radius24                        | NeerRadius.cardRadius                |
| AppThemeStyles.radius32                        | NeerRadius.sheetRadius               |