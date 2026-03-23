import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// CORE
import 'core/neer_design_system.dart';

// WIDGETLAR
import 'screens/custom_navbar.dart';
import 'widgets/common/offline_banner.dart';

// EKRANLAR — YENİ SIRA: Map(0), Chat(1), Feed(2), Catch(3), Profile(4)
import 'screens/map_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/feed_screen.dart';
import 'screens/catch_screen.dart';
import 'screens/profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 2; // Feed (orta) başlangıç
  int _previousIndex = 2;

  // Her tab için ayrı ScrollController — NavBar dot animasyonu için
  final Map<int, ScrollController> _scrollControllers = {
    0: ScrollController(), // Harita
    1: ScrollController(), // Chat
    2: ScrollController(), // Feed
    3: ScrollController(), // Catch
    4: ScrollController(), // Profil
  };

  // YENİ SIRA: Map, Chat, Feed, Catch, Profile
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const MapScreen(),
      const ChatListScreen(),
      const FeedScreen(),
      const CatchScreen(),
      ProfileScreen(externalScrollController: _scrollControllers[4]),
    ];
  }

  @override
  void dispose() {
    for (final sc in _scrollControllers.values) {
      sc.dispose();
    }
    super.dispose();
  }

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
    final bool slideRight = _currentIndex > _previousIndex;

    return GradientScaffold(
      body: OfflineAwareBody(
        child: Stack(
          children: [
            // Animasyonlu sayfa geçişi
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
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

            // Navbar — scroll-aware dot animasyonu ile
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomNavBar(
                activeIndex: _currentIndex,
                onTabChange: _onTabChange,
                scrollController: _scrollControllers[_currentIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
