import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../ui/design.dart';
import 'chart_widgets.dart';
import 'interpretation.dart';
import 'studio_store.dart';

class ReadingPanel extends StatefulWidget {
  final StudioStore store;
  final Map<String, dynamic> evidence;
  final String topic, localText;
  final VoidCallback onSettings;
  const ReadingPanel(
      {super.key,
      required this.store,
      required this.evidence,
      required this.topic,
      required this.localText,
      required this.onSettings});
  @override
  State<ReadingPanel> createState() => _ReadingPanelState();
}

class _ReadingPanelState extends State<ReadingPanel> {
  http.Client? client;
  int request = 0;
  bool busy = false;
  String? answer, error;
  String signature = '';
  @override
  void initState() {
    super.initState();
    signature = _signature();
    widget.store.addListener(_invalidate);
  }

  String _signature() => jsonEncode(
      [widget.evidence, widget.store.style.name, widget.store.model.toJson()]);
  void _invalidate() {
    final next = _signature();
    if (next != signature) {
      client?.close();
      request++;
      if (mounted) {
        setState(() {
          signature = next;
          busy = false;
          answer = null;
          error = null;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant ReadingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _invalidate();
  }

  @override
  void dispose() {
    request++;
    client?.close();
    widget.store.removeListener(_invalidate);
    super.dispose();
  }

  Future<void> generate() async {
    final id = ++request;
    client?.close();
    client = http.Client();
    setState(() {
      busy = true;
      error = null;
      answer = null;
    });
    try {
      final text = await InterpretationClient(client!).generate(
          config: widget.store.model,
          apiKey: widget.store.apiKey,
          style: widget.store.style,
          evidence: widget.evidence,
          topic: widget.topic);
      if (mounted && id == request) setState(() => answer = text);
    } catch (e) {
      if (mounted && id == request) {
        setState(() => error = e is ModelFailure
            ? e.message
            : e is FormatException
                ? e.message
                : 'The model request failed. Your local reading is still available.');
      }
    } finally {
      if (mounted && id == request) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Surface(
      color: lavenderTint,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        StudioHeading(
            'A little clarity, your way.',
            answer == null
                ? 'Local rule-based reading · No model request has generated the text below.'
                : 'Custom model interpretation · Based on the calculated chart evidence.',
            action: const Icon(Icons.auto_awesome_outlined, color: green)),
        SegmentedButton<ReadingStyle>(
            segments: const [
              ButtonSegment(
                  value: ReadingStyle.plain, label: Text('Plain English')),
              ButtonSegment(
                  value: ReadingStyle.professional, label: Text('Professional'))
            ],
            selected: {
              widget.store.style
            },
            onSelectionChanged: (v) async {
              final ok = await widget.store.setStyle(v.first);
              if (!ok && context.mounted) {
                showToast(context, 'Could not save reading preference.');
              }
            }),
        const SizedBox(height: 20),
        SelectableText(answer ?? widget.localText,
            style: const TextStyle(fontSize: 13, height: 1.9, color: ink)),
        if (error != null)
          Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Text(error!,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFFB04B3D)))),
        const SizedBox(height: 22),
        Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                  onPressed: busy
                      ? null
                      : widget.store.model.isConfigured
                          ? generate
                          : widget.onSettings,
                  icon: busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_awesome, size: 16),
                  label: Text(busy
                      ? 'Writing your interpretation…'
                      : widget.store.model.isConfigured
                          ? 'Generate with model'
                          : 'Connect a model')),
              if (busy)
                TextButton(
                    onPressed: () {
                      request++;
                      client?.close();
                      setState(() => busy = false);
                    },
                    child: const Text('Cancel')),
              TextButton.icon(
                  onPressed: widget.onSettings,
                  icon: const Icon(Icons.tune, size: 16),
                  label: const Text('Model settings')),
              if (answer != null)
                TextButton(
                    onPressed: () => setState(() => answer = null),
                    child: const Text('Show local reading')),
            ]),
        const SizedBox(height: 12),
        Text(
            widget.store.model.baseUrl.contains('/api/model')
                ? 'Generating sends the displayed chart evidence to DeepSeek through the local proxy. Names, exact birth dates, places and API keys are not included in chart evidence.'
                : 'Generating sends the displayed chart evidence to your configured model provider. Names, exact birth dates and places are omitted; review your endpoint before sending.',
            style: const TextStyle(fontSize: 10, color: muted, height: 1.7)),
      ]));
}

class ModelSettingsPanel extends StatefulWidget {
  final StudioStore store;
  const ModelSettingsPanel({super.key, required this.store});
  @override
  State<ModelSettingsPanel> createState() => _ModelSettingsPanelState();
}

class _ModelSettingsPanelState extends State<ModelSettingsPanel> {
  late final TextEditingController url, model, key;
  final form = GlobalKey<FormState>();
  final client = http.Client();
  bool showKey = false, busy = false;
  String? status;
  Map<String, dynamic>? proxy;
  @override
  void initState() {
    super.initState();
    url = TextEditingController(text: widget.store.model.baseUrl);
    model = TextEditingController(text: widget.store.model.model);
    key = TextEditingController(text: widget.store.apiKey);
    _loadProxy();
  }

