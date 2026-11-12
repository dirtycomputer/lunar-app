import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/app_state.dart';
import '../services/bazi.dart' as core;
import '../services/chart_assistant.dart';
import '../services/intent_flow.dart';
import '../studio/chart_engine.dart';
import '../studio/chart_widgets.dart';
import '../studio/glossary.dart';
import 'design.dart';
import 'journey.dart';

class IntentChooser extends StatelessWidget {
  final ValueChanged<AppIntent> onChoose;
  final VoidCallback onSettings;
  final Widget? journeyAction;
  const IntentChooser(
      {super.key,
      required this.onChoose,
      required this.onSettings,
      this.journeyAction});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
        body: SafeArea(
            child: Column(children: [
      Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1220),
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 16, 14),
                  child: Row(children: [
                    const Expanded(
                        child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: FittedBox(
                                fit: BoxFit.scaleDown, child: BrandMark()))),
                    if (journeyAction != null) ...[
                      journeyAction!,
                      const SizedBox(width: 8)
                    ],
                    IconButton(
                        tooltip: l.flowSettings,
                        onPressed: onSettings,
                        icon: const Icon(Icons.settings_outlined, size: 22))
                  ])))),
      Expanded(
          child: Center(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1024),
                      child: LayoutBuilder(builder: (context, c) {
                        final compact = c.maxWidth < 720;
                        Widget card(AppIntent i) => _IntentCard(
                            intent: i,
                            title: i == AppIntent.chart
                                ? l.flowSelfIntent
                                : l.flowMatch,
                            compact: compact,
                            onTap: () => onChoose(i));
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.journeyChoose,
                                  style: TextStyle(
                                      fontSize: compact ? 36 : 52,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -1.8,
                                      height: 1.15)),
                              SizedBox(height: compact ? 28 : 36),
                              if (compact) ...[
                                card(AppIntent.chart),
                                const SizedBox(height: 16),
                                card(AppIntent.match),
                              ] else
                                Row(children: [
                                  Expanded(child: card(AppIntent.chart)),
                                  const SizedBox(width: 24),
                                  Expanded(child: card(AppIntent.match))
                                ]),
                              const SizedBox(height: 24),
                              OutlinedButton.icon(
                                  key: const ValueKey('intent-agent'),
                                  onPressed: () => onChoose(AppIntent.agent),
                                  style: OutlinedButton.styleFrom(
                                      side: BorderSide.none,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 12)),
                                  icon: const Icon(Icons.forum_outlined,
                                      size: 19),
                                  label: Text(l.flowAskAgent)),
                            ]);
                      }))))),
    ])));
  }
}

class _IntentCard extends StatelessWidget {
  final AppIntent intent;
  final String title;
  final VoidCallback onTap;
  final bool compact;
  const _IntentCard(
      {required this.intent,
      required this.title,
      required this.onTap,
      required this.compact});
  @override
  Widget build(BuildContext context) {
    final reading = intent == AppIntent.chart;
    final foreground = reading ? Colors.white : ink;
    final scale =
        (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(1.0, 3.0);
    final titleWidget = Text(title,
        style: TextStyle(
            color: foreground,
            fontSize: compact ? 25 : 29,
            height: 1.2,
            fontWeight: FontWeight.w600,
            letterSpacing: -.8));
    final arrow = Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: reading ? Colors.white : blue),
        child: Icon(Icons.arrow_forward_rounded,
            color: reading ? blue : Colors.white, size: 22));
    return SizedBox(
        height: compact ? 182 * scale : 352 * scale.clamp(1.0, 1.6),
        child: Material(
            color: reading ? blue : blueTint,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
                key: ValueKey('intent-${intent.name}'),
                onTap: onTap,
                splashColor: reading
                    ? Colors.white.withValues(alpha: .12)
                    : blue.withValues(alpha: .10),
                child: Padding(
                    padding: EdgeInsets.all(compact ? 24 : 30),
                    child: compact
                        ? LayoutBuilder(
                            builder: (context, c) => Row(children: [
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [titleWidget, arrow])),
                                  if (scale <= 1.3)
                                    SizedBox(
                                        width: c.maxWidth * .43,
                                        child: EntranceArt(matching: !reading))
                                ]))
                        : Column(children: [
                            Expanded(
                                child: Center(
                                    child: SizedBox(
                                        width: 260,
                                        height: 230,
                                        child:
                                            EntranceArt(matching: !reading)))),
                            const SizedBox(height: 14),
                            Row(children: [
                              Expanded(child: titleWidget),
                              const SizedBox(width: 12),
                              arrow
                            ])
                          ])))));
  }
}

