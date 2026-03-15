import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback

// CORE IMPORTLARI
import '../../core/app_strings.dart';
import '../common/glass_button.dart';

// Sayfa Importları (Projende bu yolların doğru olduğundan emin ol)
import '../../screens/notifications_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/polls_screen.dart'; 
import '../dialogs/anonymous_popup.dart'; 

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

  Widget _buildMenuButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: GlassButton.fab(
          icon: icon,
          iconColor: color,
          tooltip: tooltip,
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
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
            _buildMenuButton(
              tooltip: AppStrings.notifications, // 🔥 Core String
              icon: Icons.notifications_active_rounded,
              color: Colors.pinkAccent,
              onTap: () {
                onToggleMenu();
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
              },
            ),
            
            // 2. Anketler / Değerlendirmeler
            _buildMenuButton(
              tooltip: AppStrings.polls, // 🔥 Core String
              icon: Icons.poll_rounded, 
              color: Colors.orange,
              onTap: () {
                onToggleMenu();
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PollsScreen()));
              },
            ),
            
            // 3. Anonim Mod
            _buildMenuButton(
              tooltip: AppStrings.privacyMode, // 🔥 Core String
              icon: Icons.vpn_key_off_rounded,
              color: Colors.deepPurpleAccent,
              onTap: () {
                onToggleMenu();
                showAnonymousDialog(context);
              },
            ),
            
            // 4. Ayarlar
            _buildMenuButton(
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