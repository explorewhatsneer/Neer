import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback

// Modüler Sheet Dosyaları 
// (Bu dosyaları henüz oluşturmadıysak hata verebilir, oluşturunca düzelir)
import 'place_sheet.dart';
import 'user_sheet.dart';

class InfoSheets {
  
  // 📍 MEKAN KARTI GÖSTERİCİ
  // Haritadan mekan marker'ına tıklandığında çağrılır.
  static void showPlaceCard(BuildContext context, Map<String, dynamic> placeData, String placeId) {
    // Premium His: Diğer widget'larla tutarlı olması için lightImpact kullanıyoruz
    HapticFeedback.lightImpact();
    
    // İş mantığını PlaceSheet sınıfına devreder
    PlaceSheet.show(context, placeData, placeId);
  }

  // 👤 KULLANICI KARTI GÖSTERİCİ
  // Haritadan kullanıcı avatarına tıklandığında çağrılır.
  static void showUserCard(BuildContext context, Map<String, dynamic> userData, String targetUid) {
    // Premium His
    HapticFeedback.lightImpact();
    
    // İş mantığını UserSheet sınıfına devreder
    UserSheet.show(context, userData, targetUid);
  }
}