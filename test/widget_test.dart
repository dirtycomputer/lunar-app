import 'fixtures/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:lunar_social/main.dart';
import 'package:lunar_social/models/profile.dart';
import 'package:lunar_social/services/app_state.dart';
import 'package:lunar_social/services/intent_flow.dart';
import 'package:lunar_social/services/journey.dart';
import 'package:lunar_social/services/platform_contracts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    tz.initializeTimeZones();
    await (FontLoader('Manrope')
          ..addFont(rootBundle.load('assets/fonts/Manrope-400.ttf')))
        .load();
    await (FontLoader('NotoSansSC')
          ..addFont(rootBundle.load('assets/fonts/NotoSansSC-Chart.ttf')))
        .load();
  });
  Future<AppState> start(WidgetTester tester,
      {Size size = const Size(1440, 1100),
      AppIntent? intent,
      bool personal = false,
      bool reducedMotion = false,
      double scale = 1}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final state = testAppState(await SharedPreferences.getInstance());
    if (personal) await state.updateProfile('Alex', demoBirth);
    if (intent != null) await state.chooseIntent(intent);
    await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(
            size: size,
            devicePixelRatio: 1,
            disableAnimations: reducedMotion,
            textScaler: TextScaler.linear(scale)),
        child: LunarApp(state: state)));
    await tester.pumpAndSettle();
    return state;
  }

  Future<void> finishCycle(WidgetTester tester) async {
    for (final name in ['water', 'wood', 'fire', 'earth', 'metal']) {
      final choice = find.byKey(ValueKey('element-answer-$name'));
      await tester.ensureVisible(choice);
      await tester.tap(choice);
      await tester.pumpAndSettle();
      if (name != 'metal') {
        await tester.tap(find.byKey(const ValueKey('quest-continue')));
        await tester.pumpAndSettle();
      }
    }
  }

  testWidgets(
      'first visit gives two primary cards and a secondary question entry',
      (tester) async {
    await start(tester);
    expect(find.text('Choose your path'), findsOneWidget);
    for (final value in AppIntent.values) {
      expect(find.byKey(ValueKey('intent-${value.name}')), findsOneWidget);
    }
    expect(tester.widget(find.byKey(const ValueKey('intent-agent'))),
        isA<OutlinedButton>());
    expect(
        tester.getSize(find.byKey(const ValueKey('intent-chart'))).height,
        greaterThan(
            tester.getSize(find.byKey(const ValueKey('intent-agent'))).height *
                3));
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Your energy, at a glance'), findsNothing);
    expect(find.text('A MOMENT OF WISDOM'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'the garden cycle gives feedback, collects five seals and rewards only once',
      (tester) async {
    final state = await start(tester);
    await tester.tap(find.byKey(const ValueKey('journey-open')));
    await tester.pumpAndSettle();
    for (final q in JourneyQuest.values) {
      expect(find.byKey(ValueKey('quest-${q.name}')), findsOneWidget);
    }
    await tester.tap(find.byKey(const ValueKey('quest-element')));
    await tester.pumpAndSettle();
    expect(find.text('Sample element'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('element-answer-fire')));
    await tester.pumpAndSettle();
    expect(state.journey.sparks, 0);
    expect(find.text('Take another look'), findsOneWidget);
    await finishCycle(tester);
    expect(state.journey.sparks, 20);
    expect(state.journey.seals.length, 5);
    expect(find.text('The garden is awake'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('quest-continue')));
    await tester.pumpAndSettle();
    expect(find.text('1 of 3 discoveries'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('quest-element')));
    await tester.pumpAndSettle();
    await finishCycle(tester);
    expect(find.text('Well remembered!'), findsOneWidget);
    expect(state.journey.sparks, 20);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'existing rewards still invite players into the new seal collection',
      (tester) async {
    final state = await start(tester);
    for (final quest in JourneyQuest.values) {
      await state.journey.complete(quest);
    }
    await tester.tap(find.byKey(const ValueKey('journey-open')));
    await tester.pumpAndSettle();
    expect(state.journey.sparks, 60);
    expect(find.text('2 of 3 discoveries'), findsOneWidget);
    expect(find.text('Collect the five seals'), findsOneWidget);
    expect(find.text('First light'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('quest-element')));
    await tester.pumpAndSettle();
    await finishCycle(tester);
    expect(state.journey.sparks, 60);
    expect(state.journey.gardenCompleted.length, 3);
    expect(find.text('Well remembered!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('field notes can be read before collecting a seal',
      (tester) async {
    final state = await start(tester);
    await tester.tap(find.byKey(const ValueKey('journey-open')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('garden-guide')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('guide-fire')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Fire represents warmth'), findsOneWidget);
    expect(find.text('Discover this seal in the cycle'), findsOneWidget);
    expect(state.journey.sparks, 0);
    expect(state.journey.seals, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'a spirit can be dragged onto its stone and the next link resumes after closing',
      (tester) async {
    final state = await start(tester);
    await tester.tap(find.byKey(const ValueKey('journey-open')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quest-element')));
    await tester.pumpAndSettle();
    final token = find.byKey(const ValueKey('element-answer-water'));
    final target = find.byKey(const ValueKey('cycle-drop-target'));
    await tester.timedDrag(
        token,
        tester.getCenter(target) - tester.getCenter(token),
        const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(state.journey.cycleSteps, 1);
    expect(state.journey.sparks, 0);
    await tester.tap(find.byTooltip('Close').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('journey-open')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quest-element')));
    await tester.pumpAndSettle();
    expect(find.text('1 / 5 links'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('element-answer-wood')));
    await tester.pumpAndSettle();
    expect(state.journey.cycleSteps, 2);
    expect(tester.takeException(), isNull);
  });
  testWidgets('all five spirits are visible above Continue on a phone',
      (tester) async {
    await start(tester, size: const Size(390, 844));
    await tester.tap(find.byKey(const ValueKey('journey-open')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('quest-element')));
    await tester.tap(find.byKey(const ValueKey('quest-element')));
    await tester.pumpAndSettle();
    final footer = tester.getRect(find.byKey(const ValueKey('quest-continue')));
    for (final name in ['wood', 'fire', 'earth', 'metal', 'water']) {
      final token = find.byKey(ValueKey('element-answer-$name'));
      expect(token.hitTestable(), findsOneWidget);
      expect(tester.getRect(token).bottom, lessThan(footer.top));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'a journey task opens a sample outlook without locking core features',
      (tester) async {
    final state = await start(tester, size: const Size(390, 844));
    await tester.tap(find.byKey(const ValueKey('journey-open')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quest-outlook')));
    await tester.pumpAndSettle();
    expect(find.text('This month'), findsOneWidget);
    expect(find.text('Sample chart'), findsOneWidget);
    expect(state.journey.sparks, 20);
    expect(state.personalized, isFalse);
    await tester.tap(find.byKey(const ValueKey('nav-match')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('random-match')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'journey and quiz fit a small screen with larger text and reduced motion',
      (tester) async {
    final state = await start(tester,
        size: const Size(320, 740), reducedMotion: true, scale: 1.6);
    await tester.tap(find.byKey(const ValueKey('journey-open')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('quest-element')));
    await tester.tap(find.byKey(const ValueKey('quest-element')));
    await tester.pumpAndSettle();
    await finishCycle(tester);
    expect(state.journey.sparks, 20);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const ValueKey('quest-continue')));
    await tester.tap(find.byKey(const ValueKey('quest-continue')));
    await tester.pumpAndSettle();
    expect(find.text('1 of 3 discoveries'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('quest-encounter')));
    await tester.tap(find.byKey(const ValueKey('quest-encounter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('random-match')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Close profile'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'phone matching entry shows people and random matching with three primary destinations',
      (tester) async {
    await start(tester, size: const Size(390, 844));
    await tester.ensureVisible(find.byKey(const ValueKey('intent-match')));
    await tester.tap(find.byKey(const ValueKey('intent-match')));
    await tester.pumpAndSettle();
    expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).destinations,
        hasLength(3));
    expect(find.byKey(const ValueKey('random-match')), findsOneWidget);
    expect(find.text('Sofia, 27'), findsOneWidget);
    expect(find.text('Your energy, at a glance'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'first chart entry validates birth details and consent before opening the chart',
      (tester) async {
    final state = await start(tester, size: const Size(390, 900));
    await tester.tap(find.byKey(const ValueKey('intent-chart')));
    await tester.pumpAndSettle();
    expect(find.text('Birth details'), findsOneWidget);
    final save = find.widgetWithText(FilledButton, 'Save');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your first name.'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Your first name'), 'Robin');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Please confirm you are 18+ and accept the terms.'),
        findsOneWidget);
    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(state.personalized, isTrue);
    expect(state.startIntent, AppIntent.chart);
    expect(find.text('Year'), findsOneWidget);
    expect(find.text('Reading'), findsOneWidget);
    expect(find.text('Your energy, at a glance'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'returning users open their chosen task and can return to intent selection',
      (tester) async {
    await start(tester, intent: AppIntent.match);
    expect(find.text('Choose your path'), findsNothing);
    await tester.tap(find.text('FatePair'));
    await tester.pumpAndSettle();
    expect(find.text('Choose your path'), findsOneWidget);
  });
  testWidgets(
      'matching search, empty state and reset work without energy cards',
      (tester) async {
    await start(tester, intent: AppIntent.match);
    final search = find.byKey(const ValueKey('discovery-search'));
    await tester.enterText(search, 'Paris');
    await tester.pumpAndSettle();
    expect(find.text('Sofia, 27'), findsOneWidget);
    expect(find.text('Maya, 28'), findsNothing);
    await tester.enterText(search, 'No such person');
    await tester.pumpAndSettle();
    expect(find.text('No people match these filters.'), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(find.byKey(const ValueKey('random-match')))
            .onPressed,
        isNull);
    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();
    expect(find.text('Maya, 28'), findsOneWidget);
  });
  testWidgets(
      'random matching opens a real eligible profile with compatibility details',
      (tester) async {
    final state = await start(tester, intent: AppIntent.match);
    await tester.enterText(
        find.byKey(const ValueKey('discovery-search')), 'Paris');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('random-match')));
    await tester.pumpAndSettle();
    expect(find.text('Sofia, 27'), findsNWidgets(2));
    expect(find.text('Compatibility'), findsOneWidget);
    expect(state.hidden, isEmpty);
    expect(state.journey.completed.contains(JourneyQuest.encounter), isFalse);
    await tester.tap(find.byTooltip('Close profile'));
    await tester.pumpAndSettle();
    expect(state.journey.completed.contains(JourneyQuest.encounter), isTrue);
    expect(state.journey.sparks, 20);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'saved profiles, invitations and local conversation drafts share the Match workflow',
      (tester) async {
    final state = await start(tester, intent: AppIntent.match);
    final person = state.matches.first.person;
    await tester.tap(find.byTooltip('Save ${person.name}'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('match-tab-1')));
    await tester.pumpAndSettle();
    expect(find.text('${person.name}, ${person.age}'), findsOneWidget);
    await tester.tap(find.text('${person.name}, ${person.age}'));
    await tester.pumpAndSettle();
    final invite = find.text('Connect with ${person.name}');
    await tester.ensureVisible(invite);
    await tester.tap(invite);
    await tester.pumpAndSettle();
    expect(state.social.invitations, contains(person.id));
    await tester.tap(find.text('Say hello'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('local-message-input')),
        'Hello from a local preview');
    await tester.tap(find.byTooltip('Save message locally'));
    await tester.pumpAndSettle();
    expect(state.social.messagesFor(person.id), hasLength(1));
    await tester.tap(find.byTooltip('Close conversation'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('match-tab-3')));
    await tester.pumpAndSettle();
    expect(find.text('Hello from a local preview'), findsOneWidget);
    await state.hide(person.id);
    await tester.pumpAndSettle();
    expect(find.text('No conversations yet.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'profile report flow still records the report and hides the person',
      (tester) async {
    final state = await start(tester, intent: AppIntent.match);
    await tester.tap(find.text('Sofia, 27'));
    await tester.pumpAndSettle();
    final report = find.text('Report this profile');
    await tester.ensureVisible(report);
    await tester.tap(report);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Impersonation or fake profile'));
    await tester.tap(find.text('Save local report'));
    await tester.pumpAndSettle();
    expect(state.reports.single.reasonIndex, ReportReason.impersonation.index);
    expect(state.hidden, contains('sofia'));
  });
  testWidgets(
      'chart and recent outlook expose the reading and a direct Agent action',
      (tester) async {
    await start(tester, intent: AppIntent.chart, personal: true);
    expect(find.text('Year'), findsOneWidget);
    expect(find.text('Reading'), findsOneWidget);
    expect(find.text('Chart details'), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
    await tester.tap(find.text('Read the details'));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsNWidgets(2));
    expect(
        tester
            .widgetList<SelectableText>(find.byType(SelectableText))
            .last
            .data,
        contains('Your day master is'));
    await tester.tap(find.text('Read the details'));
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsOneWidget);
    await tester.tap(find.text('Recent outlook'));
    await tester.pumpAndSettle();
    expect(find.text('This month'), findsOneWidget);
    expect(find.text('Reading'), findsOneWidget);
    expect(find.text('Ask Agent'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('asking from a reading retains the chart and returns to it',
      (tester) async {
    await start(tester, intent: AppIntent.chart, personal: true);
    final chartScroll = find.byType(SingleChildScrollView).first;
    expect(tester.getTopLeft(find.text('Reading')).dx,
        lessThan(tester.getTopLeft(find.text('Year')).dx));
    await tester.tap(find.text('Ask Agent'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('contextual-agent')), findsOneWidget);
    expect(find.text('My chart'), findsWidgets);
    expect(find.text('What stands out in my chart?'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('contextual-agent')), findsNothing);
    expect(find.text('Reading'), findsOneWidget);
    expect(chartScroll, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('phone contextual questions remain usable with the keyboard open',
      (tester) async {
    await start(tester,
        intent: AppIntent.chart, personal: true, size: const Size(390, 844));
    await tester.ensureVisible(find.text('Ask Agent'));
    await tester.tap(find.text('Ask Agent'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('contextual-agent')), findsOneWidget);
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('agent-question')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0);
    expect(find.text('Reading'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'advanced tools stay available without the old promotional heading',
      (tester) async {
    await start(tester, intent: AppIntent.chart, personal: true);
    await tester.tap(find.text('Tools'));
    await tester.pumpAndSettle();
    expect(find.text('Your four pillars'), findsOneWidget);
    expect(find.text('A deeper look at your universe.'), findsNothing);
    for (final tab in ['Luck cycles', 'Compare', 'Almanac', 'Model settings']) {
      final choice = find.widgetWithText(ChoiceChip, tab);
      await tester.ensureVisible(choice);
      await tester.tap(choice);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: tab);
    }
  });
  testWidgets(
      'Agent has a question composer and chart-specific suggested questions',
      (tester) async {
    await start(tester,
        intent: AppIntent.agent, personal: true, size: const Size(390, 844));
    expect(find.byKey(const ValueKey('agent-question')), findsOneWidget);
    expect(find.text('What stands out in my chart?'), findsOneWidget);
    expect(find.text('Connect model'), findsOneWidget);
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('settings preserve language and privacy access from every task',
      (tester) async {
    final state = await start(tester,
        intent: AppIntent.match, size: const Size(900, 1100));
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Privacy & your data'));
    await tester.pumpAndSettle();
    expect(find.text('Privacy & data'), findsOneWidget);
    await tester.tap(find.text('Legal & policies'));
    await tester.pumpAndSettle();
    expect(find.text('Terms of Service'), findsOneWidget);
    await tester.tap(find.text('Close').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close').last);
    await tester.pumpAndSettle();
    await state.setLocale(const Locale('zh'));
    await tester.pumpAndSettle();
    expect(find.text('匹配'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
