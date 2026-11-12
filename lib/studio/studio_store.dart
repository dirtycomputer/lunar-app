import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import '../services/app_state.dart';
import 'chart_engine.dart';
import 'interpretation.dart';

class StudioStore extends ChangeNotifier {
  static const configuredBase = String.fromEnvironment('LUNAR_MODEL_BASE_URL');
  static ModelConfig defaultModel() => ModelConfig(
      baseUrl: configuredBase.isNotEmpty
          ? configuredBase
          : kIsWeb
              ? '${Uri.base.origin}/api/model'
              : 'http://127.0.0.1:5199/api/model',
      model: 'auto');
  final AppState source;
  late ChartSubject primary, secondary;
  ModelConfig model = defaultModel();
  ReadingStyle style = ReadingStyle.plain;
  String apiKey = ''; // Deliberately memory-only; never SharedPreferences.
  String? loadError;
  late int _resetGeneration;
  StudioStore(this.source) {
    _resetGeneration = source.resetGeneration;
    _defaults();
    try {
      final raw = source.storage.read<String>('studio.charts');
      if (raw != null) {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        final a = ChartSubject.fromJson(j['primary'] as Map<String, dynamic>);
        final b = ChartSubject.fromJson(j['secondary'] as Map<String, dynamic>);
        ChartEngine().calculate(a);
        ChartEngine().calculate(b);
        primary = a;
        secondary = b;
      }
      final settings = source.storage.read<String>('studio.model');
      if (settings != null) {
        model =
            ModelConfig.fromJson(jsonDecode(settings) as Map<String, dynamic>);
        if (configuredBase.isNotEmpty &&
            model.model == 'auto' &&
            ((kIsWeb && model.baseUrl == '${Uri.base.origin}/api/model') ||
                model.baseUrl == 'http://127.0.0.1:5199/api/model')) {
          model = defaultModel();
        }
      }
      final s = source.storage.read<String>('studio.style');
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
        name: 'Sample comparison', birth: sampleComparisonBirth, sex: 0);
  }

  void _sourceChanged() {
    if (source.resetGeneration != _resetGeneration) {
      _resetGeneration = source.resetGeneration;
      _defaults();
      model = defaultModel();
      style = ReadingStyle.plain;
      apiKey = '';
      notifyListeners();
    }
  }

  Future<bool> updateSubjects(ChartSubject a, ChartSubject b) =>
      source.storage.write(() async {
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
      }, failure: false);

  Future<bool> configure(ModelConfig config, String key) =>
      source.storage.write(() async {
        if (config.baseUrl.trim().isNotEmpty) config.endpoint;
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
      }, failure: false);

  Future<bool> setStyle(ReadingStyle value) => source.storage.write(() async {
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
      }, failure: false);

  @override
  void dispose() {
    source.removeListener(_sourceChanged);
    super.dispose();
  }
}
