import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/bazi_labels.dart';
import '../services/bazi.dart' as bazi;
import '../services/journey.dart';
import 'design.dart';
import 'element_art.dart';
import 'garden_art.dart';
import 'garden_content.dart';
import 'garden_guide.dart';
import 'garden_widgets.dart';

class CycleWorkshop extends StatefulWidget {
  final bazi.Element element;
  final bool sample;
  final JourneyStore store;
  const CycleWorkshop(
      {super.key,
      required this.element,
      required this.sample,
      required this.store});
  @override
  State<CycleWorkshop> createState() => _CycleWorkshopState();
}

class _CycleWorkshopState extends State<CycleWorkshop>
    with SingleTickerProviderStateMixin {
  late final burst = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 720));
  bool ready = false, busy = false, hint = false, initFailed = false;
  bazi.Element? wrong, accepted, from, failedChoice;
  int earned = 0;
  JourneyStore get store => widget.store;
  bazi.Element get seed => store.cycleSeed ?? widget.element;
  int get steps => store.cycleSteps;
  bool get complete => ready && steps == 5;
  bazi.Element get current => bazi.Element.values[(seed.index + steps) % 5];
  @override
  void initState() {
    super.initState();
    store.addListener(changed);
    begin();
  }

  void changed() {
    if (mounted) setState(() {});
  }

  Future<void> begin() async {
    setState(() {
      ready = false;
      initFailed = false;
      accepted = null;
      wrong = null;
      failedChoice = null;
      hint = false;
      earned = 0;
    });
    final ok = await store.beginCycle(widget.element);
    if (mounted) {
      setState(() {
        ready = ok;
        initFailed = !ok;
      });
    }
  }

  @override
  void dispose() {
    store.removeListener(changed);
    burst.dispose();
    super.dispose();
  }

  Future<void> choose(bazi.Element element) async {
    if (!ready || busy || complete || accepted != null) return;
    final previous = current;
    setState(() {
      busy = true;
      wrong = null;
      failedChoice = null;
    });
    final move = await store.placeElement(element);
    if (!mounted) return;
    setState(() {
      busy = false;
      if (move == null) {
        failedChoice = element;
      } else if (!move.correct) {
        wrong = element;
        hint = true;
      } else {
        accepted = element;
        from = previous;
        hint = false;
        earned = move.earned;
      }
    });
    if (move?.correct == true && !MediaQuery.disableAnimationsOf(context)) {
      burst.forward(from: 0);
    }
  }

  void next() => setState(() {
        accepted = null;
        wrong = null;
        hint = false;
      });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      GardenHeader(title: l.gardenRestore, actions: [
        IconButton(
            tooltip: l.gardenGuide,
            onPressed: () => showGardenGuide(context, store, initial: current),
            icon: const Icon(Icons.auto_stories_outlined, color: gardenInk))
      ]),
      if (!ready)
        Flexible(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  ElementSpirit(element: widget.element, size: 120),
                  if (!initFailed)
                    const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator())
                  else ...[
                    Text(l.couldNotSave),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: begin, child: Text(l.releaseRetry))
                  ],
                ])))
      else ...[
        Flexible(
            child: SingleChildScrollView(
                key: const ValueKey('garden-workshop-scroll'),
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                child: LayoutBuilder(builder: (context, c) {
                  final board = Column(children: [
                    Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          GardenPill(
                              text: seed != widget.element
                                  ? l.gardenSavedCycle(elementLabel(l, seed))
                                  : widget.sample
                                      ? l.journeySample
                                      : l.gardenYourElement(
                                          elementLabel(l, widget.element)),
                              icon: Icons.spa_outlined),
                          GardenPill(
                              text: l.gardenLinks(steps),
                              icon: Icons.route_rounded),
                        ]),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                        animation: burst,
                        builder: (context, _) => CustomPaint(
                            foregroundPainter: _GardenBurst(burst.value),
                            child: _CycleBoard(
                                seed: seed,
                                steps: steps,
                                active: !complete && !busy && accepted == null,
                                onDrop: choose))),
                  ]);
                  final controls = _controls(context, l);
                  return c.maxWidth >= 760
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                              Expanded(flex: 6, child: board),
                              const SizedBox(width: 28),
                              Expanded(flex: 5, child: controls),
                            ])
                      : Column(children: [
                          board,
                          const SizedBox(height: 8),
                          controls
                        ]);
                }))),
        _footer(context, l),
      ],
    ]);
  }

  Widget _controls(BuildContext context, AppLocalizations l) {
    if (complete) {
      return Column(children: [
        Container(
            padding: const EdgeInsets.all(17),
            decoration: const BoxDecoration(
                color: Color(0xFFF5E8BC), shape: BoxShape.circle),
            child: const Icon(Icons.workspace_premium_rounded,
                color: gardenGold, size: 39)),
        const SizedBox(height: 17),
        Text(l.gardenCircleComplete,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 28,
                height: 1.2,
                fontWeight: FontWeight.w700,
                letterSpacing: -.7,
                color: gardenInk)),
        const SizedBox(height: 12),
        Text(l.gardenAllSeals,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, height: 1.7, color: muted)),
        const SizedBox(height: 20),
        Wrap(
            alignment: WrapAlignment.center,
            spacing: 7,
            runSpacing: 8,
            children: [
              for (final e in bazi.Element.values)
                Container(
                    width: 53,
                    height: 59,
                    decoration: BoxDecoration(
                        color: elementTints[e.index],
                        border: Border.all(
                            color:
                                elementColors[e.index].withValues(alpha: .3)),
                        borderRadius: BorderRadius.circular(18)),
                    child: ElementSpirit(element: e, size: 47))
            ]),
        const SizedBox(height: 16),
        Text(earned > 0 ? l.journeyReward(earned) : l.journeyRemembered,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700, color: gardenGold)),
        TextButton.icon(
            key: const ValueKey('cycle-replay'),
            onPressed: begin,
            icon: const Icon(Icons.replay_rounded, size: 17),
            label: Text(l.gardenPracticeAgain)),
      ]);
    }
    final lead = accepted != null ? from! : current;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
          accepted != null
              ? l.gardenLinkRestored
              : steps == 4
                  ? l.gardenCloseLoop
                  : l.gardenWakeNext,
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: gardenInk)),
      const SizedBox(height: 12),
      Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 6,
          children: [
            Text(elementLabel(l, lead),
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: elementColors[lead.index])),
            const Icon(Icons.arrow_forward_rounded,
                color: gardenGold, size: 23),
            Text(accepted != null ? elementLabel(l, accepted!) : '?',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: accepted == null
                        ? muted
                        : elementColors[accepted!.index])),
          ]),
      const SizedBox(height: 12),
      if (accepted == null)
        Text(l.gardenTapOrDrag,
            style: const TextStyle(fontSize: 12, height: 1.6, color: muted))
      else
        Semantics(
            liveRegion: true,
            child: Text(cycleFact(l, lead),
                style:
                    const TextStyle(fontSize: 14, height: 1.7, color: green))),
      const SizedBox(height: 20),
      if (accepted != null)
        Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: GardenPill(
                text: '${elementLabel(l, accepted!)} · ${l.gardenCollected}',
                icon: Icons.verified_rounded)),
      LayoutBuilder(builder: (context, c) {
        final compact = MediaQuery.sizeOf(context).width < 620 &&
            MediaQuery.textScalerOf(context).scale(12) <= 14.4;
        final columns = compact ? 5 : 2;
        final gap = compact ? 6.0 : 10.0;
        return Wrap(spacing: gap, runSpacing: 10, children: [
          for (final e in bazi.Element.values)
            SizedBox(
                width: (c.maxWidth - (columns - 1) * gap) / columns,
                child: _token(context, e, l, compact: compact)),
        ]);
      }),
      const SizedBox(height: 12),
      if (hint)
        Semantics(
            liveRegion: true,
            child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: amberTint, borderRadius: BorderRadius.circular(16)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.gardenGentleHint,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: amber)),
                      const SizedBox(height: 6),
                      Text(
                          '${elementLabel(l, current)} → ${elementLabel(l, supportedElement(current))}. ${cycleFact(l, current)}',
                          style: const TextStyle(
                              fontSize: 12, height: 1.6, color: amber)),
                    ])))
      else if (accepted == null)
        TextButton.icon(
            onPressed: () => setState(() => hint = true),
            icon: const Icon(Icons.lightbulb_outline_rounded, size: 17),
            label: Text(l.journeyShowCycle)),
      if (failedChoice != null)
        Semantics(
            liveRegion: true,
            child: Text(l.journeySaveFailed,
                style:
                    const TextStyle(color: coral, fontSize: 12, height: 1.6))),
    ]);
  }

  Widget _token(BuildContext context, bazi.Element e, AppLocalizations l,
      {bool compact = false}) {
    final disabled = busy || accepted != null;
    final button = OutlinedButton(
        key: ValueKey('element-answer-${e.name}'),
        onPressed: disabled ? null : () => choose(e),
        style: OutlinedButton.styleFrom(
            padding:
                EdgeInsets.symmetric(horizontal: compact ? 5 : 9, vertical: 9),
            backgroundColor: wrong == e
                ? amberTint
                : accepted == e
                    ? mintTint
                    : Colors.white,
            disabledBackgroundColor: accepted == e ? mintTint : Colors.white,
            side: BorderSide(
                color: wrong == e
                    ? amber
                    : accepted == e
                        ? green
                        : const Color(0xFFDFE4D6),
                width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18))),
        child: compact
            ? Column(mainAxisSize: MainAxisSize.min, children: [
                ElementSpirit(element: e, size: 32),
                const SizedBox(height: 3),
                Text(elementLabel(l, e),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: gardenInk)),
              ])
            : Row(children: [
                ElementSpirit(element: e, size: 39),
                const SizedBox(width: 7),
                Expanded(
                    child: Text(elementLabel(l, e),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: gardenInk))),
                if (accepted == e)
                  const Icon(Icons.check_rounded, size: 16, color: green),
              ]));
    if (disabled) return button;
    final feedback = Material(
        color: Colors.transparent,
        child: Container(
            decoration: BoxDecoration(
                color: elementTints[e.index],
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 12,
                      offset: Offset(0, 5))
                ]),
            child: ElementSpirit(element: e, size: 74)));
    if (MediaQuery.sizeOf(context).width >= 700) {
      return Draggable<bazi.Element>(
          data: e,
          feedback: feedback,
          childWhenDragging: Opacity(opacity: .3, child: button),
          child: button);
    }
    return LongPressDraggable<bazi.Element>(
        data: e,
        feedback: feedback,
        childWhenDragging: Opacity(opacity: .3, child: button),
        child: button);
  }

  Widget _footer(BuildContext context, AppLocalizations l) => Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
      decoration: const BoxDecoration(
          color: gardenPaper,
          border: Border(top: BorderSide(color: Color(0xFFE4E6D6)))),
      child: Row(children: [
        Expanded(
            child: Wrap(spacing: 5, runSpacing: 5, children: [
          for (var i = 0; i < 5; i++)
            AnimatedContainer(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 250),
                width: 18,
                height: 6,
                decoration: BoxDecoration(
                    color: i < steps ? green : const Color(0xFFDFE4D6),
                    borderRadius: BorderRadius.circular(5)))
        ])),
        const SizedBox(width: 14),
        SizedBox(
            width: MediaQuery.sizeOf(context).width >= 700
                ? 190
                : math.min(176, (MediaQuery.sizeOf(context).width - 44) * .6),
            child: FilledButton(
                key: const ValueKey('quest-continue'),
                onPressed: busy
                    ? null
                    : complete
                        ? () => Navigator.pop(context, true)
                        : failedChoice != null
                            ? () => choose(failedChoice!)
                            : accepted != null
                                ? next
                                : null,
                style: FilledButton.styleFrom(
                    backgroundColor: green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 17)),
                child: busy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(complete
                        ? l.gardenReturn
                        : failedChoice != null
                            ? l.journeyRetrySave
                            : l.gardenContinue))),
      ]));
}

