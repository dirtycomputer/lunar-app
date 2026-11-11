import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/bazi_labels.dart';
import '../services/bazi.dart' as bazi;
import '../services/journey.dart';
import 'design.dart';
import 'garden_art.dart';
import 'element_art.dart';
import 'garden_guide.dart';
import 'garden_widgets.dart';
import 'garden_workshop.dart';

Future<JourneyQuest?> showJourney(BuildContext context, JourneyStore store,
        {bazi.Element element = bazi.Element.wood, bool sample = true}) =>
    showDialog<JourneyQuest>(
        context: context,
        builder: (_) => GardenFrame(
            child: _GardenMap(store: store, element: element, sample: sample)));

Future<bool?> showElementQuest(BuildContext context,
        {required bazi.Element element,
        required bool sample,
        required JourneyStore store}) =>
    showDialog<bool>(
        context: context,
        builder: (_) => GardenFrame(
            width: 1020,
            child:
                CycleWorkshop(element: element, sample: sample, store: store)));

class _GardenMap extends StatelessWidget {
  final JourneyStore store;
  final bazi.Element element;
  final bool sample;
  const _GardenMap(
      {required this.store, required this.element, required this.sample});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ListenableBuilder(
        listenable: store,
        builder: (context, _) =>
            Column(mainAxisSize: MainAxisSize.min, children: [
              GardenHeader(title: l.gardenTitle, actions: [
                IconButton(
                    key: const ValueKey('garden-guide'),
                    tooltip: l.gardenGuide,
                    onPressed: () =>
                        showGardenGuide(context, store, initial: element),
                    icon: const Icon(Icons.auto_stories_outlined,
                        color: gardenInk))
              ]),
              Flexible(
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                      child: LayoutBuilder(builder: (context, c) {
                        final scene = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GardenScene(
                                  collected: store.seals,
                                  discoveries: store.gardenCompleted.length,
                                  onExplore: (e) => showGardenGuide(
                                      context, store,
                                      initial: e)),
                              const SizedBox(height: 16),
                              Wrap(spacing: 8, runSpacing: 8, children: [
                                GardenPill(
                                    text: sample
                                        ? l.journeySample
                                        : elementLabel(l, element),
                                    icon: Icons.spa_outlined),
                                GardenPill(
                                    text: l.gardenSeals(store.seals.length),
                                    icon: Icons.verified_outlined),
                              ]),
                            ]);
                        final tasks = _taskPanel(context, l);
                        return c.maxWidth >= 820
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Expanded(flex: 6, child: scene),
                                    const SizedBox(width: 24),
                                    Expanded(flex: 4, child: tasks),
                                  ])
                            : Column(children: [
                                scene,
                                const SizedBox(height: 22),
                                tasks
                              ]);
                      }))),
            ]));
  }

  Widget _taskPanel(BuildContext context, AppLocalizations l) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE7E8DB)),
          borderRadius: BorderRadius.circular(26)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Text(l.gardenChapter,
                  style: const TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.4,
                      color: muted,
                      fontWeight: FontWeight.w700))),
          const Icon(Icons.auto_awesome_rounded, size: 16, color: gardenGold),
          const SizedBox(width: 5),
          Text('${store.sparks}',
              style: const TextStyle(
                  fontSize: 14, color: gardenGold, fontWeight: FontWeight.w700))
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
              child: Text(
                  store.gardenCompleted.length == 3
                      ? l.gardenBloom
                      : l.gardenFirstLight,
                  style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.8,
                      height: 1.2,
                      color: gardenInk))),
          SpiritCompanion(element: element, size: 64)
        ]),
        const SizedBox(height: 14),
        ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
                minHeight: 6,
                value: store.gardenCompleted.length / 3,
                color: green,
                backgroundColor: mintTint)),
        const SizedBox(height: 10),
        Text(l.journeyProgress(store.gardenCompleted.length),
            style: const TextStyle(fontSize: 11, color: muted)),
        const SizedBox(height: 20),
        for (final q in JourneyQuest.values)
          Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GardenQuest(
                  quest: q,
                  store: store,
                  onTap: () => Navigator.pop(context, q))),
        const SizedBox(height: 8),
        Text(l.gardenCollection,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700, color: gardenInk)),
        const SizedBox(height: 12),
        Wrap(spacing: 7, runSpacing: 9, children: [
          for (final e in bazi.Element.values)
            Tooltip(
                message: elementLabel(l, e),
                child: InkWell(
                    key: ValueKey('seal-${e.name}'),
                    onTap: () => showGardenGuide(context, store, initial: e),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                        width: 43,
                        height: 49,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: store.seals.contains(e)
                                    ? elementColors[e.index]
                                        .withValues(alpha: .5)
                                    : line),
                            color: store.seals.contains(e)
                                ? elementTints[e.index]
                                : canvas,
                            borderRadius: BorderRadius.circular(16)),
                        child: Opacity(
                            opacity: store.seals.contains(e) ? 1 : .35,
                            child: ElementSpirit(element: e, size: 39)))))
        ]),
        const SizedBox(height: 16),
        TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_outward_rounded, size: 16),
            label: Text(l.journeyKeepExploring)),
      ]));
}

class _GardenQuest extends StatelessWidget {
  final JourneyQuest quest;
  final JourneyStore store;
  final VoidCallback onTap;
  const _GardenQuest(
      {required this.quest, required this.store, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final done = store.gardenCompleted.contains(quest);
    final title = switch (quest) {
      JourneyQuest.element => l.gardenRestore,
      JourneyQuest.outlook => l.journeyOutlookTask,
      JourneyQuest.encounter => l.journeyEncounterTask,
    };
    final first = JourneyQuest.values.firstWhere(
        (q) => !store.gardenCompleted.contains(q),
        orElse: () => JourneyQuest.element);
    final active = first == quest && !done;
    final subtitle = quest == JourneyQuest.element && store.hasCycleInProgress
        ? l.gardenResume(store.cycleSteps)
        : quest == JourneyQuest.element &&
                store.completed.contains(quest) &&
                !done
            ? l.gardenCollectSeals
            : done
                ? l.gardenReplay
                : l.journeyReward(20);
    return Container(
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(18), boxShadow: [
          BoxShadow(
              color: (active ? green : gardenInk).withValues(alpha: .10),
              offset: const Offset(0, 4))
        ]),
        child: Material(
            color: active ? mintTint : gardenPaper,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                    color: active
                        ? green.withValues(alpha: .5)
                        : const Color(0xFFE6E6D7))),
            child: InkWell(
                key: ValueKey('quest-${quest.name}'),
                borderRadius: BorderRadius.circular(18),
                onTap: onTap,
                child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(children: [
                      Container(
                          width: 35,
                          height: 35,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: done ? green : Colors.white,
                              shape: BoxShape.circle),
                          child: done
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 21)
                              : Text('0${quest.index + 1}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: gardenInk,
                                      fontWeight: FontWeight.w700))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(title,
                                style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    fontWeight: FontWeight.w700,
                                    color: gardenInk)),
                            const SizedBox(height: 4),
                            Text(subtitle,
                                style: const TextStyle(
                                    fontSize: 10, color: muted)),
                          ])),
                      const SizedBox(width: 8),
                      Icon(
                          done
                              ? Icons.replay_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
                          color: green),
                    ])))));
  }
}
