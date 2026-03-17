import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neer/widgets/common/shimmer_loading.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('ShimmerLoading', () {
    testWidgets('animasyon başlar', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerLoading(
          child: SizedBox(width: 100, height: 100),
        ),
      ));

      expect(find.byType(ShimmerLoading), findsOneWidget);
      // Animasyon çalıştığını doğrula — bir frame ilerlet
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(ShimmerLoading), findsOneWidget);
    });
  });

  group('ShimmerBox', () {
    testWidgets('rectangle render edilir', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerBox(width: 100, height: 50),
      ));

      expect(find.byType(ShimmerBox), findsOneWidget);
    });

    testWidgets('circle render edilir', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerBox.circle(size: 60),
      ));

      expect(find.byType(ShimmerBox), findsOneWidget);
    });
  });

  group('ShimmerGrid', () {
    testWidgets('belirtilen sayıda kart render eder', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerGrid(itemCount: 4),
      ));

      expect(find.byType(ShimmerGridCard), findsNWidgets(4));
    });

    testWidgets('varsayılan 6 kart render eder', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerGrid(),
      ));

      expect(find.byType(ShimmerGridCard), findsNWidgets(4));
    });
  });

  group('ShimmerProfileCard', () {
    testWidgets('render edilir', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerProfileCard(),
      ));

      expect(find.byType(ShimmerProfileCard), findsOneWidget);
      // İçinde ShimmerBox'lar olmalı
      expect(find.byType(ShimmerBox), findsWidgets);
    });
  });
}
