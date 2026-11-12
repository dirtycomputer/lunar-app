import 'fixtures/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:lunar_social/models/profile.dart';
import 'package:lunar_social/services/platform_contracts.dart';

void main() {
  setUpAll(tz.initializeTimeZones);
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('saved connections survive state restoration', () async {
    final prefs = await SharedPreferences.getInstance();
    final state = testAppState(prefs);
    expect(await state.toggleSaved('maya'), isTrue);
    expect(testAppState(prefs).saved, contains('maya'));
    await state.toggleSaved('maya');
    expect(testAppState(prefs).saved, isEmpty);
  });
  test('profile save recalculates chart and survives restoration', () async {
    final prefs = await SharedPreferences.getInstance();
    final state = testAppState(prefs);
    final before = state.chart.pillars.map((p) => p.value).join();
    expect(await state.updateProfile('Sam', demoPeople[1].birth), isTrue);
    expect(state.chart.pillars.map((p) => p.value).join(), isNot(before));
    final restored = testAppState(prefs);
    expect(restored.name, 'Sam');
    expect(restored.personalized, isTrue);
    expect(restored.birth.place.zone, 'Europe/London');
  });
  test('privacy reset removes personal state but preserves unrelated settings',
      () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('unrelated', 'keep');
    final state = testAppState(prefs);
    await state.updateProfile('Sam', demoBirth);
    await state.toggleSaved('maya');
    await state.hide('leo');
    expect(await state.reset(), isTrue);
    final restored = testAppState(prefs);
    expect(restored.personalized, isFalse);
    expect(restored.saved, isEmpty);
    expect(restored.hidden, isEmpty);
    expect(prefs.getString('unrelated'), 'keep');
  });
  test('corrupt profile falls back to an explicit sample', () async {
    SharedPreferences.setMockInitialValues({'profile': 'invalid json'});
    final state = testAppState(await SharedPreferences.getInstance());
    expect(state.personalized, isFalse);
    expect(state.persistenceError, isNotNull);
  });
  test('consents and reports persist and reset with the account', () async {
    final prefs = await SharedPreferences.getInstance();
    final state = testAppState(prefs);
    expect(state.hasConsent('age-terms', '1.0.0-draft'), isFalse);
    await state.acceptConsent('age-terms', '1.0.0-draft');
    expect(state.hasConsent('age-terms', '1.0.0-draft'), isTrue);
    expect(
        await state.submitReport(
            'leo', ReportReason.impersonation, 'Stolen photos'),
        isTrue);
    expect(state.reports.single.userId, 'leo');
    expect(state.reports.single.reasonIndex, ReportReason.impersonation.index);
    final restored = testAppState(prefs);
    expect(restored.hasConsent('age-terms', '1.0.0-draft'), isTrue);
    expect(restored.reports.single.note, 'Stolen photos');
    expect(await restored.reset(), isTrue);
    final cleared = testAppState(prefs);
    expect(cleared.reports, isEmpty);
    expect(cleared.hasConsent('age-terms', '1.0.0-draft'), isFalse);
  });
}
