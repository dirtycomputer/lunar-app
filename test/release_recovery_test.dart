import 'fixtures/app.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:lunar_social/main.dart';
import 'package:lunar_social/models/profile.dart';
import 'package:lunar_social/services/data_export.dart';
import 'package:lunar_social/services/device_storage.dart';
import 'package:lunar_social/services/journey.dart';
import 'package:lunar_social/studio/studio_store.dart';

class InterruptedPreferences extends Fake implements SharedPreferences {
  final SharedPreferences delegate;
  final Set<String> failRemoval = {};
  InterruptedPreferences(this.delegate);
  @override
  Object? get(String key) => delegate.get(key);
  @override
  Future<bool> setString(String key, String value) =>
      delegate.setString(key, value);
  @override
  Future<bool> setStringList(String key, List<String> value) =>
      delegate.setStringList(key, value);
  @override
  Future<bool> setBool(String key, bool value) => delegate.setBool(key, value);
  @override
  Future<bool> remove(String key) async =>
      failRemoval.contains(key) ? false : delegate.remove(key);
}

void main() {
  setUpAll(tz.initializeTimeZones);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('unfinished deletion exposes a retry from the first-use screen',
      (tester) async {
    final prefs = InterruptedPreferences(await SharedPreferences.getInstance());
    await prefs.setBool(DeviceStorage.resetKey, true);
    await prefs.setString('profile', 'private record');
    prefs.failRemoval.add('profile');
    final state = testAppState(prefs);
    await tester.pumpWidget(LunarApp(state: state));
    await tester.pumpAndSettle();
    expect(find.textContaining('Data deletion is incomplete'), findsOneWidget);
    expect(find.text('private record'), findsNothing);
    prefs.failRemoval.clear();
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Data deletion is incomplete'), findsNothing);
    expect(prefs.get('profile'), isNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });

  test('rapid saves preserve every selection and toggle parity after restart',
      () async {
    final prefs = await SharedPreferences.getInstance();
    final state = testAppState(prefs);
    expect(
        await Future.wait([
          state.toggleSaved('maya'),
          state.toggleSaved('leo'),
          state.toggleSaved('sofia'),
          state.toggleSaved('maya'),
          state.hide('noah'),
          state.hide('ethan'),
        ]),
        everyElement(isTrue));
    expect(state.saved, {'leo', 'sofia'});
    final restored = testAppState(prefs);
    expect(restored.saved, {'leo', 'sofia'});
    expect(restored.hidden, {'noah', 'ethan'});
    state.dispose();
    restored.dispose();
  });

  test('reset is a cross-store barrier against pending personal writes',
      () async {
    final prefs = await SharedPreferences.getInstance();
    final state = testAppState(prefs);
    final studio = StudioStore(state);
    final pending = [
      state.toggleSaved('maya'),
      state.updateProfile('Private', demoBirth),
      state.social.saveMessage('maya', 'Private draft'),
      state.journey.complete(JourneyQuest.element)
    ];
    final reset = state.reset();
    expect(await state.social.invite('leo'), isFalse);
    expect(await reset, isTrue);
    await Future.wait(pending);
    expect(state.personalized, isFalse);
    expect(state.saved, isEmpty);
    expect(state.social.messagesFor('maya'), isEmpty);
    expect(state.journey.sparks, 0);
    expect(prefs.getKeys().intersection(DeviceStorage.personalKeys), isEmpty);
    expect(testAppState(prefs).personalized, isFalse);
    studio.dispose();
    state.dispose();
  });

  test(
      'interrupted deletion never restores old personal data and can finish later',
      () async {
    final prefs = InterruptedPreferences(await SharedPreferences.getInstance());
    final state = testAppState(prefs);
    await state.updateProfile('Private', demoBirth);
    await state.social.saveMessage('maya', 'Private draft');
    await state.journey.complete(JourneyQuest.element);
    await prefs.delegate.setString('locale', 'zh');
    await prefs.delegate.setString('unrelated', 'keep');
    prefs.failRemoval.addAll(['profile', 'social.v1', 'journey.v1']);
    expect(await state.reset(), isFalse);
    expect(state.storage.deletionPending, isTrue);
    expect(state.personalized, isFalse);
    final restored = testAppState(prefs);
    expect(restored.personalized, isFalse);
    expect(restored.social.messagesFor('maya'), isEmpty);
    expect(restored.journey.sparks, 0);
    expect(exportDeviceData(restored), isNot(contains('Private')));
    expect(await restored.updateProfile('New', demoBirth), isFalse);
    prefs.failRemoval.clear();
    expect(await restored.reset(), isTrue);
    expect(prefs.get(DeviceStorage.resetKey), isNull);
    expect(prefs.get('profile'), isNull);
    expect(prefs.get('locale'), 'zh');
    expect(prefs.get('unrelated'), 'keep');
    restored.dispose();
    state.dispose();
  });

  test(
      'wrong-typed preferences cannot prevent startup or create unknown people',
      () async {
    SharedPreferences.setMockInitialValues({
      'saved': 23,
      'hidden': 'broken',
      'start.intent': true,
      'consents': ['malformed', 'terms@version@bad'],
      'reports': false,
      'locale': ['en']
    });
    final state = testAppState(await SharedPreferences.getInstance());
    expect(state.saved, isEmpty);
    expect(state.hidden, isEmpty);
    expect(state.reports, isEmpty);
    expect(state.consentStore.all(), isEmpty);
    expect(() => exportDeviceData(state), returnsNormally);
    expect(state.startIntent, isNull);
    expect(await state.toggleSaved('unknown'), isFalse);
    state.dispose();
  });

  test(
      'portable export includes studio charts and language but never API credentials',
      () async {
    final state = testAppState(await SharedPreferences.getInstance());
    final studio = StudioStore(state);
    await state.updateProfile('Sam', demoBirth);
    await state.setLocale(const Locale('zh'));
    await studio.updateSubjects(studio.primary, studio.secondary);
    studio.apiKey = 'private-memory-credential';
    final raw = exportDeviceData(state);
    final value = jsonDecode(raw) as Map;
    expect(value['formatVersion'], 3);
    expect(value['language'], 'zh');
    expect(value['studio']['studio.charts']['primary']['birth'], isNotNull);
    expect(raw, isNot(contains('private-memory-credential')));
    studio.dispose();
    state.dispose();
  });

  testWidgets(
      'startup storage failure has a working retry without erasing data',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(AppStartup(loadPreferences: () async {
      if (++calls == 1) throw StateError('private platform detail');
      return SharedPreferences.getInstance();
    }));
    await tester.pumpAndSettle();
    expect(find.text('Could not open your saved data'), findsOneWidget);
    expect(find.textContaining('private platform detail'), findsNothing);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('intent-chart')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
