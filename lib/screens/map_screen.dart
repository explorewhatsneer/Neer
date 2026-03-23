import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

import '../services/supabase_service.dart';
import '../core/neer_design_system.dart';
import '../core/app_strings.dart';
import '../core/snackbar_helper.dart';

import '../widgets/map/balloon_menu.dart';
import '../widgets/map/map_floating_buttons.dart';
import '../widgets/map/info_sheets.dart';
import '../widgets/search/search_modal_content.dart';
import '../widgets/map/map_styles.dart';
import '../widgets/map/map_markers.dart';
import '../widgets/map/map_data_mixin.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin, MapDataMixin {

  @override
  SupabaseService get service => _service;
  @override
  MapController get mapController => _mapController;

  final _service = SupabaseService();
  final _mapController = MapController();

  // Zoom state
  double _currentZoom = 14.0;
  int _lastZoomInt = 14;

  // Menü animasyon
  late AnimationController _menuController;
  late Animation<double> _scaleAnimation;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _scaleAnimation = CurvedAnimation(parent: _menuController, curve: Curves.easeInOutBack);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateMyLocation();
      fetchMyProfileImage();
      fetchMutualFriends();
      fetchNearbyPlaces();
    });
  }

  @override
  void dispose() {
    _menuController.dispose();
    _mapController.dispose();
    disposeMapData();
    super.dispose();
  }

  // ══════════════════════════════════
  // AKSIYONLAR
  // ══════════════════════════════════

  void _toggleMenu() {
    HapticFeedback.selectionClick();
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      _isMenuOpen ? _menuController.forward() : _menuController.reverse();
    });
  }

  Future<void> _goToMyLocation() async {
    HapticFeedback.selectionClick();
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        AppSnackBar.warning(context, AppStrings.mapLocationPermission);
      }
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    Position position = await Geolocator.getCurrentPosition();
    _mapController.move(LatLng(position.latitude, position.longitude), 16);
    updateMyLocation();
    fetchNearbyPlaces();
  }

  void _openSearchModal() async {
    HapticFeedback.mediumImpact();
    if (_isMenuOpen) _toggleMenu();

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SearchModalContent(),
    );

    if (result != null && result is Map) {
      double? lat = _safeNum(result['lat']);
      double? lng = _safeNum(result['lng']);

      if (lat != null && lng != null) {
        _mapController.move(LatLng(lat, lng), 17);
        fetchNearbyPlaces();

        if (result['type'] == 'place') {
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) InfoSheets.showPlaceCard(context, result['data'], result['id']);
          });
        }
      }
    }
  }

  double? _safeNum(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // ══════════════════════════════════
  // BUILD
  // ══════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final myUid = service.client.auth.currentUser?.id;
    final topPadding = MediaQuery.of(context).padding.top;

    bool showDotsOnly = _currentZoom >= 14.0 && _currentZoom < 16.0;
    bool showClustersAndPins = _currentZoom >= 16.0;

    return GradientScaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ═══ HARİTA ═══
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(41.0082, 28.9784),
              initialZoom: 14.0,
              onTap: (_, __) { if (_isMenuOpen) _toggleMenu(); },
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) fetchNearbyPlaces();
                if (position.zoom != null) {
                  if (position.zoom!.toInt() != _lastZoomInt) {
                    setState(() {
                      _currentZoom = position.zoom!;
                      _lastZoomInt = position.zoom!.toInt();
                    });
                  } else {
                    _currentZoom = position.zoom!;
                  }
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: isDark
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'com.example.neer',
                retinaMode: RetinaMode.isHighDensity(context),
              ),

              // MEKAN: Mini dot (zoom 14-16)
              if (showDotsOnly)
                MarkerLayer(
                  markers: places.map((p) => Marker(
                    point: LatLng(p.latitude, p.longitude),
                    width: 14, height: 14,
                    child: MiniDotMarker(category: p.category),
                  )).toList(),
                ),

              // MEKAN: Premium pin + cluster (zoom 16+)
              if (showClustersAndPins)
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 80,
                    size: const Size(50, 50),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(50),
                    maxZoom: 17,
                    markers: places.map((p) => Marker(
                      point: LatLng(p.latitude, p.longitude),
                      width: 50, height: 60,
                      child: PremiumPinMarker(place: p),
                    )).toList(),
                    builder: (context, markers) => PremiumCluster(count: markers.length, color: NeerColors.primary),
                    animationsOptions: const AnimationsOptions(
                      zoom: Duration(milliseconds: 300),
                      fitBound: Duration(milliseconds: 300),
                    ),
                    zoomToBoundsOnClick: true,
                    spiderfyCircleRadius: 100,
                  ),
                ),

              // İNSAN: Ben + Arkadaşlar
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 60,
                  size: const Size(60, 60),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(50),
                  maxZoom: 19,
                  markers: peopleMarkers,
                  builder: (context, markers) {
                    List<String> images = [];
                    for (var m in markers) {
                      if (markerImageMap.containsKey(m)) images.add(markerImageMap[m]!);
                    }
                    return FloatingAvatarsCluster(imageUrls: images);
                  },
                  animationsOptions: const AnimationsOptions(
                    zoom: Duration(milliseconds: 300),
                    fitBound: Duration(milliseconds: 300),
                  ),
                  zoomToBoundsOnClick: true,
                  spiderfyCircleRadius: 80,
                ),
              ),
            ],
          ),

          // ═══ LOGO ═══
          Positioned(
            top: topPadding + 24, left: 20,
            child: Text(
              AppStrings.appName,
              style: TextStyle(
                fontFamily: 'Visby', fontSize: 32, fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : theme.primaryColor,
                letterSpacing: -1.5,
                shadows: [Shadow(color: isDark ? Colors.black54 : Colors.white54, blurRadius: 10, offset: const Offset(0, 2))],
              ),
            ),
          ),

          // ═══ LOADING ═══
          if (isLoading)
            Positioned(
              top: topPadding + 30, left: 120,
              child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            ),

          // ═══ MENÜ BUTONU ═══
          Positioned(
            top: topPadding + 24, right: 20,
            child: _buildMenuButton(theme, isDark, myUid),
          ),

          // ═══ MENÜ İÇERİĞİ ═══
          Positioned(
            top: topPadding + 84, right: 20,
            child: BalloonMenu(isOpen: _isMenuOpen, scaleAnimation: _scaleAnimation, onToggleMenu: _toggleMenu),
          ),

          // ═══ ALT BUTONLAR ═══
          Positioned(
            bottom: 110, right: 20,
            child: MapFloatingButtons(
              onLocationTap: _goToMyLocation,
              onSearchTap: _openSearchModal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(ThemeData theme, bool isDark, String? myUid) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: myUid != null ? service.streamNotifications(myUid) : const Stream.empty(),
      builder: (context, snapshot) {
        bool hasUnread = false;
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          hasUnread = snapshot.data!.any((n) => n['is_read'] == false);
        }

        return GestureDetector(
          onTap: _toggleMenu,
          child: SizedBox(
            width: 50, height: 50,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                        boxShadow: NeerShadows.soft(),
                      ),
                      child: Icon(
                        _isMenuOpen ? Icons.close_rounded : Icons.grid_view_rounded,
                        color: isDark ? Colors.white : theme.primaryColor, size: 26,
                      ),
                    ),
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    top: 0, right: 0,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: Colors.redAccent, shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
