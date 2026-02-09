import 'dart:ui' as ui; // ImageFilter için
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import '../main.dart'; // Gerek kalmadı, instance üzerinden alıyoruz

// CORE IMPORTLARI
import '../core/theme_styles.dart'; 
import '../core/app_strings.dart'; 

// WIDGETLAR
import '../widgets/map/balloon_menu.dart'; 
import '../widgets/map/map_floating_buttons.dart';
import '../widgets/map/info_sheets.dart'; 
import '../widgets/search/search_modal_content.dart'; 

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  // 🔥 SUPABASE CLIENT
  final _supabase = Supabase.instance.client;
  
  final MapController _mapController = MapController();
  
  // Menü Animasyon
  late AnimationController _menuController;
  late Animation<double> _scaleAnimation;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _scaleAnimation = CurvedAnimation(parent: _menuController, curve: Curves.easeInOutBack);
  }

  @override
  void dispose() {
    _menuController.dispose();
    _mapController.dispose(); 
    super.dispose();
  }

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

  // --- ARAMA MODALINI AÇ ---
  void _openSearchModal() async {
    HapticFeedback.mediumImpact();
    if (_isMenuOpen) _toggleMenu();

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (context) => const SearchModalContent(),
    );

    // Sonuca git
    if (result != null && result is Map) {
      double? lat = _guvenliSayiAl(result['lat']);
      double? lng = _guvenliSayiAl(result['lng']);
      
      if (lat != null && lng != null) {
        _mapController.move(LatLng(lat, lng), 17);
        
        // Kartı göster
        if (result['type'] == 'place') {
            Future.delayed(const Duration(milliseconds: 500), () {
              if(mounted) InfoSheets.showPlaceCard(context, result['data'], result['id']);
            });
        } else if (result['type'] == 'user') {
            Future.delayed(const Duration(milliseconds: 500), () {
              if(mounted) InfoSheets.showUserCard(context, result['data'], result['id']);
            });
        }
      }
    }
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
    _mapController.move(LatLng(position.latitude, position.longitude), 15);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // 🔥 Supabase Auth ID
    String? myUid = _supabase.auth.currentUser?.id;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. HARİTA KATMANI
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(41.0082, 28.9784), // İstanbul
              initialZoom: 14.0,
              onTap: (_, __) {
                if (_isMenuOpen) _toggleMenu();
              },
            ),
            children: [
              // 🔥 DİNAMİK HARİTA STİLİ (DARK/LIGHT)
              TileLayer(
                urlTemplate: isDark 
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png' 
                    : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', 
                userAgentPackageName: 'com.example.neer',
                retinaMode: RetinaMode.isHighDensity(context),
              ),
              
              // 🔥 SUPABASE MEKANLAR KATMANI
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _supabase.from('places').stream(primaryKey: ['id']),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  
                  final places = snapshot.data!;
                  
                  return MarkerLayer(
                    markers: places.map((data) {
                      // Güvenli veri çekimi
                      double? lat = _guvenliSayiAl(data['latitude']);
                      double? lng = _guvenliSayiAl(data['longitude']);
                      
                      if (lat == null || lng == null) return const Marker(point: LatLng(0,0), child: SizedBox());
                      
                      return Marker(
                        point: LatLng(lat, lng), width: 60, height: 70, 
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            InfoSheets.showPlaceCard(context, data, data['id'].toString());
                          },
                          child: _buildCustomPlaceMarker(data['category'] ?? "Mekan", theme),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              // 🔥 SUPABASE KULLANICILAR KATMANI
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _supabase.from('profiles').stream(primaryKey: ['id']),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  
                  final users = snapshot.data!;
                  
                  // Benim arkadaş listemi bul
                  List<dynamic> myFriends = [];
                  if (myUid != null) {
                    try {
                      final myProfile = users.firstWhere((u) => u['id'] == myUid, orElse: () => {});
                      if (myProfile.isNotEmpty) {
                        myFriends = myProfile['friends'] ?? [];
                      }
                    } catch (e) {
                      // Hata olursa boş liste
                    }
                  }

                  return MarkerLayer(
                    markers: users.map((data) {
                      String userId = data['id'].toString();
                      bool isAnonymous = data['is_anonymous'] ?? false; // Snake case
                      bool isMe = userId == myUid;

                      // Gizlilik Kuralları
                      // 1. Kendim değilsem ve o kişi anonimse -> Gösterme
                      if (!isMe && isAnonymous) return const Marker(point: LatLng(0,0), child: SizedBox());
                      // 2. Kendim değilsem ve arkadaşım değilse -> Gösterme
                      if (!isMe && !myFriends.contains(userId)) return const Marker(point: LatLng(0,0), child: SizedBox());

                      double? lat = _guvenliSayiAl(data['latitude']);
                      double? lng = _guvenliSayiAl(data['longitude']);
                      
                      if (lat == null || lng == null) return const Marker(point: LatLng(0,0), child: SizedBox());
                      
                      return Marker(
                        point: LatLng(lat, lng), width: 60, height: 60,
                        child: GestureDetector(
                          onTap: () { 
                            HapticFeedback.lightImpact();
                            // Kendi kartımı açmayayım, sadece başkasını
                            if (!isAnonymous && !isMe) InfoSheets.showUserCard(context, data, userId);
                          },
                          child: _buildCustomUserMarker(data['avatar_url'], isMe, isAnonymous, theme),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),

          // 2. LOGO (SOL ÜST - GLASS)
          Positioned(
            top: topPadding + 24,
            left: 20,
                  child: Text(
                    AppStrings.appName, // "neer"
                    style: TextStyle(
                      fontFamily: 'Visby', 
                      fontSize: 32, 
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : theme.primaryColor, 
                      letterSpacing: -1.5,
                      shadows: [
                        Shadow(color: isDark ? Colors.black54 : Colors.white54, blurRadius: 10, offset: const Offset(0, 2))
                      ]
                    ),
                  ),
                ),
              
          // 3. MENÜ BUTONU (SAĞ ÜST - GLASS)
          Positioned(
            top: topPadding + 24,
            right: 20,
            child: StreamBuilder<List<Map<String, dynamic>>>(
              // 🔥 DÜZELTME: .eq('is_read', false) kaldırıldı.
              // Sadece bu kullanıcıya ait bildirimleri dinliyoruz.
              stream: myUid != null 
                  ? _supabase
                      .from('notifications')
                      .stream(primaryKey: ['id'])
                      .eq('user_id', myUid)
                  : const Stream.empty(),
              builder: (context, snapshot) {
                // 🔥 DÜZELTME: Filtrelemeyi burada (Dart tarafında) yapıyoruz.
                // Listede 'is_read' == false olan herhangi bir öğe var mı?
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
                                color: isDark ? Colors.white : theme.primaryColor,
                                size: 26,
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
                                color: Colors.redAccent, 
                                shape: BoxShape.circle, 
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

          // 4. MENÜ İÇERİĞİ (BALON)
          Positioned(
            top: topPadding + 84, 
            right: 20, 
            child: BalloonMenu(
              isOpen: _isMenuOpen,
              scaleAnimation: _scaleAnimation,
              onToggleMenu: _toggleMenu,
            ),
          ),

          // 5. ALT BUTONLAR (ARAMA + KONUM)
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

  // --- MARKER WIDGETLARI ---
  Widget _buildCustomUserMarker(String? imageUrl, bool isMe, bool isAnonymous, ThemeData theme) {
    Color borderColor = isMe ? const Color(0xFF00E5FF) : const Color(0xFF34C759); // Mavi (Ben) / Yeşil (Arkadaş)
    if (isAnonymous) borderColor = Colors.deepPurpleAccent;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Dış Hale (Glow)
        Container(
          width: 52, height: 52, 
          decoration: BoxDecoration(
            shape: BoxShape.circle, 
            color: borderColor.withOpacity(0.2), 
            boxShadow: [BoxShadow(color: borderColor.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)]
          )
        ),
        // İç Resim
        Container(
          width: 46, height: 46, 
          decoration: BoxDecoration(
            shape: BoxShape.circle, 
            border: Border.all(color: borderColor, width: 2.5), 
            color: theme.cardColor
          ), 
          child: isAnonymous || imageUrl == null || imageUrl.isEmpty 
              ? Center(child: Icon(isAnonymous ? Icons.visibility_off_rounded : Icons.person_rounded, color: theme.disabledColor, size: 24)) 
              : ClipOval(child: Image.network(imageUrl, fit: BoxFit.cover))
        ),
      ],
    );
  }

  Widget _buildCustomPlaceMarker(String category, ThemeData theme) {
    IconData icon;
    // Kategoriye göre ikon seçimi
    switch (category.toLowerCase()) {
      case 'kafe': icon = Icons.coffee_rounded; break;
      case 'yemek': icon = Icons.restaurant_rounded; break;
      case 'bar': icon = Icons.nightlife_rounded; break;
      case 'sanat': icon = Icons.palette_rounded; break;
      case 'spor': icon = Icons.fitness_center_rounded; break;
      default: icon = Icons.store_mall_directory_rounded;
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44, height: 44, 
          decoration: BoxDecoration(
            color: theme.primaryColor, // Bordo arka plan
            shape: BoxShape.circle, 
            border: Border.all(color: Colors.white, width: 2), 
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))]
          ), 
          child: Icon(icon, color: Colors.white, size: 22)
        ),
        // Küçük üçgen ok
        ClipPath(clipper: _TriangleClipper(), child: Container(color: theme.primaryColor, width: 8, height: 6))
      ],
    );
  }
}

class _TriangleClipper extends CustomClipper<ui.Path> {
  @override
  ui.Path getClip(Size size) {
    final path = ui.Path();
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper<ui.Path> oldClipper) => false;
}