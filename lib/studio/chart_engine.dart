import 'package:lunar/lunar.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/profile.dart';
import '../services/bazi.dart' as core;
import '../services/birth_clock.dart';

const tenGodEnglish = {
  '比肩': 'Peer',
  '劫财': 'Rob wealth',
  '食神': 'Eating god',
  '伤官': 'Hurting officer',
  '偏财': 'Indirect wealth',
  '正财': 'Direct wealth',
  '七杀': 'Seven killings',
  '偏官': 'Seven killings',
  '正官': 'Direct officer',
  '偏印': 'Indirect resource',
  '正印': 'Direct resource',
  '日主': 'Day master',
};
const stageEnglish = [
  'Birth',
  'Bath',
  'Crowning',
  'Office',
  'Peak',
  'Decline',
  'Sickness',
  'Death',
  'Tomb',
  'Extinction',
  'Conception',
  'Nurture'
];
String tenGod(String master, String stem) =>
    LunarUtil.SHI_SHEN['$master$stem']!;
String bilingualGod(String god) => '${tenGodEnglish[god] ?? god} · $god';
String cycleEnglish(String value) =>
    value.length == 2 ? core.Pillar('', value).english : '—';
String dateLabel(DateTime value) =>
    '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
String clockLabel(DateTime value) =>
    '${dateLabel(value)} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}:${value.second.toString().padLeft(2, '0')}';
DateTime solarDate(Solar s) => DateTime.utc(s.getYear(), s.getMonth(),
    s.getDay(), s.getHour(), s.getMinute(), s.getSecond());

class ChartSubject {
  final String name;
  final BirthData birth;
  final int sex, sect;
  final TimeBasis basis;
  const ChartSubject(
      {required this.name,
      required this.birth,
      this.sex = 1,
      this.sect = 2,
      this.basis = TimeBasis.meanSolar});
  Map<String, dynamic> toJson() => {
        'name': name,
        'birth': birth.toJson(),
        'sex': sex,
        'sect': sect,
        'basis': basis.name
      };
  factory ChartSubject.fromJson(Map<String, dynamic> j) => ChartSubject(
      name: j['name'] as String,
      birth: BirthData.fromJson(j['birth'] as Map<String, dynamic>),
      sex: j['sex'] as int,
      sect: j['sect'] as int,
      basis: TimeBasis.values.byName(j['basis'] as String));
}

// Seasons use the physical birth instant in UTC+8; day/hour use the selected
// birthplace clock. Do not recompute solar-term boundaries on shifted solar time.
class _HybridEightChar extends EightChar {
  final EightChar daily;
  _HybridEightChar(EightChar seasonal, this.daily)
      : super(seasonal.getLunar()) {
    setSect(daily.getSect());
  }
  @override
  String getDay() => daily.getDay();
  @override
  String getDayGan() => daily.getDayGan();
  @override
  String getDayZhi() => daily.getDayZhi();
  @override
  int getDayGanIndex() => daily.getDayGanIndex();
  @override
  int getDayZhiIndex() => daily.getDayZhiIndex();
  @override
  String getTime() => daily.getTime();
  @override
  String getTimeGan() => daily.getTimeGan();
  @override
  String getTimeZhi() => daily.getTimeZhi();
  @override
  String getTimeDiShi() => getDiShi(core.branches.indexOf(getTimeZhi()));
  @override
  String getTaiXi() => daily.getTaiXi();
  @override
  String getDayXun() => daily.getDayXun();
  @override
  String getDayXunKong() => daily.getDayXunKong();
  @override
  String getTimeXun() => daily.getTimeXun();
  @override
  String getTimeXunKong() => daily.getTimeXunKong();
}

class PillarDetail {
  final String label, value, god, stage, naYin, voidBranches;
  final List<String> hidden, hiddenGods;
  const PillarDetail(
      {required this.label,
      required this.value,
      required this.god,
      required this.stage,
      required this.naYin,
      required this.voidBranches,
      required this.hidden,
      required this.hiddenGods});
  String get stageLabel =>
      '${stageEnglish[EightChar.CHANG_SHENG.indexOf(stage)]} · $stage';
  Map<String, dynamic> toJson() => {
        'pillar': label,
        'ganZhi': value,
        'tenGod': god,
        'hiddenStems': hidden,
        'hiddenTenGods': hiddenGods,
        'growthStage': stage,
        'naYin': naYin,
        'voidBranches': voidBranches
      };
}

