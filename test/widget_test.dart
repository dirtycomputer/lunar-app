import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
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
    final state = AppState(await SharedPreferences.getInstance());
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
      'element practice provides a hint, saves one reward and supports replay',
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
    expect(find.text('What does Metal support?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('element-answer-fire')));
    await tester.pumpAndSettle();
    expect(state.journey.sparks, 0);
    expect(find.text('A little hint'), findsOneWidget);
    expect(find.text('Metal supports Water in the Five Elements cycle.'),
        findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('element-answer-water')));
    await tester.pumpAndSettle();
    expect(state.journey.sparks, 20);
    expect(find.text('Nice discovery!'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('quest-continue')));
    await tester.pumpAndSettle();
    expect(find.text('1 of 3 discoveries'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('quest-element')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('element-answer-water')));
    await tester.pumpAndSettle();
    expect(find.text('Well remembered!'), findsOneWidget);
    expect(state.journey.sparks, 20);
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
        size: const Size(360, 740), reducedMotion: true, scale: 1.6);
    await tester.tap(find.byKey(const ValueKey('journey-open')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('quest-element')));
    await tester.tap(find.byKey(const ValueKey('quest-element')));
    await tester.pumpAndSettle();
    final answer = find.byKey(const ValueKey('element-answer-water'));
    await tester.ensureVisible(answer);
    await tester.tap(answer);
    await tester.pumpAndSettle();
    expect(state.journey.sparks, 20);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const ValueKey('quest-continue')));
    await tester.tap(find.byKey(const ValueKey('quest-continue')));
    await tester.pumpAndSettle();
    expect(find.text('1 of 3 discoveries'), findsOneWidget);
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
    expect(find.text('YEAR'), findsOneWidget);
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
    await tester.tap(find.text('Submit report'));
    await tester.pumpAndSettle();
    expect(state.reports.single.reasonIndex, ReportReason.impersonation.index);
    expect(state.hidden, contains('sofia'));
  });
  testWidgets(
      'chart and recent outlook expose the reading and a direct Agent action',
      (tester) async {
    await start(tester, intent: AppIntent.chart, personal: true);
    expect(find.text('YEAR'), findsOneWidget);
    expect(find.text('Reading'), findsOneWidget);
    expect(find.text('Chart details'), findsOneWidget);
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
    expect(tester.getTopLeft(find.text('Reading')).dy,
        lessThan(tester.getTopLeft(find.text('YEAR')).dy));
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