class MyChartPage extends StatelessWidget {
  final AppState state;
  final ChartContext contextData;
  final bool outlook;
  final OutlookPeriod period;
  final ValueChanged<bool> onMode;
  final ValueChanged<OutlookPeriod> onPeriod;
  final ValueChanged<String> onAsk;
  final VoidCallback onEdit, onTools;
  const MyChartPage(
      {super.key,
      required this.state,
      required this.contextData,
      required this.outlook,
      required this.period,
      required this.onMode,
      required this.onPeriod,
      required this.onAsk,
      required this.onEdit,
      required this.onTools});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final r = contextData.natal;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 25,
          runSpacing: 15,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                Flexible(
                    child: Text(state.personalized ? state.name : l.flowSample,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -.6))),
                const SizedBox(width: 13),
                TermTap(
                    termId: 'master',
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: mintTint,
                            borderRadius: BorderRadius.circular(7)),
                        child: Text('${r.energy.identity} ⓘ',
                            style:
                                const TextStyle(fontSize: 11, color: green))))
              ]),
              const SizedBox(height: 10),
              Text(
                  '${dateLabel(state.birth.date)} · ${state.birth.timeKnown ? '${state.birth.hour.toString().padLeft(2, '0')}:${state.birth.minute.toString().padLeft(2, '0')}' : '—'} · ${state.birth.place.name}',
                  style: const TextStyle(fontSize: 12, color: muted))
            ]),
            Wrap(spacing: 10, runSpacing: 8, children: [
              OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 15),
                  label: Text(l.flowBirthDetails)),
              TextButton.icon(
                  onPressed: onTools,
                  icon: const Icon(Icons.tune, size: 16),
                  label: Text(l.flowTools))
            ]),
          ]),
      const SizedBox(height: 20),
      SegmentedButton<bool>(segments: [
        ButtonSegment(value: false, label: Text(l.flowOverview)),
        ButtonSegment(value: true, label: Text(l.flowOutlook))
      ], selected: {
        outlook
      }, onSelectionChanged: (v) => onMode(v.first)),
      const SizedBox(height: 20),
      if (!outlook) ...[
        LayoutBuilder(builder: (context, c) {
          final reading = _Reading(
              text: contextData.reading,
              element: r.energy.dayElement,
              onAsk: () => onAsk(l.flowQuestionOverview));
          final pillars = _PillarGrid(r);
          return c.maxWidth >= 880 &&
                  MediaQuery.textScalerOf(context).scale(14) < 20
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 6, child: reading),
                  const SizedBox(width: 24),
                  Expanded(flex: 5, child: pillars)
                ])
              : Column(
                  children: [reading, const SizedBox(height: 24), pillars]);
        }),
        const SizedBox(height: 18),
        Surface(
            padding: EdgeInsets.zero,
            child: ExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                title: Text(l.flowDetails,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                childrenPadding: const EdgeInsets.all(18),
                children: [ChartTable(r.pillars)])),
      ] else ...[
        Wrap(spacing: 9, runSpacing: 9, children: [
          for (final p in OutlookPeriod.values)
            ChoiceChip(
                label: Text(switch (p) {
                  OutlookPeriod.today => l.flowToday,
                  OutlookPeriod.month => l.flowMonth,
                  OutlookPeriod.year => l.flowYear
                }),
                selected: p == period,
                onSelected: (_) => onPeriod(p),
                showCheckmark: false)
        ]),
        const SizedBox(height: 20),
        Surface(
            child: Row(children: [
          Text(contextData.period(period).value,
              style: const TextStyle(
                  fontFamily: 'NotoSansSC', fontSize: 45, color: blue)),
          const SizedBox(width: 25),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(cycleEnglish(contextData.period(period).value),
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text(dateLabel(contextData.transit.clock.civil),
                    style: const TextStyle(fontSize: 12, color: muted)),
                const SizedBox(height: 8),
                Text(bilingualGod(contextData.period(period).god),
                    style: const TextStyle(fontSize: 12, color: green))
              ]))
        ])),
        const SizedBox(height: 22),
        _Reading(
            text: contextData.periodReading(period),
            onAsk: () => onAsk('Explain my current ${period.name} period.')),
      ],
    ]);
  }
}

