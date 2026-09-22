import 'dart:math' as math;
import 'package:lunar/lunar.dart';
import 'birth_clock.dart';
import '../models/profile.dart';

enum Element { wood, fire, earth, metal, water }

extension ElementInfo on Element {
  String get label => name[0].toUpperCase() + name.substring(1);
  String get character => ['木', '火', '土', '金', '水'][index];
  String get quality => [
        'Growth & kindness',
        'Passion & warmth',
        'Balance & trust',
        'Clarity & purpose',
        'Depth & intuition'
      ][index];
}

const stemNames = [
  'Jia',
  'Yi',
  'Bing',
  'Ding',
  'Wu',
  'Ji',
  'Geng',
  'Xin',
  'Ren',
  'Gui'
];
const stems = '甲乙丙丁戊己庚辛壬癸';
const branches = '子丑寅卯辰巳午未申酉戌亥';
const branchNames = [
  'Rat',
  'Ox',
  'Tiger',
  'Rabbit',
  'Dragon',
  'Snake',
  'Horse',
  'Goat',
  'Monkey',
  'Rooster',
  'Dog',
  'Pig'
];
const branchElements = [
  Element.water,
  Element.earth,
  Element.wood,
  Element.wood,
  Element.earth,
  Element.fire,
  Element.fire,
  Element.earth,
  Element.metal,
  Element.metal,
  Element.earth,
  Element.water
];

class Pillar {
  final String label, value;
  const Pillar(this.label, this.value);
  Element get element => Element.values[stems.indexOf(value[0]) ~/ 2];
  Element get branchElement => branchElements[branches.indexOf(value[1])];
  String get english =>
      '${stemNames[stems.indexOf(value[0])]} ${branchNames[branches.indexOf(value[1])]}';
}

class EnergyChart {
  final List<Pillar> pillars;
  final bool timeKnown;
  final DateTime solarTime;
  const EnergyChart(this.pillars, this.timeKnown, this.solarTime);
  Element get dayElement => pillars[2].element;
  String get polarity =>
      stems.indexOf(pillars[2].value[0]).isEven ? 'Yang' : 'Yin';
  String get identity => '$polarity ${dayElement.label}';
  List<double> get distribution {
    final counts = List<double>.filled(5, 0);
    for (final pillar in pillars) {
      counts[pillar.element.index]++;
      counts[pillar.branchElement.index]++;
    }
    return counts.map((e) => e / (pillars.length * 2)).toList();
  }
}

class MatchResult {
  final Person person;
  final EnergyChart chart;
  final int score, balance, connection, resonance;
  const MatchResult(this.person, this.chart, this.score, this.balance,
      this.connection, this.resonance);
  String get label => score >= 80
      ? 'Natural harmony'
      : score >= 65
          ? 'A lovely balance'
          : 'Room to discover';
}

class BaziService {
  EnergyChart calculate(BirthData data,
      {TimeBasis timeBasis = TimeBasis.meanSolar, int sect = 2}) {
    final clock = BirthClock.resolve(data);
    final adjusted = clock.at(timeBasis);
    EightChar chartAt(DateTime d) =>
        Solar.fromYmdHms(d.year, d.month, d.day, d.hour, d.minute, d.second)
            .getLunar()
            .getEightChar()
          ..setSect(sect);
    final seasonal = chartAt(clock.calendarTime);
    final daily = chartAt(adjusted);
    return EnergyChart([
      Pillar('Year', seasonal.getYear()),
      Pillar('Month', seasonal.getMonth()),
      Pillar('Day', daily.getDay()),
      if (data.timeKnown) Pillar('Hour', daily.getTime()),
    ], data.timeKnown, adjusted);
  }

  MatchResult match(EnergyChart mine, Person person) {
    final other = calculate(person.birth);
    final combined = List.generate(
        5, (i) => (mine.distribution[i] + other.distribution[i]) / 2);
    // Normalized entropy measures the balance of the combined visible elements.
    final entropy = -combined
            .where((p) => p > 0)
            .fold<double>(0, (sum, p) => sum + p * math.log(p)) /
        math.log(5);
    final balance = (entropy * 100).round();
    final a = mine.dayElement.index;
    final b = other.dayElement.index;
    final distance = (a - b).abs();
    final connection = a == b
        ? 82
        : (distance == 1 || distance == 4)
            ? 96
            : 60;
    final ba = branches.indexOf(mine.pillars[2].value[1]);
    final bb = branches.indexOf(other.pillars[2].value[1]);
    const unions = [
      {0, 1},
      {2, 11},
      {3, 10},
      {4, 9},
      {5, 8},
      {6, 7}
    ];
    final pair = {ba, bb};
    final harmony =
        unions.any((u) => u.length == pair.length && u.containsAll(pair));
    final resonance = harmony
        ? 98
        : (ba - bb).abs() == 6
            ? 50
            : (ba % 4 == bb % 4)
                ? 88
                : 72;
    final score = (balance * .45 + connection * .35 + resonance * .20).round();
    return MatchResult(person, other, score, balance, connection, resonance);
  }

  List<MatchResult> rank(EnergyChart mine, Iterable<Person> people) =>
      people.map((p) => match(mine, p)).toList()
        ..sort((a, b) => b.score != a.score
            ? b.score.compareTo(a.score)
            : a.person.id.compareTo(b.person.id));
}
