import 'fixtures/app.dart';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:lunar_social/services/bazi.dart';
import 'package:lunar_social/services/journey.dart';

class FlakyPreferences extends Fake implements SharedPreferences {
  String? value;
  bool fail = false;
  @override
  String? getString(String key) => value;
  @override
  Object? get(String key) => key == JourneyStore.storageKey ? value : null;
  @override
  Future<bool> setString(String key, String next) async {
    if (fail) return false;
    value = next;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    if (fail) return false;
    value = null;
    return true;
  }
}

void main() {
  setUpAll(tz.initializeTimeZones);
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('the five supporting relationships match the traditional cycle', () {
    const pairs = {
      Element.wood: Element.fire,
      Element.fire: Element.earth,
      Element.earth: Element.metal,
      Element.metal: Element.water,
      Element.water: Element.wood
    };
    for (final pair in pairs.entries) {
      expect(supportedElement(pair.key), pair.value);
    }
  });
  test('concurrent and repeated completion awards each discovery only once',
      () async {
    final prefs = await SharedPreferences.getInstance();
    final store = JourneyStore(prefs);
    final results = await Future.wait([
      store.complete(JourneyQuest.element),
      store.complete(JourneyQuest.element),
      store.complete(JourneyQuest.outlook),
      store.complete(JourneyQuest.encounter)
    ]);
    expect(results, [20, 0, 20, 20]);
    expect(store.sparks, 60);
    expect(store.finished, isTrue);
    final restored = JourneyStore(prefs);
    expect(restored.completed, JourneyQuest.values.toSet());
    expect(await restored.complete(JourneyQuest.element), 0);
    expect(restored.sparks, 60);
  });
  test('invalid progress cannot create extra rewards or block the app',
      () async {
    SharedPreferences.setMockInitialValues({
      JourneyStore.storageKey: jsonEncode({
        'version': 1,
        'completed': ['element', 'element', 'invented', 42],
        'sparks': 999999
      })
    });
    final prefs = await SharedPreferences.getInstance();
    expect(JourneyStore(prefs).sparks, 20);
    await prefs.setString(JourneyStore.storageKey, 'broken save');
    expect(JourneyStore(prefs).sparks, 0);
    await prefs.setString(
        JourneyStore.storageKey,
        jsonEncode({
          'version': 99,
          'completed': ['element']
        }));
    expect(JourneyStore(prefs).sparks, 0);
  });
  test('failed storage never displays an earned reward and can be retried',
      () async {
    final prefs = FlakyPreferences()..fail = true;
    final store = JourneyStore(prefs);
    expect(await store.complete(JourneyQuest.element), isNull);
    expect(store.sparks, 0);
    prefs.fail = false;
    expect(await store.complete(JourneyQuest.element), 20);
    prefs.fail = true;
    expect(await store.reset(), isFalse);
    expect(store.sparks, 20);
    prefs.fail = false;
    expect(await store.reset(), isTrue);
    expect(store.sparks, 0);
  });
  test('reset is ordered after pending writes and preserves unrelated settings',
      () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('unrelated', 'keep');
    final store = JourneyStore(prefs);
    final pending = store.complete(JourneyQuest.element);
    final reset = store.reset();
    expect(await pending, 20);
    expect(await reset, isTrue);
    expect(store.sparks, 0);
    expect(prefs.getString(JourneyStore.storageKey), isNull);
    expect(prefs.getString('unrelated'), 'keep');
    expect(JourneyStore(prefs).completed, isEmpty);
  });
  test('learning progress never changes a chart or recommendation ranking',
      () async {
    final state = testAppState(await SharedPreferences.getInstance());
    final pillars = state.chart.pillars.map((p) => p.value).toList();
    final ranking =
        state.matches.map((m) => '${m.person.id}:${m.score}').toList();
    for (final quest in JourneyQuest.values) {
      await state.journey.complete(quest);
    }
    expect(state.chart.pillars.map((p) => p.value), pillars);
    expect(state.matches.map((m) => '${m.person.id}:${m.score}'), ranking);
    expect(await state.reset(), isTrue);
    expect(state.journey.sparks, 0);
    expect(testAppState(state.preferences).journey.completed, isEmpty);
    state.dispose();
  });
}
