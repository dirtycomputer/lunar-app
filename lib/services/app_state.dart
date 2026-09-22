import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';
import 'bazi.dart';
import 'platform_contracts.dart';

class AppState extends ChangeNotifier {
  final SharedPreferences preferences;
  final BaziService service = BaziService();
  final LocalConsentService consentStore;
  final LocalModerationService moderationStore;
  late BirthData birth;
  late EnergyChart chart;
  late List<MatchResult> matches;
  String name = 'Alex';
  bool personalized = false;
  final Set<String> saved = {};
  final Set<String> hidden = {};
  List<ReportRecord> reports = [];
  String? persistenceError;
  int resetGeneration = 0;
  AppState(this.preferences)
      : consentStore = LocalConsentService(preferences),
        moderationStore = LocalModerationService(preferences) {
    birth = demoBirth;
    try {
      final raw = preferences.getString('profile');
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        birth = BirthData.fromJson(json['birth'] as Map<String, dynamic>);
        name = json['name'] as String;
        service.calculate(birth);
        personalized = true;
      }
    } catch (_) {
      birth = demoBirth;
      name = 'Alex';
      persistenceError =
          'Your saved profile could not be loaded. Please add your birth details again.';
    }
    saved.addAll(preferences.getStringList('saved') ?? []);
    hidden.addAll(preferences.getStringList('hidden') ?? []);
    reports = moderationStore.loadReports();
    localeOverride = _parseLocale(preferences.getString('locale'));
    _recalculate();
  }

  /// User-chosen app language; null means follow the system language.
  Locale? localeOverride = _parseLocale(null);

  static const Set<String> supportedLanguageCodes = {
    'en', 'zh', 'es', 'fr', 'de', 'ja', 'ko', 'pt', 'it', 'ru', 'ar', 'hi',
    'id', 'tr', 'vi', 'th', 'nl', 'pl', 'sv', 'uk', 'cs', 'da', 'no', 'fi',
    'el', 'he', 'ro', 'hu', 'ms',
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

  Future<bool> setLocale(Locale? locale) async {
    final raw = locale == null
        ? ''
        : locale.countryCode == null
            ? locale.languageCode
            : '${locale.languageCode}_${locale.countryCode}';
    try {
      if (!await preferences.setString('locale', raw)) return false;
    } catch (_) {
      return false;
    }
    localeOverride = _parseLocale(raw);
    notifyListeners();
    return true;
  }
  void _recalculate() {
    chart = service.calculate(birth);
    matches = service.rank(chart, demoPeople);
  }

  Future<bool> updateProfile(String newName, BirthData newBirth) async {
    service.calculate(newBirth);
    try {
      final ok = await preferences.setString(
          'profile',
          jsonEncode({
            'name': newName.trim(),
            'birth': newBirth.toJson(),
          }));
      if (!ok) return false;
    } catch (_) {
      return false;
    }
    name = newName.trim();
    birth = newBirth;
    personalized = true;
    _recalculate();
    notifyListeners();
    return true;
  }

  Future<bool> toggleSaved(String id) async {
    final updated = {...saved};
    updated.contains(id) ? updated.remove(id) : updated.add(id);
    try {
      if (!await preferences.setStringList('saved', updated.toList())) {
        return false;
      }
    } catch (_) {
      return false;
    }
    saved
      ..clear()
      ..addAll(updated);
    notifyListeners();
    return true;
  }

  Future<bool> hide(String id) async {
    final updated = {...hidden, id};
    try {
      if (!await preferences.setStringList('hidden', updated.toList())) {
        return false;
      }
    } catch (_) {
      return false;
    }
    hidden
      ..clear()
      ..addAll(updated);
    notifyListeners();
    return true;
  }

  bool hasConsent(String id, String version) =>
      consentStore.accepted(id, version);

  Future<bool> acceptConsent(String id, String version) async {
    final ok = await consentStore.accept(id, version);
    if (ok) notifyListeners();
    return ok;
  }

  Future<bool> submitReport(
      String userId, ReportReason reason, String note) async {
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
      notifyListeners();
    }
    return ok;
  }

  Future<bool> reset() async {
    try {
      for (final key in [
        'profile',
        'saved',
        'hidden',
        'consents',
        'reports',
        'studio.charts',
        'studio.model',
        'studio.style'
      ]) {
        if (!await preferences.remove(key)) return false;
      }
    } catch (_) {
      return false;
    }
    birth = demoBirth;
    name = 'Alex';
    personalized = false;
    saved.clear();
    hidden.clear();
    reports = [];
    resetGeneration++;
    _recalculate();
    notifyListeners();
    return true;
  }
}
