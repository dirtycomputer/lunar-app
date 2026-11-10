import 'package:flutter/material.dart';
import '../services/bazi.dart' as core;
import '../ui/design.dart';
import 'chart_engine.dart';
import 'glossary.dart';

class StudioHeading extends StatelessWidget {
  final String title, subtitle;
  final Widget? action;
  final String? termId;
  const StudioHeading(this.title, this.subtitle,
      {super.key, this.action, this.termId});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (termId != null)
            TermLink(
                termId: termId!,
                label: title,
                style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    color: blue,
                    letterSpacing: -.5))
          else
            Text(title,
                style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    color: blue,
                    letterSpacing: -.5)),
        ])),
        if (action != null) ...[const SizedBox(width: 12), action!],
      ]));
}

class ChartTable extends StatelessWidget {
  final List<PillarDetail> pillars;
  const ChartTable(this.pillars, {super.key});
  @override
  Widget build(BuildContext context) => Surface(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                    width: c.maxWidth < 680 ? 680 : c.maxWidth,
                    child: Table(
                      columnWidths: const {0: FixedColumnWidth(115)},
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        _row(
                            'PILLAR',
                            pillars
                                .map((p) => Text(p.label.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.1,
                                        color: elementColors[
                                            core.Pillar('', p.value)
                                                .element
                                                .index])))
                                .toList()),
                        _row(
                            'Stem / branch',
                            pillars
                                .map((p) => TermTap(
                                    termId: 'stems',
                                    contextText:
                                        '${p.label} pillar: ${p.value} · ${cycleEnglish(p.value)}',
                                    child: Column(children: [
                                      Text(p.value,
                                          style: TextStyle(
                                              fontFamily: 'NotoSansSC',
                                              fontSize: 34,
                                              color: elementColors[
                                                  core.Pillar('', p.value)
                                                      .element
                                                      .index],
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 6),
                                      Text(cycleEnglish(p.value),
                                          style: const TextStyle(
                                              fontSize: 12, color: ink)),
                                    ])))
                                .toList()),
                        _row(
                            'Ten Gods',
                            pillars
                                .map((p) => TermLink(
                                    termId: termForLabel(p.god) ?? 'gods',
                                    label: bilingualGod(p.god),
                                    align: TextAlign.center,
                                    contextText:
                                        '${p.label} stem ${p.value[0]} → ${bilingualGod(p.god)}',
                                    style: const TextStyle(
                                        fontSize: 11, color: violet)))
                                .toList()),
                        _row(
                            'Hidden stems',
                            pillars
                                .map((p) => Column(children: [
                                      for (var i = 0; i < p.hidden.length; i++)
                                        TermLink(
                                            termId:
                                                termForLabel(p.hiddenGods[i]) ??
                                                    'hidden',
                                            label:
                                                '${p.hidden[i]} · ${tenGodEnglish[p.hiddenGods[i]]}',
                                            align: TextAlign.center,
                                            contextText:
                                                'Hidden stem ${p.hidden[i]} in ${p.label} branch ${p.value[1]} → ${bilingualGod(p.hiddenGods[i])}',
                                            style: const TextStyle(
                                                fontSize: 11, color: ink))
                                    ]))
                                .toList()),
                        _row(
                            '12 growth stages',
                            pillars
                                .map((p) => TermLink(
                                    termId: p.stage,
                                    label: p.stageLabel,
                                    align: TextAlign.center,
                                    contextText:
                                        '${p.label} branch ${p.value[1]}: ${p.stageLabel}, relative to the natal day master.',
                                    style: const TextStyle(
                                        fontSize: 11, color: blue)))
                                .toList()),
                        _row(
                            'Na Yin · 纳音',
                            pillars
                                .map((p) => TermLink(
                                    termId: 'nayin',
                                    label: p.naYin,
                                    align: TextAlign.center,
                                    contextText:
                                        '${p.label} pillar ${p.value} → ${p.naYin}',
                                    style: const TextStyle(
                                        fontSize: 12, color: amber)))
                                .toList()),
                        _row(
                            'Void · 空亡',
                            pillars
                                .map((p) => TermLink(
                                    termId: 'void',
                                    label: p.voidBranches,
                                    align: TextAlign.center,
                                    contextText:
                                        'The ${p.label.toLowerCase()} pillar ${p.value} has xun void branches ${p.voidBranches}.',
                                    style: const TextStyle(
                                        fontSize: 13, color: violet)))
                                .toList()),
                      ],
                    )))),
        if (MediaQuery.sizeOf(context).width < 800)
          const Padding(
              padding: EdgeInsets.only(top: 13),
              child: Text('Swipe the table to see every pillar →',
                  style: TextStyle(fontSize: 10, color: muted))),
      ]));
  TableRow _row(String label, List<Widget> values) => TableRow(children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: TermLink(
                termId: termForLabel(label)!,
                label: label,
                style: const TextStyle(
                    fontSize: 11, color: blue, fontWeight: FontWeight.w600))),
        ...List.generate(
            values.length,
            (i) => Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 9),
                decoration: BoxDecoration(
                    color: elementTints[
                            core.Pillar('', pillars[i].value).element.index]
                        .withValues(alpha: .72),
                    border: const Border(
                        bottom: BorderSide(color: Colors.white, width: 3),
                        left: BorderSide(color: Colors.white, width: 3))),
                child: values[i])),
      ]);
}

