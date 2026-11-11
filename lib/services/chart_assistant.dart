import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;
import '../models/profile.dart';
import '../studio/chart_engine.dart';
import '../studio/interpretation.dart';
import '../studio/studio_store.dart';
import 'bazi.dart' as core;
import 'bazi_reference.dart';

enum OutlookPeriod { today, month, year }

const godThemes = {
  '比肩': 'independence, peers, and working alongside others',
  '劫财': 'shared resources, collaboration, and boundaries',
  '食神': 'creative output, craft, and practical expression',
  '伤官': 'original ideas, expression, and questioning established methods',
  '偏财': 'opportunities, exchange, and managing outside resources',
  '正财': 'routine, responsibility, and resource management',
  '七杀': 'pressure, initiative, and handling demanding situations',
  '正官': 'structure, commitments, and responsibility',
  '偏印': 'independent study, unconventional knowledge, and reflection',
  '正印': 'learning, support, and building knowledge',
};

class ChartContext {
  final ChartReport natal;
  final DateTime instant;
  final Map<String, dynamic> viewContext;
  late final ChartReport transit;
  ChartContext._(this.natal, this.instant, this.transit, this.viewContext);
  ChartContext withViewContext(Map<String, dynamic> value) =>
      ChartContext._(natal, instant, transit, value);
  ChartContext(this.natal, {DateTime? now, this.viewContext = const {}})
      : instant = now ?? DateTime.now() {
    final local = tz.TZDateTime.from(
        instant.toUtc(), tz.getLocation(natal.subject.birth.place.zone));
    transit = ChartEngine().calculate(ChartSubject(
        name: 'Current period',
        birth: BirthData(
            date: DateTime(local.year, local.month, local.day),
            hour: local.hour,
            minute: local.minute,
            place: natal.subject.birth.place),
        basis: natal.subject.basis,
        sect: natal.subject.sect));
  }

  PillarDetail period(OutlookPeriod value) => ChartEngine.detail(
      value.name,
      transit
          .pillars[switch (value) {
        OutlookPeriod.today => 2,
        OutlookPeriod.month => 1,
        OutlookPeriod.year => 0
      }]
          .value,
      natal.master);

  String periodReading(OutlookPeriod value) {
    final p = period(value);
    return 'The traditional focus for this period is ${godThemes[p.god] ?? 'the relationship between this stem and your day master'}.\n\n'
        '${cycleEnglish(p.value)} (${p.value}) relates to your ${natal.energy.identity} day master as ${tenGodEnglish[p.god] ?? p.god} (${p.god}). '
        'This identifies a traditional theme, rather than a forecast of an event.';
  }

  String get reading {
    final distribution = natal.energy.distribution;
    final most = distribution.reduce((a, b) => a > b ? a : b);
    final frequent = [
      for (var i = 0; i < distribution.length; i++)
        if (distribution[i] == most) core.Element.values[i].label
    ];
    final month = natal.pillars[1];
    final relations = ChartEngine.relations(
        natal.pillars.map((p) => (p.label, p.value)).toList());
    return 'Your chart highlights ${godThemes[month.god] ?? 'the relationship between the month stem and your day master'} in the traditional Ten Gods framework.\n\n'
        'Your day master is ${natal.master}, ${natal.energy.identity}. The month stem relates to it as ${tenGodEnglish[month.god] ?? month.god} (${month.god}). '
        '${frequent.join(' and ')} ${frequent.length > 1 ? 'are' : 'is'} most frequent among the visible elements (${(most * 100).round()}%). '
        'Visible counts do not measure seasonal strength.\n\n'
        '${relations.isEmpty ? 'No combinations or clashes were found in the implemented relation set.' : relations.take(3).map((r) => '${r.english}: ${r.characters} (${r.targets}).').join(' ')}'
        '${natal.subject.birth.timeKnown ? '' : '\n\nBirth time is unknown; the hour pillar is omitted.'}';
  }

  Map<String, dynamic> evidence() => {
        'natal': natal.evidence(),
        'currentPeriods': {
          for (final p in OutlookPeriod.values) p.name: period(p).toJson()
        },
        'currentDate': dateLabel(transit.clock.civil),
        'userContext': viewContext,
        'visibleReading': viewContext['readingMode'] == 'outlook'
            ? periodReading(OutlookPeriod.values.firstWhere(
                (p) => p.name == viewContext['period'],
                orElse: () => OutlookPeriod.month))
            : reading,
      };

  String referenceAnswer(String question) {
    final q = question.toLowerCase();
    if (RegExp(r'current|cycle|month|year|today|运势|流年|本月|今天').hasMatch(q)) {
      final p = RegExp(r'month|本月').hasMatch(q)
          ? OutlookPeriod.month
          : RegExp(r'today|今天').hasMatch(q)
              ? OutlookPeriod.today
              : OutlookPeriod.year;
      return periodReading(p);
    }
    if (RegExp(r'work|career|事业|工作').hasMatch(q)) {
      final p = natal.pillars[1];
      return 'Your month stem is ${p.value[0]}. Relative to ${natal.master}, its Ten God is ${tenGodEnglish[p.god] ?? p.god} (${p.god}).\n\n'
          'This is traditionally linked to ${godThemes[p.god] ?? 'the month stem’s relationship to your day master'}. '
          'A chart does not establish a suitable occupation, income, or career outcome. A connected model can explore this theme with you in more depth.';
    }
    if (RegExp(r'relat|combin|clash|五行|关联|相合|冲').hasMatch(q)) {
      final r = ChartEngine.relations(
          natal.pillars.map((p) => (p.label, p.value)).toList());
      return r.isEmpty
          ? 'No combinations or clashes were found in the implemented relation set for these pillars.'
          : r
              .map((x) =>
                  '${x.name} · ${x.english}\n${x.characters} — ${x.targets}')
              .join('\n\n');
    }
    if (RegExp(r'pillar|chart|master|element|stand|命盘|日主|特点|元素').hasMatch(q)) {
      return reading;
    }
    return 'I can explain the calculated pillars, day master, visible elements, and current periods. Connect a model for an open-ended discussion of this question.';
  }
}

