import 'package:shared_preferences/shared_preferences.dart';

/// One write queue for every store using the same preferences instance.
/// A durable deletion marker prevents partially deleted data reappearing after
/// a crash. Language and unrelated application preferences are preserved.
class DeviceStorage {
  static const resetKey = 'privacy.reset.pending';
  static const personalKeys = {
    'profile',
    'saved',
    'hidden',
    'consents',
    'reports',
    'studio.charts',
    'studio.model',
    'studio.style',
    'start.intent',
    'social.v1',
    'journey.v1',
  };
  static final _instances = Expando<DeviceStorage>();
  final SharedPreferences preferences;
  Future<void> _pending = Future.value();
  bool _resetting = false;
  int _generation = 0;
  DeviceStorage._(this.preferences);
  factory DeviceStorage(SharedPreferences preferences) =>
      _instances[preferences] ??= DeviceStorage._(preferences);

  bool get deletionPending => preferences.get(resetKey) == true;

  T? read<T>(String key) {
    if (personalKeys.contains(key) && deletionPending) return null;
    final value = preferences.get(key);
    return value is T ? value : null;
  }

  Future<T> write<T>(Future<T> Function() operation, {required T failure}) {
    final generation = _generation;
    if (_resetting || deletionPending) return Future.value(failure);
    final next = _pending.then((_) async {
      if (generation != _generation || deletionPending) return failure;
      try {
        return await operation();
      } catch (_) {
        return failure;
      }
    });
    _pending = next.then((_) {});
    return next;
  }

  Future<bool> reset({required void Function() onMarked}) {
    if (_resetting) return Future.value(false);
    _resetting = true;
    _generation++;
    final next = _pending.then((_) async {
      try {
        if (!deletionPending && !await preferences.setBool(resetKey, true)) {
          return false;
        }
        // Hide all personal state once deletion intent is durable, even when
        // an individual remove fails. A retry/startup finishes the cleanup.
        onMarked();
        var complete = true;
        for (final key in personalKeys) {
          try {
            if (!await preferences.remove(key)) complete = false;
          } catch (_) {
            complete = false;
          }
        }
        return complete && await preferences.remove(resetKey);
      } catch (_) {
        return false;
      } finally {
        _resetting = false;
      }
    });
    _pending = next.then((_) {});
    return next;
  }
}
