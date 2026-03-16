import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

// CORE IMPORTLAR
import '../../core/constants.dart';
import '../../core/text_styles.dart';
import '../../core/app_strings.dart';
import '../../core/theme_styles.dart';

import '../../services/supabase_service.dart';
import '../../widgets/dialogs/check_in_dialog.dart';

/// 🔥 V2 — Sunucu tarafı geofence doğrulaması ile Check-in butonu.
///
/// ESKİ AKIŞ: Client mesafe hesaplıyor → visits'e insert → count artır
/// YENİ AKIŞ: Client GPS alıyor → check_in_to_place RPC → Sunucu
///   mesafe doğrular, session oluşturur, live_count günceller, visit yazar
class CheckInButton extends StatefulWidget {
  final String venueId;      // place.id (String olarak geliyor, int'e çevireceğiz)
  final String venueName;
  final String venueImage;
  final VoidCallback? onCheckInSuccess;

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
  final _supabaseService = SupabaseService();

  Future<void> _handleCheckIn() async {
    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);

    try {
      // --- 1. Oturum Kontrolü ---
      final String? myUid = _supabaseService.client.auth.currentUser?.id;
      if (myUid == null) throw Exception("Oturum açık değil.");

      // --- 2. GPS İzinleri ---
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('GPS kapalı. Lütfen konum servisini açın.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Konum izni reddedildi.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Konum izni kalıcı olarak reddedildi. Ayarlardan açın.');
      }

      // --- 3. Konum Al ---
      Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      // --- 4. 🔥 SUNUCU TARAFI CHECK-IN (Yeni RPC) ---
      // Mesafe hesabı, session yönetimi, live_count güncelleme
      // ve visit kaydı tamamen sunucuda yapılıyor.
      final int placeId = int.tryParse(widget.venueId) ?? 0;
      if (placeId == 0) throw Exception('Geçersiz mekan kimliği.');

      final checkInResult = await _supabaseService.checkIn(
        userId: myUid,
        placeId: placeId,
        userLat: userPosition.latitude,
        userLng: userPosition.longitude,
      );

      if (checkInResult.isFailure) {
        throw Exception(checkInResult.error.message);
      }

      final result = checkInResult.data;

      // --- 5. SONUCU İŞLE ---
      if (result['success'] == true) {
        if (mounted) {
          setState(() => _isLoading = false);
          HapticFeedback.mediumImpact();

          widget.onCheckInSuccess?.call();

          final liveCount = result['live_count'] ?? 0;
          final distance = result['distance'] ?? 0;

          CheckInDialog.show(
            context,
            isSuccess: true,
            title: "İçeridesin! 🎉",
            message: "${widget.venueName} mekanına girişin onaylandı.\n"
                "${liveCount > 1 ? 'Şu an $liveCount kişi burada!' : 'İlk gelen sensin! 🏆'}\n"
                "Sohbet seni bekliyor.",
            venueId: widget.venueId,
            venueName: widget.venueName,
            venueImage: widget.venueImage,
          );
        }
      } else {
        // Sunucu tarafı hata
        String errorMsg;
        switch (result['error']) {
          case 'TOO_FAR':
            final dist = result['distance'] ?? '?';
            errorMsg = 'Mekana çok uzaksın (${dist}m). Yaklaşman gerekiyor.';
            break;
          case 'PLACE_NOT_FOUND':
            errorMsg = 'Mekan bulunamadı.';
            break;
          case 'ALREADY_CHECKED_IN':
            // Zaten giriş yapmış — hata değil, sohbete yönlendir
            if (mounted) {
              setState(() => _isLoading = false);
              CheckInDialog.show(
                context,
                isSuccess: true,
                title: "Zaten buradasın 📍",
                message: "${widget.venueName} mekanında aktif oturumun var.",
                venueId: widget.venueId,
                venueName: widget.venueName,
                venueImage: widget.venueImage,
              );
            }
            return; // Early return — hata dialog'u gösterme
          default:
            errorMsg = result['error']?.toString() ?? 'Bilinmeyen hata.';
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        HapticFeedback.vibrate();

        CheckInDialog.show(
          context,
          isSuccess: false,
          title: "Giriş Yapılamadı",
          message: e.toString().replaceAll("Exception: ", ""),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        boxShadow: _isLoading ? [] : AppThemeStyles.shadowHigh,
        borderRadius: AppThemeStyles.radius24,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius24),
          padding: EdgeInsets.zero,
        ),
        onPressed: _isLoading ? null : _handleCheckIn,
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_rounded, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.checkIn,
                    style: AppTextStyles.button.copyWith(fontSize: 17, letterSpacing: -0.3),
                  ),
                ],
              ),
      ),
    );
  }
}