class ChartReport {
  final ChartSubject subject;
  final BirthClock clock;
  final EightChar eight;
  final List<PillarDetail> pillars;
  final core.EnergyChart energy;
  ChartReport(this.subject, this.clock, this.eight, this.pillars, this.energy);
  String get master => eight.getDayGan();
  Map<String, String> get palaces => {
        'Fetal origin · 胎元': eight.getTaiYuan(),
        'Fetal breath · 胎息': eight.getTaiXi(),
        if (subject.birth.timeKnown) 'Life palace · 命宫': eight.getMingGong(),
        if (subject.birth.timeKnown) 'Body palace · 身宫': eight.getShenGong(),
      };
  Map<String, dynamic> evidence() => {
        'calculationInput': subject.toJson(),
        'engine': 'lunar 1.7.8 + Lunar Studio rules v1',
        'timeBasis': subject.basis.name,
        'dayBoundary': subject.sect == 2 ? '00:00' : '23:00',
        'timeKnown': subject.birth.timeKnown,
        'pillars': pillars.map((p) => p.toJson()).toList(),
        'palaces': palaces,
        'visibleElements': {
          for (final e in core.Element.values)
            e.name: energy.distribution[e.index]
        },
        'stars': ChartEngine.stars(
                this, pillars.map((p) => (p.label, p.value)).toList())
            .map((s) => s.toJson())
            .toList(),
        'relations': ChartEngine.relations(
                pillars.map((p) => (p.label, p.value)).toList())
            .map((r) => r.toJson())
            .toList(),
      };
}

class SymbolicStar {
  final String name, english, target, basis;
  const SymbolicStar(this.name, this.english, this.target, this.basis);
  Map<String, String> toJson() =>
      {'name': name, 'english': english, 'target': target, 'rule': basis};
}

class ChartRelation {
  final String name, english, targets, characters;
  const ChartRelation(this.name, this.english, this.targets, this.characters);
  Map<String, String> toJson() => {
        'name': name,
        'english': english,
        'targets': targets,
        'characters': characters
      };
}

class ChartEngine {
  ChartReport calculate(ChartSubject subject) {
    final clock = BirthClock.resolve(subject.birth);
    EightChar at(DateTime d) =>
        Solar.fromYmdHms(d.year, d.month, d.day, d.hour, d.minute, d.second)
            .getLunar()
            .getEightChar()
          ..setSect(subject.sect);
    final e =
        _HybridEightChar(at(clock.calendarTime), at(clock.at(subject.basis)));
    final energy = core.BaziService()
        .calculate(subject.birth, timeBasis: subject.basis, sect: subject.sect);
    final pillars = energy.pillars
        .map((p) => detail(p.label, p.value, e.getDayGan(),
            dayMaster: p.label == 'Day'))
        .toList();
    return ChartReport(subject, clock, e, pillars, energy);
  }

  static PillarDetail detail(String label, String value, String master,
      {bool dayMaster = false}) {
    final hidden = LunarUtil.ZHI_HIDE_GAN[value[1]]!;
    final stemIndex = core.stems.indexOf(master),
        branchIndex = core.branches.indexOf(value[1]);
    final index = (EightChar.CHANG_SHENG_OFFSET[master]! +
            (stemIndex.isEven ? branchIndex : -branchIndex)) %
        12;
    return PillarDetail(
        label: label,
        value: value,
        god: dayMaster ? '日主' : tenGod(master, value[0]),
        stage: EightChar.CHANG_SHENG[index],
        naYin: LunarUtil.NAYIN[value]!,
        voidBranches: LunarUtil.getXunKong(value),
        hidden: hidden,
        hiddenGods: hidden.map((s) => tenGod(master, s)).toList());
  }

  Yun fortune(ChartReport report) => report.eight.getYun(report.subject.sex, 2);
  DateTime fortuneStart(ChartReport report) {
    final beijing = solarDate(fortune(report).getStartSolar());
    return tz.TZDateTime.from(beijing.subtract(const Duration(hours: 8)),
        tz.getLocation(report.subject.birth.place.zone));
  }

