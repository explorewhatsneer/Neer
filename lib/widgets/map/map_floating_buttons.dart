import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:image_picker/image_picker.dart';

// CORE IMPORTLARI
import '../../core/text_styles.dart';
import '../../core/app_strings.dart';
import '../common/glass_button.dart';

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
        // ARAMA BUTONU
        GlassButton.fab(
          icon: Icons.search_rounded,
          onTap: () {
            HapticFeedback.mediumImpact();
            onSearchTap();
          },
          iconColor: theme.primaryColor,
        ),

        const SizedBox(height: 15),

        // KAMERA BUTONU
        GlassButton.fab(
          icon: Icons.camera_alt_rounded,
          onTap: () {
            HapticFeedback.mediumImpact();
            _openCamera(context);
          },
          iconColor: theme.primaryColor,
        ),

        const SizedBox(height: 15),

        // KONUM BUTONU
        GlassButton.fab(
          icon: Icons.my_location_rounded,
          onTap: () {
            HapticFeedback.mediumImpact();
            onLocationTap();
          },
          iconColor: Colors.blueAccent,
        ),
      ],
    );
  }

}