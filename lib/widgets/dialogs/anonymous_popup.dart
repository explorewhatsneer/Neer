import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// CORE IMPORTLARI
import '../../core/neer_design_system.dart';
import '../../core/app_strings.dart';

import '../../services/supabase_service.dart';

// --- DIALOG BAŞLATICI ---
void showAnonymousDialog(BuildContext context) {
  HapticFeedback.lightImpact();

  final service = SupabaseService();
  final String? uid = service.client.auth.currentUser?.id;

  if (uid == null) return; // Oturum yoksa açma

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: AppStrings.close, 
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) => const SizedBox(),
    transitionBuilder: (context, anim1, anim2, child) {
      // Yaylanma efekti
      final curvedValue = Curves.easeOutBack.transform(anim1.value);
      
      return Transform.scale(
        scale: 0.9 + (0.1 * curvedValue), 
        child: Opacity(
          opacity: anim1.value,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            elevation: 0,
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: service.streamProfileAsList(uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                   // Veri yüklenene kadar loading veya varsayılan durum
                   return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.white)));
                }

                final data = snapshot.data!.first;
                // SQL tablosunda sütun adı: 'is_anonymous'
                bool isAnonymous = data['is_anonymous'] ?? false;

                return _PremiumAnonymousCard(isAnonymous: isAnonymous, uid: uid);
              },
            ),
          ),
        ),
      );
    },
  );
}

// --- İÇERİK KARTI (PREMIUM) ---
class _PremiumAnonymousCard extends StatefulWidget {
  final bool isAnonymous;
  final String uid;

  const _PremiumAnonymousCard({required this.isAnonymous, required this.uid});

  @override
  State<_PremiumAnonymousCard> createState() => _PremiumAnonymousCardState();
}

class _PremiumAnonymousCardState extends State<_PremiumAnonymousCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final _service = SupabaseService();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 10.0, end: 25.0).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Duruma Özel Renkler
    final Color mainColor = widget.isAnonymous 
        ? const Color(0xFF5E5CE6) // İndigo (Gizli)
        : const Color(0xFF34C759); // Yeşil (Açık)
    
    final String statusText = widget.isAnonymous ? AppStrings.invisibleMode : AppStrings.liveMode;
    final IconData mainIcon = widget.isAnonymous ? Icons.visibility_off_rounded : Icons.public_rounded;

    return Stack(
      clipBehavior: Clip.none, 
      children: [
        // 1. ANA KART (GLASS)
        ClipRRect(
          borderRadius: NeerRadius.sheetRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
              decoration: BoxDecoration(
                // Dinamik Glass Rengi
                color: isDark ? Colors.black.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.85),
                borderRadius: NeerRadius.sheetRadius,
                border: Border.all(color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.6), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 40, spreadRadius: 10, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  // Üst Bilgi Hapı (Status Pill)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: mainColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: mainColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: mainColor, 
                            shape: BoxShape.circle, 
                            boxShadow: [BoxShadow(color: mainColor.withValues(alpha: 0.5), blurRadius: 6)]
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusText.toUpperCase(), 
                          // 🔥 Core Style: Caption
                          style: NeerTypography.caption.copyWith(
                            color: mainColor, 
                            fontWeight: FontWeight.w800, 
                            letterSpacing: 0.5
                          )
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Animasyonlu İkon (Pulse Effect)
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: mainColor,
                          boxShadow: [
                            BoxShadow(
                              color: mainColor.withValues(alpha: 0.5), 
                              blurRadius: _pulseAnimation.value, 
                              spreadRadius: 5
                            ),
                          ],
                        ),
                        child: Icon(mainIcon, size: 48, color: Colors.white),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // Başlık
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      widget.isAnonymous ? AppStrings.youAreHidden : AppStrings.everyoneSeesYou,
                      key: ValueKey(widget.isAnonymous),
                      // 🔥 Core Style: H2
                      style: NeerTypography.h2.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Açıklama
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      widget.isAnonymous ? AppStrings.ghostDesc : AppStrings.liveDesc,
                      key: ValueKey(widget.isAnonymous),
                      textAlign: TextAlign.center,
                      // 🔥 Core Style: BodyMedium
                      style: NeerTypography.bodyLarge.copyWith( 
                        color: isDark ? NeerColors.gray300 : NeerColors.gray600,
                        height: 1.5, 
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Aksiyon Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        HapticFeedback.mediumImpact(); 
                        
                        final result = await _service.updateProfile(widget.uid, {
                          'is_anonymous': !widget.isAnonymous,
                        });
                        if (result.isFailure) {
                          debugPrint("Anonim mod hatası: ${result.error.message}");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : NeerColors.primaryDark,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 5,
                        shadowColor: Colors.black.withValues(alpha: 0.3),
                      ),
                      child: Text(
                        widget.isAnonymous ? AppStrings.goVisible : AppStrings.goHidden,
                        // 🔥 Core Style: Button
                        style: NeerTypography.button.copyWith(
                          color: isDark ? Colors.black : Colors.white
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 2. KAPATMA BUTONU
        Positioned(
          top: 15, 
          right: 15,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 20, color: theme.iconTheme.color),
            ),
          ),
        ),
      ],
    );
  }
}