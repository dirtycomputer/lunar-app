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
        backgroundColor: canvas,
        body: SafeArea(
            child: Column(children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
              child: Row(children: [
                const FlowerLogo(size: 29),
                const SizedBox(width: 10),
                const Expanded(
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text('FatePair',
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -1.3)))),
                if (journeyAction != null) ...[
                  journeyAction!,
                  const SizedBox(width: 8)
                ],
                IconButton(
                    tooltip: l.flowSettings,
                    onPressed: onSettings,
                    icon: const Icon(Icons.settings_outlined, size: 22))
              ])),
          Expanded(
              child: Center(
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 920),
                          child: LayoutBuilder(builder: (context, c) {
                            final compact = c.maxWidth < 720;
                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l.journeyChoose,
                                      style: TextStyle(
                                          fontSize: compact ? 34 : 46,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: -1.6,
                                          height: 1.18)),
                                  SizedBox(height: compact ? 28 : 48),
                                  if (compact)
                                    ...[
                                      AppIntent.chart,
                                      AppIntent.match
                                    ].map((i) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 15),
                                        child: _IntentCard(
                                            intent: i,
                                            title: switch (i) {
                                              AppIntent.chart =>
                                                l.flowSelfIntent,
                                              AppIntent.match => l.flowMatch,
                                              AppIntent.agent => l.flowAskAgent
                                            },
                                            compact: true,
                                            onTap: () => onChoose(i))))
                                  else
                                    Row(children: [
                                      for (final i in [
                                        AppIntent.chart,
                                        AppIntent.match
                                      ])
                                        Expanded(
                                            child: Padding(
                                                padding:
                                                    EdgeInsetsDirectional.only(
                                                        end:
                                                            i == AppIntent.match
                                                                ? 0
                                                                : 20),
                                                child: _IntentCard(
                                                    intent: i,
                                                    title: switch (i) {
                                                      AppIntent.chart =>
                                                        l.flowSelfIntent,
                                                      AppIntent.match =>
                                                        l.flowMatch,
                                                      AppIntent.agent =>
                                                        l.flowAskAgent
                                                    },
                                                    onTap: () => onChoose(i))))
                                    ]),
                                  const SizedBox(height: 24),
                                  OutlinedButton.icon(
                                      key: const ValueKey('intent-agent'),
                                      onPressed: () =>
                                          onChoose(AppIntent.agent),
                                      icon: const Icon(Icons.forum_outlined,
                                          size: 18),
                                      label: Text(l.flowAskAgent)),
                                ]);
                          }))))),
        ])));
  }
}

class _IntentCard extends StatefulWidget {
  final AppIntent intent;
  final String title;
  final VoidCallback onTap;
  final bool compact;
  const _IntentCard(
      {required this.intent,
      required this.title,
      required this.onTap,
      this.compact = false});
  @override
  State<_IntentCard> createState() => _IntentCardState();
}

class _IntentCardState extends State<_IntentCard> {
  bool hover = false, pressed = false;
  @override
  Widget build(BuildContext context) {
    final i = widget.intent.index, color = [green, blue, violet][i];
    return MouseRegion(
        onEnter: (_) => setState(() => hover = true),
        onExit: (_) => setState(() => hover = false),
        child: AnimatedContainer(
            duration: MediaQuery.of(context).disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 160),
            transform: Matrix4.translationValues(
                0,
                pressed
                    ? 4
                    : hover
                        ? -4
                        : 0,
                0),
            height: widget.compact
                ? 166 *
                    (MediaQuery.textScalerOf(context).scale(14) / 14)
                        .clamp(1.0, 3.0)
                : 332,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                    color: hover ? color.withValues(alpha: .4) : line),
                boxShadow: [
                  BoxShadow(
                      color: color.withValues(alpha: .18),
                      offset: Offset(0, pressed ? 2 : 6),
                      blurRadius: hover ? 12 : 0)
                ]),
            child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                child: InkWell(
                    key: ValueKey('intent-${widget.intent.name}'),
                    onTap: widget.onTap,
                    onTapDown: (_) => setState(() => pressed = true),
                    onTapUp: (_) => setState(() => pressed = false),
                    onTapCancel: () => setState(() => pressed = false),
                    borderRadius: BorderRadius.circular(25),
                    child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: widget.compact
                            ? Row(children: [
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                      Text('0${i + 1}',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: color,
                                              fontWeight: FontWeight.w600)),
                                      Text(widget.title,
                                          style: const TextStyle(
                                              fontSize: 23,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: -.6)),
                                      Icon(Icons.arrow_forward,
                                          size: 20, color: color)
                                    ])),
                                SizedBox(
                                    width: 112 /
                                        (MediaQuery.textScalerOf(context)
                                                    .scale(14) /
                                                14)
                                            .clamp(1.0, 2.0),
                                    height: 112,
                                    child: PortalArt(
                                        matching:
                                            widget.intent == AppIntent.match))
                              ])
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text('0${i + 1}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: color,
                                            fontWeight: FontWeight.w600)),
                                    Expanded(
                                        child: Center(
                                            child: SizedBox(
                                                width: 162,
                                                height: 162,
                                                child: PortalArt(
                                                    matching: widget.intent ==
                                                        AppIntent.match)))),
                                    Row(children: [
                                      Expanded(
                                          child: Text(widget.title,
                                              style: const TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: -.7))),
                                      Icon(Icons.arrow_forward,
                                          size: 22, color: color)
                                    ])
                                  ]))))));
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
      const SizedBox(height: 28),
      SegmentedButton<bool>(segments: [
        ButtonSegment(value: false, label: Text(l.flowOverview)),
        ButtonSegment(value: true, label: Text(l.flowOutlook))
      ], selected: {
        outlook
      }, onSelectionChanged: (v) => onMode(v.first)),
      const SizedBox(height: 28),
      if (!outlook) ...[
        _Reading(
            text: contextData.reading,
            onAsk: () => onAsk(l.flowQuestionOverview)),
        const SizedBox(height: 24),
        _PillarGrid(r),
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
                borderRadius: BorderRadius.circular(20),
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
                          Text(['YEAR', 'MONTH', 'DAY', 'HOUR'][i],
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: .8,
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
  const _Reading({required this.text, required this.onAsk});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Surface(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            Text(l.flowReading,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            TextButton.icon(
                onPressed: onAsk,
                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                label: Text(l.flowAskAgent))
          ]),
      const SizedBox(height: 13),
      SelectableText(text,
          style: const TextStyle(fontSize: 14, height: 1.9, color: ink))
    ]));
  }
}
