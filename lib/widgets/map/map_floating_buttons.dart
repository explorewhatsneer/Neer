import 'dart:ui'; // ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:image_picker/image_picker.dart';

// CORE IMPORTLARI
import '../../core/text_styles.dart';
import '../../core/app_strings.dart';

class MapFloatingButtons extends StatelessWidget {
  final VoidCallback onLocationTap;
  final VoidCallback onSearchTap;

  const MapFloatingButtons({
    super.key, 
    required this.onLocationTap,
    required this.onSearchTap,
  });

  Future<void> _openCamera(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final theme = Theme.of(context);

    try {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        if(context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    AppStrings.photoCaptured, // 🔥 Core String
                    // 🔥 Core Style
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white
                    )
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF34C759), // Başarı Yeşili
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        }
      }
    } catch (e) {
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.cameraError, // 🔥 Core String
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white)
            ), 
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🔍 ARAMA BUTONU
        _buildGlassFab(
          context: context,
          icon: Icons.search_rounded,
          onTap: onSearchTap,
          color: theme.primaryColor,
        ),

        const SizedBox(height: 15),

        // 📸 KAMERA BUTONU
        _buildGlassFab(
          context: context,
          icon: Icons.camera_alt_rounded,
          onTap: () => _openCamera(context),
          color: theme.primaryColor, // Veya Colors.orangeAccent
        ),
        
        const SizedBox(height: 15),

        // 📍 KONUM BUTONU
        _buildGlassFab(
          context: context,
          icon: Icons.my_location_rounded,
          onTap: onLocationTap,
          color: Colors.blueAccent,
        ),
      ],
    );
  }

  // --- REUSABLE GLASS FAB ---
  Widget _buildGlassFab({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 50, 
      height: 50,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact(); // Titreşim
          onTap();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25), // Tam yuvarlak
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur
            child: Container(
              decoration: BoxDecoration(
                // Dinamik Arka Plan
                color: isDark ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.85),
                shape: BoxShape.circle,
                // İnce Çerçeve
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5), 
                  width: 1
                ),
                // Gölge
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15), 
                    blurRadius: 10, 
                    offset: const Offset(0, 4)
                  )
                ],
              ),
              child: Icon(
                icon, 
                color: isDark ? Colors.white : color, 
                size: 26
              ),
            ),
          ),
        ),
      ),
    );
  }
}