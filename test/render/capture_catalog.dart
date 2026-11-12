import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:lunar_social/main.dart';
import 'package:lunar_social/models/profile.dart';
import 'package:lunar_social/services/app_state.dart';
import 'package:lunar_social/services/intent_flow.dart';
import 'package:lunar_social/ui/match_card.dart';
import 'package:lunar_social/l10n/generated/app_localizations.dart';

// Run verify_catalog_live.py first. Captures use the actual fetched D1 records.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final snapshot =
      jsonDecode(File('output/catalog-live.json').readAsStringSync())
          as Map<String, dynamic>;
  final rows = (snapshot['people'] as List);
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
    ('accessible', const Size(320, 740), 2.0),
    ('zh', const Size(390, 844), 1.0),
  ]) {
    testWidgets('$name persisted catalog walkthrough', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final people = rows
          .map((x) => Person.fromCatalog(x as Map<String, dynamic>))
          .toList();
      final state = AppState(await SharedPreferences.getInstance(),
          initialPeople: people);
      if (name == 'zh') await state.setLocale(const Locale('zh'));
      await state.chooseIntent(AppIntent.match);
      await tester.pumpWidget(RepaintBoundary(
          key: const ValueKey('catalog-capture'),
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
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
            find.byKey(const ValueKey('catalog-capture')),
            matchesGoldenFile(
                '${Directory.current.path}/output/catalog-render/$phase-$name.png'));
      }

      expect(find.byType(MatchListTile), findsNWidgets(20));
      expect(find.text(l.catalogCount(1000)), findsOneWidget);
      await shot('people');
      await tester.tap(find.text(l.filters));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.genderNonBinary));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Japan'), 240,
          scrollable: find.byType(Scrollable).last, maxScrolls: 30);
      await tester.tap(find.text('Japan').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.showConnections));
      await tester.pumpAndSettle();
      expect(find.byType(MatchListTile), findsNWidgets(5));
      expect(
          tester.widgetList<MatchListTile>(find.byType(MatchListTile)).every(
              (w) =>
                  w.match.person.countryCode == 'JP' &&
                  w.match.person.gender == 'Non-binary'),
          isTrue);
      await shot('filtered');
      await tester.ensureVisible(find.byKey(const ValueKey('random-match')));
      await tester.tap(find.byKey(const ValueKey('random-match')));
      await tester.pumpAndSettle();
      expect(
          people
              .where((p) => p.countryCode == 'JP' && p.gender == 'Non-binary')
              .any((p) =>
                  find.text('${p.name}, ${p.age}').evaluate().isNotEmpty),
          isTrue);
      await shot('profile');
      await tester.tap(find.byTooltip(l.closeProfile));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(l.filters));
      await tester.tap(find.text(l.filters));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.reset));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.showConnections));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('catalog-more')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('catalog-more')));
      await tester.pumpAndSettle();
      expect(find.byType(MatchListTile), findsNWidgets(40));
      await shot('more');
      await tester.pumpWidget(const SizedBox());
      state.dispose();
    });
  }
}
