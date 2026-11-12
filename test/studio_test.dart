import 'fixtures/app.dart';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lunar/lunar.dart';
import 'package:lunar_social/models/profile.dart';
import 'package:lunar_social/services/bazi.dart' as core;
import 'package:lunar_social/services/birth_clock.dart';
import 'package:lunar_social/studio/chart_engine.dart';
import 'package:lunar_social/studio/interpretation.dart';
import 'package:lunar_social/studio/seasonal_tools.dart';
import 'package:lunar_social/studio/studio_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz.initializeTimeZones);
  const meridian = BirthPlace('Test meridian', 'Asia/Shanghai', 120);
  ChartSubject subject(
          {DateTime? date,
          int hour = 8,
          int minute = 37,
          int sect = 2,
          bool known = true,
          TimeBasis basis = TimeBasis.meanSolar,
          BirthPlace place = meridian}) =>
      ChartSubject(
          name: 'Private name',
          sect: sect,
          basis: basis,
          birth: BirthData(
              date: date ?? DateTime(2005, 12, 23),
              hour: hour,
              minute: minute,
              timeKnown: known,
              place: place));
  final engine = ChartEngine();
  test('professional fixture verifies pillars, hidden gods, growth and palaces',
      () {
    final r = engine.calculate(subject());
    expect(r.pillars.map((p) => p.value), ['乙酉', '戊子', '辛巳', '壬辰']);
    expect(r.pillars.map((p) => p.god), ['偏财', '正印', '日主', '伤官']);
    expect(r.pillars[2].hidden, ['丙', '庚', '戊']);
    expect(r.pillars[2].hiddenGods, ['正官', '劫财', '正印']);
    expect(r.pillars.map((p) => p.stage), ['临官', '长生', '死', '墓']);
    expect(r.palaces['Fetal origin · 胎元'], '己卯');
    expect(r.pillars[2].naYin, '白蜡金');
    expect(r.pillars[2].voidBranches, '申酉');
  });
  test(
      'solar correction never shifts physical solar-term year/month boundaries',
      () {
    final t = ChartEngine.term(2026, '立春');
    ChartReport at(DateTime d, TimeBasis basis) => engine.calculate(subject(
        date: DateTime(d.year, d.month, d.day),
        hour: d.hour,
        minute: d.minute,
        basis: basis,
        place: const BirthPlace('Western China', 'Asia/Shanghai', 75)));
    final before = t.subtract(const Duration(minutes: 2));
    final after = t.add(const Duration(minutes: 2));
    expect(at(before, TimeBasis.civil).pillars.first.value, '乙巳');
    expect(at(after, TimeBasis.apparentSolar).pillars.first.value, '丙午');
    expect(at(after, TimeBasis.apparentSolar).pillars[1].value,
        at(after, TimeBasis.civil).pillars[1].value);
    expect(at(after, TimeBasis.apparentSolar).pillars.last.value,
        isNot(at(after, TimeBasis.civil).pillars.last.value));
  });
  test('late Rat day boundary conventions change day but preserve year/month',
      () {
    final a = engine
        .calculate(subject(date: DateTime(1988, 2, 15), hour: 23, minute: 30));
    final b = engine.calculate(
        subject(date: DateTime(1988, 2, 15), hour: 23, minute: 30, sect: 1));
    expect(a.eight.getDay(), '庚子');
    expect(b.eight.getDay(), '辛丑');
    expect(a.eight.getYear(), b.eight.getYear());
    expect(a.eight.getMonth(), b.eight.getMonth());
  });
  test('DST gap rejects and fold selects earlier occurrence transparently', () {
    const ny = BirthPlace('NY', 'America/New_York', -75);
    expect(
        () => BirthClock.resolve(
            subject(date: DateTime(2024, 3, 10), hour: 2, minute: 30, place: ny)
                .birth),
        throwsFormatException);
    final c = BirthClock.resolve(
        subject(date: DateTime(2024, 11, 3), hour: 1, minute: 30, place: ny)
            .birth);
    expect(c.utc, DateTime.utc(2024, 11, 3, 5, 30));
    expect(c.repeatedTime, isTrue);
    expect(c.daylightSaving, isTrue);
    expect(c.meanSolar, DateTime.utc(2024, 11, 3, 0, 30));
  });
  test('equation-of-time sign and approximate seasonal extrema', () {
    expect(BirthClock.equationOfTime(DateTime.utc(2026, 2, 11, 12)),
        closeTo(-14.2, .5));
    expect(BirthClock.equationOfTime(DateTime.utc(2026, 11, 3, 12)),
        closeTo(16.4, .5));
    final c = BirthClock.resolve(
        subject(date: DateTime(2026, 11, 3), hour: 12, minute: 0).birth);
    expect(c.apparentSolar.difference(c.meanSolar).inSeconds,
        closeTo(16.4 * 60, 30));
  });
  test('unknown time omits hour and hour-dependent palace evidence', () {
    final r = engine.calculate(subject(known: false));
    expect(r.pillars.length, 3);
    expect(r.palaces.length, 2);
    expect((r.evidence()['pillars'] as List).length, 3);
  });
  test('calculation inputs are included for authoritative server verification',
      () {
    final r = engine.calculate(subject());
    final input = r.evidence()['calculationInput'] as Map<String, dynamic>;
    expect(input, r.subject.toJson());
    expect(input['birth']['zone'], r.subject.birth.place.zone);
    expect(input['birth']['longitude'], r.subject.birth.place.longitude);
    expect(input['basis'], r.subject.basis.name);
    expect(input, isNot(contains('apiKey')));
  });

  test('all twelve solar months have correct boundaries and pillar mapping',
      () {
    for (final y in [1900, 2000, 2026, 2100]) {
      for (var m = 0; m < 12; m++) {
        final range = ChartEngine.monthRange(y, m);
        expect(range.$2.isAfter(range.$1), isTrue);
        final midpoint = range.$1.add(
            Duration(seconds: range.$2.difference(range.$1).inSeconds ~/ 2));
        final actual = Solar.fromYmdHms(midpoint.year, midpoint.month,
                midpoint.day, midpoint.hour, midpoint.minute, midpoint.second)
            .getLunar()
            .getMonthInGanZhiExact();
        expect(ChartEngine.monthly(y, m), actual, reason: '$y month $m');
      }
    }
    expect(ChartEngine.monthRange(2026, 11).$1.year, 2027);
  });
  test('fortune reverses with traditional sex and matches pinned engine start',
      () {
    final a = engine.calculate(subject());
    final b = engine
        .calculate(ChartSubject(name: 'B', birth: a.subject.birth, sex: 0));
    expect(engine.fortune(a).isForward(), isFalse);
    expect(engine.fortune(b).isForward(), isTrue);
    final original = Solar.fromYmdHms(2005, 12, 23, 8, 37, 0)
        .getLunar()
        .getEightChar()
        .getYun(1, 2);
    expect(engine.fortune(a).getStartSolar().toYmdHms(),
        original.getStartSolar().toYmdHms());
  });
  test('cross-chart triples include duplicate branches from second chart', () {
    final relations = ChartEngine.relations(
        [('A Year', '甲申'), ('A Month', '丙子'), ('A Day', '戊辰'), ('B Day', '庚申')],
        crossOnly: true);
    final triple = relations.where((r) => r.name == '三合');
    expect(triple.length, 1);
    expect(triple.first.targets, contains('B Day'));
    expect(
        relations
            .every((r) => r.targets.contains('A ') && r.targets.contains('B ')),
        isTrue);
  });
  test('common relations identify clashes harms and complete groups', () {
    final r = ChartEngine.relations(
        [('Year', '甲子'), ('Month', '己丑'), ('Day', '庚午'), ('Hour', '辛未')]);
    expect(r.any((r) => r.characters == '甲己' && r.name == '天干五合'), isTrue);
    expect(r.any((r) => r.characters == '子午' && r.name == '六冲'), isTrue);
    expect(r.any((r) => r.characters == '子未' && r.name == '六害'), isTrue);
  });
  test('symbolic stars state deterministic day stem and natal branch rules',
      () {
    final r =
        engine.calculate(subject()); // Xin day, Si day branch, You year branch
    final stars = ChartEngine.stars(r, [('Transit', '庚寅'), ('Transit2', '戊子')]);
    expect(stars.any((s) => s.name == '天乙贵人' && s.target == 'Transit'), isTrue);
    expect(stars.any((s) => s.name == '文昌' && s.target == 'Transit2'), isTrue);
    expect(stars.every((s) => s.basis.isNotEmpty), isTrue);
  });
  test('2026 Five Movements/Six Qi covers a contiguous solar-term year', () {
    final y = SeasonalTools.forYear(2026);
    expect(y.ganZhi, '丙午');
    expect(y.annualElement, core.Element.water);
    expect(y.excess, isTrue);
    expect(y.heaven, contains('Shaoyin'));
    expect(y.earth, contains('Yangming'));
    expect(y.qi[2].guest, y.heaven);
    expect(y.qi[5].guest, y.earth);
    for (var i = 0; i < 5; i++) {
      expect(y.qi[i].end, y.qi[i + 1].start);
    }
    expect(y.qi.last.end.year, 2027);
    expect(y.guests, [
      core.Element.water,
      core.Element.wood,
      core.Element.fire,
      core.Element.earth,
      core.Element.metal
    ]);
  });
  test('almanac preserves lunar leap month and splits midnight Rat periods',
      () {
    final day = AlmanacDay(DateTime(2023, 3, 22));
    expect(day.lunar.getMonth(), -2);
    expect(day.lunar.getDay(), 1);
    expect(day.hours.first.$2, '00:00–00:59');
    expect(day.hours.last.$2, '21:00–22:59');
    expect(day.lateRat.$2, '23:00–23:59');
    expect(Lunar.fromYmd(2023, -2, 1).getSolar().toYmd(), '2023-03-22');
  });
  test('custom model uses explicit style, proxy header and evidence JSON',
      () async {
    final client = MockClient((req) async {
      expect(req.url.toString(),
          'http://127.0.0.1:5199/api/model/chat/completions');
      expect(req.headers['X-Lunar-Client'], 'studio');
      expect(req.headers.containsKey('Authorization'), isFalse);
      final body = jsonDecode(req.body);
      expect(body['model'], 'auto');
      expect(body['messages'][0]['content'], contains('precise terms'));
      expect(
          jsonDecode(body['messages'][1]['content'])['computedEvidence']
              ['pillars'],
          isNotEmpty);
      return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'content': 'Computed reading'}
              }
            ]
          }),
          200);
    });
    final result = await InterpretationClient(client).generate(
        config: const ModelConfig(
            baseUrl: 'http://127.0.0.1:5199/api/model', model: 'auto'),
        apiKey: '',
        style: ReadingStyle.professional,
        evidence: engine.calculate(subject()).evidence(),
        topic: 'Study');
    expect(result, 'Computed reading');
  });
  test('model failure never leaks provider response and rejects blank output',
      () async {
    Future<String> run(http.Response r) =>
        InterpretationClient(MockClient((_) async => r)).generate(
            config: const ModelConfig(
                baseUrl: 'https://example.test/v1', model: 'test'),
            apiKey: 'test-session-key',
            style: ReadingStyle.plain,
            evidence: {},
            topic: 'Test');
    await expectLater(
        run(http.Response('secret debug details', 401)),
        throwsA(isA<ModelFailure>().having(
            (e) => e.message, 'safe message', isNot(contains('secret')))));
    await expectLater(
        run(http.Response('{"choices":[{"message":{"content":""}}]}', 200)),
        throwsA(isA<ModelFailure>()));
  });
  test(
      'endpoint validator prevents credentials in persisted URL and remote HTTP',
      () {
    for (final url in [
      'https://user:secret@example.test',
      'https://example.test?key=secret',
      'http://example.test/v1',
      'http://192.168.evil.test/v1'
    ]) {
      expect(() => ModelConfig(baseUrl: url, model: 'x').endpoint,
          throwsFormatException);
    }
    expect(
        const ModelConfig(baseUrl: 'https://example.test/v1/', model: 'x')
            .endpoint
            .path,
        '/v1/chat/completions');
  });
  test('store persists charts and settings, never key; reset clears studio',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final state = testAppState(prefs);
    addTearDown(state.dispose);
    final own = StudioStore(state);
    addTearDown(own.dispose);
    expect(await own.updateSubjects(subject(), own.secondary), isTrue);
    await own.configure(
        const ModelConfig(baseUrl: 'https://example.test/v1', model: 'custom'),
        'secret-memory-key');
    expect(prefs.getKeys().map(prefs.get).join(),
        isNot(contains('secret-memory-key')));
    final reloaded = StudioStore(state);
    expect(reloaded.primary.birth.date, subject().birth.date);
    expect(reloaded.apiKey, '');
    reloaded.dispose();
    await state.reset();
    expect(own.apiKey, '');
    expect(prefs.getString('studio.charts'), isNull);
    expect(own.primary.name, 'Alex');
  });
}
