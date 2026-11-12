import '../test/fixtures/people.dart';
import 'dart:convert';
import 'dart:io';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:lunar_social/models/profile.dart';
import 'package:lunar_social/services/birth_clock.dart';
import 'package:lunar_social/studio/chart_engine.dart';

void main() {
  tz.initializeTimeZones();
  final engine = ChartEngine();
  final subjects = <ChartSubject>[
    for (final person in demoPeople)
      ChartSubject(name: 'Fixture ${person.id}', birth: person.birth),
    ChartSubject(
        name: 'Known fixture',
        birth: BirthData(
            date: DateTime(2005, 12, 23),
            hour: 8,
            minute: 37,
            place: const BirthPlace('UTC+8 meridian', 'Asia/Shanghai', 120))),
    for (final basis in TimeBasis.values)
      for (final sect in [1, 2])
        ChartSubject(
            name: 'Late Zi ${basis.name} $sect',
            birth: BirthData(
                date: DateTime(2024, 2, 4),
                hour: 23,
                minute: 30,
                place: birthPlaces[8]),
            basis: basis,
            sect: sect),
    for (final minute in [26, 27])
      for (final longitude in [90.0, 150.0])
        ChartSubject(
            name: 'Li Chun $minute $longitude',
            birth: BirthData(
                date: DateTime(2024, 2, 4),
                hour: 16,
                minute: minute,
                place: BirthPlace('Boundary', 'Asia/Shanghai', longitude))),
    ChartSubject(
        name: 'Repeated DST',
        birth: BirthData(
            date: DateTime(2024, 11, 3),
            hour: 1,
            minute: 30,
            place: birthPlaces[1])),
    ChartSubject(
        name: 'Unknown hour',
        birth: BirthData(
            date: DateTime(1997, 6, 18),
            timeKnown: false,
            place: birthPlaces[0])),
    ChartSubject(
        name: 'Historical Kolkata',
        birth: BirthData(
            date: DateTime(1945, 7, 8), hour: 12, place: birthPlaces[10]),
        sex: 0),
  ];
  stdout.writeln(jsonEncode([
    for (final s in subjects)
      {
        'subject': s.toJson(),
        'expectedPillars':
            engine.calculate(s).pillars.map((p) => p.toJson()).toList(),
        'expectedUtc': engine.calculate(s).clock.utc.toIso8601String(),
        if (s.birth.timeKnown)
          'expectedFortuneStart':
              engine.fortuneStart(engine.calculate(s)).toIso8601String(),
      }
  ]));
}
