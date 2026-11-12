import '../fixtures/app.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:lunar_social/main.dart';
import 'package:lunar_social/l10n/generated/app_localizations.dart';

// Explicit renderer QA: this file deliberately is not a default *_test.dart.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    tz.initializeTimeZones();
    final manrope = FontLoader('Manrope');
    for (final w in [400, 500, 600, 700]) {
      manrope.addFont(rootBundle.load('assets/fonts/Manrope-$w.ttf'));
    }
    await manrope.load();
    await (FontLoader('NotoSansSC')
          ..addFont(rootBundle.load('assets/fonts/NotoSansSC-Chart.ttf')))
        .load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });
  for (final (name, size, scale) in [
    ('desktop', const Size(1440, 1000), 1.0),
    ('mobile', const Size(390, 844), 1.0),
    ('accessible', const Size(320, 740), 2.0),
    ('zh', const Size(390, 844), 1.0),
    ('landscape', const Size(844, 390), 1.2),
  ]) {
    testWidgets('$name core UI walkthrough', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final state = testAppState(await SharedPreferences.getInstance());
      if (name == 'zh') await state.setLocale(const Locale('zh'));
      await tester.pumpWidget(RepaintBoundary(
          key: const ValueKey('capture-ui'),
          child: MediaQuery(
              data: MediaQueryData(
                  size: size,
                  textScaler: TextScaler.linear(scale),
                  disableAnimations: scale > 1),
              child: LunarApp(state: state))));
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future.wait(state.matches.map((m) =>
          precacheImage(AssetImage(m.person.image),
              tester.element(find.byType(Scaffold).first)))));
      await tester.pumpAndSettle();
      final l =
          AppLocalizations.of(tester.element(find.byType(Scaffold).first))!;
      Future<void> shot(String page) async {
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
            find.byKey(const ValueKey('capture-ui')),
            matchesGoldenFile(
                '${Directory.current.path}/output/ui/$page-$name.png'));
      }

      await shot('start');
      await tester.ensureVisible(find.byKey(const ValueKey('intent-match')));
      await tester.tap(find.byKey(const ValueKey('intent-match')));
      await tester.pumpAndSettle();
      await shot('matches');
      await tester.ensureVisible(find.byKey(const ValueKey('random-match')));
      await tester.tap(find.byKey(const ValueKey('random-match')));
      await tester.pumpAndSettle();
      await shot('profile');
      await tester.tap(find.byTooltip(l.closeProfile));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('nav-chart')));
      await tester.pumpAndSettle();
      await shot('chart');
      await tester.ensureVisible(find.text(l.flowOutlook));
      await tester.tap(find.text(l.flowOutlook));
      await tester.pumpAndSettle();
      await shot('outlook');
      await tester.tap(find.byKey(const ValueKey('nav-agent')));
      await tester.pumpAndSettle();
      await shot('agent');
      await tester.tap(find.byKey(const ValueKey('journey-open')));
      await tester.pumpAndSettle();
      await shot('garden');
      await tester.tap(find.byTooltip(l.actionClose).last);
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      state.dispose();
    });
  }
}
