import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

// CORE IMPORT
import '../core/app_strings.dart';

class StorageService {
  // 🔥 Supabase İstemcisi
  final _supabase = Supabase.instance.client;

  // Profil Resmi Yükle ve URL Döndür
  Future<String?> uploadProfileImage(File imageFile, String uid) async {
    try {
      // Dosya adı: uid.jpg
      final String fileName = '$uid.jpg';
      const String bucketName = 'profile_images'; // Panelde açtığın bucket adı

      // 1. Yükleme İşlemi
      // 'upsert: true' -> Dosya varsa üzerine yazar (Firebase'deki mantığın aynısı)
      await _supabase.storage.from(bucketName).upload(
        fileName,
        imageFile,
        fileOptions: const FileOptions(
          cacheControl: '3600', 
          upsert: true 
        ),
      );

      // 2. Public URL (İndirme Linki) Al
      // Supabase'de getDownloadURL yerine getPublicUrl kullanılır ve await gerektirmez.
      final String publicUrl = _supabase.storage.from(bucketName).getPublicUrl(fileName);
      
      // Cache sorunu yaşamamak için (profil resmi güncellenince eski resim görünmesin diye)
      // URL'nin sonuna zaman damgası ekliyoruz. (Opsiyonel ama önerilir)
      final String timestampedUrl = "$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}";

      return timestampedUrl;
    } catch (e) {
      print("${AppStrings.imageUploadError} $e");
      return null;
    }
  }
}