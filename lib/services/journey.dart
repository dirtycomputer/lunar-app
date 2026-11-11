import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bazi.dart';

enum JourneyQuest { element, outlook, encounter }

Element supportedElement(Element element) =>
    Element.values[(element.index + 1) % Element.values.length];

/// Learning progress only; never modifies a chart or a compatibility score.
class JourneyStore extends ChangeNotifier {
  static const storageKey = 'journey.v1';
  static const reward = 20;
  final SharedPreferences preferences;
  Set<JourneyQuest> _completed = {};
  Future<void> _pending = Future.value();
  JourneyStore(this.preferences) {
    try {
      final raw = preferences.getString(storageKey);
      if (raw == null) return;
      final value = jsonDecode(raw) as Map<String, dynamic>;
      if (value['version'] != 1 || value['completed'] is! List) return;
      _completed = JourneyQuest.values
          .where((q) => (value['completed'] as List).contains(q.name))
          .toSet();
    } catch (_) {
      // A damaged progress record cannot prevent charts or matching from opening.
    }
  }
  Set<JourneyQuest> get completed => UnmodifiableSetView(_completed);
  int get sparks => _completed.length * reward;
  bool get finished => _completed.length == JourneyQuest.values.length;
  Map<String, dynamic> toJson() => {
        'version': 1,
        'completed': [
          for (final q in JourneyQuest.values)
            if (_completed.contains(q)) q.name
        ],
      };

  // Writes are serialized; retrying or replaying a quest cannot mint more sparks.
  Future<int?> complete(JourneyQuest quest) {
    final operation = _pending.then((_) async {
      if (_completed.contains(quest)) return 0;
      final next = {..._completed, quest};
      try {
        final ok = await preferences.setString(
            storageKey,
            jsonEncode({
              'version': 1,
              'completed': next.map((q) => q.name).toList(),
            }));
        if (!ok) return null;
      } catch (_) {
        return null;
      }
      _completed = next;
      notifyListeners();
      return reward;
    });
    _pending = operation.then((_) {});
    return operation;
  }

  Future<bool> reset() {
    final operation = _pending.then((_) async {
      try {
        if (!await preferences.remove(storageKey)) return false;
      } catch (_) {
        return false;
      }
      _completed = {};
      notifyListeners();
      return true;
    });
    _pending = operation.then((_) {});
    return operation;
  }
}
