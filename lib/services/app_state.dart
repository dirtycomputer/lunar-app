import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';
import 'bazi.dart';
import 'platform_contracts.dart';
import 'social.dart';
import 'intent_flow.dart';
import 'journey.dart';
import 'device_storage.dart';
import 'people_repository.dart';
import 'sharing.dart';

class AppState extends ChangeNotifier {
  final SharedPreferences preferences;
  final DeviceStorage storage;
  bool _disposed = false;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  final BaziService service = BaziService();
  final LocalConsentService consentStore;
  final LocalModerationService moderationStore;
  late final LocalSocialStore social;
  late final JourneyStore journey;
  late final SharingStore sharing;
  late BirthData birth;
  late EnergyChart chart;
  late List<MatchResult> matches;
  final PeopleRepository? _peopleRepository;
  List<Person> _people;
  final Set<String> _knownIds = {};
  List<Person> get people => _people;
  Future<void>? _catalogTask;
  bool catalogLoading = false;
  String? catalogError, catalogRevision;
  String name = 'Alex';
  bool personalized = false;
  final Set<String> saved = {};
  final Set<String> hidden = {};
  List<ReportRecord> reports = [];
  String? persistenceError;
  int resetGeneration = 0;
  AppIntent? startIntent;
  AppState(this.preferences,
      {PeopleRepository? peopleRepository,
      SharingRepository? sharingRepository,
      List<Person>? initialPeople})
      : _peopleRepository = peopleRepository ??
            (initialPeople == null ? PeopleRepository() : null),
        _people = List.unmodifiable(initialPeople ?? const <Person>[]),
        storage = DeviceStorage(preferences),
        consentStore = LocalConsentService(preferences),
        moderationStore = LocalModerationService(preferences) {
    birth = demoBirth;
    _knownIds.addAll(_people.map((p) => p.id));
    try {
      final raw = storage.read<String>('profile');
      if (raw == null && storage.read<Object>('profile') != null) {
        throw const FormatException('Invalid saved profile.');
      }
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        birth = BirthData.fromJson(json['birth'] as Map<String, dynamic>);
        name = (json['name'] as String).trim();
        if (!_validProfile(name, birth)) {
          throw const FormatException('Invalid saved profile.');
        }
        service.calculate(birth);
        personalized = true;
      }
    } catch (_) {
      birth = demoBirth;
      name = 'Alex';
      persistenceError =
          'Your saved profile could not be loaded. Please add your birth details again.';
    }
    saved.addAll((storage.read<List<String>>('saved') ?? []).where(_validId));
    hidden.addAll((storage.read<List<String>>('hidden') ?? []).where(_validId));
    reports = moderationStore.loadReports();
    localeOverride = _parseLocale(storage.read<String>('locale'));
    final intent = storage.read<String>('start.intent');
    for (final value in AppIntent.values) {
      if (value.name == intent) startIntent = value;
    }
    social = LocalSocialStore(preferences,
        knownIds: _knownIds, allowUnresolved: _peopleRepository != null);
    social.addListener(_notify);
    sharing = SharingStore(storage, repository: sharingRepository);
    sharing.addListener(_notify);
    journey = JourneyStore(preferences);
    journey.addListener(_notify);
    _recalculate();
    if (_peopleRepository != null) unawaited(refreshCatalog());
  }

  /// User-chosen app language; null means follow the system language.
  Locale? localeOverride = _parseLocale(null);

  static const Set<String> supportedLanguageCodes = {
    'en',
    'zh',
    'es',
    'fr',
    'de',
    'ja',
    'ko',
    'pt',
    'it',
    'ru',
    'ar',
    'hi',
    'id',
    'tr',
    'vi',
    'th',
    'nl',
    'pl',
    'sv',
    'uk',
    'cs',
    'da',
    'no',
    'fi',
    'el',
    'he',
    'ro',
    'hu',
    'ms',
  };

  static Locale? _parseLocale(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split('_');
    if (!supportedLanguageCodes.contains(parts[0])) return null;
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }

  static bool _validProfile(String name, BirthData birth) {
    final now = DateTime.now();
    final cutoff = DateTime(now.year - 18, now.month, now.day);
    return name.isNotEmpty &&
        name.runes.length <= 30 &&
        birth.date.year >= 1900 &&
        !birth.date.isAfter(cutoff);
  }

  static bool _validId(String id) =>
      RegExp(r'^[a-zA-Z0-9_-]{1,48}$').hasMatch(id);
  bool _known(String id) => _knownIds.contains(id);

  Future<void> refreshCatalog() =>
      _catalogTask ??= _fetchCatalog().whenComplete(() => _catalogTask = null);

  Future<void> _fetchCatalog() async {
    final repository = _peopleRepository;
    if (repository == null || _disposed) return;
    catalogLoading = true;
    catalogError = null;
    _notify();
    try {
      final catalog = await repository.load();
      if (_disposed) return;
      _people = catalog.people;
      _knownIds
        ..clear()
        ..addAll(_people.map((p) => p.id));
      catalogRevision = catalog.revision;
      _recalculate();
    } catch (_) {
      if (!_disposed) catalogError = 'catalog_unavailable';
    } finally {
      if (!_disposed) {
        catalogLoading = false;
        _notify();
      }
    }
  }

  Future<bool> setLocale(Locale? locale) => storage.write(() async {
        final raw = locale == null ? '' : locale.toString();
        if (locale != null && _parseLocale(raw) == null) return false;
        if (!await preferences.setString('locale', raw)) return false;
        localeOverride = _parseLocale(raw);
        _notify();
        return true;
      }, failure: false);

  void _recalculate() {
    chart = service.calculate(birth);
    matches = service.rank(chart, _people);
  }

  Future<bool> chooseIntent(AppIntent intent) => storage.write(() async {
        if (!await preferences.setString('start.intent', intent.name)) {
          return false;
        }
        startIntent = intent;
        _notify();
        return true;
      }, failure: false);

  Future<bool> updateProfile(String newName, BirthData newBirth) {
    final trimmed = newName.trim();
    if (!_validProfile(trimmed, newBirth)) return Future.value(false);
    final calculated = service.calculate(newBirth);
    return storage.write(() async {
      if (!await preferences.setString(
          'profile',
          jsonEncode({
            'name': trimmed,
            'birth': newBirth.toJson(),
          }))) {
        return false;
      }
      name = trimmed;
      birth = newBirth;
      personalized = true;
      persistenceError = null;
      chart = calculated;
      matches = service.rank(chart, _people);
      _notify();
      return true;
    }, failure: false);
  }

  Future<bool> toggleSaved(String id) {
    if (!_known(id)) return Future.value(false);
    return storage.write(() async {
      final updated = {...saved};
      updated.contains(id) ? updated.remove(id) : updated.add(id);
      if (!await preferences.setStringList('saved', updated.toList())) {
        return false;
      }
      saved
        ..clear()
        ..addAll(updated);
      _notify();
      return true;
    }, failure: false);
  }

  Future<bool> hide(String id) {
    if (!_known(id)) return Future.value(false);
    return storage.write(() async {
      final updated = {...hidden, id};
      if (!await preferences.setStringList('hidden', updated.toList())) {
        return false;
      }
      hidden
        ..clear()
        ..addAll(updated);
      _notify();
      return true;
    }, failure: false);
  }

  bool hasConsent(String id, String version) =>
      consentStore.accepted(id, version);

  Future<bool> acceptConsent(String id, String version) async {
    final ok = await consentStore.accept(id, version);
    if (ok) _notify();
    return ok;
  }

  Future<bool> submitReport(
      String userId, ReportReason reason, String note) async {
    if (!_known(userId) || note.length > 1000) return false;
    final record = ReportRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: userId,
      reasonIndex: reason.index,
      note: note,
      at: DateTime.now().toIso8601String(),
    );
    final ok = await moderationStore.reportUser(record);
    if (ok) {
      reports = moderationStore.loadReports();
      _notify();
    }
    return ok;
  }

  Future<bool> reset() async {
    final complete = await storage.reset(
        beforeMark: sharing.revokeBeforeReset,
        onMarked: () {
          birth = demoBirth;
          name = 'Alex';
          personalized = false;
          startIntent = null;
          persistenceError = null;
          saved.clear();
          hidden.clear();
          reports = [];
          social.forget();
          journey.forget();
          sharing.forget();
          resetGeneration++;
          _recalculate();
          _notify();
        });
    _notify();
    return complete;
  }

  @override
  void dispose() {
    _disposed = true;
    _peopleRepository?.close();
    social.removeListener(_notify);
    social.dispose();
    journey.removeListener(_notify);
    journey.dispose();
    sharing.removeListener(_notify);
    sharing.dispose();
    super.dispose();
  }
}