  Future<void> _loadProxy() async {
    if (!url.text.contains('/api/model')) return;
    try {
      final r = await client
          .get(Uri.parse('${url.text.replaceFirst(RegExp(r'/+$'), '')}/info'))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200 && mounted) {
        setState(() => proxy = jsonDecode(r.body) as Map<String, dynamic>);
      }
    } catch (_) {
      if (mounted) {
        setState(() => proxy = {'status': 'unreachable', 'configured': false});
      }
    }
  }

  @override
  void dispose() {
    client.close();
    for (final c in [url, model, key]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save({bool test = false}) async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      status = null;
    });
    final config =
        ModelConfig(baseUrl: url.text.trim(), model: model.text.trim());
    try {
      if (!await widget.store.configure(config, key.text.trim())) {
        throw const ModelFailure('Could not save settings.');
      }
      if (test) {
        final answer = await InterpretationClient(client).generate(
            config: config,
            apiKey: key.text.trim(),
            style: ReadingStyle.plain,
            evidence: {'connectionTest': true},
            topic:
                'Connection test only. Reply with exactly: Lunar connection ready.');
        if (mounted) {
          setState(() => status =
              'Connection verified. ${answer.length > 160 ? answer.substring(0, 160) : answer}');
        }
      } else {
        if (mounted) {
          setState(() => status =
              'Settings saved. The client key stays in memory for this app session.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => status = e is ModelFailure
            ? e.message
            : e is FormatException
                ? e.message
                : 'Connection failed. Check the provider configuration.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const StudioHeading('Your model. Your interpretation.',
            'Connect DeepSeek, a local model, or any compatible chat-completion endpoint.'),
        if (proxy != null)
          Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Surface(
                  color: const Color(0xFFEDF1E5),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(
                              proxy!['status'] == 'ready'
                                  ? Icons.check_circle_outline
                                  : Icons.info_outline,
                              color: green),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(
                                  'DeepSeek proxy · ${proxy!['status']}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)))
                        ]),
                        const SizedBox(height: 10),
                        const Text(
                            'Provider key is held by the local server. It is never sent to this page.',
                            style: TextStyle(fontSize: 12, color: muted)),
                        if (proxy!['models'] is List)
                          Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: (proxy!['models'] as List)
                                      .map((m) => ActionChip(
                                          label: Text(m as String,
                                              style: const TextStyle(
                                                  fontSize: 11)),
                                          onPressed: () =>
                                              setState(() => model.text = m)))
                                      .toList())),
                      ]))),
        Surface(
            child: Form(
                key: form,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                          controller: url,
                          decoration: const InputDecoration(
                              labelText: 'Base URL',
                              helperText:
                                  'Include /v1 if required by the provider. The app appends /chat/completions.'),
                          validator: (v) {
                            try {
                              ModelConfig(baseUrl: v ?? '', model: 'check')
                                  .endpoint;
                              return null;
                            } on FormatException catch (e) {
                              return e.message;
                            }
                          },
                          onChanged: (_) => setState(() => proxy = null)),
                      const SizedBox(height: 20),
                      TextFormField(
                          controller: model,
                          decoration: const InputDecoration(
                              labelText: 'Model ID',
                              helperText:
                                  'Use auto with the local DeepSeek proxy, or enter an exact provider model ID.'),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Enter a model ID.'
                              : null),
                      const SizedBox(height: 20),
                      TextFormField(
                          controller: key,
                          obscureText: !showKey,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                              labelText: 'Client API key · optional',
                              helperText:
                                  'Leave empty when using the local proxy or an unauthenticated local model.',
                              suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => showKey = !showKey),
                                  tooltip: showKey ? 'Hide key' : 'Show key',
                                  icon: Icon(showKey
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined)))),
                      const SizedBox(height: 24),
                      Wrap(spacing: 12, runSpacing: 12, children: [
                        FilledButton(
                            onPressed: busy ? null : () => save(),
                            child: const Text('Save model settings')),
                        OutlinedButton(
                            onPressed: busy ? null : () => save(test: true),
                            child:
                                Text(busy ? 'Connecting…' : 'Test connection'))
                      ]),
                      if (status != null)
                        Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: SelectableText(status!,
                                style: const TextStyle(
                                    fontSize: 12, height: 1.7))),
                    ]))),
        const SizedBox(height: 22),
        const Surface(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('How the connection works',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          SizedBox(height: 12),
          Text(
              'Lunar calculates charts locally, then sends a structured evidence packet only when you request an interpretation. The model explains the data; it does not generate the pillars.\n\nThe default local proxy discovers available DeepSeek models. For Ollama use http://localhost:11434/v1; for LM Studio use your configured local /v1 endpoint. Browser providers must allow CORS.\n\nThe proxy is a local development service. For a released app, point to an authenticated production backend. Client keys are not persisted; server keys are supplied at startup.',
              style: TextStyle(fontSize: 12, color: muted, height: 1.9)),
        ])),
      ]);
}
