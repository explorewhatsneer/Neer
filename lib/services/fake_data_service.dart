import 'dart:math';
import 'package:faker/faker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeDataService {
  final _supabase = Supabase.instance.client;
  final _faker = Faker();
  final _random = Random();

  // Mekan isimlerini sabitliyoruz ki "Sık Uğrananlar"da aynı isimler sayılabilsin
  final List<String> _popularPlaces = [
    "Espresso Lab", "Starbucks", "Viyana Kahvesi", 
    "Petra Roasting Co.", "Federal Coffee", "Salt Galata", 
    "Minoa Bookstore", "Karaköy Güllüoğlu"
  ];

  String _getRandomImage() {
    final id = _random.nextInt(1000);
    return "https://picsum.photos/id/$id/500/500";
  }

  // --- 1. PROFİL GÜNCELLEME ---
  Future<void> createFakeProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      print("❌ HATA: Kullanıcı giriş yapmamış.");
      return;
    }

    try {
      await _supabase.from('profiles').upsert({
        'id': userId,
        'full_name': _faker.person.name(),
        'username': _faker.internet.userName().replaceAll('.', '_'),
        'bio': "Gezgin 🌍 | Kahve Sever ☕ | İstanbul",
        'avatar_url': "https://i.pravatar.cc/300?img=${_random.nextInt(60)}",
        'followers_count': _random.nextInt(2000) + 100,
        'following_count': _random.nextInt(500) + 50,
        'check_in_count': _random.nextInt(50),
        'photo_count': _random.nextInt(100),
        'trust_score': (_random.nextDouble() * 5) + 5,
        'updated_at': DateTime.now().toIso8601String(),
      });
      print("✅ Profil güncellendi.");
    } catch (e) {
      print("❌ Profil hatası: $e");
    }
  }

  // --- 2. GÖNDERİLER (Aktivite + Değerlendirme + Sık Uğrananlar) ---
  Future<void> seedPosts(int count) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    List<Map<String, dynamic>> posts = [];

    for (int i = 0; i < count; i++) {
      // %70 ihtimalle listeden bir mekan seçelim (Sık uğrananlar dolsun diye)
      String place = _random.nextBool() 
          ? _popularPlaces[_random.nextInt(_popularPlaces.length)]
          : _faker.company.name();

      // %50 ihtimalle 'review' (Değerlendirme), %50 'post' (Fotoğraf)
      bool isReview = _random.nextDouble() < 0.5; 

      posts.add({
        'user_id': userId,
        'type': isReview ? 'review' : 'post', 
        'content': isReview ? _faker.lorem.sentence() : "Burayı çok sevdim! 📸",
        'image_url': isReview ? null : _getRandomImage(),
        'location_name': place, // get_top_places fonksiyonu burayı sayacak
        'rating': isReview ? (_random.nextDouble() * 2) + 3 : null,
        'review_comment': isReview ? "Harika bir deneyimdi! " + _faker.lorem.sentence() : null,
        'created_at': _faker.date.dateTime(minYear: 2023, maxYear: 2024).toIso8601String(),
      });
    }

    try {
      await _supabase.from('posts').insert(posts);
      print("✅ $count adet gönderi/değerlendirme eklendi.");
    } catch (e) {
      print("❌ Post ekleme hatası: $e");
    }
  }

  // --- 3. FAVORİLER ---
  Future<void> seedFavorites(int count) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    List<Map<String, dynamic>> favorites = [];
    for (int i = 0; i < count; i++) {
      favorites.add({
        'user_id': userId,
        'name': _popularPlaces[_random.nextInt(_popularPlaces.length)],
        'image': _getRandomImage(),
        'rating': (_random.nextDouble() * 1.5) + 3.5,
        'address': _faker.address.streetAddress(),
      });
    }
    try {
      await _supabase.from('favorites').insert(favorites);
      print("✅ $count adet favori eklendi.");
    } catch (e) {
      print("❌ Favori ekleme hatası: $e");
    }
  }

  // --- 4. NOTLAR ---
  Future<void> seedNotes(int count) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    List<Map<String, dynamic>> notes = [];
    for (int i = 0; i < count; i++) {
      notes.add({
        'user_id': userId,
        'place_name': _popularPlaces[_random.nextInt(_popularPlaces.length)], 
        'content': "Wifi şifresi: 12345678. " + _faker.lorem.sentence(),
        'date': _faker.date.dateTime(minYear: 2024).toIso8601String(),
      });
    }
    try {
      await _supabase.from('notes').insert(notes);
      print("✅ $count adet not eklendi.");
    } catch (e) {
      print("❌ Not ekleme hatası: $e");
    }
  }

  // --- 5. GÖREVLER (Quests) ---
  Future<void> seedQuests(int count) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    List<Map<String, dynamic>> quests = [];
    final titles = ["Kahve Kaşifi", "Şehir Rehberi", "Sosyal Kelebek", "Gurme"];
    final subtitles = ["5 farklı 3. dalga kahveci keşfet", "10 check-in yap", "3 arkadaşını davet et", "5 detaylı yorum yaz"];

    for (int i = 0; i < count; i++) {
      int r = _random.nextInt(titles.length);
      quests.add({
        'user_id': userId,
        'title': titles[r],
        'subtitle': subtitles[r],
        'progress': _random.nextInt(80) + 10,
      });
    }
    try {
      await _supabase.from('quests').insert(quests);
      print("✅ $count adet görev eklendi.");
    } catch (e) {
      print("❌ Görev ekleme hatası: $e");
    }
  }

  // --- ANA ÇALIŞTIRMA FONKSİYONU ---
  Future<void> seedAll() async {
    print("⏳ Veri tabanı dolduruluyor...");
    await createFakeProfile();
    await seedPosts(20);      // Sık uğrananlar ve Activity için bol veri
    await seedFavorites(4);   
    await seedNotes(3);       
    await seedQuests(2);      
    print("🎉 TÜM İŞLEMLER TAMAMLANDI!");
  }
}