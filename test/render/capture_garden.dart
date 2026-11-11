import 'dart:io';
import 'dart:convert';
import 'package:lunar_social/services/journey.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:lunar_social/main.dart';
import 'package:lunar_social/l10n/generated/app_localizations.dart';
import 'package:lunar_social/services/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    tz.initializeTimeZones();
    final font = FontLoader('Manrope');
    for (final w in [400, 500, 600, 700]) {
      font.addFont(rootBundle.load('assets/fonts/Manrope-$w.ttf'));
    }
    await font.load();
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
    ('accessible', const Size(320, 740), 1.6),
    ('zh', const Size(390, 844), 1.0),
    ('legacy', const Size(1440, 1000), 1.0),
  ]) {
    testWidgets('$name garden adventure', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues(name == 'legacy'
          ? {
              JourneyStore.storageKey: jsonEncode({
                'version': 1,
                'completed': ['element', 'outlook', 'encounter']
              })
            }
          : {});
      final state = AppState(await SharedPreferences.getInstance());
      if (name == 'zh') await state.setLocale(const Locale('zh'));
      await tester.pumpWidget(RepaintBoundary(
          key: const ValueKey('capture'),
          child: MediaQuery(
              data: MediaQueryData(
                  size: size,
                  textScaler: TextScaler.linear(scale),
                  disableAnimations: scale > 1),
              child: LunarApp(state: state))));
      await tester.pumpAndSettle();
      final l =
          AppLocalizations.of(tester.element(find.byType(Scaffold).first))!;
      Future<void> shot(String phase) async {
        await tester.pump();
        await expectLater(
            find.byKey(const ValueKey('capture')),
            matchesGoldenFile(
                '${Directory.current.path}/output/garden/$phase-$name.png'));
      }

      await tester.tap(find.byKey(const ValueKey('journey-open')));
      await tester.pumpAndSettle();
      await shot('map');
      await tester.tap(find.byKey(const ValueKey('garden-guide')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('guide-water')));
      await tester.pumpAndSettle();
      await shot('notes');
      await tester.tap(find.byTooltip(l.actionClose).last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('quest-element')));
      await tester.tap(find.byKey(const ValueKey('quest-element')));
      await tester.pumpAndSettle();
      await shot('workshop');
      await tester
          .ensureVisible(find.byKey(const ValueKey('element-answer-fire')));
      await tester.tap(find.byKey(const ValueKey('element-answer-fire')));
      await tester.pumpAndSettle();
      await shot('hint');
      for (final choice in ['water', 'wood', 'fire', 'earth', 'metal']) {
        await tester
            .ensureVisible(find.byKey(ValueKey('element-answer-$choice')));
        await tester.tap(find.byKey(ValueKey('element-answer-$choice')));
        await tester.pumpAndSettle();
        if (choice == 'water') await shot('link');
        if (choice != 'metal') {
          await tester.tap(find.byKey(const ValueKey('quest-continue')));
          await tester.pumpAndSettle();
        }
      }
      await shot('complete');
      expect(state.journey.sparks, name == 'legacy' ? 60 : 20);
      expect(state.journey.seals.length, 5);
      await tester.tap(find.byKey(const ValueKey('quest-continue')));
      await tester.pumpAndSettle();
      await shot('collected');
      await tester.ensureVisible(find.byKey(const ValueKey('quest-outlook')));
      await tester.tap(find.byKey(const ValueKey('quest-outlook')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('journey-open')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('quest-encounter')));
      await tester.tap(find.byKey(const ValueKey('quest-encounter')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('random-match')));
      await tester.tap(find.byKey(const ValueKey('random-match')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(l.closeProfile));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('journey-open')));
      await tester.pumpAndSettle();
      await shot('bloom');
      expect(state.journey.sparks, 60);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      state.dispose();
    });
  }
}
