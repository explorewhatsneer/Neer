import 'dart:ui'; // ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback

// CORE IMPORTLARI
import '../../core/app_strings.dart'; 
// import '../../core/theme_styles.dart'; // Gerekirse eklenebilir

// Sayfa Importları (Projende bu yolların doğru olduğundan emin ol)
import '../../screens/notifications_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/polls_screen.dart'; 
import '../common/anonymous_popup.dart'; 

class BalloonMenu extends StatelessWidget {
  final bool isOpen;
  final Animation<double> scaleAnimation;
  final VoidCallback onToggleMenu;

  const BalloonMenu({
    super.key,
    required this.isOpen,
    required this.scaleAnimation,
    required this.onToggleMenu,
  });

  Widget _buildGlassButton({
    required BuildContext context,
    required IconData icon, 
    required Color color, 
    required VoidCallback onTap, 
    required String tooltip
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScaleTransition(
      scale: scaleAnimation,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15), // Butonlar arası boşluk
        child: Tooltip(
          message: tooltip,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact(); // Titreşim
              onTap();
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur Efekti
                child: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    // Dinamik Yarı Saydam Zemin
                    color: isDark ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.85),
                    shape: BoxShape.circle,
                    // Premium Çerçeve
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.6), 
                      width: 1
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15), 
                        blurRadius: 10, 
                        offset: const Offset(0, 4)
                      )
                    ],
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isOpen, // Menü kapalıyken tıklamayı engelle
      child: SizedBox(
        width: 50, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Bildirimler
            _buildGlassButton(
              context: context,
              tooltip: AppStrings.notifications, // 🔥 Core String
              icon: Icons.notifications_active_rounded,
              color: Colors.pinkAccent,
              onTap: () {
                onToggleMenu();
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
              },
            ),
            
            // 2. Anketler / Değerlendirmeler
            _buildGlassButton(
              context: context,
              tooltip: AppStrings.polls, // 🔥 Core String
              icon: Icons.poll_rounded, 
              color: Colors.orange,
              onTap: () {
                onToggleMenu();
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PollsScreen()));
              },
            ),
            
            // 3. Anonim Mod
            _buildGlassButton(
              context: context,
              tooltip: AppStrings.privacyMode, // 🔥 Core String
              icon: Icons.vpn_key_off_rounded,
              color: Colors.deepPurpleAccent,
              onTap: () {
                onToggleMenu();
                showAnonymousDialog(context);
              },
            ),
            
            // 4. Ayarlar
            _buildGlassButton(
              context: context,
              tooltip: AppStrings.settings, // 🔥 Core String
              icon: Icons.settings_rounded,
              color: Colors.blueGrey,
              onTap: () {
                onToggleMenu();
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}