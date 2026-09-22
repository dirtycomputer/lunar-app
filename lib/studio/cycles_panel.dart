import 'package:flutter/material.dart';
import 'package:lunar/lunar.dart';
import '../ui/design.dart';
import 'chart_engine.dart';
import 'chart_widgets.dart';

class CyclesPanel extends StatefulWidget {
  final ChartReport report;
  final Widget Function(Map<String, dynamic>, String) reading;
  const CyclesPanel({super.key, required this.report, required this.reading});
  @override
  State<CyclesPanel> createState() => _CyclesPanelState();
}

class _CyclesPanelState extends State<CyclesPanel> {
  int decade = 0, year = DateTime.now().year, month = 0;
  DateTime? selectedDay;
  List<DaYun> get decades => ChartEngine()
      .fortune(widget.report)
      .getDaYunBy(10)
      .where((d) => d.getIndex() > 0)
      .toList();
  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(covariant CyclesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.report.subject != widget.report.subject) _reset();
  }

  void _reset() {
    final all = decades;
    final current = all
        .indexWhere((d) => year >= d.getStartYear() && year <= d.getEndYear());
    decade = current < 0 ? 0 : current;
    year = year.clamp(all[decade].getStartYear(), all[decade].getEndYear());
    selectedDay = null;
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.report,
        engine = ChartEngine(),
        yun = engine.fortune(r),
        all = decades,
        d = all[decade];
    final range = ChartEngine.monthRange(year, month);
    final first = DateTime.utc(range.$1.year, range.$1.month, range.$1.day);
    final end = DateTime.utc(range.$2.year, range.$2.month, range.$2.day);
    final days = List.generate(
        end.difference(first).inDays + 1, (i) => first.add(Duration(days: i)));
    final chosen = selectedDay != null && days.contains(selectedDay)
        ? selectedDay!
        : first;
    var snapshot = chosen.add(const Duration(hours: 12));
    if (snapshot.isBefore(range.$1)) {
      snapshot = range.$1.add(const Duration(seconds: 1));
    }
    if (!snapshot.isBefore(range.$2)) {
      snapshot = range.$2.subtract(const Duration(seconds: 1));
    }
    final transit = Solar.fromYmdHms(snapshot.year, snapshot.month,
            snapshot.day, snapshot.hour, snapshot.minute, snapshot.second)
        .getLunar()
        .getEightChar()
      ..setSect(r.subject.sect);
    final flow = [
      ChartEngine.detail('Da Yun', d.getGanZhi(), r.master),
      ChartEngine.detail('Year transit', transit.getYear(), r.master),
      ChartEngine.detail('Month transit', transit.getMonth(), r.master),
      ChartEngine.detail('Day transit', transit.getDay(), r.master)
    ];
    final labels = [
      ...r.pillars.map((p) => ('Natal ${p.label}', p.value)),
      ...flow.map((p) => (p.label, p.value))
    ];
    final relationships = ChartEngine.relations(labels),
        stars =
            ChartEngine.stars(r, flow.map((p) => (p.label, p.value)).toList());
    final evidence = {
      'natal': r.evidence(),
      'transitSnapshot': clockLabel(snapshot),
      'transitZone': 'UTC+8',
      'fortuneDirection': yun.isForward() ? 'forward' : 'reverse',
      'flows': flow.map((p) => p.toJson()).toList(),
      'relations': relationships.map((v) => v.toJson()).toList(),
      'transitStars': stars.map((s) => s.toJson()).toList()
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const StudioHeading('See the layers of time.',
          'Select a decade, solar year, solar-term month and day. All transit snapshots use UTC+8.'),
      FactTiles({
        'Direction': yun.isForward() ? 'Forward · 顺行' : 'Reverse · 逆行',
        'Starts after':
            '${yun.getStartYear()}y ${yun.getStartMonth()}m ${yun.getStartDay()}d ${yun.getStartHour()}h',
        'Start at birthplace': clockLabel(engine.fortuneStart(r)),
        'Convention': 'Minute-based 起运 · sect 2'
      }),
      if (!r.subject.birth.timeKnown)
        const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
                'Birth time unknown: start-of-luck timing is estimated from local noon.',
                style: TextStyle(fontSize: 12, color: muted))),
      const SizedBox(height: 25),
      const Text('DECADE FORTUNE · 大运',
          style: TextStyle(fontSize: 10, color: muted, letterSpacing: 1.2)),
      const SizedBox(height: 13),
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (var i = 0; i < all.length; i++)
              Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    showCheckmark: false,
                    selected: decade == i,
                    onSelected: (_) => setState(() {
                      decade = i;
                      year = all[i].getStartYear();
                      selectedDay = null;
                    }),
                    label: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(all[i].getGanZhi(),
                                  style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text(
                                  '${all[i].getStartYear()}–${all[i].getEndYear()}',
                                  style: const TextStyle(fontSize: 11)),
                              const SizedBox(height: 4),
                              Text(
                                  'Age ${all[i].getStartAge()}–${all[i].getEndAge()}',
                                  style: const TextStyle(fontSize: 10)),
                            ])),
                  )),
          ])),
      const SizedBox(height: 10),
      const Text(
          'Ages use the library’s traditional nominal-age convention, not birthday-based age.',
          style: TextStyle(fontSize: 10, color: muted)),
      const SizedBox(height: 24),
      Wrap(spacing: 14, runSpacing: 14, children: [
        SizedBox(
            width: 210,
            child: DropdownButtonFormField<int>(
                value: year,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Solar year · 流年'),
                items: List.generate(10, (i) => d.getStartYear() + i)
                    .map((y) => DropdownMenuItem(
                        value: y,
                        child: Text('$y · ${ChartEngine.annual(y)}',
                            style: const TextStyle(fontSize: 12))))
                    .toList(),
                onChanged: (v) => setState(() {
                      year = v!;
                      selectedDay = null;
                    }))),
        SizedBox(
            width: 235,
            child: DropdownButtonFormField<int>(
                value: month,
                isExpanded: true,
                decoration:
                    const InputDecoration(labelText: 'Solar-term month · 流月'),
                items: List.generate(
                    12,
                    (i) => DropdownMenuItem(
                        value: i,
                        child: Text(
                            '${i + 1} · ${ChartEngine.monthTerms[i]} · ${ChartEngine.monthly(year, i)}',
                            style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (v) => setState(() {
                      month = v!;
                      selectedDay = null;
                    }))),
      ]),
      const SizedBox(height: 18),
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              children: days
                  .map((date) => Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: ChoiceChip(
                          label: Text('${date.month}/${date.day}',
                              style: const TextStyle(fontSize: 11)),
                          selected: date == chosen,
                          showCheckmark: false,
                          onSelected: (_) =>
                              setState(() => selectedDay = date))))
                  .toList())),
      const SizedBox(height: 14),
      Text(
          'Snapshot: ${clockLabel(snapshot)} UTC+8. Boundary dates use a time inside the selected solar month.',
          style: const TextStyle(fontSize: 10, color: muted)),
      const SizedBox(height: 22),
      ChartTable(flow),
      const SizedBox(height: 24),
      Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const StudioHeading('Natal + transit relationships',
            'Combinations, clashes, harms, breaks and punishments. A combination does not imply successful transformation.'),
        RelationList(relationships)
      ])),
      const SizedBox(height: 22),
      Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const StudioHeading('Transit symbolic stars',
            'Da Yun, year, month and day assessed against natal day/year anchors.'),
        StarList(stars)
      ])),
      const SizedBox(height: 24),
      widget.reading(evidence,
          'Selected cycles: ${flow.map((p) => '${p.label} ${p.value} (${bilingualGod(p.god)})').join('; ')}. ${relationships.length} structural relationships were found. Start-of-luck timing ${r.subject.birth.timeKnown ? 'uses the recorded birth time' : 'is approximate because the birth hour is unknown'}. These are calendar layers for study, not predictions of events.'),
    ]);
  }
}
