import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neer/widgets/common/loading_button.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)));
  }

  testWidgets('LoadingButton shows label', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      LoadingButton(
        onPressed: () async {},
        label: 'Kaydet',
      ),
    ));

    expect(find.text('Kaydet'), findsOneWidget);
  });

  testWidgets('LoadingButton shows icon when provided', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      LoadingButton(
        onPressed: () async {},
        label: 'Gönder',
        icon: Icons.send_rounded,
      ),
    ));

    expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    expect(find.text('Gönder'), findsOneWidget);
  });

  testWidgets('LoadingButton shows spinner during async operation', (tester) async {
    final completer = Completer<void>();

    await tester.pumpWidget(buildTestWidget(
      LoadingButton(
        onPressed: () => completer.future,
        label: 'Kaydet',
      ),
    ));

    // Tap the button
    await tester.tap(find.text('Kaydet'));
    await tester.pump();

    // Spinner should be visible
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Label should be hidden
    expect(find.text('Kaydet'), findsNothing);

    // Complete the async operation
    completer.complete();
    await tester.pumpAndSettle();

    // Label should be back
    expect(find.text('Kaydet'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('LoadingButton.destructive uses red background', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      LoadingButton.destructive(
        onPressed: () async {},
        label: 'Sil',
      ),
    ));

    expect(find.text('Sil'), findsOneWidget);

    // Find the Material widget and check its color
    final material = tester.widget<Material>(
      find.descendant(of: find.byType(LoadingButton), matching: find.byType(Material)).first,
    );
    expect(material.color, const Color(0xFFFF3B30));
  });
}
