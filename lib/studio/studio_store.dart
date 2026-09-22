import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import '../services/app_state.dart';
import 'chart_engine.dart';
import 'interpretation.dart';

class StudioStore extends ChangeNotifier {
  final AppState source;
  late ChartSubject primary, secondary;
  ModelConfig model = ModelConfig(
      baseUrl: kIsWeb
          ? '${Uri.base.origin}/api/model'
          : const String.fromEnvironment('LUNAR_MODEL_BASE_URL',
              defaultValue: 'http://127.0.0.1:5199/api/model'),
      model: 'auto');
  ReadingStyle style = ReadingStyle.plain;
  String apiKey = ''; // Deliberately memory-only; never SharedPreferences.
  String? loadError;
  late int _resetGeneration;
  StudioStore(this.source) {
    _resetGeneration = source.resetGeneration;
    _defaults();
    try {
      final raw = source.preferences.getString('studio.charts');
      if (raw != null) {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        final a = ChartSubject.fromJson(j['primary'] as Map<String, dynamic>);
        final b = ChartSubject.fromJson(j['secondary'] as Map<String, dynamic>);
        ChartEngine().calculate(a);
        ChartEngine().calculate(b);
        primary = a;
        secondary = b;
      }
      final settings = source.preferences.getString('studio.model');
      if (settings != null) {
        model =
            ModelConfig.fromJson(jsonDecode(settings) as Map<String, dynamic>);
      }
      final s = source.preferences.getString('studio.style');
      if (s != null) style = ReadingStyle.values.byName(s);
    } catch (_) {
      loadError =
          'Some studio settings could not be restored. Please review your chart details.';
    }
    source.addListener(_sourceChanged);
  }
  void _defaults() {
    primary = ChartSubject(name: source.name, birth: source.birth);
    secondary = ChartSubject(
        name: demoPeople.first.name, birth: demoPeople.first.birth, sex: 0);
  }

  void _sourceChanged() {
    if (source.resetGeneration != _resetGeneration) {
      _resetGeneration = source.resetGeneration;
      _defaults();
      model = ModelConfig(
          baseUrl: kIsWeb
              ? '${Uri.base.origin}/api/model'
              : 'http://127.0.0.1:5199/api/model',
          model: 'auto');
      style = ReadingStyle.plain;
      apiKey = '';
      notifyListeners();
    }
  }

  Future<bool> updateSubjects(ChartSubject a, ChartSubject b) async {
    ChartEngine().calculate(a);
    ChartEngine().calculate(b);
    try {
      if (!await source.preferences.setString('studio.charts',
          jsonEncode({'primary': a.toJson(), 'secondary': b.toJson()}))) {
        return false;
      }
    } catch (_) {
      return false;
    }
    primary = a;
    secondary = b;
    notifyListeners();
    return true;
  }

  Future<bool> configure(ModelConfig config, String key) async {
    if (config.isConfigured) config.endpoint;
    try {
      if (!await source.preferences
          .setString('studio.model', jsonEncode(config.toJson()))) {
        return false;
      }
    } catch (_) {
      return false;
    }
    model = config;
    apiKey = key;
    notifyListeners();
    return true;
  }

  Future<bool> setStyle(ReadingStyle value) async {
    try {
      if (!await source.preferences.setString('studio.style', value.name)) {
        return false;
      }
    } catch (_) {
      return false;
    }
    style = value;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    source.removeListener(_sourceChanged);
    super.dispose();
  }
}
