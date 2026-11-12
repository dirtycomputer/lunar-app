import 'fixtures/app.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:lunar_social/main.dart';
import 'package:lunar_social/models/profile.dart';
import 'package:lunar_social/services/chart_assistant.dart';
import 'package:lunar_social/studio/chart_engine.dart';
import 'package:lunar_social/studio/interpretation.dart';
import 'package:lunar_social/studio/studio_store.dart';
import 'package:lunar_social/ui/agent_page.dart';

void main() {
  setUpAll(() async {
    tz.initializeTimeZones();
    final font = FontLoader('Manrope');
    for (final weight in [400, 500, 600, 700]) {
      font.addFont(rootBundle.load('assets/fonts/Manrope-$weight.ttf'));
    }
    await font.load();
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));
  http.Response answer(String text) => http.Response(
      jsonEncode({
        'choices': [
          {
            'message': {'content': text}
          }
        ]
      }),
      200);

  test(
      'retry preserves the original question and context without duplicate turns',
      () async {
    final state = testAppState(await SharedPreferences.getInstance());
    final studio = StudioStore(state);
    await studio.configure(
        const ModelConfig(baseUrl: 'https://example.com/v1', model: 'test'),
        '');
    var attempts = 0;
    final requests = <Map<String, dynamic>>[];
    final agent = ChartAgent(studio,
        clientFactory: () => MockClient((request) async {
              requests.add(jsonDecode(request.body) as Map<String, dynamic>);
              if (++attempts == 2) return http.Response('{}', 503);
              return answer('A model answer.');
            }));
    await agent.ask('First question');
    final progress = {'sparks': 20};
    await agent
        .ask('My next question', userContext: {'learningProgress': progress});
    expect(agent.canRetry, isTrue);
    progress['sparks'] = 60;
    await agent.retry();
    expect(agent.turns.map((t) => t.text), [
      'First question',
      'A model answer.',
      'My next question',
      'A model answer.'
    ]);
    expect(agent.error, isNull);
    expect(agent.canRetry, isFalse);
    expect(requests[1], requests[2]);
    expect(jsonEncode(requests.last), contains('20'));
    agent.dispose();
    studio.dispose();
    state.dispose();
  });

  test('an offline status check is an explicit retryable failure', () async {
    final state = testAppState(await SharedPreferences.getInstance());
    final studio = StudioStore(state);
    var ready = false;
    final agent = ChartAgent(studio,
        clientFactory: () => MockClient((request) async {
              if (request.method == 'GET') {
                if (!ready) throw http.ClientException('offline');
                return http.Response('{"configured":true}', 200);
              }
              return answer('Connected again.');
            }));
    await agent.ask('What is BaZi?');
    expect(agent.error, contains('Could not connect'));
    expect(agent.turns.last.source, 'reference');
    ready = true;
    await agent.retry();
    expect(agent.turns.length, 2);
    expect(agent.turns.last.text, 'Connected again.');
    agent.dispose();
    studio.dispose();
    state.dispose();
  });

  test('cancel can be retried and a late answer cannot replace the new result',
      () async {
    final state = testAppState(await SharedPreferences.getInstance());
    final studio = StudioStore(state);
    await studio.configure(
        const ModelConfig(baseUrl: 'https://example.com/v1', model: 'test'),
        '');
    var calls = 0;
    final delayed = Completer<http.Response>();
    final agent = ChartAgent(studio,
        clientFactory: () => MockClient(
            (_) async => ++calls == 1 ? delayed.future : answer('New answer')));
    final pending = agent.ask('Keep this question');
    await Future<void>.delayed(Duration.zero);
    agent.cancel();
    expect(agent.canRetry, isTrue);
    await agent.retry();
    delayed.complete(answer('Stale answer'));
    await pending;
    expect(
        agent.turns.map((t) => t.text), ['Keep this question', 'New answer']);
    agent.dispose();
    studio.dispose();
    state.dispose();
  });

  test(
      'chart cache reuses reports and invalidates when time or convention changes',
      () {
    final cache = ChartContextCache();
    final subject = ChartSubject(name: 'Sam', birth: demoBirth);
    final now = DateTime.utc(2026, 11, 11, 10, 20);
    final first = cache.get(subject, now: now, viewContext: {'task': 'chart'});
    final second = cache.get(subject,
        now: now.add(const Duration(seconds: 30)),
        viewContext: {'task': 'match'});
    expect(identical(first.natal, second.natal), isTrue);
    expect(identical(first.transit, second.transit), isTrue);
    expect(first.viewContext['task'], 'chart');
    expect(second.viewContext['task'], 'match');
    expect(
        identical(
            cache.get(subject, now: now.add(const Duration(minutes: 1))).natal,
            first.natal),
        isFalse);
    final other = cache
        .get(ChartSubject(name: 'Sam', birth: demoBirth, sect: 1), now: now);
    expect(other.natal.subject.sect, 1);
  });

  testWidgets(
      'failed questions expose a retry that replaces the reference answer',
      (tester) async {
    final state = testAppState(await SharedPreferences.getInstance());
    final studio = StudioStore(state);
    await studio.configure(
        const ModelConfig(baseUrl: 'https://example.com/v1', model: 'test'),
        '');
    var calls = 0;
    final agent = ChartAgent(studio,
        clientFactory: () => MockClient((_) async => ++calls == 1
            ? http.Response('{}', 503)
            : answer('Recovered answer')));
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 740),
          viewInsets: EdgeInsets.only(bottom: 260),
          textScaler: TextScaler.linear(2),
        ),
        child: LunarApp(state: state)));
    final context = tester.element(find.byType(Scaffold).first);
    await showDialogForTest(
        tester,
        context,
        AgentPage(
            agent: agent,
            personalized: false,
            name: 'Alex',
            chart: null,
            onEdit: () {},
            onSettings: () {}));
    await tester.enterText(
        find.byKey(const ValueKey('agent-question')), 'What is BaZi?');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('agent-retry')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('agent-retry')));
    await tester.pumpAndSettle();
    expect(find.text('Recovered answer'), findsOneWidget);
    expect(agent.turns.length, 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    agent.dispose();
    studio.dispose();
    state.dispose();
  });
}

Future<void> showDialogForTest(
    WidgetTester tester, BuildContext context, Widget child) async {
  showDialog<void>(
      context: context,
      builder: (_) => Dialog.fullscreen(child: Scaffold(body: child)));
  await tester.pumpAndSettle();
}
