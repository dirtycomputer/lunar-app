import 'dart:convert';
import 'app_state.dart';

/// One portable export contract for the device's actual persisted data.
/// Model credentials and transient conversation text are never included.
String exportDeviceData(AppState state) =>
    const JsonEncoder.withIndent('  ').convert({
      'app': 'FatePair',
      'formatVersion': 2,
      'scope': 'This device only',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'profile': state.personalized
          ? {'name': state.name, 'birth': state.birth.toJson()}
          : null,
      'saved': state.saved.toList(),
      'hidden': state.hidden.toList(),
      'social': state.social.toJson(),
      'journey': state.journey.toJson(),
      'reports': state.reports.map((r) => r.toJson()).toList(),
      'consents': state.consentStore
          .all()
          .map((c) => {'id': c.id, 'version': c.version, 'at': c.at})
          .toList(),
      'studio': {
        for (final key in ['studio.charts', 'studio.model', 'studio.style'])
          key: _decode(state.storage.read<String>(key)),
      },
      'language': state.storage.read<String>('locale'),
      'startIntent': state.startIntent?.name,
      'deletionPending': state.storage.deletionPending,
    });

Object? _decode(String? value) {
  if (value == null) return null;
  try {
    return jsonDecode(value);
  } catch (_) {
    return value;
  }
}
