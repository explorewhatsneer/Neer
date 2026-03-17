import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// WIDGETLAR
import 'screens/custom_navbar.dart';
import 'widgets/common/offline_banner.dart';

// EKRANLAR
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/catch_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Başlangıç sayfası: 2 (MapScreen - Ortadaki)
  int _currentIndex = 2;

  // Sayfaların Listesi (Sıralama Navbar ikonlarıyla aynı olmalı)
  // 0: Profil, 1: Sohbet, 2: Harita, 3: Akış, 4: Catch
  final List<Widget> _screens = [
    const ProfileScreen(),
    const ChatListScreen(),
    const MapScreen(),
    const FeedScreen(),
    const CatchScreen(),
  ];

  void _onTabChange(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent, // Global gradient main.dart builder'dan gelir
      resizeToAvoidBottomInset: false,
      body: OfflineAwareBody(
        child: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
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
      ),
    );
  }
}