class RelationList extends StatelessWidget {
  final List<ChartRelation> relations;
  const RelationList(this.relations, {super.key});
  @override
  Widget build(BuildContext context) => relations.isEmpty
      ? const Text('No interactions found in the implemented rule set.',
          style: TextStyle(fontSize: 12, color: muted))
      : Wrap(
          spacing: 8,
          runSpacing: 9,
          children: relations.map((r) {
            final id = termForLabel(r.name) ?? 'combine';
            final constructive = id == 'combine';
            final color = constructive ? blue : coral;
            return TermTap(
                termId: id,
                contextText: '${r.characters} · ${r.name}\n${r.targets}',
                radius: BorderRadius.circular(14),
                child: Ink(
                    decoration: BoxDecoration(
                        color: constructive ? blueTint : coralTint,
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${r.characters} · ${r.english} ⓘ',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: color,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 5),
                          Text('${r.name} · ${r.targets}',
                              style: const TextStyle(fontSize: 10, color: ink)),
                        ])));
          }).toList());
}

class StarList extends StatelessWidget {
  final List<SymbolicStar> stars;
  const StarList(this.stars, {super.key});
  @override
  Widget build(BuildContext context) => stars.isEmpty
      ? const Text('No stars from this rule set are present.',
          style: TextStyle(fontSize: 12, color: muted))
      : Wrap(
          spacing: 8,
          runSpacing: 8,
          children: stars
              .map((s) => TermTap(
                  termId: termForLabel(s.name) ?? 'stars',
                  contextText:
                      '${s.target} · ${s.english} (${s.name})\n${s.basis}',
                  radius: BorderRadius.circular(14),
                  child: Ink(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 12),
                      decoration: BoxDecoration(
                          color: amberTint,
                          borderRadius: BorderRadius.circular(14)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${s.english} · ${s.name} ⓘ',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: amber,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 5),
                            Text(s.target,
                                style:
                                    const TextStyle(fontSize: 10, color: ink)),
                            const SizedBox(height: 4),
                            Text(s.basis,
                                style:
                                    const TextStyle(fontSize: 9, color: muted)),
                          ]))))
              .toList());
}

class FactTiles extends StatelessWidget {
  final Map<String, String> facts;
  const FactTiles(this.facts, {super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final count = c.maxWidth > 850
            ? 4
            : c.maxWidth > 550
                ? 3
                : 2;
        return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: facts.entries.toList().asMap().entries.map((item) {
              final e = item.value,
                  i = item.key % accentColors.length,
                  id = termForLabel(item.value.key);
              final card = Surface(
                  color: accentTints[i],
                  padding: const EdgeInsets.all(18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${e.key}${id != null ? ' ⓘ' : ''}',
                            style: TextStyle(
                                fontSize: 10,
                                color: accentColors[i],
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        Text(e.value,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: accentColors[i])),
                      ]));
              return SizedBox(
                  width: (c.maxWidth - 12 * (count - 1)) / count,
                  child: id == null
                      ? card
                      : TermTap(
                          termId: id,
                          contextText: '${e.key}: ${e.value}',
                          radius: BorderRadius.circular(24),
                          child: card));
            }).toList());
      });
}
