import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback

// WIDGETLAR
import 'screens/custom_navbar.dart'; // 🔥 Daha önce oluşturduğumuz widget

// EKRANLAR
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/feed_screen.dart';   
import 'screens/friends_screen.dart'; 

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Başlangıç sayfası: 2 (MapScreen - Ortadaki)
  int _currentIndex = 2;

  // Sayfaların Listesi (Sıralama Navbar ikonlarıyla aynı olmalı)
  // 0: Profil, 1: Sohbet, 2: Harita, 3: Akış, 4: Arkadaşlar
  final List<Widget> _screens = [
    const ProfileScreen(),    
    const ChatListScreen(),   
    const MapScreen(),        
    const FeedScreen(),       
    const FriendsScreen(),    
  ];

  void _onTabChange(int index) {
    if (_currentIndex != index) {
      // Sekme değişirken hafif titreşim ver
      HapticFeedback.selectionClick();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true, // Navbar'ın arkasına içerik uzanabilsin (Glass effect ve yuvarlak kavis için şart)
      backgroundColor: theme.scaffoldBackgroundColor, // Dinamik zemin rengi
      
      // Klavye açıldığında Navbar'ın yukarı zıplamasını engellemek için false yapıyoruz.
      // (Chat ekranı gibi sayfalar kendi içlerinde Scaffold kullanarak klavyeyi yönetir)
      resizeToAvoidBottomInset: false, 
      
      body: Stack(
        children: [
          // 1. EKRANLAR (Durumu korumak için IndexedStack kullanıyoruz, böylece harita her seferinde yeniden yüklenmez)
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // 2. SABİT NAVBAR (En Üst Katman)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomNavBar(
              activeIndex: _currentIndex, 
              onTabChange: _onTabChange,  
            ),
          ),
        ],
      ),
    );
  }
}