  static String annual(int year) =>
      Solar.fromYmd(year, 7, 1).getLunar().getYearInGanZhiExact();
  static String monthly(int year, int index) {
    final start = core.stems.indexOf(annual(year)[0]) % 5 * 2 + 2;
    return '${core.stems[(start + index) % 10]}${core.branches[(2 + index) % 12]}';
  }

  static const monthTerms = [
    '立春',
    '惊蛰',
    '清明',
    '立夏',
    '芒种',
    '小暑',
    '立秋',
    '白露',
    '寒露',
    '立冬',
    '大雪',
    '小寒'
  ];
  static DateTime term(int year, String name) {
    final maps = [
      Solar.fromYmd(year, 6, 1).getLunar().getJieQiTable(),
      Solar.fromYmd(year, 1, 1).getLunar().getJieQiTable()
    ];
    for (final m in maps) {
      for (final item in m.entries) {
        if (item.key == name && item.value.getYear() == year) {
          return solarDate(item.value);
        }
      }
    }
    throw StateError('Solar term unavailable: $name $year');
  }

  static (DateTime, DateTime) monthRange(int year, int index) {
    final start = term(index == 11 ? year + 1 : year, monthTerms[index]);
    final end =
        term(index >= 10 ? year + 1 : year, monthTerms[(index + 1) % 12]);
    return (start, end);
  }

  static List<ChartRelation> relations(List<(String, String)> pillars,
      {bool crossOnly = false}) {
    final out = <ChartRelation>[];
    void add(String cn, String en, List<int> indices, bool stem) {
      if (crossOnly && !indices.any((i) => pillars[i].$1.startsWith('A '))) {
        return;
      }
      if (crossOnly && !indices.any((i) => pillars[i].$1.startsWith('B '))) {
        return;
      }
      out.add(ChartRelation(
          cn,
          en,
          indices.map((i) => pillars[i].$1).join(' ↔ '),
          indices.map((i) => pillars[i].$2[stem ? 0 : 1]).join('')));
    }

    bool pair(String pair, String a, String b) =>
        a != b && pair.contains(a) && pair.contains(b);
    for (var i = 0; i < pillars.length; i++) {
      for (var j = i + 1; j < pillars.length; j++) {
        final a = pillars[i].$2, b = pillars[j].$2;
        for (final v in ['甲己', '乙庚', '丙辛', '丁壬', '戊癸']) {
          if (pair(v, a[0], b[0])) {
            add('天干五合', 'Stem combination', [i, j], true);
          }
        }
        for (final v in ['甲庚', '乙辛', '丙壬', '丁癸']) {
          if (pair(v, a[0], b[0])) add('天干相冲', 'Stem clash', [i, j], true);
        }
        for (final rule in <(String, String, List<String>)>[
          ('六合', 'Six combination', ['子丑', '寅亥', '卯戌', '辰酉', '巳申', '午未']),
          ('六冲', 'Six clash', ['子午', '丑未', '寅申', '卯酉', '辰戌', '巳亥']),
          ('六害', 'Six harm', ['子未', '丑午', '寅巳', '卯辰', '申亥', '酉戌']),
          ('六破', 'Six break', ['子酉', '丑辰', '寅亥', '卯午', '巳申', '未戌']),
          ('相刑', 'Punishment pair', ['子卯', '寅巳', '巳申', '寅申', '丑戌', '戌未', '丑未']),
        ]) {
          if (rule.$3.any((v) => pair(v, a[1], b[1]))) {
            add(rule.$1, rule.$2, [i, j], false);
          }
        }
        if (a[1] == b[1] && '辰午酉亥'.contains(a[1])) {
          add('自刑', 'Self-punishment', [i, j], false);
        }
      }
    }
    for (final group in <(String, String, List<String>)>[
      ('三合', 'Three harmony', ['申子辰', '亥卯未', '寅午戌', '巳酉丑']),
      ('三会', 'Seasonal assembly', ['寅卯辰', '巳午未', '申酉戌', '亥子丑']),
      ('三刑全', 'Complete punishment', ['寅巳申', '丑戌未']),
    ]) {
      for (final chars in group.$3) {
        final options = chars
            .split('')
            .map((ch) => List.generate(pillars.length, (i) => i)
                .where((i) => pillars[i].$2[1] == ch)
                .toList())
            .toList();
        for (final i in options[0]) {
          for (final j in options[1]) {
            for (final k in options[2]) {
              add(group.$1, group.$2, [i, j, k], false);
            }
          }
        }
      }
    }
    return out;
  }

