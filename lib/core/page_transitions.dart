import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// iOS tarzı sağdan sola kayma geçişi.
///
/// GoRouter route'larında kullanım:
/// ```dart
/// GoRoute(
///   path: '/settings',
///   pageBuilder: (context, state) => buildSlideTransition(
///     context, state, const SettingsScreen(),
///   ),
/// )
/// ```
CustomTransitionPage<T> buildSlideTransition<T>(
  BuildContext context,
  GoRouterState state,
  Widget child, {
  Duration duration = const Duration(milliseconds: 300),
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Primary: yeni sayfa sağdan giriyor
      final slideIn = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ));

      // Secondary: eski sayfa hafifçe sola kayıyor
      final slideOut = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.3, 0.0),
      ).animate(CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ));

      return SlideTransition(
        position: slideOut,
        child: SlideTransition(
          position: slideIn,
          child: child,
        ),
      );
    },
  );
}

/// Alttan yukarı kayma geçişi (modal benzeri).
///
/// Bottom sheet tarzı sayfalar için kullanılır.
CustomTransitionPage<T> buildModalTransition<T>(
  BuildContext context,
  GoRouterState state,
  Widget child, {
  Duration duration = const Duration(milliseconds: 350),
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ));

      final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        ),
      );

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: child,
        ),
      );
    },
  );
}

/// Fade geçişi (sakin, yumuşak geçiş).
///
/// Login → Home gibi büyük context değişimlerinde kullanılır.
CustomTransitionPage<T> buildFadeTransition<T>(
  BuildContext context,
  GoRouterState state,
  Widget child, {
  Duration duration = const Duration(milliseconds: 400),
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}
