import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/text_styles.dart';

// --- BASE CARD ---
class PremiumCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? shadows;

  const PremiumCard({super.key, required this.child, this.onTap, this.borderRadius = 24, this.color, this.padding, this.shadows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () { if (onTap != null) { HapticFeedback.lightImpact(); onTap!(); } },
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? theme.cardColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: shadows ?? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: child,
      ),
    );
  }
}

// 1. DİKEY MEKAN KARTI (DEĞİŞMEDİ, GÜZEL)
class VerticalPlaceCard extends StatelessWidget {
  final String name, rating, imgUrl;
  final VoidCallback? onTap;
  const VerticalPlaceCard({super.key, required this.name, required this.rating, required this.imgUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: PremiumCard(
          onTap: onTap, padding: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.network(imgUrl, fit: BoxFit.cover)),
              Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)], stops: const [0.6, 1.0]))),
              Positioned(bottom: 20, left: 16, right: 16, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star_rounded, color: Colors.amber, size: 14), const SizedBox(width: 4), Text(rating, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))])), const SizedBox(height: 6), Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20, height: 1.1), maxLines: 2, overflow: TextOverflow.ellipsis)])),
            ],
          ),
        ),
      ),
    );
  }
}
class HorizontalPlaceCard extends VerticalPlaceCard { const HorizontalPlaceCard({super.key, required super.name, required super.rating, required super.imgUrl, super.onTap}); }

// ==========================================
// 📝 2. NOT KARTI ("Sticky Note" / Journal Style)
// ==========================================
class VerticalNoteCard extends StatelessWidget {
  final String placeName, note, date, profileImg;
  final VoidCallback? onTap;