/// Reuse the expensive natal/transit reports while only UI context changes.
/// Time, birth data, and calculation conventions participate in invalidation.
class ChartContextCache {
  String? _key;
  ChartContext? _value;
  ChartContext get(
    ChartSubject subject, {
    DateTime? now,
    Map<String, dynamic> viewContext = const {},
  }) {
    final instant = now ?? DateTime.now();
    final key =
        jsonEncode([subject.toJson(), instant.millisecondsSinceEpoch ~/ 60000]);
    if (key != _key) {
      _value = ChartContext(ChartEngine().calculate(subject), now: instant);
      _key = key;
    }
    return _value!.withViewContext(viewContext);
  }
}

class AgentTurn {
  final String role, text, source;
  final Map<String, dynamic>? contextSnapshot;
  const AgentTurn(this.role, this.text,
      {this.source = '', this.contextSnapshot});
}

class _RetryQuestion {
  final String question;
  final ChartContext? context;
  final Map<String, dynamic> snapshot;
  final List<Map<String, String>> history;
  const _RetryQuestion(
      this.question, this.context, this.snapshot, this.history);
}

class ChartAgent extends ChangeNotifier {
  final StudioStore studio;
  final http.Client Function() clientFactory;
  final List<AgentTurn> _turns = [];
  List<AgentTurn> get turns => List.unmodifiable(_turns);
  bool busy = false;
  String? error;
  http.Client? _client;
  _RetryQuestion? _retry;
  int _request = 0;
  bool get canRetry => !busy && error != null && _retry != null;
  ChartAgent(this.studio, {http.Client Function()? clientFactory})
      : clientFactory = clientFactory ?? http.Client.new;

  Future<bool> _modelAvailable(http.Client client) async {
    final config = studio.model;
    if (!config.isConfigured) return false;
    if (!config.baseUrl.replaceFirst(RegExp(r'/+$'), '').endsWith('/api/model')) {
      return true;
    }
    try {
      final response = await client
          .get(Uri.parse(
              '${config.baseUrl.replaceFirst(RegExp(r'/+$'), '')}/info'))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw const ModelFailure(
            'Could not connect to the interpretation service. Your question is kept.');
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['configured'] == true;
    } catch (error) {
      if (error is ModelFailure) rethrow;
      throw const ModelFailure(
          'Could not connect to the interpretation service. Your question is kept.');
    }
  }

  Future<void> ask(String question,
      {ChartContext? context,
      Map<String, dynamic> userContext = const {}}) async {
    final q = question.trim();
    if (q.isEmpty || busy || q.length > 2000) return;
    final Map<String, dynamic> snapshot =
        context?.evidence() ?? {'personalChartAvailable': false};
    if (userContext.isNotEmpty) {
      snapshot['userContext'] = {
        ...?snapshot['userContext'] as Map<String, dynamic>?,
        ...userContext
      };
    }
    final frozen = jsonDecode(jsonEncode(snapshot)) as Map<String, dynamic>;
    final history = _turns
        .map((t) => <String, String>{
              'role': t.role,
              'content': t.contextSnapshot == null
                  ? t.text
                  : jsonEncode({
                      'question': t.text,
                      'computedEvidence': t.contextSnapshot,
                    }),
            })
        .toList();
    _retry = _RetryQuestion(q, context, frozen, history);
    _turns.add(AgentTurn('user', q, contextSnapshot: frozen));
    await _run(_retry!);
  }

  Future<void> retry() async {
    if (!canRetry) return;
    if (_turns.isNotEmpty &&
        _turns.last.role == 'assistant' &&
        _turns.last.source == 'reference') {
      _turns.removeLast();
    }
    await _run(_retry!);
  }

  Future<void> _run(_RetryQuestion question) async {
    final id = ++_request;
    busy = true;
    error = null;
    notifyListeners();
    final client = clientFactory();
    _client = client;
    String reference() =>
        question.context?.referenceAnswer(question.question) ??
        generalReference(question.question);
    try {
      final available = await _modelAvailable(client);
      if (id != _request) return;
      if (available) {
        final answer = await InterpretationClient(client).generate(
          config: studio.model,
          apiKey: studio.apiKey,
          style: ReadingStyle.professional,
          evidence: question.snapshot,
          topic: question.context == null
              ? 'General BaZi study question'
              : 'BaZi question and answer',
          question: question.question,
          conversation: question.history,
        );
        if (id == _request) {
          _turns.add(AgentTurn('assistant', answer, source: 'model'));
        }
      } else {
        _turns.add(AgentTurn('assistant', reference(), source: 'reference'));
      }
    } catch (e) {
      if (id == _request) {
        error = e is ModelFailure
            ? e.message
            : 'The model is unavailable. Your question is kept.';
        _turns.add(AgentTurn('assistant', reference(), source: 'reference'));
      }
    } finally {
      client.close();
      if (id == _request) {
        busy = false;
        _client = null;
        notifyListeners();
      }
    }
  }

  void cancel() {
    final wasBusy = busy;
    _request++;
    _client?.close();
    _client = null;
    busy = false;
    if (wasBusy) {
      error = 'Request stopped. Your question is kept and can be retried.';
    }
    notifyListeners();
  }

  void clear() {
    _request++;
    _client?.close();
    _client = null;
    busy = false;
    _turns.clear();
    _retry = null;
    error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _request++;
    _client?.close();
    super.dispose();
  }
}
