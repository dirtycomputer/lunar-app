import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/bazi_labels.dart';
import '../services/bazi.dart' as bazi;
import '../services/journey.dart';
import 'design.dart';
import 'garden_art.dart';
import 'garden_content.dart';
import 'garden_widgets.dart';

Future<void> showGardenGuide(BuildContext context, JourneyStore store,
        {bazi.Element initial = bazi.Element.wood}) =>
    showDialog<void>(
        context: context,
        builder: (_) => GardenFrame(
            width: 620, child: _GardenGuide(store: store, initial: initial)));

class _GardenGuide extends StatefulWidget {
  final JourneyStore store;
  final bazi.Element initial;
  const _GardenGuide({required this.store, required this.initial});
  @override
  State<_GardenGuide> createState() => _GardenGuideState();
}

class _GardenGuideState extends State<_GardenGuide> {
  late bazi.Element selected = widget.initial;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      GardenHeader(title: l.gardenGuide),
      Flexible(
          child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(children: [
                Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 9,
                    runSpacing: 10,
                    children: [
                      for (final e in bazi.Element.values)
                        ChoiceChip(
                            key: ValueKey('guide-${e.name}'),
                            selected: e == selected,
                            showCheckmark: false,
                            label: Text(elementLabel(l, e)),
                            avatar: Icon(
                                widget.store.seals.contains(e)
                                    ? Icons.verified_rounded
                                    : Icons.circle_outlined,
                                size: 16,
                                color: elementColors[e.index]),
                            onSelected: (_) => setState(() => selected = e)),
                    ]),
                const SizedBox(height: 24),
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: line),
                        borderRadius: BorderRadius.circular(26)),
                    child: Column(children: [
                      Stack(alignment: Alignment.center, children: [
                        Container(
                            width: 145,
                            height: 145,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(colors: [
                                  elementTints[selected.index],
                                  Colors.white
                                ]))),
                        SpiritCompanion(element: selected, size: 126),
                      ]),
                      const SizedBox(height: 10),
                      Text(elementLabel(l, selected),
                          style: TextStyle(
                              fontSize: 27,
                              color: elementColors[selected.index],
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Text(elementMeaning(l, selected),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14, height: 1.7, color: gardenInk)),
                      const SizedBox(height: 22),
                      Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            GardenPill(
                                text:
                                    '${elementLabel(l, bazi.Element.values[(selected.index + 4) % 5])} → ${elementLabel(l, selected)}',
                                icon: Icons.south_west_rounded),
                            GardenPill(
                                text:
                                    '${elementLabel(l, selected)} → ${elementLabel(l, supportedElement(selected))}',
                                icon: Icons.north_east_rounded),
                          ]),
                      const SizedBox(height: 18),
                      Text(cycleFact(l, selected),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: muted, fontSize: 13, height: 1.6)),
                      const SizedBox(height: 24),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                            widget.store.seals.contains(selected)
                                ? Icons.verified_rounded
                                : Icons.local_florist_outlined,
                            size: 20,
                            color: gardenGold),
                        const SizedBox(width: 8),
                        Flexible(
                            child: Text(
                                widget.store.seals.contains(selected)
                                    ? l.gardenCollected
                                    : l.gardenNotCollected,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: gardenGold))),
                      ]),
                    ])),
                const SizedBox(height: 18),
                Text(l.gardenTradition,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 11, color: muted, height: 1.7)),
              ]))),
    ]);
  }
}
