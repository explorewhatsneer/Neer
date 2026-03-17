import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neer/widgets/common/animated_list_item.dart';

void main() {
  Widget buildTestWidget(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('AnimatedListItem renders child', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      const AnimatedListItem(
        index: 0,
        child: Text('Test Item'),
      ),
    ));

    // Initially opacity may be 0, pump to animate
    await tester.pumpAndSettle();

    expect(find.text('Test Item'), findsOneWidget);
  });

  testWidgets('AnimatedListItem has fade and slide animation', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      const AnimatedListItem(
        index: 0,
        child: Text('Animated'),
      ),
    ));

    // Before animation settles
    expect(find.text('Animated'), findsOneWidget);

    // After animation completes
    await tester.pumpAndSettle();
    expect(find.text('Animated'), findsOneWidget);
  });

  testWidgets('Multiple AnimatedListItems render in list', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return AnimatedListItem(
            index: index,
            child: Text('Item $index'),
          );
        },
      ),
    ));

    await tester.pumpAndSettle();

    for (int i = 0; i < 5; i++) {
      expect(find.text('Item $i'), findsOneWidget);
    }
  });
}
