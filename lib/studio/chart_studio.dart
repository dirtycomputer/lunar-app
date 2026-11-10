import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/birth_clock.dart';
import '../ui/design.dart';
import 'chart_engine.dart';
import 'chart_widgets.dart';
import 'classic_library.dart';
import 'cycles_panel.dart';
import 'interpretation.dart';
import 'reading_panel.dart';
import 'studio_store.dart';
import 'subject_editor.dart';
import 'tool_panels.dart';

class ChartStudio extends StatefulWidget {
  final StudioStore store;
  final int initialTab;
  final bool compact;
  const ChartStudio(
      {super.key,
      required this.store,
      this.initialTab = 0,
      this.compact = false});
  @override
  State<ChartStudio> createState() => _ChartStudioState();
}

class _ChartStudioState extends State<ChartStudio> {
  late int tab;
  @override
  void initState() {
    super.initState();
    tab = widget.initialTab;
  }

  StudioStore get store => widget.store;
  static const tabs = [
    'Birth chart',
    'Luck cycles',
    'Compare',
    'Almanac',
    'Five phases',
    'Library',
    'Model settings'
  ];
  Future<void> edit({bool second = false}) async {
    final result = await editChartSubject(
        context, second ? store.secondary : store.primary);
    if (result == null || !mounted) return;
    final ok = await store.updateSubjects(
        second ? store.primary : result, second ? result : store.secondary);
    if (!ok && mounted) {
      showToast(context, 'Could not save the chart. Please try again.');
    }
  }

