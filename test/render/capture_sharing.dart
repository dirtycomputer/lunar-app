import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:lunar_social/services/app_state.dart';
import 'package:lunar_social/services/sharing.dart';
import 'package:lunar_social/ui/sharing_pages.dart';
import 'package:lunar_social/ui/profile_editor.dart';
import 'package:lunar_social/ui/design.dart';
import 'package:lunar_social/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    tz.initializeTimeZones();
    for (final family in ['Manrope', 'NotoSansSC', 'MaterialIcons']) {
      final font = FontLoader(family);
      if (family == 'Manrope') {
        for (final w in [400, 500, 600, 700]) {
          font.addFont(rootBundle.load('assets/fonts/Manrope-$w.ttf'));
        }
      } else if (family == 'NotoSansSC') {
        font.addFont(rootBundle.load('assets/fonts/NotoSansSC-Chart.ttf'));
      } else {
        font.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      }
      await font.load();
    }
  });
  for (final (device, size, scale) in [
    ('desktop', const Size(1440, 1000), 1.0),
    ('phone', const Size(390, 844), 1.0),
    ('accessible', const Size(320, 740), 2.0)
  ]) {
    testWidgets('$device friend sharing walkthrough', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      const id = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
      final result = jsonDecode(
              File('test/fixtures/shared_result.json').readAsStringSync())
          as Map<String, dynamic>;
      final expires =
          DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch ~/
              1000;
      var joined = false, created = false;
      Map<String, dynamic> response() => {
            'id': id,
            'kind': 'pair',
            'portrait': result['host'],
            'status': joined ? 'complete' : 'open',
            'expiresAt': expires,
            if (joined) 'result': result
          };
      final state = AppState(await SharedPreferences.getInstance(),
          initialPeople: [], sharingRepository:
              SharingRepository(client: MockClient((request) async {
        if (request.url.path.endsWith('/join')) {
          final input = jsonDecode(request.body) as Map;
          expect(input.keys, unorderedEquals(['portrait', 'consent']));
          result['guest'] = input['portrait'];
          joined = true;
        }
        if (request.url.path == '/api/shares' && request.method == 'POST') {
          created = true;
        }
        return http.Response(
            jsonEncode(request.url.path == '/api/shares'
                ? {'id': id, 'expiresAt': expires}
                : response()),
            200);
      })));
      final capture = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
          key: capture,
          child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: lunarTheme(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: const [Locale('en')],
              builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(scale),
                      disableAnimations: scale > 1),
                  child: child!),
              home: SharedLinkPage(state: state, id: id, onExit: () {}))));
      await tester.pumpAndSettle();
      Future<void> shot(String phase) async {
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
            find.byKey(capture),
            matchesGoldenFile(
                '${Directory.current.path}/output/sharing-render/$phase-$device.png'));
      }

      await shot('invite');
      await tester.ensureVisible(find.byKey(const ValueKey('join-start')));
      await tester.tap(find.byKey(const ValueKey('join-start')));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileEditor), findsOneWidget);
      final l =
          AppLocalizations.of(tester.element(find.byType(ProfileEditor)))!;
      await tester.enterText(find.byType(TextFormField).first, 'Sam');
      await tester.ensureVisible(find.text(l.noTimeCheckbox));
      await tester.tap(find.text(l.noTimeCheckbox));
      await tester.pumpAndSettle();
      final consent = find
          .descendant(
              of: find.byType(ProfileEditor), matching: find.byType(Checkbox))
          .last;
      await tester.ensureVisible(consent);
      await tester.tap(consent);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(l.discoverEnergy));
      await tester.tap(find.text(l.discoverEnergy));
      await tester.pumpAndSettle();
      expect(find.text('Your shared details'), findsOneWidget);
      expect(joined, isFalse);
      await shot('preview');
      await tester.ensureVisible(find.byKey(const ValueKey('join-consent')));
      await tester.tap(find.byKey(const ValueKey('join-consent')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('join-confirm')));
      await tester.tap(find.byKey(const ValueKey('join-confirm')));
      await tester.pumpAndSettle();
      expect(joined, isTrue);
      expect(find.text('Your elements together'), findsOneWidget);
      expect(tester.getTopLeft(find.byType(PairResultView)).dy,
          greaterThanOrEqualTo(56));
      await shot('result');
      await tester.ensureVisible(find.text('Compare with another friend'));
      await tester.tap(find.text('Compare with another friend'));
      await tester.pumpAndSettle();
      expect(find.text('Invite a friend'), findsOneWidget);
      await shot('onward-preview');
      await tester.ensureVisible(find.byKey(const ValueKey('share-consent')));
      await tester.tap(find.byKey(const ValueKey('share-consent')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('share-create')));
      await tester.tap(find.byKey(const ValueKey('share-create')));
      await tester.pumpAndSettle();
      expect(created, isTrue);
      expect(find.text('Your link is ready'), findsOneWidget);
      await shot('link-ready');
      await tester.pumpWidget(const SizedBox());
      state.dispose();
    });
  }
}
