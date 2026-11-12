import 'fixtures/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:lunar_social/main.dart';
import 'package:lunar_social/models/profile.dart';
import 'package:lunar_social/services/intent_flow.dart';

void main() {
  setUpAll(() async {
    tz.initializeTimeZones();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
    final font = FontLoader('Manrope');
    for (final weight in [400, 500, 600, 700]) {
      font.addFont(rootBundle.load('assets/fonts/Manrope-$weight.ttf'));
    }
    await font.load();
    await (FontLoader('NotoSansSC')
          ..addFont(rootBundle.load('assets/fonts/NotoSansSC-Chart.ttf')))
        .load();
  });
  for (final (name, size, scale) in [
    ('narrow phone with large text', const Size(320, 740), 2.0),
    ('landscape phone', const Size(844, 390), 1.2),
    ('desktop', const Size(1440, 1000), 1.0),
  ]) {
    testWidgets('core tasks and settings remain accessible on $name',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final state = testAppState(await SharedPreferences.getInstance());
      await state.updateProfile('Alex', demoBirth);
      await state.chooseIntent(AppIntent.chart);
      await tester.pumpWidget(MediaQuery(
          data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(scale),
              disableAnimations: true),
          child: LunarApp(state: state)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final task in ['match', 'agent']) {
        await tester.tap(find.byKey(ValueKey('nav-$task')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Privacy & your data'));
      await tester.tap(find.text('Privacy & your data'));
      await tester.pumpAndSettle();
      expect(find.text('Privacy & data'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      state.dispose();
    });
  }
}
