import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:lunar_social/main.dart';
import 'package:lunar_social/models/profile.dart';
import 'package:lunar_social/services/app_state.dart';
import 'package:lunar_social/services/bazi.dart' as bazi;
import 'package:lunar_social/services/data_export.dart';
import 'package:lunar_social/services/device_storage.dart';
import 'package:lunar_social/services/sharing.dart';
import 'package:lunar_social/ui/sharing_pages.dart';
import 'package:lunar_social/ui/design.dart';
import 'package:lunar_social/l10n/generated/app_localizations.dart';

const id = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
final until = DateTime.now().toUtc().add(const Duration(days: 7));
const portrait = ElementPortrait(
    name: 'Alex',
    element: bazi.Element.wood,
    traits: [0, 1],
    counts: [2, 1, 1, 1, 1]);
Map<String, dynamic> link({bool completed = false}) => {
      'id': id,
      'kind': 'pair',
      'status': completed ? 'complete' : 'open',
      'portrait': portrait.toJson(),
      'expiresAt': until.millisecondsSinceEpoch ~/ 1000,
      if (completed)
        'result': jsonDecode(
            File('test/fixtures/shared_result.json').readAsStringSync())
    };
http.Response ok(Object value) => http.Response(jsonEncode(value), 200);

class FailingSharingPreferences extends Fake implements SharedPreferences {
  final SharedPreferences delegate;
  bool fail = false;
  FailingSharingPreferences(this.delegate);
  @override
  Object? get(String key) => delegate.get(key);
  @override
  Future<bool> setString(String key, String value) async =>
      fail ? false : delegate.setString(key, value);
  @override
  Future<bool> setBool(String key, bool value) => delegate.setBool(key, value);
  @override
  Future<bool> remove(String key) => delegate.remove(key);
}

