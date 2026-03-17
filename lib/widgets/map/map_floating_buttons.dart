import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:image_picker/image_picker.dart';

// CORE IMPORTLARI
import '../../core/app_strings.dart';
import '../../core/snackbar_helper.dart';
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
    try {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        if(context.mounted) {
          AppSnackBar.success(context, AppStrings.photoCaptured);
        }
      }
    } catch (e) {
      if(context.mounted) {
        AppSnackBar.error(context, AppStrings.cameraError);
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