import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:neer/core/page_transitions.dart';

void main() {
  group('Page Transitions', () {
    testWidgets('slide transition doğru render edilir', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.push('/second'),
                child: const Text('Go'),
              ),
            ),
          ),
          GoRoute(
            path: '/second',
            pageBuilder: (context, state) => buildSlideTransition(
              context,
              state,
              const Scaffold(body: Text('Second Page')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Second Page'), findsOneWidget);
    });

    testWidgets('modal transition doğru render edilir', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.push('/modal'),
                child: const Text('Open'),
              ),
            ),
          ),
          GoRoute(
            path: '/modal',
            pageBuilder: (context, state) => buildModalTransition(
              context,
              state,
              const Scaffold(body: Text('Modal Page')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Modal Page'), findsOneWidget);
    });

    testWidgets('fade transition doğru render edilir', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.push('/fade'),
                child: const Text('Fade'),
              ),
            ),
          ),
          GoRoute(
            path: '/fade',
            pageBuilder: (context, state) => buildFadeTransition(
              context,
              state,
              const Scaffold(body: Text('Fade Page')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.tap(find.text('Fade'));
      await tester.pumpAndSettle();

      expect(find.text('Fade Page'), findsOneWidget);
    });
  });
}
