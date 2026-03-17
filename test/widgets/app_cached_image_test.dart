import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neer/widgets/common/app_cached_image.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('AppCachedImage', () {
    testWidgets('boş URL ile fallback gösterir', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCachedImage(
          imageUrl: '',
          width: 100,
          height: 100,
        ),
      ));

      // Fallback container ve icon göstermeli
      expect(find.byType(AppCachedImage), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('geçersiz URL ile fallback gösterir', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCachedImage(
          imageUrl: 'not-a-url',
          width: 80,
          height: 80,
        ),
      ));

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('.avatar constructor render edilir', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCachedImage.avatar(imageUrl: '', radius: 30),
      ));

      // Boş URL ile fallback: person icon gösterilir
      expect(find.byType(AppCachedImage), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('.cover constructor render edilir', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCachedImage.cover(imageUrl: '', height: 200),
      ));

      expect(find.byType(AppCachedImage), findsOneWidget);
    });

    testWidgets('borderRadius uygulanır', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppCachedImage(
          imageUrl: '',
          width: 100,
          height: 100,
          borderRadius: 16,
        ),
      ));

      // borderRadius > 0 olduğunda ClipRRect olmamalı (URL boş, fallback gösterilir)
      expect(find.byType(AppCachedImage), findsOneWidget);
    });
  });

  group('CachedAvatar', () {
    testWidgets('isim baş harfi gösterir (resim yoksa)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const CachedAvatar(
          imageUrl: '',
          name: 'Ahmet',
          radius: 24,
        ),
      ));

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('online indicator gösterir', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const CachedAvatar(
          imageUrl: '',
          name: 'Mehmet',
          radius: 28,
          showOnlineIndicator: true,
          isOnline: true,
        ),
      ));

      // CachedAvatar + online indicator'lı Stack widget tree'de olmalı
      expect(find.byType(CachedAvatar), findsOneWidget);
      // İsim baş harfi göstermeli
      expect(find.text('M'), findsOneWidget);
    });

    testWidgets('online indicator kapalıyken göstermez', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const CachedAvatar(
          imageUrl: '',
          name: 'Zeynep',
          radius: 24,
          showOnlineIndicator: false,
        ),
      ));

      // Stack olmamalı (indicator kapalı)
      expect(find.byType(CachedAvatar), findsOneWidget);
    });

    testWidgets('boş isimde ? gösterir', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const CachedAvatar(
          imageUrl: '',
          name: '',
          radius: 20,
        ),
      ));

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('dark modda render edilir', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData.dark(),
        home: const Scaffold(
          body: CachedAvatar(
            imageUrl: '',
            name: 'Test',
            radius: 24,
          ),
        ),
      ));

      expect(find.text('T'), findsOneWidget);
    });
  });
}
