import 'dart:io';
import 'dart:ui'; // ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback

// CORE IMPORTLARI
import '../../core/theme_styles.dart'; 
import '../../core/text_styles.dart';
import '../../core/app_strings.dart'; 

// 1. NEER TEXT FIELD (Premium Giriş Alanı)
class NeerTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType inputType;

  const NeerTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.maxLines = 1,
    this.inputType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppThemeStyles.radius16,
        boxShadow: isDark ? [] : AppThemeStyles.shadowLow,
        border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: inputType,
        // 🔥 Core Style: BodyLarge (SF Pro Regular)
        style: AppTextStyles.bodyLarge.copyWith(
          color: theme.textTheme.bodyLarge?.color
        ),
        cursorColor: theme.primaryColor,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          // 🔥 Core Style: BodySmall (Label)
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: theme.disabledColor, 
            fontWeight: FontWeight.bold
          ),
          icon: Icon(icon, color: theme.primaryColor.withOpacity(0.8)),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

// 2. BÖLÜM BAŞLIĞI
class EditSectionTitle extends StatelessWidget {
  final String title;
  const EditSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title, 
          // 🔥 Core Style: H3 (Semibold)
          style: AppTextStyles.h3.copyWith(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 18
          )
        ),
      ),
    );
  }
}

// 3. AVATAR DÜZENLEME ALANI (Header İçin)
class EditAvatarArea extends StatelessWidget {
  final File? selectedImage;
  final String? currentUrl;
  final VoidCallback onEditTap;

  const EditAvatarArea({
    super.key,
    required this.selectedImage,
    required this.currentUrl,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Hangi resmin gösterileceğine karar ver
    ImageProvider<Object> imageProvider;
    if (selectedImage != null) {
      imageProvider = FileImage(selectedImage!);
    } else if (currentUrl != null && currentUrl!.isNotEmpty) {
      imageProvider = NetworkImage(currentUrl!);
    } else {
      imageProvider = const NetworkImage("https://i.pravatar.cc/300"); 
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Arkaplan (Blur)
        Image(image: imageProvider, fit: BoxFit.cover),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            color: isDark ? Colors.black.withOpacity(0.6) : Colors.black.withOpacity(0.3),
          ),
        ),
        
        // 2. Avatar ve Buton
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Stack(
                children: [
                  // Avatar Çerçevesi
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), 
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: theme.cardColor,
                      backgroundImage: imageProvider,
                    ),
                  ),
                  
                  // Düzenle Butonu
                  Positioned(
                    bottom: 0, right: 0,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact(); // Titreşim
                        onEditTap();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                          ]
                        ),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onEditTap();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Text(
                    AppStrings.changePhoto, // 🔥 Core String
                    // 🔥 Core Style: Caption (Bold White)
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}