import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neer/widgets/common/empty_state.dart';

void main() {
  Widget buildTestWidget(Widget child, {bool isDark = false}) {
    return MaterialApp(
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(body: child),
    );
  }

  testWidgets('EmptyState icon, title ve description gösterir', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      const EmptyState(
        icon: Icons.group_off_rounded,
        title: 'Henüz arkadaş yok',
        description: 'Haritadan arkadaş bul!',
      ),
    ));

    expect(find.byIcon(Icons.group_off_rounded), findsOneWidget);
    expect(find.text('Henüz arkadaş yok'), findsOneWidget);
    expect(find.text('Haritadan arkadaş bul!'), findsOneWidget);
  });

  testWidgets('EmptyState description olmadan çalışır', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      const EmptyState(
        icon: Icons.notifications_off_rounded,
        title: 'Bildirim yok',
      ),
    ));

    expect(find.byIcon(Icons.notifications_off_rounded), findsOneWidget);
    expect(find.text('Bildirim yok'), findsOneWidget);
  });

  testWidgets('EmptyState custom iconSize uygulanır', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Sonuç yok',
        iconSize: 64,
      ),
    ));

    final iconWidget = tester.widget<Icon>(find.byIcon(Icons.search_off_rounded));
    expect(iconWidget.size, 64);
  });

  testWidgets('EmptyState action widget gösterir', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      EmptyState(
        icon: Icons.group_off_rounded,
        title: 'Boş',
        action: ElevatedButton(onPressed: () {}, child: const Text('Ekle')),
      ),
    ));

    expect(find.text('Ekle'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
