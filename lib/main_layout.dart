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

  // Scroll-aware collapse — tüm ekranlardan gelen scroll yönü
  final ValueNotifier<bool> _navCollapsed = ValueNotifier(false);
  double _lastScrollPixels = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const MapScreen(),
      const ChatListScreen(),
      const FeedScreen(),
      const CatchScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _navCollapsed.dispose();
    super.dispose();
  }

  void _onTabChange(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick();
      // Tab değiştiğinde navbar'ı aç
      _navCollapsed.value = false;
      _lastScrollPixels = 0;
      setState(() {
        _previousIndex = _currentIndex;
        _currentIndex = index;
      });
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final pixels = notification.metrics.pixels;
      final delta = pixels - _lastScrollPixels;
      _lastScrollPixels = pixels;

      // Post-frame to avoid setting ValueNotifier during build
      if (delta > 6 && !_navCollapsed.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _navCollapsed.value = true;
        });
      } else if (delta < -4 && _navCollapsed.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _navCollapsed.value = false;
        });
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bool slideRight = _currentIndex > _previousIndex;

    return GradientScaffold(
      body: OfflineAwareBody(
        child: Stack(
          children: [
            // Animasyonlu sayfa geçişi + scroll dinleme
            NotificationListener<ScrollNotification>(
              onNotification: _handleScrollNotification,
              child: AnimatedSwitcher(
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
            ),

            // Navbar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomNavBar(
                activeIndex: _currentIndex,
                onTabChange: _onTabChange,
                shouldCollapse: _navCollapsed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