class _CycleBoard extends StatelessWidget {
  final bazi.Element seed;
  final int steps;
  final bool active;
  final ValueChanged<bazi.Element> onDrop;
  const _CycleBoard(
      {required this.seed,
      required this.steps,
      required this.active,
      required this.onDrop});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth, h = w * .94, radius = w * .33;
        final center = Offset(w * .5, h * .48);
        final socket = math.min(69.0, w * .23);
        final target = (steps + 1) % 5;
        final l = AppLocalizations.of(context)!;
        return SizedBox(
            height: h,
            child: Stack(children: [
              Positioned.fill(
                  child: ExcludeSemantics(
                      child: CustomPaint(painter: _CyclePainter(steps)))),
              Positioned(
                  left: w * .5 - w * .16,
                  top: h * .48 - w * .17,
                  child: SpiritCompanion(element: seed, size: w * .32)),
              for (var i = 0; i < 5; i++)
                Positioned(
                    left: center.dx +
                        math.cos(-math.pi / 2 + i * math.pi * 2 / 5) * radius -
                        socket / 2,
                    top: center.dy +
                        math.sin(-math.pi / 2 + i * math.pi * 2 / 5) * radius -
                        socket / 2,
                    child: DragTarget<bazi.Element>(
                      onWillAcceptWithDetails: (_) => active && i == target,
                      onAcceptWithDetails: (d) => onDrop(d.data),
                      builder: (context, candidates, rejected) {
                        final revealed = i == 0 || i <= steps;
                        final e = bazi.Element.values[(seed.index + i) % 5];
                        final highlighted = active && i == target;
                        return Semantics(
                            label: highlighted
                                ? l.gardenDropTarget
                                : revealed
                                    ? elementLabel(l, e)
                                    : l.gardenSleeping,
                            child: AnimatedContainer(
                                key: highlighted
                                    ? const ValueKey('cycle-drop-target')
                                    : null,
                                duration:
                                    MediaQuery.disableAnimationsOf(context)
                                        ? Duration.zero
                                        : const Duration(milliseconds: 280),
                                width: socket,
                                height: socket,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: candidates.isNotEmpty
                                        ? mintTint
                                        : revealed
                                            ? Colors.white
                                            : const Color(0xFFF0F1E5),
                                    border: Border.all(
                                        color: highlighted
                                            ? gardenGold
                                            : revealed
                                                ? elementColors[e.index]
                                                    .withValues(alpha: .4)
                                                : const Color(0xFFDEE1CF),
                                        width: highlighted ? 3 : 1.5),
                                    boxShadow: [
                                      if (highlighted)
                                        const BoxShadow(
                                            color: Color(0x26D7AF50),
                                            blurRadius: 18,
                                            spreadRadius: 3),
                                      const BoxShadow(
                                          color: Color(0x100B3523),
                                          offset: Offset(0, 4),
                                          blurRadius: 4)
                                    ]),
                                child: AnimatedSwitcher(
                                    duration:
                                        MediaQuery.disableAnimationsOf(context)
                                            ? Duration.zero
                                            : const Duration(milliseconds: 330),
                                    switchInCurve: Curves.easeOutBack,
                                    transitionBuilder: (child, animation) =>
                                        ScaleTransition(
                                            scale: animation, child: child),
                                    child: revealed
                                        ? ElementSpirit(
                                            element: e, size: socket - 7)
                                        : Icon(
                                            highlighted
                                                ? Icons.add_rounded
                                                : Icons.more_horiz_rounded,
                                            color: highlighted
                                                ? gardenGold
                                                : const Color(0xFFC0C8B4),
                                            size: 26))));
                      },
                    )),
            ]));
      });
}

