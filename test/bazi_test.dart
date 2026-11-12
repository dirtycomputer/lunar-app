import 'fixtures/people.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunar_social/models/profile.dart';
import 'package:lunar_social/services/bazi.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  setUpAll(tz.initializeTimeZones);
  final service = BaziService();
  test('known eight-character fixture at standard meridian', () {
    final chart = service.calculate(BirthData(
        date: DateTime(2005, 12, 23),
        hour: 8,
        minute: 37,
        place: const BirthPlace('UTC+8 meridian', 'Asia/Shanghai', 120)));
    expect(chart.pillars.map((p) => p.value), ['乙酉', '戊子', '辛巳', '壬辰']);
    expect(chart.identity, 'Yin Metal');
    expect(chart.distribution.reduce((a, b) => a + b), closeTo(1, 1e-10));
  });
  test('year changes at start of spring, not January 1', () {
    const place = BirthPlace('UTC+8 meridian', 'Asia/Shanghai', 120);
    final before = service.calculate(BirthData(
        date: DateTime(1988, 2, 2), hour: 22, minute: 30, place: place));
    final after = service.calculate(BirthData(
        date: DateTime(1988, 2, 15), hour: 22, minute: 30, place: place));
    expect(before.pillars[0].value, '丁卯');
    expect(after.pillars[0].value, '戊辰');
  });
  test('day boundary is midnight, including late Rat hour', () {
    const place = BirthPlace('UTC+8 meridian', 'Asia/Shanghai', 120);
    final late = service.calculate(BirthData(
        date: DateTime(1988, 2, 15), hour: 23, minute: 30, place: place));
    expect(late.pillars[2].value, '庚子');
    expect(late.pillars[3].value, '戊子');
  });
  test('historical daylight saving and longitude affect solar time', () {
    final chart = service.calculate(BirthData(
        date: DateTime(1997, 6, 18),
        hour: 9,
        minute: 30,
        place: birthPlaces[0]));
    expect(chart.solarTime.hour, 8);
    expect(chart.solarTime.minute, 20);
  });
  test('nonexistent DST time is rejected', () {
    expect(
        () => service.calculate(BirthData(
            date: DateTime(2024, 3, 10),
            hour: 2,
            minute: 30,
            place: birthPlaces[1])),
        throwsFormatException);
  });
  test('repeated DST time resolves to earlier instant', () {
    final chart = service.calculate(BirthData(
        date: DateTime(2024, 11, 3),
        hour: 1,
        minute: 30,
        place: const BirthPlace('New York meridian', 'America/New_York', -75)));
    expect(chart.solarTime, DateTime.utc(2024, 11, 3, 0, 30));
  });
  test('unknown time excludes fourth pillar and renormalizes', () {
    final chart = service.calculate(BirthData(
        date: DateTime(1997, 6, 18), timeKnown: false, place: birthPlaces[0]));
    expect(chart.pillars.length, 3);
    expect(chart.timeKnown, isFalse);
    expect(chart.distribution.reduce((a, b) => a + b), closeTo(1, 1e-10));
  });
  test(
      'scores are bounded, deterministic, sorted and respond to profile changes',
      () {
    final chart = service.calculate(demoBirth);
    final matches = service.rank(chart, demoPeople);
    expect(matches.map((m) => m.score),
        orderedEquals(service.rank(chart, demoPeople).map((m) => m.score)));
    for (var i = 0; i < matches.length; i++) {
      expect(matches[i].score, inInclusiveRange(0, 100));
      if (i > 0) {
        expect(matches[i - 1].score, greaterThanOrEqualTo(matches[i].score));
      }
    }
    final other = service.calculate(demoPeople[1].birth);
    expect(
        service
            .rank(other, demoPeople)
            .map((m) => '${m.person.id}:${m.score}')
            .join(','),
        isNot(matches.map((m) => '${m.person.id}:${m.score}').join(',')));
  });
  test('age respects birthday rather than just birth year', () {
    final person = demoPeople.first;
    expect(person.ageAt(DateTime(2026, 5, 11)), 27);
    expect(person.ageAt(DateTime(2026, 5, 12)), 28);
  });
}
