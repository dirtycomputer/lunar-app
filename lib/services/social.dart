import 'dart:convert';
import 'device_storage.dart';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A local-only composition preview. There is deliberately no delivery state,
/// remote recipient, or simulated reply; production transport is a separate task.
class LocalMessage {
  final String id, text;
  final DateTime createdAt;
  const LocalMessage(this.id, this.text, this.createdAt);
  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };
  factory LocalMessage.fromJson(Map<String, dynamic> value) => LocalMessage(
      value['id'] as String,
      value['text'] as String,
      DateTime.parse(value['createdAt'] as String));
}

class LocalSocialStore extends ChangeNotifier {
  static const storageKey = 'social.v1';
  static const maxMessageLength = 1000;
  final SharedPreferences preferences;
  final Set<String> knownIds;
  Set<String> _invitations = {};
  Map<String, List<LocalMessage>> _threads = {};
  DeviceStorage get storage => DeviceStorage(preferences);
  bool _disposed = false;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  int _sequence = 0;

  LocalSocialStore(this.preferences, {required this.knownIds}) {
    try {
      final raw = storage.read<String>(storageKey);
      if (raw == null) return;
      final value = jsonDecode(raw) as Map<String, dynamic>;
      if (value['version'] != 1) return;
      _invitations = (value['invitations'] as List)
          .whereType<String>()
          .where(knownIds.contains)
          .toSet();
      final threads = value['threads'] as Map<String, dynamic>;
      for (final entry in threads.entries) {
        if (!knownIds.contains(entry.key) || entry.value is! List) continue;
        final messages = <LocalMessage>[];
        for (final record in entry.value as List) {
          try {
            final message =
                LocalMessage.fromJson(record as Map<String, dynamic>);
            if (message.text.trim().isNotEmpty &&
                message.text.length <= maxMessageLength) {
              messages.add(message);
            }
          } catch (_) {
            // Recover independently: one damaged draft must not hide others.
          }
        }
        if (messages.isNotEmpty) _threads[entry.key] = messages;
      }
    } catch (_) {
      // An invalid local social save must not break charts or discovery.
    }
  }

  Set<String> get invitations => UnmodifiableSetView(_invitations);
  Iterable<String> get conversationIds => _threads.keys;
  List<LocalMessage> messagesFor(String id) =>
      List.unmodifiable(_threads[id] ?? const <LocalMessage>[]);
  Map<String, dynamic> toJson() => _encode(_invitations, _threads);

  Map<String, dynamic> _encode(
          Set<String> invitations, Map<String, List<LocalMessage>> threads) =>
      {
        'version': 1,
        'invitations': invitations.toList(),
        'threads': threads.map((id, messages) =>
            MapEntry(id, messages.map((m) => m.toJson()).toList())),
      };

  // Serialize writes so rapid saves cannot overwrite a more recent draft.
  // Publish in-memory changes only after storage confirms success.
  Future<bool> _change(
      void Function(Set<String>, Map<String, List<LocalMessage>>) change,
      {bool remove = false}) {
    return storage.write(() async {
      final invitations = {..._invitations};
      final threads =
          _threads.map((id, messages) => MapEntry(id, [...messages]));
      change(invitations, threads);
      try {
        final ok = remove
            ? await preferences.remove(storageKey)
            : await preferences.setString(
                storageKey, jsonEncode(_encode(invitations, threads)));
        if (!ok) return false;
      } catch (_) {
        return false;
      }
      _invitations = invitations;
      _threads = threads;
      _notify();
      return true;
    }, failure: false);
  }

  Future<bool> invite(String id) => !knownIds.contains(id)
      ? Future.value(false)
      : _change((invitations, _) => invitations.add(id));
  Future<bool> withdraw(String id) =>
      _change((invitations, _) => invitations.remove(id));
  Future<bool> saveMessage(String id, String text) {
    final trimmed = text.trim();
    if (!knownIds.contains(id) ||
        trimmed.isEmpty ||
        trimmed.length > maxMessageLength) {
      return Future.value(false);
    }
    return _change((_, threads) {
      final now = DateTime.now();
      (threads[id] ??= []).add(LocalMessage(
          '${now.microsecondsSinceEpoch}-${_sequence++}', trimmed, now));
    });
  }

  void forget() {
    _invitations = {};
    _threads = {};
  }

  Future<bool> clear() => _change((invitations, threads) {
        invitations.clear();
        threads.clear();
      }, remove: true);
}
