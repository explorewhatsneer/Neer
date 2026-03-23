## BÖLÜM 6: PROFILE SCREEN TAB 1 — `profile_screen.dart`

### 6.1 İçerik Hiyerarşisi (SIRAYA UYMAK ZORUNLU)
1. Bento Dashboard (quest + not + yorum)
2. Neer Kimliği kartı
3. Rozet Vitrini
4. Görevler Preview
5. Favoriler (Stacked Carousel)
6. Sık Uğrananlar (A Tasarımı)

### 6.2 SupabaseService Yeni Metodlar
`supabase_service.dart`'a ekle:

```dart
// Kullanıcı rozetleri
Future<List<Map<String, dynamic>>> getUserBadges(String uid) async {
  try {
    final response = await _supabase
        .from('user_badges')
        .select('*, badge_definitions(*)')
        .eq('user_id', uid)
        .order('earned_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  } catch (e) { return []; }
}

// Tüm rozet tanımları
Future<List<Map<String, dynamic>>> getAllBadgeDefinitions() async {
  try {
    final response = await _supabase
        .from('badge_definitions')
        .select()
        .order('sort_order');
    return List<Map<String, dynamic>>.from(response);
  } catch (e) { return []; }
}

// Aktif görevler
Future<List<Map<String, dynamic>>> getUserActiveQuests(String uid) async {
  try {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
    final weekNum = _getWeekNumber(today);
    final weekStr = '${today.year}-W${weekNum.toString().padLeft(2,'0')}';

    final response = await _supabase
        .from('quest_definitions')
        .select('*, user_quests!left(progress, is_completed, period)')
        .order('sort_order');
    return List<Map<String, dynamic>>.from(response);
  } catch (e) { return []; }
}

// Neer Kimliği istatistikleri
Future<Map<String, dynamic>> getUserIdentityStats(String uid) async {
  try {
    final result = await _supabase.rpc('get_user_identity_stats', params: {'target_uid': uid});
    return Map<String, dynamic>.from(result as Map);
  } catch (e) { return {'total_places': 0, 'total_photos': 0, 'active_days': 0}; }
}

// Isı haritası
Future<List<Map<String, dynamic>>> getUserHeatmapPoints(String uid, {String period = 'all'}) async {
  try {
    final result = await _supabase.rpc('get_user_heatmap_points', params: {
      'target_uid': uid,
      'period_filter': period,
    });
    return List<Map<String, dynamic>>.from(result);
  } catch (e) { return []; }
}

// Quest ilerleme güncelle
Future<Map<String, dynamic>> updateQuestProgress(String uid, String questId, {int increment = 1}) async {
  try {
    final result = await _supabase.rpc('update_quest_progress', params: {
      'p_user_id': uid,
      'p_quest_id': questId,
      'p_increment': increment,
    });
    return Map<String, dynamic>.from(result as Map);
  } catch (e) { return {}; }
}

int _getWeekNumber(DateTime date) {
  final startOfYear = DateTime(date.year, 1, 1);
  final dayOfYear = date.difference(startOfYear).inDays;
  return ((dayOfYear + startOfYear.weekday - 1) / 7).ceil();
}
```

