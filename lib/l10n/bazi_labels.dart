import '../services/bazi.dart';
import 'generated/app_localizations.dart';

String elementLabel(AppLocalizations l, Element e) => switch (e) {
      Element.wood => l.elementWood,
      Element.fire => l.elementFire,
      Element.earth => l.elementEarth,
      Element.metal => l.elementMetal,
      Element.water => l.elementWater,
    };

String elementQuality(AppLocalizations l, Element e) => switch (e) {
      Element.wood => l.qualityWood,
      Element.fire => l.qualityFire,
      Element.earth => l.qualityEarth,
      Element.metal => l.qualityMetal,
      Element.water => l.qualityWater,
    };

String elementQualityShort(AppLocalizations l, Element e) => switch (e) {
      Element.wood => l.qualityWoodShort,
      Element.fire => l.qualityFireShort,
      Element.earth => l.qualityEarthShort,
      Element.metal => l.qualityMetalShort,
      Element.water => l.qualityWaterShort,
    };

String polarityLabel(AppLocalizations l, EnergyChart chart) =>
    chart.polarity == 'Yang' ? l.polarityYang : l.polarityYin;

String identityLabel(AppLocalizations l, EnergyChart chart) =>
    '${polarityLabel(l, chart)} ${elementLabel(l, chart.dayElement)}';

String pillarLabel(AppLocalizations l, Pillar pillar) => switch (pillar.label) {
      'Year' => l.pillarYear,
      'Month' => l.pillarMonth,
      'Day' => l.pillarDay,
      _ => l.pillarHour,
    };

const koStems = [
  '갑',
  '을',
  '병',
  '정',
  '무',
  '기',
  '경',
  '신',
  '임',
  '계'
];

String stemDisplay(AppLocalizations l, Pillar pillar) {
  final i = stems.indexOf(pillar.value[0]);
  final code = l.localeName;
  if (code.startsWith('zh') || code == 'ja') {
    return stems[i];
  }
  if (code == 'ko') {
    return koStems[i];
  }
  return stemNames[i];
}

String branchLabel(AppLocalizations l, Pillar pillar) {
  final i = branches.indexOf(pillar.value[1]);
  return switch (i) {
    0 => l.branchRat,
    1 => l.branchOx,
    2 => l.branchTiger,
    3 => l.branchRabbit,
    4 => l.branchDragon,
    5 => l.branchSnake,
    6 => l.branchHorse,
    7 => l.branchGoat,
    8 => l.branchMonkey,
    9 => l.branchRooster,
    10 => l.branchDog,
    _ => l.branchPig,
  };
}

String comboLabel(AppLocalizations l, Pillar pillar) =>
    '${stemDisplay(l, pillar)} ${branchLabel(l, pillar)}';

String matchLabel(AppLocalizations l, int score) => score >= 80
    ? l.matchNatural
    : score >= 65
        ? l.matchLovely
        : l.matchRoom;
