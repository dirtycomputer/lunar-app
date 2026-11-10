import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/bazi_labels.dart';
import '../services/app_state.dart';
import '../services/bazi.dart' as bazi;
import '../studio/glossary.dart';
import 'design.dart';
import 'language_picker.dart';
import 'legal_center.dart';

class EnergyPage extends StatelessWidget {
  final AppState state;
  final VoidCallback onEdit, onLearn;
  const EnergyPage(
      {super.key,
      required this.state,
      required this.onEdit,
      required this.onLearn});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 20,
          runSpacing: 20,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.energyTitle,
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 10),
              Text(l10n.energySub, style: const TextStyle(color: muted)),
            ]),
            OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text(l10n.editBirth)),
          ]),
      const SizedBox(height: 28),
      if (!state.personalized)
        Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Surface(
                color: const Color(0xFFF6F1E7),
                padding: const EdgeInsets.all(18),
                child: Row(children: [
                  const Icon(Icons.lightbulb_outline, color: Color(0xFFAD9055)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(l10n.sampleNotice,
                          style: const TextStyle(fontSize: 12))),
                  TextButton(onPressed: onEdit, child: Text(l10n.getStarted))
                ]))),
      LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth > 700;
        final ring = Surface(
            child: Column(children: [
          ElementRing(chart: state.chart, size: 215),
          const SizedBox(height: 23),
          Text(elementQuality(l10n, state.chart.dayElement),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(l10n.dayMasterBody,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted, fontSize: 12, height: 1.8)),
          const SizedBox(height: 6),
          TermLink(
              termId: 'master',
              label: l10n.whatIsDayMaster,
              contextText:
                  l10n.myDayMasterContext(identityLabel(l10n, state.chart)),
              style: const TextStyle(fontSize: 11, color: violet))
        ]));
        final elements = Surface(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TermLink(
              termId: 'stems',
              label: l10n.fiveElements,
              contextText: l10n.elementsContext,
              style: const TextStyle(
                  fontSize: 19, fontWeight: FontWeight.w600, color: ink)),
          const SizedBox(height: 5),
          Text(l10n.elementsSub,
              style: const TextStyle(fontSize: 11, color: muted)),
          const SizedBox(height: 25),
          for (final e in bazi.Element.values)
            Padding(
                padding: const EdgeInsets.only(bottom: 21),
                child: Row(children: [
                  Icon(elementIcon(e), color: elementColors[e.index], size: 23),
                  const SizedBox(width: 14),
                  SizedBox(
                      width: 58,
                      child: Text(elementLabel(l10n, e),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600))),
                  Expanded(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                              minHeight: 8,
                              value: state.chart.distribution[e.index],
                              color: elementColors[e.index],
                              backgroundColor: line))),
                  const SizedBox(width: 15),
                  SizedBox(
                      width: 36,
                      child: Text(
                          '${(state.chart.distribution[e.index] * 100).round()}%',
                          style: const TextStyle(fontSize: 12, color: muted))),
                ])),
        ]));
        return wide
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: ring),
                const SizedBox(width: 24),
                Expanded(child: elements)
              ])
            : Column(children: [ring, const SizedBox(height: 20), elements]);
      }),
      const SizedBox(height: 30),
      TermLink(
          termId: 'pillars',
          label: l10n.fourPillars,
          contextText: l10n.pillarsContext,
          style: const TextStyle(
              fontSize: 21, fontWeight: FontWeight.w600, color: ink)),
      const SizedBox(height: 8),
      Text(l10n.pillarsSub, style: const TextStyle(color: muted, fontSize: 12)),
      const SizedBox(height: 20),
      LayoutBuilder(builder: (context, c) {
        final columns = c.maxWidth > 650 ? 4 : 2;
        return Wrap(spacing: 14, runSpacing: 14, children: [
          for (final pillar in state.chart.pillars)
            SizedBox(
                width: (c.maxWidth - 14 * (columns - 1)) / columns,
                child: TermTap(
                    termId: 'pillars',
                    contextText: l10n.pillarContext(pillarLabel(l10n, pillar),
                        '${pillar.value} (${comboLabel(l10n, pillar)})'),
                    radius: BorderRadius.circular(24),
                    child: Surface(
                        padding: const EdgeInsets.all(20),
                        color: elementTints[pillar.element.index],
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(pillarLabel(l10n, pillar).toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          elementColors[pillar.element.index],
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.4)),
                              const SizedBox(height: 19),
                              Text(stemDisplay(l10n, pillar),
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          elementColors[pillar.element.index])),
                              Text(branchLabel(l10n, pillar),
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Color.lerp(
                                          elementColors[pillar.element.index],
                                          ink,
                                          .45))),
                              const SizedBox(height: 17),
                              ElementPill(pillar.element),
                            ])))),
          if (!state.chart.timeKnown)
            SizedBox(
                width: (c.maxWidth - 14 * (columns - 1)) / columns,
                child: Surface(
                    child: Column(children: [
                  const Icon(Icons.schedule, color: muted),
                  const SizedBox(height: 20),
                  Text(l10n.hourUnknown),
                  const SizedBox(height: 10),
                  Text(l10n.hourUnknownBody,
                      style: const TextStyle(fontSize: 11, color: muted)),
                ]))),
        ]);
      }),
      const SizedBox(height: 28),
      Surface(
          color: const Color(0xFFEDF1E5),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.contextTitle,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(
                '${l10n.calcNote(state.birth.place.zone, state.birth.place.longitude.toStringAsFixed(2))}${state.chart.timeKnown ? '' : ' ${l10n.noTimeBoundaryNote}'}',
                style:
                    const TextStyle(fontSize: 12, color: muted, height: 1.8)),
            const SizedBox(height: 4),
            TermLink(
                termId: 'solar',
                label: l10n.solarWhy,
                contextText: l10n.solarContext(
                    state.birth.place.longitude.toStringAsFixed(2)),
                style: const TextStyle(fontSize: 11, color: green)),
            const SizedBox(height: 12),
            TextButton.icon(
                onPressed: onLearn,
                label: Text(l10n.understandChart),
                icon: const Icon(Icons.arrow_forward, size: 16)),
          ])),
      const SizedBox(height: 16),
      TextButton.icon(
          onPressed: () => showPrivacy(context, state),
          icon: const Icon(Icons.lock_outline, size: 16),
          label: Text(l10n.privacyData)),
      TextButton.icon(
          onPressed: () => showLanguagePicker(context, state),
          icon: const Icon(Icons.translate, size: 16),
          label: Text(l10n.languageTitle)),
    ]);
  }
}

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l10n.meetElements,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
      const SizedBox(height: 20),
      LayoutBuilder(
          builder: (context, c) => Wrap(spacing: 15, runSpacing: 15, children: [
                for (final e in bazi.Element.values)
                  SizedBox(
                      width: c.maxWidth > 900
                          ? (c.maxWidth - 60) / 5
                          : c.maxWidth > 550
                              ? (c.maxWidth - 30) / 3
                              : (c.maxWidth - 15) / 2,
                      child: Surface(
                          padding: const EdgeInsets.all(20),
                          color: Color.lerp(
                              elementColors[e.index], Colors.white, .9)!,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(elementIcon(e),
                                    color: elementColors[e.index], size: 30),
                                const SizedBox(height: 20),
                                Text(elementLabel(l10n, e),
                                    style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Text(elementQuality(l10n, e),
                                    style: const TextStyle(
                                        fontSize: 11, color: muted)),
                              ]))),
              ])),
      const SizedBox(height: 30),
      _GuideSection(
          tint: blueTint,
          accent: blue,
          title: l10n.guidePillarsTitle,
          body: l10n.guidePillarsBody,
          terms: [
            ('pillars', l10n.termFourPillars),
            ('stems', l10n.termStemsBranches),
            ('master', l10n.termDayMaster)
          ]),
      _GuideSection(
          tint: lavenderTint,
          accent: violet,
          title: l10n.guideHarmonyTitle,
          body: l10n.guideHarmonyBody,
          terms: [
            ('gods', l10n.termTenGods),
            ('combine', l10n.termCombinations)
          ]),
      _GuideSection(
          tint: coralTint,
          accent: coral,
          title: l10n.guideScoreTitle,
          body: l10n.guideScoreBody),
      _GuideSection(
          tint: mintTint,
          accent: green,
          title: l10n.guideTimezoneTitle,
          body: l10n.guideTimezoneBody,
          terms: [('solar', l10n.termSolarTime)]),
      _GuideSection(
          tint: amberTint,
          accent: amber,
          title: l10n.guideNoTimeTitle,
          body: l10n.guideNoTimeBody,
          terms: [('pillars', l10n.termFourPillars)]),
      _GuideSection(
          tint: blueTint,
          accent: blue,
          title: l10n.guideCommunityTitle,
          body: l10n.guideCommunityBody),
      const SizedBox(height: 15),
      Center(
          child: Text(l10n.guideFooter,
              style: const TextStyle(color: green, fontSize: 12))),
    ]);
  }
}

