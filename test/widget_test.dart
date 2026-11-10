import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:lunar_social/main.dart';
import 'package:lunar_social/services/app_state.dart';
import 'package:lunar_social/services/platform_contracts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    tz.initializeTimeZones();
    final loader = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/fonts/Manrope-400.ttf'));
    await loader.load();
  });
  Future<AppState> start(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final state = AppState(await SharedPreferences.getInstance());
    await tester.pumpWidget(LunarApp(state: state));
    await tester.pumpAndSettle();
    return state;
  }

  testWidgets('desktop discovery renders without layout errors',
      (tester) async {
    await start(tester, const Size(1440, 1100));
    expect(find.text('Find your kind of energy'), findsOneWidget);
    expect(find.text('Your energy, at a glance'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('mobile navigation and guide remain usable', (tester) async {
    await start(tester, const Size(390, 844));
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.text('Guide').last);
    await tester.pumpAndSettle();
    expect(find.text('Ancient roots.\nHuman connections.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('My energy').last);
    await tester.pumpAndSettle();
    expect(find.text('A nature all your own.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('narrow mobile editor validates before saving', (tester) async {
    final state = await start(tester, const Size(360, 800));
    await tester.tap(find.text('Find my energy'));
    await tester.pumpAndSettle();
    expect(find.text('It starts with you.'), findsOneWidget);
    final submit = find.text('Discover my energy');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your first name.'), findsOneWidget);
    expect(state.personalized, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editor requires 18+ and terms consent before saving',
      (tester) async {
    final state = await start(tester, const Size(360, 900));
    await tester.tap(find.text('Find my energy'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Your first name').first, 'Robin');
    final submit = find.text('Discover my energy');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('Please confirm you are 18+ and accept the terms.'),
        findsOneWidget);
    expect(state.personalized, isFalse);
    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(state.personalized, isTrue);
    expect(state.hasConsent('age-terms', '1.0.0-draft'), isTrue);
  });
  testWidgets('profile detail offers report flow that records and hides',
      (tester) async {
    final state = await start(tester, const Size(900, 1100));
    await tester.tap(find.text('Sofia, 27'));
    await tester.pumpAndSettle();
    expect(find.text('Hide this profile'), findsOneWidget);
    final report = find.text('Report this profile');
    await tester.ensureVisible(report);
    await tester.tap(report);
    await tester.pumpAndSettle();
    expect(find.textContaining('Tell us what is wrong.'), findsOneWidget);
    await tester.tap(find.text('Impersonation or fake profile'));
    await tester.enterText(
        find
            .widgetWithText(
                TextField, 'Anything else we should know? (optional)')
            .first,
        'Using my photos');
    await tester.tap(find.text('Submit report'));
    await tester.pumpAndSettle();
    expect(state.reports.single.userId, 'sofia');
    expect(state.reports.single.reasonIndex, ReportReason.impersonation.index);
    expect(state.hidden, contains('sofia'));
    expect(find.text('Report received. This profile is now hidden.'),
        findsOneWidget);
  });
  testWidgets('privacy dialog leads to legal center and documents',
      (tester) async {
    await start(tester, const Size(900, 1100));
    await tester.tap(find.text('My energy').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Privacy & your data'));
    await tester.tap(find.text('Privacy & your data'));
    await tester.pumpAndSettle();
    expect(find.text('Your details stay yours.'), findsOneWidget);
    await tester.tap(find.text('Legal & policies'));
    await tester.pumpAndSettle();
    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Child Safety (CSAE) Policy'), findsOneWidget);
    expect(find.text('Content Moderation & Reporting Policy'), findsOneWidget);
    await tester.tap(find.text('Account & Data Deletion Policy'));
    await tester.pumpAndSettle();
    expect(find.textContaining('web deletion request URL'), findsOneWidget);
    await tester.tap(find.text('Close').last);
    await tester.pumpAndSettle();
    expect(find.text('Delete account & data'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('language picker switches the app language and persists',
      (tester) async {
    final state = await start(tester, const Size(900, 1100));
    await tester.tap(find.text('My energy').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Language'));
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    expect(find.text('Use system language'), findsOneWidget);
    final dialogList = find
        .descendant(
            of: find.byType(AlertDialog), matching: find.byType(Scrollable))
        .first;
    for (var i = 0; i < 8 && find.text('简体中文').evaluate().isEmpty; i++) {
      await tester.drag(dialogList, const Offset(0, -300));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('简体中文'));
    await tester.pumpAndSettle();
    expect(state.localeOverride, const Locale('zh'));
    expect(state.preferences.getString('locale'), 'zh');
    expect(find.text('语言'), findsNWidgets(2));
    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('隐私与数据'));
    await tester.pumpAndSettle();
    expect(find.text('法律与政策'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('save action appears in connections and can be undone',
      (tester) async {
    final state = await start(tester, const Size(1440, 1100));
    final person = state.matches.first.person;
    await tester.tap(find.byTooltip('Save ${person.name}'));
    await tester.pumpAndSettle();
    expect(state.saved, contains(person.id));
    await tester.tap(find.text('Connections').first);
    await tester.pumpAndSettle();
    expect(find.text('1 saved connections'), findsOneWidget);
    await tester.tap(find.byTooltip('Unsave ${person.name}'));
    await tester.pumpAndSettle();
    expect(find.text('Good connections are worth saving.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('filters produce an honest empty state and reset',
      (tester) async {
    await start(tester, const Size(1440, 1100));
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged!(100);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show connections'));
    await tester.pumpAndSettle();
    expect(find.text('A little more room to explore.'), findsOneWidget);
    await tester.tap(find.text('Reset filters'));
    await tester.pumpAndSettle();
    expect(find.text('6 connections to discover'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('studio tabs render on narrow mobile and editor preserves date',
      (tester) async {
    await start(tester, const Size(390, 844));
    await tester.tap(find.text('Studio').last);
    await tester.pumpAndSettle();
    expect(find.text('Your four pillars'), findsOneWidget);
    expect(tester.takeException(), isNull);
    for (final tab in [
      'Luck cycles',
      'Compare',
      'Almanac',
      'Five phases',
      'Library',
      'Model settings',
      'Birth chart'
    ]) {
      final choice = find.widgetWithText(ChoiceChip, tab);
      await tester.ensureVisible(choice);
      await tester.tap(choice);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: tab);
    }
    final edit = find.byTooltip('Edit Alex birth details');
    await tester.ensureVisible(edit);
    await tester.tap(edit);
    await tester.pumpAndSettle();
    expect(find.text('Chart details'), findsOneWidget);
    await tester.tap(find.text('Chinese lunar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gregorian'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Close chart editor'));
    await tester.pumpAndSettle();
    expect(find.text('Chart details'), findsNothing);
  });
  testWidgets('profile invitations and local messages appear in Connections',
      (tester) async {
    final state = await start(tester, const Size(1440, 1100));
    final person = state.matches.first.person;
    await tester.tap(find.text('${person.name}, ${person.age}'));
    await tester.pumpAndSettle();
    final invite = find.text('Connect with ${person.name}');
    await tester.ensureVisible(invite);
    await tester.tap(invite);
    await tester.pumpAndSettle();
    expect(state.social.invitations, contains(person.id));
    expect(find.text('Invitation pending'), findsOneWidget);
    await tester.tap(find.text('Say hello'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('local-message-input')),
        'Hello! What is your favourite trail?');
    await tester.tap(find.byTooltip('Save message locally'));
    await tester.pumpAndSettle();
    expect(state.social.messagesFor(person.id).single.text,
        'Hello! What is your favourite trail?');
    expect(find.text('Local conversation preview. No messages are delivered.'),
        findsOneWidget);
    await tester.tap(find.byTooltip('Close conversation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Connections').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('social-tab-1')));
    await tester.pumpAndSettle();
    expect(find.text('Invitation pending'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('social-tab-2')));
    await tester.pumpAndSettle();
    expect(find.text('Hello! What is your favourite trail?'), findsOneWidget);
    await state.hide(person.id);
    await tester.pumpAndSettle();
    expect(find.text('Hello! What is your favourite trail?'), findsNothing);
    expect(find.text('A thoughtful hello goes a long way.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('discovery search works with names, places and interests',
      (tester) async {
    final state = await start(tester, const Size(1440, 1100));
    final field = find.byKey(const ValueKey('discovery-search'));
    await tester.enterText(field, 'Paris');
    await tester.pumpAndSettle();
    expect(find.text('Sofia, 27'), findsOneWidget);
    expect(find.text('Maya, 28'), findsNothing);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('6 connections to discover'), findsOneWidget);
    await tester.enterText(field, 'Hiking');
    await tester.pumpAndSettle();
    expect(find.text('Maya, 28'), findsOneWidget);
    expect(state.matches, hasLength(6));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'phone composer and Connections remain usable with keyboard space',
      (tester) async {
    final state = await start(tester, const Size(360, 800));
    final person = state.matches.first.person;
    await state.social.saveMessage(person.id, 'A local hello');
    await tester.tap(find.byKey(const ValueKey('nav-connections')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('social-tab-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A local hello'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('local-message-input')), 'Another hello');
    await tester.tap(find.byTooltip('Save message locally'));
    await tester.pumpAndSettle();
    expect(state.social.messagesFor(person.id), hasLength(2));
    expect(tester.takeException(), isNull);
  });
}
