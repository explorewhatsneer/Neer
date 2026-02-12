import 'dart:async'; // Timer (Debounce) için gerekli
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

// 🔥 CORE IMPORTLAR
import '../core/theme_styles.dart'; 
import '../core/app_strings.dart'; 
import '../core/constants.dart'; // AppColors için
import '../models/place_model.dart'; 

// WIDGET IMPORTLARI
import '../widgets/map/balloon_menu.dart'; 
import '../widgets/map/map_floating_buttons.dart';
import '../widgets/map/info_sheets.dart'; 
import '../widgets/search/search_modal_content.dart'; 
import '../widgets/map/map_styles.dart'; 

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  final MapController _mapController = MapController();
  
  // 🔥 LİSTELER VE KONUM
  List<PlaceModel> _places = [];
  List<Marker> _friendMarkers = []; 
  LatLng? _myLocation; 
  String? profileImage; // 👤 Kendi profil resmimiz için değişken
  
  bool _isLoading = false;
  Timer? _debounceTimer; 
  
  // 🔍 Zoom Durumu (Başlangıç 14)
  double _currentZoom = 14.0;
  int _lastZoomInt = 14; 

  // Menü Animasyon
  late AnimationController _menuController;
  late Animation<double> _scaleAnimation;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _scaleAnimation = CurvedAnimation(parent: _menuController, curve: Curves.easeInOutBack);
    
    // Açılış işlemleri
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMyLocation(); 
      _fetchMyProfileImage(); // 👤 Profil resmini çek
      _fetchMutualFriends(); 
      _fetchNearbyPlaces(); 
    });
  }

  @override
  void dispose() {
    _menuController.dispose();
    _mapController.dispose(); 
    _debounceTimer?.cancel();
    super.dispose();
  }

  // --- 📡 1. Kendi Konumumu Al ve Güncelle ---
  Future<void> _updateMyLocation() async {
    try {
      final myId = _supabase.auth.currentUser?.id;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      if (mounted) {
        setState(() {
          _myLocation = LatLng(position.latitude, position.longitude);
        });
      }

      if (myId == null) return;

      // Veritabanına kaydet
      await _supabase.from('profiles').update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'last_location_update': DateTime.now().toIso8601String(),
      }).eq('id', myId);
      
    } catch (e) {
      debugPrint("Konum güncelleme hatası: $e");
    }
  }

  // 👤 Kendi Profil Resmimi Çek
  Future<void> _fetchMyProfileImage() async {
    try {
      final myId = _supabase.auth.currentUser?.id;
      if (myId == null) return;

      final data = await _supabase.from('profiles').select('avatar_url').eq('id', myId).single();
      if (mounted && data['avatar_url'] != null) {
        setState(() {
          profileImage = data['avatar_url'];
        });
      }
    } catch (e) {
      debugPrint("Profil resmi çekme hatası: $e");
    }
  }

  // --- 📡 2. Arkadaşları Çek ---
  Future<void> _fetchMutualFriends() async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    try {
      final List<dynamic> response = await _supabase
          .rpc('get_mutual_friends_locations', params: {'my_id': myId});

      if (!mounted) return;

      setState(() {
        _friendMarkers = response.map((friend) {
          double lat = _guvenliSayiAl(friend['latitude']) ?? 0.0;
          double lng = _guvenliSayiAl(friend['longitude']) ?? 0.0;

          // Arkadaş markerlarını oluşturuyoruz
          return Marker(
            point: LatLng(lat, lng),
            width: 60, height: 75,
            child: _buildFriendAvatarMarker(friend),
          );
        }).toList();
      });
    } catch (e) {
      debugPrint("Arkadaşları çekerken hata: $e");
    }
  }

  // --- 📡 3. Mekanları Çek ---
  Future<void> _fetchNearbyPlaces() async {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;

      try {
        final center = _mapController.camera.center;
        
        final List<dynamic> response = await _supabase.rpc(
          'get_nearby_places',
          params: {
            'lat': center.latitude,
            'long': center.longitude,
            'radius_meters': 5000.0,
          },
        );

        List<PlaceModel> tempPlaces = [];
        for (var item in response) {
          tempPlaces.add(PlaceModel.fromMap(item));
        }

        if (mounted) {
          setState(() {
            _places = tempPlaces;
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Mekan çekme hatası: $e");
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  // --- 🎨 MARKER TASARIMLARI ---

  // 🔥 1. MEKAN: Mini Nokta (Orta Mesafe Zoom İçin)
  Widget _buildMiniDot(String category) {
    Color color = getCategoryColor(category);
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 1))
        ]
      ),
    );
  }

  // 🔥 2. MEKAN: Premium Pin (Yakın Zoom İçin)
  Widget _buildPremiumPin(PlaceModel place) {
    Color color = getCategoryColor(place.category);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Map<String, dynamic> dataMap = {
             'name': place.name,
             'category': place.category,
             'image': place.image,
             'average_rating': place.averageRating,
             'latitude': place.latitude,
             'longitude': place.longitude,
        };
        InfoSheets.showPlaceCard(context, dataMap, place.id.toString());
      },
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Damla Şekli
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color, // Kategori rengi
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
              ],
            ),
            child: Icon(getCategoryIcon(place.category), color: Colors.white, size: 22),
          ),
          // Altındaki Üçgen Uç
          Positioned(
            bottom: 12, 
            child: ClipPath(
              clipper: TriangleClipper(),
              child: Container(color: color, width: 12, height: 10),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 3. ARKADAŞ MARKER (YEŞİL ÇERÇEVE 🟢)
  Widget _buildFriendAvatarMarker(dynamic friend) {
    String avatarUrl = friend['avatar_url'] ?? '';
    String userId = friend['id'].toString();
    
    // 🟢 Arkadaş rengi: Yeşil
    const Color friendColor = Color(0xFF4CAF50); 

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        InfoSheets.showUserCard(context, friend, userId);
      },
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Çerçeve ve Avatar
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: friendColor, // YEŞİL
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
              ],
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey[900],
              backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            ),
          ),
          // Altındaki Üçgen
          Positioned(
            bottom: 22, // Konum ayarı
            child: ClipPath(
              clipper: TriangleClipper(),
              child: Container(color: friendColor, width: 10, height: 8), // YEŞİL OK
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 4. KENDİ KONUMUM (MAVİ ÇERÇEVE + FOTOĞRAF 🔵👤)
  Widget _buildMyLocationMarker() {
    // 🔵 Benim rengim: Mavi
    const Color myColor = Colors.blue;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Arka plandaki yanıp sönen hare (Pulse Effect)
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: myColor.withOpacity(0.25), 
            shape: BoxShape.circle,
          ),
        ),
        // Ana Çerçeve
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: Colors.white, 
            shape: BoxShape.circle, 
            border: Border.all(color: myColor, width: 3), // MAVİ ÇERÇEVE
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))
            ]
          ),
          child: Padding(
            padding: const EdgeInsets.all(0), // Beyaz boşluk
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              // Fotoğraf varsa göster, yoksa ikon göster
              backgroundImage: profileImage != null ? NetworkImage(profileImage!) : null,
              child: profileImage == null 
                  ? const Icon(Icons.person, color: Colors.grey) 
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  // --- YARDIMCI FONKSİYONLAR ---

  void _toggleMenu() {
    HapticFeedback.selectionClick(); 
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _menuController.forward();
      } else {
        _menuController.reverse();
      }
    });
  }

  double? _guvenliSayiAl(dynamic deger) {
    if (deger == null) return null;
    if (deger is double) return deger;
    if (deger is int) return deger.toDouble();
    if (deger is String) return double.tryParse(deger);
    return null;
  }

  Future<void> _kendiKonumumaGit() async {
    HapticFeedback.selectionClick();
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.mapLocationPermission)));
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    Position position = await Geolocator.getCurrentPosition();
    
    // Hem haritayı odakla hem de konumu güncelle
    _mapController.move(LatLng(position.latitude, position.longitude), 16);
    _updateMyLocation(); 
    _fetchNearbyPlaces();
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
      double? lat = _guvenliSayiAl(result['lat']);
      double? lng = _guvenliSayiAl(result['lng']);
      
      if (lat != null && lng != null) {
        _mapController.move(LatLng(lat, lng), 17);
        _fetchNearbyPlaces(); 
        
        if (result['type'] == 'place') {
            Future.delayed(const Duration(milliseconds: 800), () {
              if(mounted) InfoSheets.showPlaceCard(context, result['data'], result['id']);
            });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    String? myUid = _supabase.auth.currentUser?.id;
    final topPadding = MediaQuery.of(context).padding.top;

    // 🔥 MAP LOJİĞİ: ZOOM SEVİYESİNE GÖRE GÖSTERİM 🔥
    // 12'den küçükse hiçbir mekan gösterme
    bool showDotsOnly = _currentZoom >= 14.0 && _currentZoom < 16.0;
    bool showClustersAndPins = _currentZoom >= 16.0;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. HARİTA KATMANI
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(41.0082, 28.9784),
              initialZoom: 14.0,
              onTap: (_, __) { if (_isMenuOpen) _toggleMenu(); },
              
              // 🔥 Zoom ve Konum Takibi
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) _fetchNearbyPlaces();
                
                if (position.zoom != null) {
                   // Sadece tam sayı değiştiğinde setState yap (Performans)
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

              // 🔥 KATMAN A: MEKANLAR (NOKTA MODU - Kümeleme YOK)
              // Sadece 12 ile 14.5 zoom arasındayken çalışır.
              if (showDotsOnly)
                MarkerLayer(
                  markers: _places.map((place) => Marker(
                    point: LatLng(place.latitude, place.longitude),
                    width: 14, height: 14,
                    child: _buildMiniDot(place.category),
                  )).toList(),
                ),

              // 🔥 KATMAN B: MEKANLAR (PIN MODU - Kümeleme VAR)
              // Sadece 14.5 zoom üzerindeyken çalışır.
              if (showClustersAndPins)
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 80, 
                    size: const Size(50, 50),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(50),
                    maxZoom: 17, 
                    
                    // Sadece mekanları kümeye sokuyoruz
                    markers: _places.map((place) => Marker(
                        point: LatLng(place.latitude, place.longitude),
                        width: 50, height: 60,
                        child: _buildPremiumPin(place)
                    )).toList(),

                    // Küme Tasarımı
                    builder: (context, markers) {
                      return PremiumCluster(count: markers.length, color: AppColors.primary);
                    },
                    
                    // Örümcek Ağı
                    animationsOptions: const AnimationsOptions(
                      zoom: Duration(milliseconds: 300),
                      fitBound: Duration(milliseconds: 300),
                    ),
                    zoomToBoundsOnClick: true, 
                    spiderfyCircleRadius: 100,
                  ),
                ),

              // 🔥 KATMAN C: ARKADAŞLAR (En Üstte - Bağımsız)
              // Bu katman her zaman, her zoom seviyesinde görünür ve asla kümelenmez.
              MarkerLayer(markers: _friendMarkers),

              // 🔥 KATMAN D: KENDİ KONUMUM (Mavi Çerçeveli & Fotoğraflı)
              if (_myLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _myLocation!,
                      width: 60, height: 60, // Biraz büyüttük (Eskisi 24'tü)
                      child: _buildMyLocationMarker(),
                    ),
                  ],
                ),
            ],
          ),

          // LOGO
          Positioned(
            top: topPadding + 24, left: 20,
            child: Text(
              AppStrings.appName,
              style: TextStyle(
                fontFamily: 'Visby', fontSize: 32, fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : theme.primaryColor, 
                letterSpacing: -1.5,
                shadows: [Shadow(color: isDark ? Colors.black54 : Colors.white54, blurRadius: 10, offset: const Offset(0, 2))]
              ),
            ),
          ),
          
          // LOADING
          if (_isLoading)
             Positioned(
              top: topPadding + 30, left: 120,
              child: const SizedBox(
                width: 20, height: 20, 
                child: CircularProgressIndicator(strokeWidth: 2)
              )
            ),

          // MENÜ BUTONU
          Positioned(
            top: topPadding + 24, right: 20,
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: myUid != null 
                  ? _supabase.from('notifications').stream(primaryKey: ['id']).eq('user_id', myUid).limit(10)
                  : const Stream.empty(),
              builder: (context, snapshot) {
                bool hasUnread = false;
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                   hasUnread = snapshot.data!.any((notification) => notification['is_read'] == false);
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
                                color: isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.7),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                                boxShadow: AppThemeStyles.shadowLow,
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
                                border: Border.all(color: Colors.white, width: 2)
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }
            ),
          ),

          // MENÜ İÇERİĞİ
          Positioned(
            top: topPadding + 84, right: 20, 
            child: BalloonMenu(isOpen: _isMenuOpen, scaleAnimation: _scaleAnimation, onToggleMenu: _toggleMenu),
          ),

          // ALT BUTONLAR
          Positioned(
            bottom: 110, right: 20,
            child: MapFloatingButtons(
              onLocationTap: _kendiKonumumaGit,
              onSearchTap: _openSearchModal,
            ),
          ),
        ],
      ),
    );
  }
}