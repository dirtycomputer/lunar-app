import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:lunar_social/models/profile.dart';
import 'package:lunar_social/services/app_state.dart';
import 'package:lunar_social/services/bazi.dart';
import 'package:lunar_social/services/people_repository.dart';
import 'package:lunar_social/main.dart';
import 'package:lunar_social/services/intent_flow.dart';
import 'package:lunar_social/ui/match_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final dataset = jsonDecode(File('catalog/seed.json').readAsStringSync())
      as Map<String, dynamic>;
  final rows = (dataset['people'] as List)
      .map((x) => x['profile'] as Map<String, dynamic>)
      .toList();
  final revision = dataset['revision'];
  setUpAll(() async {
    tz.initializeTimeZones();
    final font = FontLoader('Manrope');
    for (final weight in [400, 500, 600, 700]) {
      font.addFont(rootBundle.load('assets/fonts/Manrope-$weight.ttf'));
    }
    await font.load();
    await (FontLoader('NotoSansSC')
          ..addFont(rootBundle.load('assets/fonts/NotoSansSC-Chart.ttf')))
        .load();
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));
  http.Response page(http.Request request, {String? changedRevision}) {
    final after = request.url.queryParameters['after'];
    final index =
        after == null ? 0 : rows.indexWhere((p) => p['id'] == after) + 1;
    final records = rows.skip(index).take(200).toList();
    return http.Response(
        jsonEncode({
          'storage': 'cloudflare-d1',
          'synthetic': true,
          'revision': changedRevision ?? revision,
          'total': 1000,
          'people': records,
          'nextCursor':
              index + records.length < 1000 ? records.last['id'] : null
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'});
  }

  test(
      'catalog reads five bounded pages and validates all 1,000 synthetic adults',
      () async {
    final requests = <Uri>[];
    final repository = PeopleRepository(client: MockClient((r) async {
      requests.add(r.url);
      return page(r);
    }));
    final result = await repository.load();
    repository.close();
    expect(requests, hasLength(5));
    expect(result.people, hasLength(1000));
    expect(result.people.map((p) => p.id).toSet(), hasLength(1000));
    expect(result.people.map((p) => p.countryCode).toSet(), hasLength(40));
    expect(
        result.people
            .every((p) => p.synthetic && p.image.isEmpty && p.age >= 18),
        isTrue);
    expect(requests.every((r) => r.queryParameters['limit'] == '200'), isTrue);
  });
  test('all stored lunar-python snapshots match the Flutter chart engine', () {
    final service = BaziService();
    for (final row in rows) {
      final person = Person.fromCatalog(row);
      final calculated = service.calculate(person.birth);
      expect(person.catalogChart!.pillars,
          calculated.pillars.map((p) => p.value).toList(),
          reason: person.id);
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
  test('a changed revision or duplicate page cannot publish a partial catalog',
      () async {
    var count = 0;
    final changed = PeopleRepository(
        client: MockClient((r) async =>
            page(r, changedRevision: ++count > 1 ? 'other' : null)));
    await expectLater(changed.load(), throwsFormatException);
    changed.close();
    final duplicate = PeopleRepository(
        client: MockClient((r) async => http.Response(
            jsonEncode({
              'storage': 'cloudflare-d1',
              'synthetic': true,
              'revision': revision,
              'total': 2,
              'people': [rows.first, rows.first],
              'nextCursor': null
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'})));
    await expectLater(duplicate.load(), throwsFormatException);
    duplicate.close();
  });
  test(
      'network failure keeps the catalog empty and retry loads persisted records',
      () async {
    var failed = true;
    final repository = PeopleRepository(
        client:
            MockClient((r) async => failed ? http.Response('', 503) : page(r)));
    final state = AppState(await SharedPreferences.getInstance(),
        peopleRepository: repository);
    await state.refreshCatalog();
    expect(state.people, isEmpty);
    expect(state.matches, isEmpty);
    expect(state.catalogError, isNotNull);
    failed = false;
    await state.refreshCatalog();
    expect(state.people, hasLength(1000));
    expect(state.catalogError, isNull);
    expect(state.catalogRevision, revision);
    state.dispose();
  });
  test('saved IDs and drafts survive asynchronous loading and profile changes',
      () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved', ['catalog-0003']);
    await prefs.setString(
        'social.v1',
        jsonEncode({
          'version': 1,
          'invitations': ['catalog-0003'],
          'threads': {
            'catalog-0003': [
              {
                'id': 'draft',
                'text': 'A local note',
                'createdAt': '2026-11-12T00:00:00Z'
              }
            ]
          }
        }));
    final gate = Completer<void>();
    final state = AppState(prefs,
        peopleRepository: PeopleRepository(client: MockClient((r) async {
      await gate.future;
      return page(r);
    })));
    expect(state.catalogLoading, isTrue);
    expect(state.saved, contains('catalog-0003'));
    await state.updateProfile('Updated', sampleComparisonBirth);
    gate.complete();
    await state.refreshCatalog();
    expect(state.name, 'Updated');
    expect(state.birth.date, sampleComparisonBirth.date);
    expect(state.saved, contains('catalog-0003'));
    expect(state.social.invitations, contains('catalog-0003'));
    expect(
        state.social.messagesFor('catalog-0003').single.text, 'A local note');
    expect(await state.toggleSaved('catalog-0004'), isTrue);
    final watch = Stopwatch()..start();
    state.service.rank(state.chart, state.people);
    watch.stop();
    // Report a benchmark without a flaky wall-clock assertion on CI machines.
    stdout.writeln(
        'Ranked 1,000 stored charts in ${watch.elapsedMilliseconds} ms.');
    await state.reset();
    expect(state.people, hasLength(1000));
    expect(state.saved, isEmpty);
    expect(state.social.messagesFor('catalog-0003'), isEmpty);
    state.dispose();
  });
  test('invalid birth dates, zones and chart conventions fail validation', () {
    Map<String, dynamic> copy() =>
        jsonDecode(jsonEncode(rows.first)) as Map<String, dynamic>;
    final date = copy();
    (date['birth'] as Map)['date'] = '2001-02-31';
    expect(() => Person.fromCatalog(date), throwsFormatException);
    final zone = copy();
    (zone['birth'] as Map)['zone'] = 'Invalid/Timezone';
    expect(() => Person.fromCatalog(zone), throwsA(anything));
    final convention = copy();
    (convention['chart'] as Map)['sect'] = 1;
    expect(() => Person.fromCatalog(convention), throwsFormatException);
  });
  for (final (size, scale) in [
    (const Size(1440, 1000), 1.0),
    (const Size(320, 740), 2.0)
  ]) {
    testWidgets(
        '1,000-profile pagination remains tappable after an encounter at $size / $scale',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final state = AppState(await SharedPreferences.getInstance(),
          initialPeople: rows.map(Person.fromCatalog).toList());
      await state.chooseIntent(AppIntent.match);
      await tester.pumpWidget(MediaQuery(
          data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(scale),
              disableAnimations: true),
          child: LunarApp(state: state)));
      await tester.pumpAndSettle();
      expect(find.byType(MatchListTile), findsNWidgets(20));
      await tester.tap(find.byKey(const ValueKey('random-match')));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Close profile').hitTestable(), findsOneWidget);
      await tester.tap(find.byTooltip('Close profile'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('catalog-more')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('catalog-more')).hitTestable(),
          findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('catalog-more')));
      await tester.pumpAndSettle();
      expect(find.byType(MatchListTile), findsNWidgets(40));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      state.dispose();
    });
  }
}
