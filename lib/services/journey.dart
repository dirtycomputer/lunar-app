import 'dart:collection';
import 'dart:convert';
import 'device_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bazi.dart';

enum JourneyQuest { element, outlook, encounter }

Element supportedElement(Element element) =>
    Element.values[(element.index + 1) % 5];
Element nextCycleElement(Element seed, int steps) =>
    Element.values[(seed.index + steps + 1) % 5];

class GardenMove {
  final bool correct;
  final int steps, earned;
  const GardenMove(this.correct, this.steps, this.earned);
}

/// Learning only. Neither the garden nor its collection changes a chart/score.
class JourneyStore extends ChangeNotifier {
  static const storageKey = 'journey.v1';
  static const reward = 20;
  final SharedPreferences preferences;
  Set<JourneyQuest> _completed = {};
  Set<Element> _seals = {};
  Element? _cycleSeed;
  int _cycleSteps = 0;
  bool _disposed = false;
  DeviceStorage get storage => DeviceStorage(preferences);

  JourneyStore(this.preferences) {
    try {
      final raw = storage.read<String>(storageKey);
      if (raw == null) return;
      final value = jsonDecode(raw) as Map<String, dynamic>;
      if (![1, 2].contains(value['version']) || value['completed'] is! List) {
        return;
      }
      _completed = JourneyQuest.values
          .where((q) => (value['completed'] as List).contains(q.name))
          .toSet();
      if (value['version'] != 2) return;
      final seals = value['seals'];
      if (seals is List) {
        _seals = Element.values.where((e) => seals.contains(e.name)).toSet();
      }
      final cycle = value['cycle'];
      if (cycle is Map &&
          cycle['steps'] is int &&
          (cycle['steps'] as int) >= 0 &&
          (cycle['steps'] as int) <= 5) {
        for (final element in Element.values) {
          if (cycle['seed'] == element.name) {
            _cycleSeed = element;
            _cycleSteps = cycle['steps'] as int;
          }
        }
      }
      if (_cycleSteps == 5 && !_completed.contains(JourneyQuest.element)) {
        _cycleSteps = 0;
      }
    } catch (_) {
      // Damaged progress cannot prevent charts or matching from opening.
    }
  }
  Set<JourneyQuest> get completed => UnmodifiableSetView(_completed);
  Set<Element> get seals => UnmodifiableSetView(_seals);
  Set<JourneyQuest> get gardenCompleted => UnmodifiableSetView({
        for (final quest in _completed)
          if (quest != JourneyQuest.element || _seals.length == 5) quest,
      });
  Element? get cycleSeed => _cycleSeed;
  int get cycleSteps => _cycleSteps;
  bool get hasCycleInProgress => _cycleSteps > 0 && _cycleSteps < 5;
  int get sparks => _completed.length * reward;
  bool get finished => _completed.length == JourneyQuest.values.length;
  Map<String, dynamic> _encode(Set<JourneyQuest> completed, Set<Element> seals,
          Element? seed, int steps) =>
      {
        'version': 2,
        'completed': [
          for (final q in JourneyQuest.values)
            if (completed.contains(q)) q.name
        ],
        'seals': [
          for (final e in Element.values)
            if (seals.contains(e)) e.name
        ],
        'cycle': seed == null ? null : {'seed': seed.name, 'steps': steps},
      };
  Map<String, dynamic> toJson() => {
        ..._encode(_completed, _seals, _cycleSeed, _cycleSteps),
        'gardenCompleted': gardenCompleted.map((quest) => quest.name).toList(),
      };
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<bool> beginCycle(Element seed) => storage.write(() async {
        if (hasCycleInProgress || (_cycleSteps == 0 && _cycleSeed == seed)) {
          return true;
        }
        if (!await preferences.setString(
            storageKey, jsonEncode(_encode(_completed, _seals, seed, 0)))) {
          return false;
        }
        _cycleSeed = seed;
        _cycleSteps = 0;
        _notify();
        return true;
      }, failure: false);

  /// Validate and save one link atomically with its seal and final reward.
  Future<GardenMove?> placeElement(Element choice) =>
      storage.write<GardenMove?>(() async {
        if (_cycleSeed == null ||
            _cycleSteps == 5 ||
            choice != nextCycleElement(_cycleSeed!, _cycleSteps)) {
          return GardenMove(false, _cycleSteps, 0);
        }
        final steps = _cycleSteps + 1;
        final seals = {..._seals, choice};
        final completed = {..._completed};
        final earned =
            steps == 5 && completed.add(JourneyQuest.element) ? reward : 0;
        if (!await preferences.setString(storageKey,
            jsonEncode(_encode(completed, seals, _cycleSeed, steps)))) {
          return null;
        }
        _completed = completed;
        _seals = seals;
        _cycleSteps = steps;
        _notify();
        return GardenMove(true, steps, earned);
      }, failure: null);

  Future<int?> complete(JourneyQuest quest) => storage.write<int?>(() async {
        if (_completed.contains(quest)) return 0;
        final next = {..._completed, quest};
        if (!await preferences.setString(storageKey,
            jsonEncode(_encode(next, _seals, _cycleSeed, _cycleSteps)))) {
          return null;
        }
        _completed = next;
        _notify();
        return reward;
      }, failure: null);

  void forget() {
    _completed = {};
    _seals = {};
    _cycleSeed = null;
    _cycleSteps = 0;
  }

  Future<bool> reset() => storage.write(() async {
        if (!await preferences.remove(storageKey)) return false;
        forget();
        _notify();
        return true;
      }, failure: false);
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
