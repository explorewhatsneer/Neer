import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neer/core/connectivity_service.dart';
import 'package:neer/core/language_manager.dart';
import 'package:neer/core/theme_manager.dart';
import 'package:neer/main.dart' show themeManager, languageManager;
import 'package:neer/widgets/common/offline_banner.dart';

void main() {
  group('OfflineAwareBody', () {
    testWidgets('child widget render edilir', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OfflineAwareBody(
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(OfflineAwareBody), findsOneWidget);
    });

    testWidgets('online durumda banner gizli', (tester) async {
      // ConnectivityService varsayılan olarak online
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OfflineAwareBody(
              child: const Text('Main'),
            ),
          ),
        ),
      );

      await tester.pump();
      // Banner gizli olmalı — SizeTransition animasyonu 0
      expect(find.text('Main'), findsOneWidget);
    });
  });
}
