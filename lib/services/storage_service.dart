import 'dart:io';
import 'package:flutter/foundation.dart';
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
      debugPrint("${AppStrings.imageUploadError} $e");
      return null;
    }
  }

  /// Mekan veya post fotoğrafı yükle — eski dosyayı temizle
  Future<String?> uploadImage({
    required File imageFile,
    required String bucket,
    required String path,
    String? oldUrl,
  }) async {
    try {
      // 1. Eski dosyayı sil (varsa)
      if (oldUrl != null && oldUrl.isNotEmpty) {
        try {
          final uri = Uri.tryParse(oldUrl);
          if (uri != null) {
            // URL'den storage path'ini çıkar: .../storage/v1/object/public/bucket/path
            final segments = uri.pathSegments;
            final bucketIdx = segments.indexOf(bucket);
            if (bucketIdx != -1 && bucketIdx + 1 < segments.length) {
              final oldPath = segments.sublist(bucketIdx + 1).join('/').split('?').first;
              await _supabase.storage.from(bucket).remove([oldPath]);
            }
          }
        } catch (e) {
          // Eski dosya silinemezse devam et — yeni dosya yüklenmeli
          debugPrint('Eski dosya silinemedi: $e');
        }
      }

      // 2. Yeni dosyayı yükle
      await _supabase.storage.from(bucket).upload(
        path,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      // 3. Public URL al
      final publicUrl = _supabase.storage.from(bucket).getPublicUrl(path);
      return "$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}";
    } catch (e) {
      debugPrint("Resim yükleme hatası: $e");
      return null;
    }
  }
}