class _GuideSection extends StatelessWidget {
  final String title, body;
  final Color tint, accent;
  final List<(String, String)> terms;
  const _GuideSection(
      {required this.title,
      required this.body,
      this.tint = Colors.white,
      this.accent = blue,
      this.terms = const []});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Surface(
          padding: const EdgeInsets.all(22),
          color: tint,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.lerp(accent, ink, .3))),
            const SizedBox(height: 10),
            Text(body,
                style:
                    const TextStyle(fontSize: 12, color: muted, height: 1.9)),
            if (terms.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('DIG DEEPER',
                        style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                            color: muted)),
                    for (final (id, label) in terms)
                      TermLink(
                          termId: id,
                          label: label,
                          style: TextStyle(fontSize: 11, color: accent))
                  ])
            ]
          ])));
}

Future<void> showPrivacy(BuildContext context, AppState state) =>
    showDialog<void>(
        context: context,
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
              backgroundColor: canvas,
              title: Text(l10n.privacyTitle),
              content: SizedBox(
                  width: 430,
                  child: SingleChildScrollView(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(l10n.privacyBody1,
                            style: const TextStyle(fontSize: 13, height: 1.8)),
                        const SizedBox(height: 15),
                        Text(l10n.privacyBody2,
                            style: const TextStyle(
                                fontSize: 12, height: 1.8, color: muted)),
                        const SizedBox(height: 15),
                        Text(l10n.privacyBody3,
                            style: const TextStyle(
                                fontSize: 12, height: 1.8, color: muted)),
                      ]))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.actionClose)),
                TextButton(
                    onPressed: () => showLegalCenter(context, state),
                    child: Text(l10n.legalPolicies)),
                OutlinedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                          context: context,
                          builder: (inner) => AlertDialog(
                                  title: Text(l10n.clearDataTitle),
                                  content: Text(l10n.clearDataBody),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(inner, false),
                                        child: Text(l10n.keepMyData)),
                                    FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(inner, true),
                                        child: Text(l10n.clearData))
                                  ]));
                      if (confirm != true) return;
                      final ok = await state.reset();
                      if (context.mounted) {
                        Navigator.pop(context);
                        showToast(context,
                            ok ? l10n.clearOkToast : l10n.clearFailToast);
                      }
                    },
                    child: Text(l10n.resetLocalData))
              ]);
        });
