import 'package:flutter/material.dart';
import '../services/bazi.dart' as core;
import '../ui/design.dart';
import 'chart_engine.dart';
import 'chart_widgets.dart';
import 'seasonal_tools.dart';

class AlmanacPanel extends StatefulWidget {
  const AlmanacPanel({super.key});
  @override
  State<AlmanacPanel> createState() => _AlmanacPanelState();
}

class _AlmanacPanelState extends State<AlmanacPanel> {
  DateTime selected = DateTime.now();
  String activity = '嫁娶';
  List<DateTime>? results;
  void move(int direction) => setState(() {
        selected = DateTime(selected.year, selected.month + direction, 1);
        results = null;
      });
  @override
  Widget build(BuildContext context) {
    final day = AlmanacDay(selected);
    final monthFirst = DateTime(selected.year, selected.month, 1),
        days = DateTime(selected.year, selected.month + 1, 0).day;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const StudioHeading('Make sense of the calendar.',
          'Lunar dates, solar terms and traditional almanac activities. Civil dates use the Chinese calendar (UTC+8).'),
      Surface(
          child: Column(children: [
        Row(children: [
          IconButton(
              onPressed: selected.year <= 1900 && selected.month == 1
                  ? null
                  : () => move(-1),
              tooltip: 'Previous month',
              icon: const Icon(Icons.chevron_left)),
          Expanded(
              child: Text(
                  MaterialLocalizations.of(context).formatMonthYear(selected),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600))),
          IconButton(
              onPressed: selected.year >= 2100 && selected.month == 12
                  ? null
                  : () => move(1),
              tooltip: 'Next month',
              icon: const Icon(Icons.chevron_right)),
          IconButton(
              tooltip: 'Choose calendar date',
              onPressed: () async {
                final value = await showDatePicker(
                    context: context,
                    initialDate: selected,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100, 12, 31));
                if (value != null) {
                  setState(() {
                    selected = value;
                    results = null;
                  });
                }
              },
              icon: const Icon(Icons.calendar_month_outlined)),
        ]),
        const SizedBox(height: 15),
        Row(children: [
          for (final name in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'])
            Expanded(
                child: Text(name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, color: muted)))
        ]),
        const SizedBox(height: 10),
        LayoutBuilder(
            builder: (context, c) => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ((monthFirst.weekday - 1 + days) / 7).ceil() * 7,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisExtent: c.maxWidth < 500 ? 47 : 59,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3),
                itemBuilder: (context, index) {
                  final n = index - monthFirst.weekday + 2;
                  if (n < 1 || n > days) return const SizedBox.shrink();
                  final chosen = n == selected.day;
                  return Material(
                      color: chosen ? green : const Color(0xFFF4F6F0),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                          onTap: () => setState(() => selected =
                              DateTime(selected.year, selected.month, n)),
                          borderRadius: BorderRadius.circular(12),
                          child: Center(
                              child: Text('$n',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: chosen
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: chosen ? Colors.white : ink)))));
                })),
      ])),
      const SizedBox(height: 22),
      FactTiles({
        'Gregorian': dateLabel(selected),
        'Lunar date': day.lunarLabel,
        'Day pillar': day.lunar.getDayInGanZhi(),
        'Solar term': day.lunar.getJieQi().isEmpty
            ? 'No term today'
            : day.lunar.getJieQi()
      }),
      const SizedBox(height: 22),
      Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Traditional recommendations · 宜',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: green)),
        const SizedBox(height: 12),
        _activities(day.recommended, false),
        const SizedBox(height: 24),
        const Text('Traditional avoidances · 忌',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _activities(day.avoided, true),
        const SizedBox(height: 16),
        const Text(
            'Cultural calendar labels, not guarantees of favorable outcomes or guidance for medical or financial decisions.',
            style: TextStyle(fontSize: 10, color: muted)),
      ])),
      const SizedBox(height: 24),
      Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const StudioHeading('Explore upcoming dates',
            'Search the next 30 civil dates for a traditional activity. This is not a personalized election.'),
        Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String>(
                      value: activity,
                      decoration: const InputDecoration(labelText: 'Activity'),
                      items: ['嫁娶', '出行', '开市', '移徙']
                          .map((a) => DropdownMenuItem(
                              value: a,
                              child: Text(activityLabel(a),
                                  style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (v) => setState(() {
                            activity = v!;
                            results = null;
                          }))),
              FilledButton(
                  onPressed: () => setState(() => results = List.generate(
                          30,
                          (i) => DateTime(selected.year, selected.month,
                              selected.day + i)).where((d) {
                        final a = AlmanacDay(d);
                        return a.recommended.contains(activity) &&
                            !a.avoided.contains(activity);
                      }).toList()),
                  child: const Text('Find dates')),
            ]),
        if (results != null) ...[
          const SizedBox(height: 16),
          Text('${results!.length} dates match the almanac listing.',
              style: const TextStyle(fontSize: 12, color: muted)),
          const SizedBox(height: 10),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: results!
                  .map((d) => ActionChip(
                      label: Text(dateLabel(d)),
                      onPressed: () => setState(() => selected = d)))
                  .toList())
        ],
      ])),
      const SizedBox(height: 24),
      const StudioHeading('The hours of the day',
          'Early and late Zi (Rat) hours are shown separately. Hour pillars follow the library’s late-Zi convention.'),
      LayoutBuilder(builder: (context, c) {
        final n = c.maxWidth > 850
            ? 4
            : c.maxWidth > 500
                ? 3
                : 2;
        return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [...day.hours, day.lateRat]
                .map((h) => SizedBox(
                    width: (c.maxWidth - 12 * (n - 1)) / n,
                    child: Surface(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(h.$1,
                                  style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(h.$2,
                                  style: const TextStyle(
                                      fontSize: 11, color: muted)),
                              const SizedBox(height: 8),
                              Text(
                                  h.$3 == '吉'
                                      ? 'Auspicious · 吉'
                                      : 'Inauspicious · 凶',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: h.$3 == '吉' ? green : muted)),
                              const SizedBox(height: 10),
                              Text('宜 ${h.$4.map(activityLabel).join(' / ')}',
                                  style: const TextStyle(
                                      fontSize: 9, height: 1.6)),
                              const SizedBox(height: 7),
                              Text('忌 ${h.$5.map(activityLabel).join(' / ')}',
                                  style: const TextStyle(
                                      fontSize: 9, color: muted, height: 1.6)),
                            ]))))
                .toList());
      }),
    ]);
  }

  Widget _activities(List<String> values, bool avoid) => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values
          .map((v) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color:
                      avoid ? const Color(0xFFF8F0EC) : const Color(0xFFEDF1E5),
                  borderRadius: BorderRadius.circular(10)),
              child:
                  Text(activityLabel(v), style: const TextStyle(fontSize: 11))))
          .toList());
}