  static List<SymbolicStar> stars(
      ChartReport natal, List<(String, String)> targets) {
    final out = <SymbolicStar>[];
    final day = natal.master,
        dayBranch = natal.eight.getDayZhi(),
        yearBranch = natal.eight.getYearZhi();
    const noble = {
      '甲': '丑未',
      '戊': '丑未',
      '庚': '丑未',
      '乙': '子申',
      '己': '子申',
      '丙': '亥酉',
      '丁': '亥酉',
      '壬': '卯巳',
      '癸': '卯巳',
      '辛': '寅午'
    };
    const literary = {
      '甲': '巳',
      '乙': '午',
      '丙': '申',
      '丁': '酉',
      '戊': '申',
      '己': '酉',
      '庚': '亥',
      '辛': '子',
      '壬': '寅',
      '癸': '卯'
    };
    const salary = {
      '甲': '寅',
      '乙': '卯',
      '丙': '巳',
      '丁': '午',
      '戊': '巳',
      '己': '午',
      '庚': '申',
      '辛': '酉',
      '壬': '亥',
      '癸': '子'
    };
    const blade = {'甲': '卯', '丙': '午', '戊': '午', '庚': '酉', '壬': '子'};
    final dayVoid = LunarUtil.getXunKong(natal.eight.getDay());
    for (final t in targets) {
      void hit(String cn, String en, bool yes, String basis) {
        if (yes) out.add(SymbolicStar(cn, en, t.$1, basis));
      }

      hit('天乙贵人', 'Heavenly noble', noble[day]!.contains(t.$2[1]),
          'Day stem $day → ${noble[day]}');
      hit('文昌', 'Literary star', literary[day] == t.$2[1],
          'Day stem $day → ${literary[day]}');
      hit('禄神', 'Prosperity star', salary[day] == t.$2[1],
          'Day stem $day → ${salary[day]}');
      hit('羊刃', 'Yang blade', blade[day] == t.$2[1],
          'Yang day-stem convention; yin stems omitted');
      hit('空亡', 'Void', dayVoid.contains(t.$2[1]),
          'Natal day xun void: $dayVoid');
      final red = core.branches[(3 - core.branches.indexOf(yearBranch)) % 12];
      hit('红鸾', 'Red phoenix', red == t.$2[1],
          'Year branch $yearBranch → $red');
      hit(
          '天喜',
          'Heavenly joy',
          core.branches[(core.branches.indexOf(red) + 6) % 12] == t.$2[1],
          'Opposite the red phoenix branch');
      for (final anchor in [('Year', yearBranch), ('Day', dayBranch)]) {
        for (final group in [
          ('申子辰', '酉', '寅', '辰', '子'),
          ('寅午戌', '卯', '申', '戌', '午'),
          ('亥卯未', '子', '巳', '未', '卯'),
          ('巳酉丑', '午', '亥', '丑', '酉')
        ]) {
          if (!group.$1.contains(anchor.$2)) continue;
          hit('桃花', 'Peach blossom', t.$2[1] == group.$2,
              '${anchor.$1} branch ${anchor.$2} → ${group.$2}');
          hit('驿马', 'Travel horse', t.$2[1] == group.$3,
              '${anchor.$1} branch ${anchor.$2} → ${group.$3}');
          hit('华盖', 'Canopy', t.$2[1] == group.$4,
              '${anchor.$1} branch ${anchor.$2} → ${group.$4}');
          hit('将星', 'General star', t.$2[1] == group.$5,
              '${anchor.$1} branch ${anchor.$2} → ${group.$5}');
        }
      }
      hit(
          '魁罡',
          'Kui gang',
          t.$1 == 'Day' && ['庚辰', '庚戌', '壬辰', '戊戌'].contains(t.$2),
          'Natal day pillar only; four Kui gang combinations');
    }
    return out;
  }
}
