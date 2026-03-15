import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback 

// CORE IMPORTLARI
import '../../core/text_styles.dart';
import '../../core/app_strings.dart'; 

class CustomNavBar extends StatelessWidget {
  final int activeIndex;
  final Function(int) onTabChange; 

  const CustomNavBar({
    super.key, 
    required this.activeIndex, 
    required this.onTabChange
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final double barHeight = 95; 
    final double itemWidth = size.width / 5;

    return SizedBox(
      width: size.width,
      height: barHeight + 30, // Gölge ve topun taşması için pay
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. ARKA PLAN (KAYAN KAVİS - CUSTOM PAINTER)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: activeIndex.toDouble(), end: activeIndex.toDouble()),
            duration: const Duration(milliseconds: 400), 
            curve: Curves.easeOutQuart, 
            builder: (context, value, child) {
              return CustomPaint(
                size: Size(size.width, barHeight),
                painter: _OrganicFluidPainter(
                  selectedIndex: value, 
                  itemsCount: 5,
                  color: theme.cardColor, // Dinamik Renk (Siyah/Beyaz)
                  shadowColor: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                ),
              );
            },
          ),

          // ✨ 2. TEK VE GEZGİN TOP (Kavisle Beraber Kayar)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400), // Kavisle senkronize
            curve: Curves.easeOutQuart, 
            
            // YATAY KONUM (Merkezleme Formülü)
            left: (itemWidth * activeIndex) + (itemWidth / 2) - 30, 
            
            // DİKEY KONUM
            top: 15, 
            
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft, 
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withValues(alpha: 0.4), 
                    blurRadius: 18, 
                    offset: const Offset(0, 8),
                  )
                ],
                border: Border.all(color: theme.scaffoldBackgroundColor, width: 3), // Topun etrafında boşluk hissi
              ),
              child: Icon(
                _getIconForIndex(activeIndex),
                color: Colors.white,
                size: 28, 
              ),
            ),
          ),

          // 3. PASİF İKONLAR VE YAZILAR (SABİT)
          SizedBox(
            width: size.width,
            height: barHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                final bool isActive = index == activeIndex;
                
                return GestureDetector(
                  onTap: () {
                     if (!isActive) {
                       HapticFeedback.lightImpact(); // Titreşim
                       onTabChange(index); 
                     }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: itemWidth, 
                    height: barHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // PASİF İKON (Aktifse kaybolur)
                        AnimatedOpacity(
                          opacity: isActive ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _getIconForIndex(index),
                            color: theme.disabledColor,
                            size: 26, 
                          ),
                        ),
                        
                        // YAZI (Sadece Aktifse Görünür)
                        Positioned(
                          bottom: 22, 
                          child: AnimatedOpacity(
                            opacity: isActive ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: isActive 
                              ? Text(
                                  _getLabel(index), 
                                  // 🔥 Core Style: Caption (Bold Primary)
                                  style: AppTextStyles.caption.copyWith(
                                    color: theme.primaryColor, 
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12
                                  )
                                )
                              : const SizedBox(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // İkonlar
  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0: return Icons.person_rounded; 
      case 1: return Icons.chat_bubble_rounded;
      case 2: return Icons.location_on_rounded; 
      case 3: return Icons.dynamic_feed_rounded; // Akış
      case 4: return Icons.people_alt_rounded;
      default: return Icons.circle;
    }
  }

  // Etiketler
  String _getLabel(int index) {
    switch (index) {
      case 0: return AppStrings.navProfile; 
      case 1: return AppStrings.navChat;
      case 2: return AppStrings.navMap;
      case 3: return AppStrings.navFeed;
      case 4: return AppStrings.navFriends;
      default: return "";
    }
  }
}

// ✨ ORGANİK RESSAM (SIVILAŞTIRMA EFEKTİ - Aynen Korundu)
class _OrganicFluidPainter extends CustomPainter {
  final double selectedIndex; 
  final int itemsCount;
  final Color color;
  final Color shadowColor;

  _OrganicFluidPainter({
    required this.selectedIndex, 
    required this.itemsCount, 
    required this.color,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    final path = Path();
    final double itemWidth = size.width / itemsCount;
    final double centerX = (itemWidth * selectedIndex) + (itemWidth / 2);
    
    // Kavisin genişliği ve derinliği
    const double notchWidth = 150.0; 
    const double notchDepth = 55.0; 

    path.moveTo(0, 0); 
    double leftStart = centerX - (notchWidth / 2);
    path.lineTo(leftStart, 0); 

    // Bezier Eğrileri (Sıvı efekti için)
    // İNİŞ (Kavisin sol tarafı)
    path.cubicTo(
      leftStart + (notchWidth * 0.30), 0,            
      centerX - (notchWidth * 0.30), notchDepth,     
      centerX, notchDepth,                           
    );
    // ÇIKIŞ (Kavisin sağ tarafı)
    path.cubicTo(
      centerX + (notchWidth * 0.30), notchDepth,     
      centerX + (notchWidth - (notchWidth * 0.30)) - (notchWidth / 2), 0, 
      centerX + (notchWidth / 2), 0                  
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height); 
    path.lineTo(0, size.height); 
    path.close();

    // Önce gölgeyi çiz
    canvas.drawPath(path, shadowPaint);
    // Sonra şekli çiz
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OrganicFluidPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex || oldDelegate.color != color;
  }
}