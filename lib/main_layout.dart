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
  int _currentIndex = 2;
  int _previousIndex = 2;

  final List<Widget> _screens = const [
    ProfileScreen(),
    ChatListScreen(),
    MapScreen(),
    FeedScreen(),
    CatchScreen(),
  ];

  void _onTabChange(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _previousIndex = _currentIndex;
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Geçiş yönü: sola mı sağa mı kayıyor
    final bool slideRight = _currentIndex > _previousIndex;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: OfflineAwareBody(
        child: Stack(
          children: [
            // Animasyonlu sayfa geçişi
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                // Sadece yeni ekranı fade+slide ile getir
                final slideOffset = Tween<Offset>(
                  begin: Offset(slideRight ? 0.05 : -0.05, 0),
                  end: Offset.zero,
                );
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: slideOffset.animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(_currentIndex),
                child: _screens[_currentIndex],
              ),
            ),

            // Navbar
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
