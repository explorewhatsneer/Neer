import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

// 🔥 CORE IMPORTLAR
import '../../core/constants.dart';
import '../../core/text_styles.dart';
import '../../core/app_strings.dart';
import '../../core/theme_styles.dart'; 

import '../../widgets/dialogs/check_in_dialog.dart'; 

class CheckInButton extends StatefulWidget {
  final String venueId;
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
  final _supabase = Supabase.instance.client;

  Future<void> _handleCheckIn() async {
    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);

    try {
      final String? myUid = _supabase.auth.currentUser?.id;
      if (myUid == null) throw Exception("Oturum açık değil.");

      // --- 1. İzinler ve Servis ---
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'GPS Kapalı.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Konum izni reddedildi.';
      }

      // --- 2. Konum Alma ---
      Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      final placeData = await _supabase
          .from('places')
          .select('latitude, longitude')
          .eq('id', widget.venueId)
          .single();

      final Distance distance = const Distance();
      final double meterDist = distance.as(
        LengthUnit.Meter,
        LatLng(userPosition.latitude, userPosition.longitude),
        LatLng(placeData['latitude'], placeData['longitude']),
      );

      debugPrint("📏 Mesafe: $meterDist metre");

      // --- 3. Mesafe Kontrolü ---
      if (meterDist > 125) {
        throw 'Mekana çok uzaksın (${meterDist.toInt()}m).';
      }

      // --- 4. Veritabanı Kayıt ---
      await _supabase.from('visits').insert({
        'user_id': myUid,
        'place_id': widget.venueId,
      });

      // --- 5. BAŞARILI ---
      if (mounted) {
        setState(() => _isLoading = false);
        HapticFeedback.mediumImpact();
        
        if (widget.onCheckInSuccess != null) widget.onCheckInSuccess!();

        // 🔥 ARTIK SADECE VERİYİ YOLLUYORUZ
        // Navigasyon işini Dialog'un kendisine bıraktık.
        // Böylece buton unmount olsa bile Dialog hayatta olduğu için çalışacak.
        CheckInDialog.show(
          context,
          isSuccess: true,
          title: "İçeridesin! 🎉",
          message: "${widget.venueName} mekanına girişin onaylandı. Sohbet seni bekliyor.",
          // Verileri Dialog'a emanet et:
          venueId: widget.venueId,
          venueName: widget.venueName,
          venueImage: widget.venueImage,
        );
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
                height: 24, width: 24, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
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