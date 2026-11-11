import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lunar_social/services/bazi.dart';
import 'package:lunar_social/services/journey.dart';
import 'journey_test.dart' show FlakyPreferences;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('every seed closes the supporting cycle with five distinct seals',
      () async {
    for (final seed in Element.values) {
      SharedPreferences.setMockInitialValues({});
      final store = JourneyStore(await SharedPreferences.getInstance());
      expect(await store.beginCycle(seed), isTrue);
      for (var step = 0; step < 5; step++) {
        final move = await store.placeElement(nextCycleElement(seed, step));
        expect(move!.correct, isTrue);
        expect(move.steps, step + 1);
        expect(move.earned, step == 4 ? 20 : 0);
        expect(store.sparks, step == 4 ? 20 : 0);
      }
      expect(store.seals, Element.values.toSet());
      expect(store.completed, {JourneyQuest.element});
      store.dispose();
    }
  });
  test('wrong and duplicate placements cannot advance or award sparks',
      () async {
    final store = JourneyStore(await SharedPreferences.getInstance());
    await store.beginCycle(Element.metal);
    expect((await store.placeElement(Element.fire))!.correct, isFalse);
    expect(store.cycleSteps, 0);
    final moves = await Future.wait(
        [store.placeElement(Element.water), store.placeElement(Element.water)]);
    expect(moves.map((m) => m!.correct), [true, false]);
    expect(store.cycleSteps, 1);
    expect(store.seals, {Element.water});
    expect(store.sparks, 0);
  });
  test(
      'a saved partial cycle resumes with its original seed after profile changes',
      () async {
    final prefs = await SharedPreferences.getInstance();
    final first = JourneyStore(prefs);
    await first.beginCycle(Element.metal);
    await first.placeElement(Element.water);
    await first.placeElement(Element.wood);
    final restored = JourneyStore(prefs);
    expect(await restored.beginCycle(Element.fire), isTrue);
    expect(restored.cycleSeed, Element.metal);
    expect(restored.cycleSteps, 2);
    expect(restored.seals, {Element.water, Element.wood});
    expect((await restored.placeElement(Element.fire))!.correct, isTrue);
  });
  test(
      'legacy rewards survive migration and replay does not mint a second reward',
      () async {
    SharedPreferences.setMockInitialValues({
      JourneyStore.storageKey: jsonEncode({
        'version': 1,
        'completed': ['element', 'outlook']
      })
    });
    final prefs = await SharedPreferences.getInstance();
    final store = JourneyStore(prefs);
    expect(store.sparks, 40);
    expect(store.gardenCompleted, {JourneyQuest.outlook});
    await store.beginCycle(Element.wood);
    for (var i = 0; i < 5; i++) {
      expect(
          (await store.placeElement(nextCycleElement(Element.wood, i)))!.earned,
          0);
    }
    expect(store.seals.length, 5);
    expect(store.gardenCompleted, {JourneyQuest.element, JourneyQuest.outlook});
    expect(JourneyStore(prefs).sparks, 40);
    await store.beginCycle(Element.water);
    expect(store.cycleSeed, Element.water);
    expect(store.cycleSteps, 0);
    expect(store.seals.length, 5);
  });
  test('failed saves preserve the pending step, collection and final reward',
      () async {
    final prefs = FlakyPreferences();
    final store = JourneyStore(prefs);
    await store.beginCycle(Element.earth);
    for (var i = 0; i < 4; i++) {
      await store.placeElement(nextCycleElement(Element.earth, i));
    }
    prefs.fail = true;
    expect(await store.placeElement(Element.earth), isNull);
    expect(store.cycleSteps, 4);
    expect(store.seals.length, 4);
    expect(store.sparks, 0);
    prefs.fail = false;
    expect((await store.placeElement(Element.earth))!.earned, 20);
    expect(store.seals.length, 5);
    expect(store.sparks, 20);
  });
  test('clearing progress also clears the active cycle and field-note seals',
      () async {
    final prefs = await SharedPreferences.getInstance();
    final store = JourneyStore(prefs);
    await store.beginCycle(Element.fire);
    await store.placeElement(Element.earth);
    expect(await store.reset(), isTrue);
    expect(store.cycleSteps, 0);
    expect(store.cycleSeed, isNull);
    expect(store.seals, isEmpty);
    expect(JourneyStore(prefs).seals, isEmpty);
  });
}