  const VerticalNoteCard({super.key, required this.placeName, required this.note, required this.date, required this.profileImg, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Not kağıdı rengi: Açık modda hafif sarımsı/krem, koyu modda koyu gri
    final bgColor = theme.brightness == Brightness.dark ? const Color(0xFF2C2C2E) : const Color(0xFFFFFDF5);
    final textColor = theme.brightness == Brightness.dark ? Colors.white70 : const Color(0xFF333333);

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: PremiumCard(
          onTap: onTap,
          color: bgColor, // Kağıt rengi
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          // Hafif kağıt gölgesi
          shadows: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(2, 4))],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst Kısım: Tarih ve Pin İkonu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(date, style: AppTextStyles.caption.copyWith(color: theme.disabledColor, fontSize: 10)),
                  Icon(Icons.push_pin_rounded, size: 16, color: theme.primaryColor.withOpacity(0.5)),
                ],
              ),
              const SizedBox(height: 12),
              
              // Not İçeriği (El yazısı havası için fontStyle: italic)
              Expanded(
                child: Text(
                  note,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 15,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                    color: textColor,
                    fontFamily: 'Georgia', // Serif font daha "not" gibi durur
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const Divider(height: 20),
              
              // Alt Kısım: Mekan ve Avatar
              Row(
                children: [
                  CircleAvatar(radius: 12, backgroundImage: NetworkImage(profileImg)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      placeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
class HorizontalNoteCard extends VerticalNoteCard { const HorizontalNoteCard({super.key, required super.placeName, required super.note, required super.date, required super.profileImg, super.onTap}); }

// ==========================================
// ⭐ 3. DEĞERLENDİRME KARTI (Ultra Premium iOS Style)
// ==========================================
class DetailedReviewCard extends StatefulWidget {
  final String placeName;
  final double score;
  final String date;
  final VoidCallback? onTap;

  const DetailedReviewCard({
    super.key, 
    required this.placeName, 
    required this.score, 
    required this.date, 
    this.onTap
  });

  @override
  State<DetailedReviewCard> createState() => _DetailedReviewCardState();
}

class _DetailedReviewCardState extends State<DetailedReviewCard> {
  bool _isExpanded = false;

  void _toggleExpand() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scoreColor = _getScoreColor(widget.score);

    // Fake Puanlar
    final double taste = widget.score;
    final double service = (widget.score - 0.3).clamp(1.0, 5.0);
    final double ambiance = (widget.score + 0.2).clamp(1.0, 5.0);
    final double price = (widget.score - 0.5).clamp(1.0, 5.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      // 🔥 Align: TopCenter -> Kartın yukarıya yapışık kalıp aşağı uzamasını sağlar
      child: Align(
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: _toggleExpand,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutBack, // Yaylanma efekti
            // Kartın minimum yüksekliği ve genişliği
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(28), // Daha modern geniş köşe
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: [
                // Çok yumuşak, yaygın gölge (iOS Style)
                BoxShadow(
                  color: scoreColor.withOpacity(_isExpanded ? 0.12 : 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Column(
                mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla
                children: [
                  
                  // --- ÜST KISIM (HEADER) ---
                  Container(
                    padding: const EdgeInsets.all(20), // Daha geniş iç boşluk
                    color: Colors.transparent,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 1. Puan Kutusu (Gradient Squircle)
                        Container(
                          width: 56, height: 56, // Büyüttük
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                              colors: [scoreColor, scoreColor.withOpacity(0.75)],
                            ),
                            borderRadius: BorderRadius.circular(20), // Squircle formu
                            boxShadow: [
                              BoxShadow(color: scoreColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.score.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white, height: 1.0),
                              ),
                              const SizedBox(height: 2),
                              const Icon(Icons.star_rounded, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 14),

                        // 2. Başlık ve Bilgiler
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.placeName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.h3.copyWith(fontSize: 16, height: 1.1),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 13, color: theme.disabledColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    widget.date, 
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.disabledColor, letterSpacing: -0.2)
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 3. Ok İkonu (Minimal)
                        AnimatedRotation(
                          turns: _isExpanded ? 0.25 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.arrow_forward_ios_rounded, size: 10, color: theme.disabledColor),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- ALT KISIM (DETAYLAR - AŞAĞI AÇILIR) ---
                  // alignment: Alignment.topCenter -> Yukarıyı sabitle, aşağı doğru aç!
                  AnimatedSize(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutBack, // "Yaylanarak" açılma
                    alignment: Alignment.topCenter, 
                    child: SizedBox(
                      height: _isExpanded ? null : 0, 
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        decoration: BoxDecoration(
                          // Hafif bir zemin rengi ayrımı (Opsiyonel, temizlik için şeffaf bıraktım)
                          // color: theme.scaffoldBackgroundColor.withOpacity(0.3),
                        ),
                        child: Column(
                          children: [
                            Divider(height: 1, color: theme.dividerColor.withOpacity(0.08)),
                            const SizedBox(height: 20),
                            
                            // İstatistikler (Daha temiz Grid)
                            Row(
                              children: [
                                _buildPremiumStat(context, "Lezzet", Icons.restaurant, taste, scoreColor),
                                const SizedBox(width: 16),
                                _buildPremiumStat(context, "Servis", Icons.room_service, service, scoreColor),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildPremiumStat(context, "Ortam", Icons.chair, ambiance, scoreColor),
                                const SizedBox(width: 16),
                                _buildPremiumStat(context, "Fiyat", Icons.attach_money, price, scoreColor),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Yeni Premium Stat Bar Tasarımı
  Widget _buildPremiumStat(BuildContext context, String label, IconData icon, double val, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: theme.disabledColor.withOpacity(0.5)),
              const SizedBox(width: 6),
              Text(
                label, 
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))
              ),
              const Spacer(),
              Text(
                val.toStringAsFixed(1), 
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Bar
          Stack(
            children: [
              // Arka plan barı
              Container(
                height: 6, 
                width: 100, 
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.8), 
                  borderRadius: BorderRadius.circular(3)
                )
              ),
              // Doluluk barı
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutExpo,
                height: 6,
                width: 100 * (val / 5.5), // Container genişliğine oranla (yaklaşık)
                decoration: BoxDecoration(
                  color: color, 
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
                  ]
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 4.5) return const Color(0xFF2ECC71); // Emerald Green
    if (score >= 4.0) return const Color(0xFF3498DB); // Blue
    if (score >= 3.0) return const Color(0xFFF1C40F); // Yellow
    return const Color(0xFFE74C3C); // Red
  }
}

// ==========================================
// 🎖 4. GÖREV KARTI -> BAŞARI ROZETİ (Achievement Badge)
// ==========================================
class DynamicQuestCard extends StatelessWidget {
  final String title, subtitle;
  final double progress;

  const DynamicQuestCard({super.key, required this.title, required this.subtitle, required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = progress >= 100;
    
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 130, // Daha kompakt
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(100), // Hap (Capsule) şekli
        border: Border.all(color: isCompleted ? const Color(0xFFFFD700) : theme.dividerColor.withOpacity(0.2), width: isCompleted ? 2 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
      child: Row(
        children: [
          // İkon / Yuvarlak Progress
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress / 100,
                backgroundColor: theme.dividerColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? const Color(0xFFFFD700) : theme.primaryColor),
                strokeWidth: 3,
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: (isCompleted ? const Color(0xFFFFD700) : theme.primaryColor).withOpacity(0.1),
                child: Icon(
                  isCompleted ? Icons.emoji_events : Icons.flag,
                  size: 18,
                  color: isCompleted ? const Color(0xFFFFD700) : theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          
          // Yazı
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isCompleted ? "Tamamlandı" : "${progress.toInt()}%", 
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isCompleted ? Colors.orange : theme.primaryColor)
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}