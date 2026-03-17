import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neer/widgets/common/app_confirm_dialog.dart';

void main() {
  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              await AppConfirmDialog.show(
                context: context,
                title: 'Sil',
                content: 'Silmek istiyor musunuz?',
                confirmText: 'Sil',
                isDestructive: true,
                haptic: false,
              );
            },
            child: const Text('Show Dialog'),
          ),
        ),
      ),
    );
  }

  testWidgets('AppConfirmDialog shows title and content', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Sil'), findsWidgets); // title + confirm button
    expect(find.text('Silmek istiyor musunuz?'), findsOneWidget);
    expect(find.text('İptal'), findsOneWidget);
  });

  testWidgets('AppConfirmDialog cancel returns false', (tester) async {
    bool? result;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await AppConfirmDialog.show(
                context: context,
                title: 'Test',
                content: 'Content',
                haptic: false,
              );
            },
            child: const Text('Show'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('İptal'));
    await tester.pumpAndSettle();

    expect(result, false);
  });

  testWidgets('AppConfirmDialog confirm returns true', (tester) async {
    bool? result;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await AppConfirmDialog.show(
                context: context,
                title: 'Test',
                content: 'Content',
                confirmText: 'OK',
                haptic: false,
              );
            },
            child: const Text('Show'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(result, true);
  });
}