class _PillarGrid extends StatelessWidget {
  final ChartReport report;
  const _PillarGrid(this.report);
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final small = c.maxWidth < 520;
        return Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: line)),
            clipBehavior: Clip.antiAlias,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (var i = 0; i < 4; i++)
                Expanded(
                    child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: small ? 22 : 28, horizontal: 4),
                        decoration: BoxDecoration(
                            color: i == 2 ? mintTint : null,
                            border: BorderDirectional(
                                end: BorderSide(
                                    color:
                                        i == 3 ? Colors.transparent : line))),
                        child: Column(children: [
                          Text(
                              [
                                AppLocalizations.of(context)!.pillarYear,
                                AppLocalizations.of(context)!.pillarMonth,
                                AppLocalizations.of(context)!.pillarDay,
                                AppLocalizations.of(context)!.pillarHour,
                              ][i],
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: i == 2 ? green : muted)),
                          const SizedBox(height: 21),
                          if (i < report.pillars.length) ...[
                            Text(report.pillars[i].value[0],
                                style: TextStyle(
                                    fontFamily: 'NotoSansSC',
                                    fontSize: small ? 35 : 46,
                                    color: elementColors[core.stems.indexOf(
                                            report.pillars[i].value[0]) ~/
                                        2])),
                            const SizedBox(height: 5),
                            Text(
                                core.stemNames[core.stems
                                    .indexOf(report.pillars[i].value[0])],
                                style: const TextStyle(
                                    fontSize: 10, color: muted)),
                            const SizedBox(height: 15),
                            Text(report.pillars[i].value[1],
                                style: TextStyle(
                                    fontFamily: 'NotoSansSC',
                                    fontSize: small ? 35 : 46,
                                    color: ink)),
                            const SizedBox(height: 5),
                            Text(
                                core.branchNames[core.branches
                                    .indexOf(report.pillars[i].value[1])],
                                style: const TextStyle(
                                    fontSize: 10, color: muted)),
                          ] else
                            const SizedBox(
                                height: 153,
                                child: Center(
                                    child: Text('—',
                                        style: TextStyle(
                                            fontSize: 30, color: muted))))
                        ])))
            ]));
      });
}

class _Reading extends StatelessWidget {
  final String text;
  final VoidCallback onAsk;
  final core.Element? element;
  const _Reading({required this.text, required this.onAsk, this.element});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final paragraphs = text.split('\n\n');
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(26)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(l.flowReading,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -.6))),
            if (element != null) ElementSpirit(element: element!, size: 48),
          ]),
          const SizedBox(height: 12),
          SelectableText(paragraphs.first,
              style: const TextStyle(fontSize: 15, height: 1.65, color: ink)),
          if (paragraphs.length > 1)
            Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                    key: ValueKey('reading-details-$text'),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 8),
                    title: Text(l.flowReadingDetails,
                        style: const TextStyle(
                            fontSize: 13,
                            color: muted,
                            fontWeight: FontWeight.w600)),
                    children: [
                      SelectableText(paragraphs.skip(1).join('\n\n'),
                          style: const TextStyle(
                              fontSize: 15, height: 1.8, color: ink))
                    ])),
          const SizedBox(height: 12),
          TextButton.icon(
              onPressed: onAsk,
              style: TextButton.styleFrom(
                  backgroundColor: blueTint,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))),
              icon: const Icon(Icons.chat_bubble_outline, size: 17),
              label: Text(l.flowAskAgent))
        ]));
  }
}
