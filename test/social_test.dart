import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:lunar_social/services/app_state.dart';
import 'package:lunar_social/services/social.dart';

void main() {
  setUpAll(tz.initializeTimeZones);
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('invitations persist, are idempotent, and remain separate from saves',
      () async {
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs);
    expect(await state.social.invite('maya'), isTrue);
    expect(await state.social.invite('maya'), isTrue);
    expect(state.saved, isEmpty);
    final restored = AppState(prefs);
    expect(restored.social.invitations, {'maya'});
    expect(await restored.social.withdraw('maya'), isTrue);
    expect(AppState(prefs).social.invitations, isEmpty);
  });
  test('messages are validated local drafts and survive restoration', () async {
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs);
    expect(
        await state.social.saveMessage('maya', '  Hello, Maya 👋  '), isTrue);
    expect(await state.social.saveMessage('maya', '   '), isFalse);
    expect(await state.social.saveMessage('maya', 'x' * 1001), isFalse);
    expect(await state.social.saveMessage('unknown', 'Hello'), isFalse);
    expect(await state.social.invite('unknown'), isFalse);
    final restored = AppState(prefs);
    final message = restored.social.messagesFor('maya').single;
    expect(message.text, 'Hello, Maya 👋');
    expect(message.id, isNotEmpty);
    expect(
        message.createdAt, state.social.messagesFor('maya').single.createdAt);
    final json = jsonDecode(prefs.getString(LocalSocialStore.storageKey)!);
    expect(json['threads']['maya'][0].containsKey('delivered'), isFalse);
    expect(restored.social.invitations, isEmpty);
  });
  test('concurrent actions preserve every draft and invitation', () async {
    final state = AppState(await SharedPreferences.getInstance());
    final results = await Future.wait([
      state.social.saveMessage('maya', 'First thought'),
      state.social.invite('leo'),
      state.social.saveMessage('maya', 'And another thought'),
    ]);
    expect(results, everyElement(isTrue));
    expect(state.social.messagesFor('maya').map((m) => m.text),
        ['First thought', 'And another thought']);
    expect(state.social.messagesFor('maya').map((m) => m.id).toSet(),
        hasLength(2));
    expect(state.social.invitations, {'leo'});
  });
  test(
      'a malformed draft does not erase valid records or expose unknown profiles',
      () async {
    final good =
        LocalMessage('one', 'A valid draft', DateTime(2026, 1, 1)).toJson();
    SharedPreferences.setMockInitialValues({
      LocalSocialStore.storageKey: jsonEncode({
        'version': 1,
        'invitations': ['maya', 'unknown'],
        'threads': {
          'maya': [
            good,
            {'bad': true}
          ],
          'unknown': [good]
        }
      })
    });
    final state = AppState(await SharedPreferences.getInstance());
    expect(state.social.invitations, {'maya'});
    expect(state.social.messagesFor('maya').single.text, 'A valid draft');
    expect(state.social.messagesFor('unknown'), isEmpty);
  });
  test('privacy reset clears social data and preserves other preferences',
      () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('unrelated', 'keep');
    final state = AppState(prefs);
    await state.social.invite('maya');
    await state.social.saveMessage('maya', 'Hello');
    expect(await state.reset(), isTrue);
    expect(state.social.invitations, isEmpty);
    expect(state.social.conversationIds, isEmpty);
    expect(prefs.getString(LocalSocialStore.storageKey), isNull);
    expect(prefs.getString('unrelated'), 'keep');
  });
}
