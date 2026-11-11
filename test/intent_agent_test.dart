import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:lunar_social/models/profile.dart';
import 'package:lunar_social/services/app_state.dart';
import 'package:lunar_social/services/chart_assistant.dart';
import 'package:lunar_social/services/intent_flow.dart';
import 'package:lunar_social/studio/chart_engine.dart';
import 'package:lunar_social/studio/interpretation.dart';
import 'package:lunar_social/studio/studio_store.dart';

void main() {
  setUpAll(tz.initializeTimeZones);
  setUp(() => SharedPreferences.setMockInitialValues({}));
  ChartContext context() => ChartContext(
      ChartEngine()
          .calculate(ChartSubject(name: 'Private name', birth: demoBirth)),
      now: DateTime.utc(2026, 11, 10, 8));
  test('intent selection survives restart and privacy reset returns to chooser',
      () async {
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs);
    expect(state.startIntent, isNull);
    expect(await state.chooseIntent(AppIntent.match), isTrue);
    expect(AppState(prefs).startIntent, AppIntent.match);
    await state.reset();
    expect(AppState(prefs).startIntent, isNull);
  });
  test(
      'random matching stays within eligible people and avoids consecutive repeats',
      () async {
    final state = AppState(await SharedPreferences.getInstance());
    final picker = RandomMatchPicker(random: Random(4));
    final eligible = state.matches.take(3).toList();
    String? previous;
    for (var i = 0; i < 20; i++) {
      final match = picker.pick(eligible)!;
      expect(eligible, contains(match));
      expect(match.person.id, isNot(previous));
      previous = match.person.id;
    }
    expect(picker.pick([]), isNull);
    expect(picker.pick(eligible.take(1).toList()), eligible.first);
  });
  test(
      'recent outlook uses current transit stems relative to the natal day master',
      () {
    final c = context();
    final month = c.period(OutlookPeriod.month);
    expect(month.god, tenGod(c.natal.master, month.value[0]));
    expect(c.periodReading(OutlookPeriod.month), contains(month.value));
    final evidence = jsonEncode(c.evidence());
    expect(evidence, contains('Private name'));
    expect(evidence, contains('San Francisco'));
    expect(evidence, contains('1997-06-18'));
  });
  test(
      'an unconfigured model gives a labelled calculated reference without a completion request',
      () async {
    final state = AppState(await SharedPreferences.getInstance());
    final studio = StudioStore(state);
    var posts = 0;
    final agent = ChartAgent(studio,
        clientFactory: () => MockClient((r) async {
              if (r.method == 'POST') posts++;
              return http.Response('{"configured":false}', 200);
            }));
    await agent.ask('What stands out in my chart?', context: context());
    expect(posts, 0);
    expect(agent.turns.last.source, 'reference');
    expect(agent.turns.last.text, contains(context().natal.energy.identity));
    expect(agent.busy, isFalse);
    agent.dispose();
    studio.dispose();
    state.dispose();
  });
  test(
      'professional model Q&A includes the question, prior turns and calculated evidence',
      () async {
    final state = AppState(await SharedPreferences.getInstance());
    final studio = StudioStore(state);
    await studio.configure(
        const ModelConfig(
            baseUrl: 'https://example.com/v1', model: 'study-model'),
        'memory-only-key');
    final requests = <Map<String, dynamic>>[];
    final agent = ChartAgent(studio,
        clientFactory: () => MockClient((r) async {
              requests.add(jsonDecode(r.body));
              return http.Response(
                  jsonEncode({
                    'choices': [
                      {
                        'message': {'content': 'A grounded answer.'}
                      }
                    ]
                  }),
                  200);
            }));
    await agent.ask('Explain my day master', context: context());
    await agent.ask('How does that relate to this month?', context: context());
    expect(agent.turns.last.source, 'model');
    expect(requests, hasLength(2));
    final messages = requests.last['messages'] as List;
    expect(messages[0]['content'], contains('precise terms'));
    expect(jsonDecode(messages[1]['content'])['question'],
        'Explain my day master');
    expect(messages[2]['content'], 'A grounded answer.');
    final packet = jsonDecode(messages.last['content']);
    expect(packet['question'], 'How does that relate to this month?');
    expect(packet['computedEvidence']['natal']['pillars'], hasLength(4));
    expect(jsonEncode(packet), isNot(contains('memory-only-key')));
    expect(packet['computedEvidence']['natal']['calculationInput']['name'],
        'Private name');
    agent.dispose();
    studio.dispose();
    state.dispose();
  });
  test(
      'a long conversation retains its first question and original reading context',
      () async {
    final state = AppState(await SharedPreferences.getInstance());
    final studio = StudioStore(state);
    await studio.configure(
        const ModelConfig(baseUrl: 'https://example.com/v1', model: 'test'),
        'memory-only-key');
    final packets = <Map<String, dynamic>>[];
    final agent = ChartAgent(studio,
        clientFactory: () => MockClient((r) async {
              packets.add(jsonDecode(r.body));
              return http.Response(
                  jsonEncode({
                    'choices': [
                      {
                        'message': {'content': 'Recorded answer.'}
                      }
                    ]
                  }),
                  200);
            }));
    for (var i = 0; i < 10; i++) {
      await agent.ask('Question $i',
          context: ChartContext(context().natal,
              now: DateTime.utc(2026, 11, 10, 8),
              viewContext: {
                'period': i == 0 ? 'month' : 'year',
                'readingMode': 'outlook'
              }));
    }
    final messages = packets.last['messages'] as List;
    expect(messages.length, 20);
    final first = jsonDecode(messages[1]['content']);
    expect(first['question'], 'Question 0');
    expect(first['computedEvidence']['userContext']['period'], 'month');
    expect(
        jsonDecode(messages.last['content'])['computedEvidence']['userContext']
            ['period'],
        'year');
    expect(agent.turns.length, 20);
    expect(jsonEncode(packets.last), isNot(contains('memory-only-key')));
    agent.dispose();
    studio.dispose();
    state.dispose();
  });
  test('cancelled answers do not arrive in a new conversation', () async {
    final state = AppState(await SharedPreferences.getInstance());
    final studio = StudioStore(state);
    await studio.configure(
        const ModelConfig(
            baseUrl: 'https://example.com/v1', model: 'study-model'),
        '');
    final response = Completer<http.Response>();
    final agent = ChartAgent(studio,
        clientFactory: () => MockClient((_) => response.future));
    final pending = agent.ask('Explain my chart', context: context());
    await Future<void>.delayed(Duration.zero);
    agent.clear();
    response.complete(http.Response(
        '{"choices":[{"message":{"content":"Stale answer"}}]}', 200));
    await pending;
    expect(agent.turns, isEmpty);
    expect(agent.busy, isFalse);
    agent.dispose();
    studio.dispose();
    state.dispose();
  });
  test('general Agent questions work before birth details are entered',
      () async {
    final state = AppState(await SharedPreferences.getInstance());
    final studio = StudioStore(state);
    final agent = ChartAgent(studio,
        clientFactory: () => MockClient(
            (_) async => http.Response('{"configured":false}', 200)));
    await agent.ask('What is BaZi?');
    expect(agent.turns.last.text, contains('Eight Characters'));
    expect(agent.turns.last.source, 'reference');
    agent.dispose();
    studio.dispose();
    state.dispose();
  });
  test('connected general Q&A does not manufacture a personal chart', () async {
    final state = AppState(await SharedPreferences.getInstance());
    final studio = StudioStore(state);
    await studio.configure(
        const ModelConfig(
            baseUrl: 'https://example.com/v1', model: 'study-model'),
        '');
    late Map<String, dynamic> body;
    final agent = ChartAgent(studio,
        clientFactory: () => MockClient((r) async {
              body = jsonDecode(r.body);
              return http.Response(
                  '{"choices":[{"message":{"content":"A general explanation."}}]}',
                  200);
            }));
    await agent.ask('How do the Ten Gods work?', userContext: {
      'learningProgress': {
        'completed': ['element'],
        'sparks': 20
      }
    });
    final packet = jsonDecode((body['messages'] as List).last['content']);
    expect(packet['computedEvidence']['personalChartAvailable'], false);
    expect(
        packet['computedEvidence']['userContext']['learningProgress']['sparks'],
        20);
    expect(packet['computedEvidence'].containsKey('natal'), isFalse);
    expect(agent.turns.last.source, 'model');
    agent.dispose();
    studio.dispose();
    state.dispose();
  });
}
