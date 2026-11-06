import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/ui/widgets/searchable_picker.dart';

void main() {
  testWidgets('long list scrolls both ways, filters by search, picks, and '
      'stays keyboard-safe at 375pt', (tester) async {
    tester.view.physicalSize = const Size(375, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final options = [
      for (var i = 0; i < 150; i++)
        PickerOption<int>(
          value: i,
          title: 'ITEM-$i',
          subtitle:
              'A very long secondary description that must ellipsize instead '
              'of overflowing the 375 point wide phone layout $i',
          group: 'Group ${i ~/ 50}',
        ),
    ];
    PickerOption<int>? picked;
    await tester.pumpWidget(
      AppLocaleScope(
        locale: AppLocale(),
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async => picked = await showSearchablePicker<int>(
                  context,
                  title: 'Pick',
                  options: options,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('ITEM-0'), findsOneWidget);
    expect(find.text('ITEM-100'), findsNothing);

    final list = find.byType(ListView);
    for (var i = 0; i < 8; i++) {
      await tester.drag(list, const Offset(0, -400));
      await tester.pumpAndSettle();
    }
    expect(find.text('ITEM-0'), findsNothing);
    final visibleIndexes = tester
        .widgetList<Text>(find.textContaining(RegExp(r'^ITEM-\d+$')))
        .map((t) => int.parse(t.data!.substring(5)));
    expect(visibleIndexes, isNotEmpty);
    expect(visibleIndexes.every((i) => i >= 10), isTrue);
    for (var i = 0; i < 7; i++) {
      await tester.drag(list, const Offset(0, 400));
      await tester.pumpAndSettle();
    }
    expect(find.text('ITEM-0'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.enterText(
      find.byKey(const ValueKey('picker-search')),
      'item-142',
    );
    await tester.pumpAndSettle();
    expect(find.text('ITEM-142'), findsOneWidget);
    expect(find.text('ITEM-0'), findsNothing);

    await tester.tap(find.text('ITEM-142'));
    await tester.pumpAndSettle();
    expect(picked?.value, 142);
  });
}
