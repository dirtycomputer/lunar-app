import 'dart:math' as math;
import 'package:timezone/timezone.dart' as tz;
import '../models/profile.dart';

enum TimeBasis { civil, meanSolar, apparentSolar }

extension TimeBasisLabel on TimeBasis {
  String get label =>
      ['Local clock time', 'Mean solar time', 'True solar time'][index];
}

class BirthClock {
  final DateTime utc, civil, meanSolar, apparentSolar;
  final String zone;
  final Duration offset;
  final bool daylightSaving, repeatedTime;
  final double equationMinutes;
  const BirthClock(
      {required this.utc,
      required this.civil,
      required this.meanSolar,
      required this.apparentSolar,
      required this.zone,
      required this.offset,
      required this.daylightSaving,
      required this.repeatedTime,
      required this.equationMinutes});
  DateTime at(TimeBasis basis) => switch (basis) {
        TimeBasis.civil => civil,
        TimeBasis.meanSolar => meanSolar,
        TimeBasis.apparentSolar => apparentSolar,
      };
  DateTime get calendarTime => utc.add(const Duration(hours: 8));
  static BirthClock resolve(BirthData data) {
    if (data.date.year < 1900 ||
        data.date.year > 2100 ||
        !data.place.longitude.isFinite ||
        data.place.longitude < -180 ||
        data.place.longitude > 180 ||
        (data.timeKnown &&
            (data.hour < 0 ||
                data.hour > 23 ||
                data.minute < 0 ||
                data.minute > 59))) {
      throw const FormatException(
          'Check the birth date, time and birthplace coordinates.');
    }
    final location = tz.getLocation(data.place.zone);
    final wall = tz.TZDateTime(
        location,
        data.date.year,
        data.date.month,
        data.date.day,
        data.timeKnown ? data.hour : 12,
        data.timeKnown ? data.minute : 0);
    if (wall.year != data.date.year ||
        wall.month != data.date.month ||
        wall.day != data.date.day ||
        (data.timeKnown &&
            (wall.hour != data.hour || wall.minute != data.minute))) {
      throw const FormatException(
          'This local time did not exist because the clocks changed. Please check your birth time.');
    }
    var utc = wall.toUtc();
    var repeated = false;
    for (final delta in [-180, -120, -90, -60, -30, 30, 60, 90, 120, 180]) {
      final instant = wall.toUtc().add(Duration(minutes: delta));
      final alternative = tz.TZDateTime.from(instant, location);
      if (alternative.year == wall.year &&
          alternative.month == wall.month &&
          alternative.day == wall.day &&
          alternative.hour == wall.hour &&
          alternative.minute == wall.minute) {
        repeated = true;
        if (instant.isBefore(utc)) utc = instant;
      }
    }
    final resolved = tz.TZDateTime.from(utc, location);
    final mean =
        utc.add(Duration(seconds: (data.place.longitude * 240).round()));
    final equation = equationOfTime(utc);
    return BirthClock(
        utc: utc,
        civil: DateTime.utc(
            wall.year, wall.month, wall.day, wall.hour, wall.minute),
        meanSolar: mean,
        apparentSolar: mean.add(Duration(seconds: (equation * 60).round())),
        zone: data.place.zone,
        offset: resolved.timeZoneOffset,
        daylightSaving: resolved.timeZone.isDst,
        repeatedTime: repeated,
        equationMinutes: equation);
  }

  // NOAA fractional-year approximation, in minutes. This is explicitly an
  // approximation rather than a sub-second ephemeris calculation.
  static double equationOfTime(DateTime instant) {
    final u = instant.toUtc();
    final day = u.difference(DateTime.utc(u.year)).inSeconds / 86400;
    final days =
        DateTime.utc(u.year + 1).difference(DateTime.utc(u.year)).inDays;
    final gamma = 2 * math.pi / days * (day - .5);
    return 229.18 *
        (.000075 +
            .001868 * math.cos(gamma) -
            .032077 * math.sin(gamma) -
            .014615 * math.cos(2 * gamma) -
            .040849 * math.sin(2 * gamma));
  }
}
