import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:supabase_flutter/supabase_flutter.dart';

// CORE IMPORTLARI
import '../../core/text_styles.dart';
import '../../core/app_strings.dart'; 

import '../../services/firestore_service.dart';
import '../../screens/group_chat_screen.dart';

class CheckInButton extends StatefulWidget {
  final String venueId;
  final String venueName;
  final String venueImage;
  final VoidCallback? onCheckInSuccess; // İşlem bitince yapılacak ek işler

  const CheckInButton({
    super.key,
    required this.venueId,
    required this.venueName,
    required this.venueImage,
    this.onCheckInSuccess,
  });

  @override
  State<CheckInButton> createState() => _CheckInButtonState();
}

class _CheckInButtonState extends State<CheckInButton> {
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();

  void _handleCheckIn() async {
    // 1. Fiziksel Geri Bildirim
    HapticFeedback.heavyImpact();
    
    setState(() => _isLoading = true);

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    
    try {
      // Supabase ID'si alınıyor
      final String? myUid = Supabase.instance.client.auth.currentUser?.id;

      if (myUid == null) {
        throw Exception("Kullanıcı oturumu bulunamadı.");
      }
      
      // 2. Servisi çağır (Safe ID döner)
      // 🔥 DÜZELTME: Parametreler sırasıyla (userId, placeId, placeName) gönderiliyor.
      String safeId = await _firestoreService.sendCheckIn(
        myUid,            // 1. Parametre: User ID
        widget.venueId,   // 2. Parametre: Mekan ID
        widget.venueName, // 3. Parametre: Mekan İsmi
      );
      
      // 3. Başarılı mesajı (Premium SnackBar)
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.checkInSuccess, 
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white, 
                      fontWeight: FontWeight.w600
                    )
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF34C759), // Başarı Yeşili
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }

      // 4. Ekstra callback (Varsa çalıştır)
      if (widget.onCheckInSuccess != null) {
        widget.onCheckInSuccess!();
      }

      // 5. Hafif gecikme ile yönlendirme
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => GroupChatScreen(
              groupId: safeId,
              groupName: widget.venueName,
              groupImage: widget.venueImage,
            ),
          ),
        );
      }
      
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              "${AppStrings.error}: $e", 
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white)
            ),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          )
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 56, // Standart Premium Yükseklik
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor, 
          foregroundColor: Colors.white,
          elevation: _isLoading ? 0 : 8,
          shadowColor: theme.primaryColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: EdgeInsets.zero,
        ),
        onPressed: _isLoading ? null : _handleCheckIn,
        child: _isLoading
            ? const SizedBox(
                height: 24, 
                width: 24, 
                child: CircularProgressIndicator(
                  color: Colors.white, 
                  strokeWidth: 2.5
                )
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.checkIn, 
                    style: AppTextStyles.button, 
                  ),
                ],
              ),
      ),
    );
  }
}