void main() {
  setUpAll(tz.initializeTimeZones);
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('URLs accept only opaque share IDs and tokens contain 192 random bits',
      () {
    final tokens = List.generate(200, (_) => newShareToken());
    expect(tokens.toSet().length, 200);
    expect(tokens.every((x) => RegExp(r'^[A-Za-z0-9_-]{32}$').hasMatch(x)),
        isTrue);
    expect(shareIdFromUri(Uri.parse('https://example.test/s/$id')), id);
    expect(shareIdFromUri(Uri.parse('https://example.test/#/s/$id')), id);
    expect(shareIdFromUri(Uri.parse('https://example.test/s/short')), isNull);
    expect(shareIdFromUri(Uri.parse('https://example.test/?birth=private')),
        isNull);
  });
  test(
      'sharing snapshot is derived from the calculated chart, with unknown hours omitted',
      () {
    final chart = bazi.BaziService().calculate(BirthData(
        date: demoBirth.date,
        hour: 12,
        minute: 0,
        place: demoBirth.place,
        timeKnown: false));
    final pair = ElementPortrait.fromChart('A', chart, pair: true);
    expect(pair.counts!.reduce((a, b) => a + b), 6);
    expect(pair.unknownTime, isTrue);
    expect(pair.element, chart.dayElement);
    final card = ElementPortrait.fromChart('A', chart, pair: false);
    expect(card.toJson().keys, unorderedEquals(['name', 'element', 'traits']));
    expect(jsonEncode(pair.toJson()), isNot(contains('1997')));
    expect(pair.toJson().keys,
        unorderedEquals(['name', 'element', 'traits', 'counts']));
  });
  test(
      'an ambiguous network failure keeps credentials; restart retries the same creation',
      () async {
    final prefs = await SharedPreferences.getInstance();
    final ids = <String>[], credentials = <String>[];
    var offline = true;
    final repository = SharingRepository(client: MockClient((r) async {
      ids.add((jsonDecode(r.body) as Map)['id'] as String);
      credentials.add(r.headers['Authorization']!);
      expect(prefs.getString('sharing.v1'), contains(ids.last));
      if (offline) throw const SocketException('offline');
      return ok(
          {'id': ids.last, 'expiresAt': until.millisecondsSinceEpoch ~/ 1000});
    }));
    final store = SharingStore(DeviceStorage(prefs), repository: repository);
    await expectLater(
        store.create('pair', portrait), throwsA(isA<ShareFailure>()));
    expect(store.entries.single.pending, isTrue);
    final restored = SharingStore(DeviceStorage(prefs), repository: repository);
    offline = false;
    await restored.send(restored.entries.single);
    expect(ids.toSet().length, 1);
    expect(credentials.toSet().length, 1);
    expect(restored.entries.single.pending, isFalse);
    store.dispose();
    restored.dispose();
  });
  test('no request leaves the device when saving its revocation handle fails',
      () async {
    var requests = 0;
    final prefs =
        FailingSharingPreferences(await SharedPreferences.getInstance())
          ..fail = true;
    final store = SharingStore(DeviceStorage(prefs),
        repository: SharingRepository(client: MockClient((r) async {
      requests++;
      return ok({});
    })));
    await expectLater(
        store.create('pair', portrait), throwsA(isA<ShareFailure>()));
    expect(requests, 0);
    expect(store.entries, isEmpty);
    store.dispose();
  });
  test(
      'remote success with a failed local acknowledgement can be recovered after restart',
      () async {
    final prefs =
        FailingSharingPreferences(await SharedPreferences.getInstance());
    final repository = SharingRepository(client: MockClient((r) async {
      prefs.fail = true;
      return ok({'id': id, 'expiresAt': until.millisecondsSinceEpoch ~/ 1000});
    }));
    final store = SharingStore(DeviceStorage(prefs), repository: repository);
    await expectLater(
        store.create('pair', portrait), throwsA(isA<ShareFailure>()));
    final restored = SharingStore(DeviceStorage(prefs));
    expect(restored.entries.single.pending, isTrue);
    expect(restored.entries.single.secret, isNotEmpty);
    store.dispose();
    restored.dispose();
  });
  test(
      'privacy deletion waits for an in-flight create and preserves access when withdrawal is offline',
      () async {
    final received = Completer<void>(), release = Completer<void>();
    var withdrawOffline = true;
    var creates = 0, deletes = 0;
    final state =
        AppState(await SharedPreferences.getInstance(), initialPeople: [],
            sharingRepository: SharingRepository(client: MockClient((r) async {
      if (r.method == 'POST') {
        creates++;
        received.complete();
        await release.future;
        return ok(
            {'id': id, 'expiresAt': until.millisecondsSinceEpoch ~/ 1000});
      }
      deletes++;
      if (withdrawOffline) throw const SocketException('offline');
      return ok({'deleted': true});
    })));
    await state.updateProfile('Private person', demoBirth);
    final creating = state.sharing.create('pair', portrait);
    await received.future;
    final resetting = state.reset();
    expect(await state.updateProfile('Too late', demoBirth), isFalse);
    await expectLater(
        state.sharing.create('pair', portrait), throwsA(isA<ShareFailure>()));
    release.complete();
    await creating;
    expect(await resetting, isFalse);
    expect(state.personalized, isTrue);
    expect(state.sharing.entries.length, 1);
    expect(creates, 1);
    expect(deletes, 1);
    withdrawOffline = false;
    expect(await state.reset(), isTrue);
    expect(state.personalized, isFalse);
    expect(state.sharing.entries, isEmpty);
    expect(state.preferences.getKeys().intersection(DeviceStorage.personalKeys),
        isEmpty);
    state.dispose();
  });
  test('exports contain shared summaries but never participant credentials',
      () async {
    final state = AppState(await SharedPreferences.getInstance(),
        initialPeople: [],
        sharingRepository: SharingRepository(
            client: MockClient((r) async => ok({
                  'id': id,
                  'expiresAt': until.millisecondsSinceEpoch ~/ 1000
                }))));
    final e = await state.sharing.create('pair', portrait);
    final exported = exportDeviceData(state);
    expect(exported, contains('Alex'));
    expect(exported, isNot(contains(e.secret)));
    expect((jsonDecode(exported) as Map)['sharing'], hasLength(1));
    state.dispose();
  });
  test('a corrupt local entry does not discard other revocation handles',
      () async {
    final prefs = await SharedPreferences.getInstance();
    final valid = ShareEntry(
        id: id,
        secret: newShareToken(),
        kind: 'pair',
        role: 'owner',
        portrait: portrait,
        expiresAt: until);
    await prefs.setString(
        'sharing.v1',
        jsonEncode([
          {'broken': true},
          valid.toJson()
        ]));
    final store = SharingStore(DeviceStorage(prefs));
    expect(store.entries.single.id, id);
    expect(store.restoreError, isNotNull);
    store.dispose();
  });
  testWidgets('an open result disappears when its link expires',
      (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(const Duration(seconds: 5));
    await prefs.setString(
        'sharing.v1',
        jsonEncode([
          ShareEntry(
                  id: id,
                  secret: newShareToken(),
                  kind: 'pair',
                  role: 'guest',
                  portrait: portrait,
                  expiresAt: expiry)
              .toJson()
        ]));
    final state = AppState(prefs,
        initialPeople: [],
        sharingRepository: SharingRepository(
            client: MockClient((r) async => ok({
                  ...link(completed: true),
                  'expiresAt': expiry.millisecondsSinceEpoch ~/ 1000
                }))));
    await tester.pumpWidget(MaterialApp(
        theme: lunarTheme(),
        home: SharedLinkPage(state: state, id: id, onExit: () {})));
    await tester.pumpAndSettle();
    expect(find.text('Something you share'), findsOneWidget);
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();
    expect(find.text('Something you share'), findsNothing);
    expect(find.textContaining('expired or was withdrawn'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });
  testWidgets(
      'a friend URL bypasses first-use cards and preserves the shared identity',
      (tester) async {
    final state = AppState(await SharedPreferences.getInstance(),
        initialPeople: [],
        sharingRepository: SharingRepository(
            client: MockClient((r) async => ok(
                r.url.path.endsWith('/open') ? {'recorded': true} : link()))));
    await tester.pumpWidget(MaterialApp(
        theme: lunarTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('en')],
        home: ShareGateway(
            state: state,
            initialUri: Uri.parse('https://example.test/s/$id'))));
    await tester.pumpAndSettle();
    expect(find.text('Compare with Alex'), findsOneWidget);
    expect(find.byKey(const ValueKey('join-start')), findsOneWidget);
    expect(find.text('Choose your path'), findsNothing);
    expect(find.textContaining('No account or download'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });
  testWidgets(
      'share preview requires consent and cannot publish the sample profile',
      (tester) async {
    final state =
        AppState(await SharedPreferences.getInstance(), initialPeople: []);
    await state.updateProfile('Alex', demoBirth);
    await tester.pumpWidget(MaterialApp(
        theme: lunarTheme(),
        home: ShareComposer(state: state, kind: 'portrait')));
    await tester.pumpAndSettle();
    final button =
        tester.widget<FilledButton>(find.byKey(const ValueKey('share-create')));
    expect(button.onPressed, isNull);
    expect(find.textContaining('No birth date'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('share-consent')));
    await tester.tap(find.byKey(const ValueKey('share-consent')));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('share-create')))
            .onPressed,
        isNotNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });
  for (final size in [
    const Size(390, 844),
    const Size(320, 740),
    const Size(1440, 1000)
  ]) {
    testWidgets(
        'pair result is scrollable and actionable at $size with large text',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'sharing.v1',
          jsonEncode([
            ShareEntry(
                    id: id,
                    secret: newShareToken(),
                    kind: 'pair',
                    role: 'guest',
                    portrait: portrait,
                    expiresAt: until)
                .toJson()
          ]));
      final state = AppState(prefs,
          initialPeople: [],
          sharingRepository: SharingRepository(
              client: MockClient((r) async => ok(link(completed: true)))));
      await tester.pumpWidget(MaterialApp(
          theme: lunarTheme(),
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: child!),
          home: SharedLinkPage(state: state, id: id, onExit: () {})));
      await tester.pumpAndSettle();
      expect(find.text('Your elements together'), findsOneWidget);
      await tester.ensureVisible(find.text('Compare with another friend'));
      await tester.pumpAndSettle();
      expect(find.text('Something you share'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      state.dispose();
    });
  }
}