class FivePhasesPanel extends StatefulWidget {
  const FivePhasesPanel({super.key});
  @override
  State<FivePhasesPanel> createState() => _FivePhasesPanelState();
}

class _FivePhasesPanelState extends State<FivePhasesPanel> {
  int year = DateTime.now().year, stage = 0;
  @override
  Widget build(BuildContext context) {
    final data = SeasonalTools.forYear(year),
        period = SeasonalTools.forYear(year).qi[stage];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      StudioHeading('Five Movements, Six Qi',
          'A traditional seasonal model, shown as an interactive cultural calendar.',
          action: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
                onPressed: year > 1900 ? () => setState(() => year--) : null,
                tooltip: 'Previous seasonal year',
                icon: const Icon(Icons.chevron_left)),
            Text('$year',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            IconButton(
                onPressed: year < 2100 ? () => setState(() => year++) : null,
                tooltip: 'Next seasonal year',
                icon: const Icon(Icons.chevron_right)),
          ])),
      FactTiles({
        'Year · 年干支': data.ganZhi,
        'Annual movement · 岁运':
            '${data.annualElement.label} · ${data.excess ? 'Excess 太过' : 'Insufficiency 不及'}',
        'Heaven · 司天': data.heaven,
        'Earth · 在泉': data.earth
      }),
      const SizedBox(height: 26),
      const StudioHeading('Five movements · 五运',
          'Host movement follows wood → fire → earth → metal → water. Guest movement begins with the annual element.'),
      LayoutBuilder(builder: (context, c) {
        final n = c.maxWidth > 700 ? 5 : 2;
        return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
                5,
                (i) => SizedBox(
                    width: (c.maxWidth - 12 * (n - 1)) / n,
                    child: Surface(
                        padding: const EdgeInsets.all(18),
                        color: Color.lerp(elementColors[data.guests[i].index],
                            Colors.white, .92)!,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('MOVEMENT ${i + 1}',
                                  style: const TextStyle(
                                      fontSize: 9,
                                      color: muted,
                                      letterSpacing: 1)),
                              const SizedBox(height: 16),
                              Icon(elementIcon(data.guests[i]),
                                  color: elementColors[data.guests[i].index],
                                  size: 28),
                              const SizedBox(height: 14),
                              Text('Host · ${data.hosts[i].label}',
                                  style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 7),
                              Text('Guest · ${data.guests[i].label}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                            ])))));
      }),
      const SizedBox(height: 14),
      const Text(
          'The five cards show phase order, not exact five-step handover times. Six-Qi boundaries below use astronomical solar terms in UTC+8.',
          style: TextStyle(fontSize: 10, color: muted)),
      const SizedBox(height: 28),
      const StudioHeading('Six Qi · 六气',
          'Select a period to inspect host and guest Qi. The seasonal year runs from Great Cold to the next Great Cold.'),
      LayoutBuilder(builder: (context, c) {
        final n = c.maxWidth > 850
            ? 6
            : c.maxWidth > 500
                ? 3
                : 2;
        return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
                6,
                (i) => SizedBox(
                    width: (c.maxWidth - 8 * (n - 1)) / n,
                    child: Material(
                        color: stage == i ? green : const Color(0xFFEDF1E5),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                            onTap: () => setState(() => stage = i),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                                padding: const EdgeInsets.all(17),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('QI ${i + 1}',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: stage == i
                                                  ? Colors.white70
                                                  : muted)),
                                      const SizedBox(height: 10),
                                      Text(data.qi[i].guest.split(' · ').first,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: stage == i
                                                  ? Colors.white
                                                  : ink,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 7),
                                      Text(dateLabel(data.qi[i].start),
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: stage == i
                                                  ? Colors.white70
                                                  : muted)),
                                    ])))))));
      }),
      const SizedBox(height: 20),
      Surface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            'Period ${stage + 1} · ${dateLabel(period.start)} → ${dateLabel(period.end)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 18),
        FactTiles({'Host Qi · 主气': period.host, 'Guest Qi · 客气': period.guest}),
        const SizedBox(height: 16),
        Text(
            'Starts ${clockLabel(period.start)} UTC+8\nEnds ${clockLabel(period.end)} UTC+8 (exclusive)',
            style: const TextStyle(fontSize: 11, color: muted, height: 1.7)),
        const SizedBox(height: 12),
        const Text(
            'For study of the Su Wen tradition. This diagram is not a medical assessment, treatment recommendation or weather forecast.',
            style: TextStyle(fontSize: 11, color: muted, height: 1.7)),
      ])),
    ]);
  }
}
