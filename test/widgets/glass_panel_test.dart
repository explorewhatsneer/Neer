import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neer/widgets/common/glass_panel.dart';

void main() {
  group('GlassPanel', () {
    Widget buildTestWidget({
      Brightness brightness = Brightness.light,
      required Widget child,
    }) {
      return MaterialApp(
        theme: brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        home: Scaffold(body: child),
      );
    }

    testWidgets('light modda render edilir', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const GlassPanel(
          child: Text('Hello'),
        ),
      ));

      expect(find.text('Hello'), findsOneWidget);
      expect(find.byType(GlassPanel), findsOneWidget);
    });

    testWidgets('dark modda render edilir', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        brightness: Brightness.dark,
        child: const GlassPanel(
          child: Text('Dark Mode'),
        ),
      ));

      expect(find.text('Dark Mode'), findsOneWidget);
    });

    testWidgets('.sheet constructor çalışır', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const GlassPanel.sheet(
          child: SizedBox(height: 200, child: Text('Sheet')),
        ),
      ));

      expect(find.text('Sheet'), findsOneWidget);
    });

    testWidgets('.card constructor çalışır', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const GlassPanel.card(
          child: Text('Card'),
        ),
      ));

      expect(find.text('Card'), findsOneWidget);
    });

    testWidgets('.appBar constructor çalışır', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const GlassPanel.appBar(
          child: Text('AppBar'),
        ),
      ));

      expect(find.text('AppBar'), findsOneWidget);
    });

    testWidgets('padding ve margin uygulanır', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const GlassPanel(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.all(8),
          child: Text('Padded'),
        ),
      ));

      // Container'ın padding ve margin'ı olduğunu doğrula
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GlassPanel),
          matching: find.byType(Container),
        ),
      );
      expect(container.padding, const EdgeInsets.all(16));
      expect(container.margin, const EdgeInsets.all(8));
    });

    testWidgets('custom width ve height çalışır', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        child: const GlassPanel(
          width: 200,
          height: 100,
          child: Text('Sized'),
        ),
      ));

      expect(find.text('Sized'), findsOneWidget);
      // Container width/height doğru atanmış
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GlassPanel),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints, isNotNull);
    });
  });
}