  Widget reading(Map<String, dynamic> evidence, String text, String topic) =>
      ReadingPanel(
          key: ValueKey(topic),
          store: store,
          evidence: evidence,
          topic: topic,
          localText: text,
          onSettings: () => setState(() => tab = 6));
  @override
  Widget build(BuildContext context) => ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final report = ChartEngine().calculate(store.primary);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!widget.compact) ...[
            Text('Chart tools',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
          ],
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: List.generate(
                      tabs.length,
                      (i) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Builder(builder: (context) {
                            final selected = tab == i;
                            final color = accentColors[i % accentColors.length];
                            return ChoiceChip(
                                label: Text(tabs[i],
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: selected ? color : muted,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.w500)),
                                selected: selected,
                                showCheckmark: false,
                                selectedColor:
                                    accentTints[i % accentTints.length],
                                side: BorderSide(
                                    color: selected
                                        ? color.withValues(alpha: .35)
                                        : line),
                                onSelected: (_) => setState(() => tab = i));
                          }))))),
          const SizedBox(height: 27),
          if (store.loadError != null)
            Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(store.loadError!,
                    style: const TextStyle(color: muted))),
          if (tab < 2) ...[
            _subjectCard(store.primary, onEdit: () => edit()),
            Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    final ok = await store.updateSubjects(
                        ChartSubject(
                            name: store.source.name,
                            birth: store.source.birth,
                            sex: store.primary.sex,
                            basis: store.primary.basis,
                            sect: store.primary.sect),
                        store.secondary);
                    if (!ok && context.mounted) {
                      showToast(context, 'Could not import your profile.');
                    }
                  },
                  icon: const Icon(Icons.person_outline, size: 16),
                  label: const Text('Use my dating profile'),
                )),
            const SizedBox(height: 24)
          ],
          switch (tab) {
            0 => _birth(report),
            1 => CyclesPanel(
                report: report,
                reading: (e, t) =>
                    reading(e, t, 'Natal chart and selected fortune cycles')),
            2 => _compare(report),
            3 => const AlmanacPanel(),
            4 => const FivePhasesPanel(),
            5 => _library(),
            _ => ModelSettingsPanel(store: store),
          },
        ]);
      });
  Widget _subjectCard(ChartSubject subject, {required VoidCallback onEdit}) =>
      Surface(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            const CircleAvatar(
                backgroundColor: Color(0xFFEDF1E5),
                child: Icon(Icons.person_outline, color: green)),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(subject.name,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  Text(
                      '${dateLabel(subject.birth.date)} · ${subject.birth.timeKnown ? '${subject.birth.hour.toString().padLeft(2, '0')}:${subject.birth.minute.toString().padLeft(2, '0')}' : 'Time unknown'} · ${subject.birth.place.name}',
                      style: const TextStyle(fontSize: 11, color: muted)),
                  const SizedBox(height: 4),
                  Text(
                      '${subject.basis.label} · Day begins ${subject.sect == 2 ? '00:00' : '23:00'}',
                      style: const TextStyle(fontSize: 10, color: muted)),
                ])),
            const SizedBox(width: 10),
            IconButton.outlined(
                onPressed: onEdit,
                tooltip: 'Edit ${subject.name} birth details',
                icon: const Icon(Icons.edit_outlined, size: 18)),
          ]));
  Widget _birth(ChartReport r) {
    final clock = r.clock;
    final offset =
        '${clock.offset.isNegative ? '-' : '+'}${(clock.offset.inMinutes.abs() ~/ 60).toString().padLeft(2, '0')}:${(clock.offset.inMinutes.abs() % 60).toString().padLeft(2, '0')}';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const StudioHeading('Your four pillars',
          'The day master anchors the Ten Gods and twelve growth stages. Chinese terms sit alongside English labels.'),
      ChartTable(r.pillars),
      if (!r.subject.birth.timeKnown)
        const Padding(
            padding: EdgeInsets.only(top: 14),
            child: Text(
                'Birth time unknown: the hour pillar and hour-dependent palaces are omitted. Noon is used for the remaining calculation; a day near a solar-time or solar-term boundary may be uncertain.',
                style: TextStyle(fontSize: 12, color: muted))),
      const SizedBox(height: 24),
      FactTiles(r.palaces),
      const SizedBox(height: 26),
      Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const StudioHeading('The clock behind your chart',
            'IANA time zones resolve historical offsets and daylight saving. Seasons use the birth instant; day and hour use your selected clock.'),
        Wrap(spacing: 26, runSpacing: 16, children: [
          _clockFact('Birthplace clock', clockLabel(clock.civil)),
          _clockFact('Time zone', '${clock.zone} · UTC$offset'),
          _clockFact('Daylight saving',
              clock.daylightSaving ? 'Active at birth' : 'Not active at birth'),
          _clockFact('Mean solar time', clockLabel(clock.meanSolar)),
          _clockFact('True solar time', clockLabel(clock.apparentSolar)),
          _clockFact('Equation of time',
              '${clock.equationMinutes.toStringAsFixed(2)} minutes · NOAA approximation'),
        ]),
        if (clock.repeatedTime)
          const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                  'This clock time occurred twice at a daylight-saving transition. The earlier occurrence is used.',
                  style: TextStyle(fontSize: 11, color: muted))),
      ])),
      const SizedBox(height: 24),
      Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const StudioHeading('Connections inside the chart',
            'Traditional structural rules. Combinations do not automatically mean transformation.'),
        RelationList(ChartEngine.relations(
            r.pillars.map((p) => (p.label, p.value)).toList()))
      ])),
      const SizedBox(height: 24),
      Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const StudioHeading('Symbolic stars · 神煞',
            'Twelve common auxiliary rules, with their calculation basis shown. Schools differ; these are study references.'),
        StarList(ChartEngine.stars(
            r, r.pillars.map((p) => (p.label, p.value)).toList()))
      ])),
      const SizedBox(height: 24),
      reading(r.evidence(), localReading(r, store.style),
          'Birth chart interpretation'),
    ]);
  }

  Widget _clockFact(String label, String value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: muted)),
            const SizedBox(height: 5),
            Text(value,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))
          ]);
  Widget _compare(ChartReport a) {
    final b = ChartEngine().calculate(store.secondary);
    final relations = ChartEngine.relations([
      ...a.pillars.map((p) => ('A ${p.label}', p.value)),
      ...b.pillars.map((p) => ('B ${p.label}', p.value))
    ], crossOnly: true);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const StudioHeading('Two charts. Room for understanding.',
          'Compare structural patterns without reducing a relationship to a prediction. Both charts are editable and saved on this device.'),
      LayoutBuilder(
          builder: (context, c) => c.maxWidth > 750
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                      child: _subjectCard(store.primary, onEdit: () => edit())),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _subjectCard(store.secondary,
                          onEdit: () => edit(second: true)))
                ])
              : Column(children: [
                  _subjectCard(store.primary, onEdit: () => edit()),
                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () async {
                          final ok = await store.updateSubjects(
                              ChartSubject(
                                  name: store.source.name,
                                  birth: store.source.birth,
                                  sex: store.primary.sex,
                                  basis: store.primary.basis,
                                  sect: store.primary.sect),
                              store.secondary);
                          if (!ok && context.mounted) {
                            showToast(
                                context, 'Could not import your profile.');
                          }
                        },
                        icon: const Icon(Icons.person_outline, size: 16),
                        label: const Text('Use my dating profile'),
                      )),
                  const SizedBox(height: 14),
                  _subjectCard(store.secondary,
                      onEdit: () => edit(second: true))
                ])),
      const SizedBox(height: 22),
      FactTiles({
        'A sees B’s day stem': bilingualGod(tenGod(a.master, b.master)),
        'B sees A’s day stem': bilingualGod(tenGod(b.master, a.master)),
        'A · day pillar': a.eight.getDay(),
        'B · day pillar': b.eight.getDay()
      }),
      const SizedBox(height: 25),
      Text('A · ${a.subject.name}',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      ChartTable(a.pillars),
      const SizedBox(height: 25),
      Text('B · ${b.subject.name}',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      ChartTable(b.pillars),
      const SizedBox(height: 24),
      Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const StudioHeading('Between the two charts',
            'Only interactions spanning both charts are included. A clash is a symbolic difference, not evidence of an unhealthy relationship.'),
        RelationList(relations)
      ])),
      const SizedBox(height: 24),
      reading({
        'chartA': a.evidence(),
        'chartB': b.evidence(),
        'crossRelations': relations.map((r) => r.toJson()).toList()
      }, localReading(a, store.style, b: b),
          'Two-person relationship comparison'),
    ]);
  }

  Widget _library() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const StudioHeading('From the source. In your words.',
            'Three curated public-domain excerpts with original English commentary. This is a starter library, not a complete classical-text database.'),
        SegmentedButton<ReadingStyle>(segments: const [
          ButtonSegment(
              value: ReadingStyle.plain, label: Text('Plain English')),
          ButtonSegment(
              value: ReadingStyle.professional, label: Text('Professional'))
        ], selected: {
          store.style
        }, onSelectionChanged: (v) => store.setStyle(v.first)),
        const SizedBox(height: 22),
        for (final p in classicPassages)
          Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Surface(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(p.book,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(p.section,
                        style: const TextStyle(fontSize: 11, color: muted)),
                    const SizedBox(height: 20),
                    Text(p.original,
                        style: const TextStyle(
                            fontSize: 23,
                            fontFamily: 'NotoSansSC',
                            height: 1.8,
                            color: green)),
                    const SizedBox(height: 16),
                    Text(
                        store.style == ReadingStyle.plain
                            ? p.plain
                            : p.professional,
                        style: const TextStyle(fontSize: 13, height: 1.9)),
                    const SizedBox(height: 16),
                    SelectableText(p.url,
                        style: const TextStyle(fontSize: 10, color: muted)),
                    TextButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: p.url));
                          if (mounted) {
                            showToast(context, 'Source link copied.');
                          }
                        },
                        icon: const Icon(Icons.link, size: 16),
                        label: const Text('Copy source link')),
                  ]))),
      ]);
}