class _CyclePainter extends CustomPainter {
  final int steps;
  const _CyclePainter(this.steps);
  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width * .5, s.height * .48), radius = s.width * .33;
    c.drawCircle(
        center,
        radius * .83,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFE7EDD7),
            gardenPaper.withValues(alpha: 0)
          ]).createShader(Rect.fromCircle(center: center, radius: radius)));
    c.drawOval(
        Rect.fromCenter(
            center: center + Offset(0, s.width * .11),
            width: s.width * .31,
            height: s.width * .12),
        Paint()..color = const Color(0xFFDFE6D1));
    for (var i = 0; i < 5; i++) {
      final start = -math.pi / 2 + i * math.pi * 2 / 5;
      final rect = Rect.fromCircle(center: center, radius: radius);
      c.drawArc(
          rect,
          start + .23,
          math.pi * 2 / 5 - .46,
          false,
          Paint()
            ..color = i < steps
                ? green.withValues(alpha: .65)
                : const Color(0xFFDADECB)
            ..style = PaintingStyle.stroke
            ..strokeWidth = i < steps ? 5 : 3
            ..strokeCap = StrokeCap.round);
      final mid = start + math.pi / 5;
      c.save();
      c.translate(center.dx + math.cos(mid) * radius,
          center.dy + math.sin(mid) * radius);
      c.rotate(mid + math.pi / 2);
      c.drawPath(
          Path()
            ..moveTo(5, 0)
            ..lineTo(-3, -4)
            ..lineTo(-3, 4)
            ..close(),
          Paint()..color = i < steps ? green : const Color(0xFFB5C1AA));
      c.restore();
    }
    for (var i = 0; i < steps * 3; i++) {
      final a = i * 2.4, r = radius * .53 + (i % 3) * 6;
      final p = center + Offset(math.cos(a) * r, math.sin(a) * r);
      c.drawCircle(
          p,
          3.3,
          Paint()
            ..color =
                i.isEven ? const Color(0xFFDCAE57) : const Color(0xFFACC393));
      c.drawCircle(p + const Offset(0, -2), 1.3, Paint()..color = gardenPaper);
    }
  }

  @override
  bool shouldRepaint(_CyclePainter old) => old.steps != steps;
}

class _GardenBurst extends CustomPainter {
  final double t;
  const _GardenBurst(this.t);
  @override
  void paint(Canvas c, Size s) {
    if (t <= 0 || t >= 1) return;
    for (var i = 0; i < 22; i++) {
      final a = i * math.pi * 2 / 22, r = (.15 + t * .3) * s.width;
      final p = Offset(s.width * .5 + math.cos(a) * r,
          s.height * .48 + math.sin(a) * r * .75 + t * t * 25);
      c.save();
      c.translate(p.dx, p.dy);
      c.rotate(a + t * 2);
      c.drawRRect(
          RRect.fromRectAndRadius(
              const Rect.fromLTWH(-2, -4, 4, 8), const Radius.circular(2)),
          Paint()
            ..color = [gardenGold, green, const Color(0xFFE1A693)][i % 3]
                .withValues(alpha: 1 - t));
      c.restore();
    }
  }

  @override
  bool shouldRepaint(_GardenBurst old) => old.t != t;
}
