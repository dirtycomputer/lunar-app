import 'package:lunar/lunar.dart';
import '../services/bazi.dart' as core;
import 'chart_engine.dart';

class QiPeriod {
  final int index;
  final String host, guest;
  final DateTime start, end;
  const QiPeriod(this.index, this.host, this.guest, this.start, this.end);
}

class FivePhaseYear {
  final int year;
  final String ganZhi;
  final core.Element annualElement;
  final bool excess;
  final String heaven, earth;
  final List<core.Element> hosts, guests;
  final List<QiPeriod> qi;
  const FivePhaseYear(this.year, this.ganZhi, this.annualElement, this.excess,
      this.heaven, this.earth, this.hosts, this.guests, this.qi);
}

class SeasonalTools {
  static const qiNames = [
    'Jueyin · Wind wood',
    'Shaoyin · Sovereign fire',
    'Taiyin · Damp earth',
    'Shaoyang · Minister fire',
    'Yangming · Dry metal',
    'Taiyang · Cold water'
  ];
  static FivePhaseYear forYear(int year) {
    final gz = ChartEngine.annual(year);
    final stem = core.stems.indexOf(gz[0]),
        branch = core.branches.indexOf(gz[1]);
    const yearly = [
      core.Element.earth,
      core.Element.metal,
      core.Element.water,
      core.Element.wood,
      core.Element.fire
    ];
    final element = yearly[stem % 5], heaven = (branch + 1) % 6;
    const bounds = ['大寒', '春分', '小满', '大暑', '秋分', '小雪', '大寒'];
    final qi = List.generate(
        6,
        (i) => QiPeriod(
            i,
            qiNames[[0, 1, 3, 2, 4, 5][i]],
            qiNames[(heaven + i - 2) % 6],
            ChartEngine.term(year, bounds[i]),
            ChartEngine.term(i == 5 ? year + 1 : year, bounds[i + 1])));
    return FivePhaseYear(
        year,
        gz,
        element,
        stem.isEven,
        qiNames[heaven],
        qiNames[(heaven + 3) % 6],
        core.Element.values,
        List.generate(5, (i) => core.Element.values[(element.index + i) % 5]),
        qi);
  }
}

class AlmanacDay {
  final DateTime date;
  final Lunar lunar;
  AlmanacDay(this.date)
      : lunar = Solar.fromYmd(date.year, date.month, date.day).getLunar();
  String get lunarLabel =>
      '${lunar.getYearInChinese()}年 ${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}';
  List<String> get recommended => lunar.getDayYi();
  List<String> get avoided => lunar.getDayJi();
  List<(String, String, String, List<String>, List<String>)> get hours =>
      List.generate(12, (i) {
        final hour = i == 0 ? 0 : i * 2;
        final l = Solar.fromYmdHms(date.year, date.month, date.day, hour, 0, 0)
            .getLunar();
        return (
          l.getTimeInGanZhi(),
          i == 0
              ? '00:00–00:59'
              : '${(hour - 1).toString().padLeft(2, '0')}:00–${hour.toString().padLeft(2, '0')}:59',
          l.getTimeTianShenLuck(),
          l.getTimeYi(),
          l.getTimeJi()
        );
      });
  (String, String, String, List<String>, List<String>) get lateRat {
    final l =
        Solar.fromYmdHms(date.year, date.month, date.day, 23, 0, 0).getLunar();
    return (
      l.getTimeInGanZhi(),
      '23:00–23:59',
      l.getTimeTianShenLuck(),
      l.getTimeYi(),
      l.getTimeJi()
    );
  }
}

const activityEnglish = {
  '祭祀': 'Rituals',
  '祈福': 'Prayers',
  '求嗣': 'Family blessing',
  '开光': 'Consecration',
  '塑绘': 'Art & painting',
  '出行': 'Travel',
  '嫁娶': 'Marriage',
  '纳采': 'Betrothal',
  '订盟': 'Engagement',
  '安床': 'Set a bed',
  '移徙': 'Relocation',
  '入宅': 'Move into a home',
  '安香': 'Install an altar',
  '出火': 'Move sacred fire',
  '拆卸': 'Dismantling',
  '修造': 'Renovation',
  '动土': 'Groundwork',
  '上梁': 'Roof beams',
  '竖柱': 'Raise pillars',
  '开市': 'Open a business',
  '立券': 'Contracts',
  '交易': 'Trading',
  '纳财': 'Receive money',
  '挂匾': 'Hang a sign',
  '栽种': 'Planting',
  '纳畜': 'Raise animals',
  '牧养': 'Herding',
  '捕捉': 'Capture',
  '结网': 'Make nets',
  '畋猎': 'Hunting',
  '安葬': 'Burial',
  '破土': 'Funeral groundwork',
  '启钻': 'Exhumation',
  '修坟': 'Tomb repairs',
  '立碑': 'Memorial stone',
  '入殓': 'Encoffining',
  '移柩': 'Move a coffin',
  '除服': 'End mourning',
  '成服': 'Begin mourning',
  '解除': 'Release rites',
  '沐浴': 'Bathing',
  '剃头': 'Haircut',
  '理发': 'Haircut',
  '扫舍': 'House cleaning',
  '求医': 'Seek care (traditional listing)',
  '治病': 'Healing rites (traditional listing)',
  '赴任': 'Take office',
  '会亲友': 'Meet friends',
  '进人口': 'Welcome family',
  '裁衣': 'Tailoring',
  '冠笄': 'Coming of age',
  '作灶': 'Build a stove',
  '修饰垣墙': 'Repair walls',
  '平治道涂': 'Repair roads',
  '塞穴': 'Seal openings',
  '掘井': 'Dig a well',
  '开池': 'Dig a pond',
  '造仓': 'Build storage',
  '酝酿': 'Brewing',
  '伐木': 'Woodcutting',
  '合帐': 'Prepare curtains',
  '造庙': 'Build a temple',
  '教牛马': 'Train animals',
  '分居': 'Separate households',
  '余事勿取': 'Avoid other activities',
  '诸事不宜': 'No activities advised by this tradition',
  '诸事不忌': 'No traditional restrictions',
  '无': 'None',
};
String activityLabel(String value) =>
    '${activityEnglish[value] ?? 'Traditional activity'} · $value';
