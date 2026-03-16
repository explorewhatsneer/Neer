import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../models/place_model.dart';
import '../../services/supabase_service.dart';
import 'map_markers.dart';

/// map_screen.dart'ın veri yükleme fonksiyonlarını ayıran mixin.
/// Bu mixin _MapScreenState'e eklenerek kullanılır.
mixin MapDataMixin<T extends StatefulWidget> on State<T> {
  // Subclass'ın tanımlaması gereken
  SupabaseService get service;
  MapController get mapController;

  // State
  List<PlaceModel> places = [];
  List<Marker> peopleMarkers = [];
  List<Marker> tempFriendMarkers = [];
  final Map<Marker, String> markerImageMap = {};
  LatLng? myLocation;
  String? profileImage;
  bool isLoading = false;
  Timer? debounceTimer;

  // ══════════════════════════════════
  // VERİ YÜKLEME
  // ══════════════════════════════════

  /// Kendi konumumu al ve DB'ye kaydet
  Future<void> updateMyLocation() async {
    try {
      final myId = service.client.auth.currentUser?.id;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      if (mounted) {
        setState(() {
          myLocation = LatLng(position.latitude, position.longitude);
        });
        rebuildPeopleMarkers();
      }

      if (myId == null) return;
      await service.updateLocation(myId, position.latitude, position.longitude);
    } catch (e) {
      debugPrint("Konum güncelleme hatası: $e");
    }
  }

  /// Profil resmimi çek
  Future<void> fetchMyProfileImage() async {
    try {
      final myId = service.client.auth.currentUser?.id;
      if (myId == null) return;

      final data = await service.getProfileFields(myId, 'avatar_url');
      if (mounted && data != null && data['avatar_url'] != null) {
        setState(() {
          profileImage = data['avatar_url'];
        });
        rebuildPeopleMarkers();
      }
    } catch (e) {
      debugPrint("Profil resmi çekme hatası: $e");
    }
  }

  /// Arkadaşları çek ve marker oluştur
  Future<void> fetchMutualFriends() async {
    final myId = service.client.auth.currentUser?.id;
    if (myId == null) return;

    try {
      final response = await service.getMutualFriendsLocations(myId);
      if (!mounted) return;

      List<Marker> newMarkers = [];

      for (var friend in response) {
        double lat = _safeDouble(friend['latitude']) ?? 0.0;
        double lng = _safeDouble(friend['longitude']) ?? 0.0;
        String avatarUrl = friend['avatar_url'] ?? '';
        String userId = friend['id'].toString();

        Marker marker = Marker(
          point: LatLng(lat, lng),
          width: 60, height: 75,
          child: FriendAvatarMarker(friend: friend, userId: userId),
        );

        newMarkers.add(marker);
        markerImageMap[marker] = avatarUrl;
      }

      tempFriendMarkers = newMarkers;
      rebuildPeopleMarkers();
    } catch (e) {
      debugPrint("Arkadaşları çekerken hata: $e");
    }
  }

  /// Ben + Arkadaşlar marker listesini birleştir
  void rebuildPeopleMarkers() {
    if (!mounted) return;

    List<Marker> combined = [];

    if (myLocation != null) {
      Marker myMarker = Marker(
        point: myLocation!,
        width: 60, height: 60,
        child: MyLocationMarker(profileImage: profileImage),
      );
      combined.add(myMarker);
      markerImageMap[myMarker] = profileImage ?? '';
    }

    combined.addAll(tempFriendMarkers);

    setState(() {
      peopleMarkers = combined;
    });
  }

  /// Yakın mekanları çek (debounced)
  Future<void> fetchNearbyPlaces() async {
    if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();

    debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;

      try {
        final center = mapController.camera.center;

        final response = await service.getNearbyPlaces(
          lat: center.latitude,
          lng: center.longitude,
          radiusKm: 5.0,
        );

        List<PlaceModel> tempPlaces = [];
        for (var item in response) {
          tempPlaces.add(PlaceModel.fromMap(item));
        }

        if (mounted) {
          setState(() {
            places = tempPlaces;
            isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Mekan çekme hatası: $e");
        if (mounted) setState(() => isLoading = false);
      }
    });
  }

  // ══════════════════════════════════
  // YARDIMCI
  // ══════════════════════════════════

  double? _safeDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  void disposeMapData() {
    debounceTimer?.cancel();
  }
}
