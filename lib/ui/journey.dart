import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/bazi_labels.dart';
import '../services/bazi.dart' as bazi;
import '../services/journey.dart';
import 'design.dart';

/// A small painted companion. Its element is a chart symbol, never a score.
class ElementSpirit extends StatelessWidget {
  final bazi.Element element;
  final double size;
  const ElementSpirit({super.key, required this.element, this.size = 108});
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
      child: CustomPaint(
          size: Size.square(size), painter: _SpiritPainter(element)));
}

class _SpiritPainter extends CustomPainter {
  final bazi.Element element;
  const _SpiritPainter(this.element);
  @override
  void paint(Canvas c, Size s) {
    c.save();
    c.scale(s.width / 100, s.height / 100);
    final color = elementColors[element.index];
    c.drawOval(const Rect.fromLTWH(26, 86, 50, 8),
        Paint()..color = color.withValues(alpha: .13));
    final body = Path();
    switch (element) {
      case bazi.Element.wood:
        body.moveTo(51, 8);
        body.cubicTo(12, 18, 8, 67, 36, 80);
        body.cubicTo(69, 98, 95, 54, 51, 8);
      case bazi.Element.fire:
        body.moveTo(51, 7);
        body.cubicTo(86, 34, 95, 70, 65, 83);
        body.cubicTo(29, 99, 8, 68, 25, 44);
        body.quadraticBezierTo(37, 33, 39, 22);
        body.quadraticBezierTo(35, 49, 49, 40);
        body.quadraticBezierTo(59, 28, 51, 7);
      case bazi.Element.earth:
        body.addRRect(RRect.fromRectAndRadius(
            const Rect.fromLTWH(18, 24, 65, 61), const Radius.circular(21)));
      case bazi.Element.metal:
        body.moveTo(50, 12);
        body.quadraticBezierTo(66, 14, 80, 32);
        body.quadraticBezierTo(93, 57, 75, 76);
        body.quadraticBezierTo(51, 96, 29, 77);
        body.quadraticBezierTo(10, 57, 23, 33);
        body.quadraticBezierTo(36, 15, 50, 12);
      case bazi.Element.water:
        body.moveTo(50, 7);
        body.cubicTo(33, 30, 12, 48, 22, 68);
        body.cubicTo(37, 99, 91, 85, 80, 53);
        body.quadraticBezierTo(69, 30, 50, 7);
    }
    body.close();
    c.drawPath(body, Paint()..color = elementTints[element.index]);
    c.drawPath(
        body,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round);
    c.drawOval(const Rect.fromLTWH(28, 32, 11, 20),
        Paint()..color = Colors.white.withValues(alpha: .72));
    final eye = Paint()..color = ink;
    c.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(38, 48, 5, 8), const Radius.circular(3)),
        eye);
    c.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(59, 48, 5, 8), const Radius.circular(3)),
        eye);
    final smile = Path()
      ..moveTo(46, 61)
      ..quadraticBezierTo(51, 66, 57, 61);
    c.drawPath(
        smile,
        Paint()
          ..color = ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round);
    c.drawOval(const Rect.fromLTWH(29, 59, 11, 5),
        Paint()..color = color.withValues(alpha: .22));
    c.drawOval(const Rect.fromLTWH(64, 59, 11, 5),
        Paint()..color = color.withValues(alpha: .22));
    if (element == bazi.Element.earth) {
      final leaf = Path()
        ..moveTo(49, 25)
        ..quadraticBezierTo(30, 18, 39, 12)
        ..quadraticBezierTo(49, 11, 49, 25)
        ..moveTo(50, 25)
        ..quadraticBezierTo(51, 9, 63, 13)
        ..quadraticBezierTo(67, 22, 50, 25);
      c.drawPath(leaf, Paint()..color = green);
    }
    if (element == bazi.Element.metal) {
      c.drawPath(
          Path()
            ..moveTo(50, 21)
            ..lineTo(55, 28)
            ..lineTo(50, 34)
            ..lineTo(45, 28)
            ..close(),
          Paint()..color = color.withValues(alpha: .45));
    }
    c.restore();
  }

  @override
  bool shouldRepaint(_SpiritPainter old) => old.element != element;
}

class PortalArt extends StatelessWidget {
  final bool matching;
  const PortalArt({super.key, this.matching = false});
  @override
  Widget build(BuildContext context) => AspectRatio(
      aspectRatio: 1.3,
      child: LayoutBuilder(
          builder: (context, c) =>
              Stack(alignment: Alignment.center, children: [
                Positioned.fill(
                    child: CustomPaint(painter: _PortalPainter(matching))),
                if (matching) ...[
                  Positioned(
                      left: c.maxWidth * .08,
                      top: c.maxHeight * .20,
                      child: ElementSpirit(
                          element: bazi.Element.water, size: c.maxWidth * .46)),
                  Positioned(
                      right: c.maxWidth * .05,
                      top: c.maxHeight * .33,
                      child: ElementSpirit(
                          element: bazi.Element.fire, size: c.maxWidth * .42)),
                ] else
                  Positioned(
                      left: c.maxWidth * .20,
                      top: c.maxHeight * .07,
                      child: ElementSpirit(
                          element: bazi.Element.wood, size: c.maxWidth * .62)),
              ])));
}

class _PortalPainter extends CustomPainter {
  final bool matching;
  const _PortalPainter(this.matching);
  @override
  void paint(Canvas c, Size s) {
    final color = matching ? blue : green;
    c.drawOval(
        Rect.fromLTWH(
            s.width * .05, s.height * .18, s.width * .9, s.height * .69),
        Paint()..color = matching ? blueTint : mintTint);
    final path = Path()
      ..moveTo(s.width * .13, s.height * .83)
      ..cubicTo(s.width * .7, s.height * 1.1, s.width * .91, s.height * .64,
          s.width * .74, s.height * .4);
    final metric = path.computeMetrics().first;
    for (double d = 0; d < metric.length; d += 12) {
      c.drawPath(
          metric.extractPath(d, math.min(d + 5, metric.length)),
          Paint()
            ..color = color.withValues(alpha: .28)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round);
    }
    for (final p in [
      Offset(s.width * .13, s.height * .24),
      Offset(s.width * .83, s.height * .21),
      Offset(s.width * .88, s.height * .67)
    ]) {
      c.drawLine(
          p - const Offset(4, 0),
          p + const Offset(4, 0),
          Paint()
            ..color = color.withValues(alpha: .55)
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round);
      c.drawLine(
          p - const Offset(0, 4),
          p + const Offset(0, 4),
          Paint()
            ..color = color.withValues(alpha: .55)
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(_PortalPainter old) => old.matching != matching;
}

class JourneyBadge extends StatelessWidget {
  final JourneyStore store;
  final VoidCallback onTap;
  const JourneyBadge({super.key, required this.store, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ListenableBuilder(
        listenable: store,
        builder: (context, _) => Tooltip(
            message: l.journeyTitle,
            excludeFromSemantics: true,
            child: Semantics(
                button: true,
                label: l.journeyTitle,
                value: l.journeySparks(store.sparks),
                child: Material(
                    color: amberTint,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                        key: const ValueKey('journey-open'),
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 9),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.auto_awesome_rounded,
                                  color: amber, size: 18),
                              const SizedBox(width: 7),
                              if (MediaQuery.sizeOf(context).width >= 350 &&
                                  MediaQuery.textScalerOf(context).scale(13) <=
                                      16) ...[
                                Text(l.journeyShort,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: amber)),
                                const SizedBox(width: 7),
                              ],
                              AnimatedSwitcher(
                                  duration:
                                      MediaQuery.of(context).disableAnimations
                                          ? Duration.zero
                                          : const Duration(milliseconds: 240),
                                  transitionBuilder: (child, a) =>
                                      ScaleTransition(
                                          scale: a,
                                          child: FadeTransition(
                                              opacity: a, child: child)),
                                  child: Text('${store.sparks}',
                                      key: ValueKey(store.sparks),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: amber))),
                            ])))))));
  }
}

Future<JourneyQuest?> showJourney(BuildContext context, JourneyStore store) =>
    showDialog<JourneyQuest>(
        context: context,
        builder: (ctx) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            backgroundColor: canvas,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: 540,
                    maxHeight: MediaQuery.sizeOf(ctx).height * .9),
                child: _JourneyMap(store: store))));

class _JourneyMap extends StatelessWidget {
  final JourneyStore store;
  const _JourneyMap({required this.store});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ListenableBuilder(
        listenable: store,
        builder: (context, _) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(l.journeyTitle,
                        style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.8))),
                IconButton(
                    tooltip: l.actionClose,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 21))
              ]),
              Center(
                  child: Column(children: [
                const ElementSpirit(element: bazi.Element.wood, size: 96),
                Text(store.finished ? l.journeyAllDone : l.journeyChapter,
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: amber, size: 17),
                        const SizedBox(width: 7),
                        Text(l.journeySparks(store.sparks),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: amber)),
                      ]),
                      Text(l.journeyProgress(store.completed.length),
                          style: const TextStyle(fontSize: 11, color: muted)),
                    ]),
              ])),
              const SizedBox(height: 26),
              for (final q in JourneyQuest.values) ...[
                Align(
                    alignment: q == JourneyQuest.outlook
                        ? AlignmentDirectional.centerEnd
                        : AlignmentDirectional.centerStart,
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 385),
                        child: _QuestNode(
                            quest: q,
                            done: store.completed.contains(q),
                            onTap: () => Navigator.pop(context, q)))),
                if (q != JourneyQuest.encounter)
                  LayoutBuilder(builder: (context, c) {
                    final left = math.min(385.0, c.maxWidth) / 2;
                    final right = c.maxWidth - left;
                    return SizedBox(
                        height: 24,
                        width: double.infinity,
                        child: CustomPaint(
                            painter: _QuestLinkPainter(
                                q == JourneyQuest.element ? left : right,
                                q == JourneyQuest.element ? right : left)));
                  }),
              ],
              const SizedBox(height: 23),
              Center(
                  child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l.journeyKeepExploring))),
            ])));
  }
}

class _QuestLinkPainter extends CustomPainter {
  final double start, end;
  const _QuestLinkPainter(this.start, this.end);
  @override
  void paint(Canvas c, Size s) {
    final path = Path()
      ..moveTo(start, 0)
      ..cubicTo(start, s.height * .65, end, s.height * .35, end, s.height);
    final metric = path.computeMetrics().first;
    for (double d = 0; d < metric.length; d += 9) {
      c.drawPath(
          metric.extractPath(d, math.min(d + 4, metric.length)),
          Paint()
            ..color = line
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(_QuestLinkPainter old) =>
      old.start != start || old.end != end;
}

class _QuestNode extends StatelessWidget {
  final JourneyQuest quest;
  final bool done;
  final VoidCallback onTap;
  const _QuestNode(
      {required this.quest, required this.done, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final color = done ? green : [green, amber, blue][quest.index];
    final title = switch (quest) {
      JourneyQuest.element => l.journeyElementTask,
      JourneyQuest.outlook => l.journeyOutlookTask,
      JourneyQuest.encounter => l.journeyEncounterTask
    };
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: .18),
                  offset: const Offset(0, 4))
            ]),
        child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(21),
                side:
                    BorderSide(color: color.withValues(alpha: .3), width: 1.5)),
            child: InkWell(
                key: ValueKey('quest-${quest.name}'),
                onTap: onTap,
                borderRadius: BorderRadius.circular(21),
                child: Padding(
                    padding: const EdgeInsets.all(17),
                    child: Row(children: [
                      Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: done
                                  ? mintTint
                                  : [
                                      mintTint,
                                      amberTint,
                                      blueTint
                                    ][quest.index],
                              shape: BoxShape.circle),
                          child: Icon(
                              done
                                  ? Icons.check_rounded
                                  : [
                                      Icons.spa_rounded,
                                      Icons.wb_sunny_rounded,
                                      Icons.people_alt_rounded
                                    ][quest.index],
                              color: color,
                              size: 24)),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(title,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(
                                done
                                    ? l.journeyCompleted
                                    : l.journeyReward(JourneyStore.reward),
                                style: TextStyle(
                                    fontSize: 11,
                                    color: color,
                                    fontWeight: FontWeight.w600)),
                          ])),
                      const SizedBox(width: 10),
                      Icon(
                          done
                              ? Icons.replay_rounded
                              : Icons.arrow_forward_rounded,
                          color: color,
                          size: 19),
                    ])))));
  }
}

Future<bool?> showElementQuest(BuildContext context,
        {required bazi.Element element,
        required bool sample,
        required JourneyStore store}) =>
    showDialog<bool>(
        context: context,
        builder: (ctx) => Dialog(
            backgroundColor: canvas,
            insetPadding: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
                width: 520,
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(ctx).height * .93),
                    child: _ElementQuest(
                        element: element, sample: sample, store: store)))));

class _ElementQuest extends StatefulWidget {
  final bazi.Element element;
  final bool sample;
  final JourneyStore store;
  const _ElementQuest(
      {required this.element, required this.sample, required this.store});
  @override
  State<_ElementQuest> createState() => _ElementQuestState();
}

class _ElementQuestState extends State<_ElementQuest>
    with SingleTickerProviderStateMixin {
  late final AnimationController celebration = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 550));
  bazi.Element? wrong;
  bool hint = false, busy = false, solved = false, failed = false;
  int? earned;
  bazi.Element get answer => supportedElement(widget.element);
  @override
  void dispose() {
    celebration.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (busy) return;
    setState(() {
      busy = true;
      failed = false;
    });
    final value = await widget.store.complete(JourneyQuest.element);
    if (!mounted) return;
    setState(() {
      busy = false;
      earned = value;
      failed = value == null;
    });
    if (value != null &&
        value > 0 &&
        !MediaQuery.of(context).disableAnimations) {
      celebration.forward(from: 0);
    }
  }

  void choose(bazi.Element choice) {
    if (solved || busy) return;
    if (choice != answer) {
      setState(() {
        wrong = choice;
        hint = true;
      });
      return;
    }
    setState(() {
      solved = true;
      wrong = null;
      hint = true;
    });
    save();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final first = elementLabel(l, widget.element),
        next = elementLabel(l, answer);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 14, 0),
          child: Row(children: [
            Expanded(
                child: Text(l.journeyElementTitle,
                    style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.6))),
            IconButton(
                tooltip: l.actionClose,
                onPressed: () => Navigator.pop(context, false),
                icon: const Icon(Icons.close, size: 21)),
          ])),
      Flexible(
          child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
              child: Column(children: [
                AnimatedBuilder(
                    animation: celebration,
                    builder: (context, child) => CustomPaint(
                        foregroundPainter: _BurstPainter(celebration.value),
                        child: SizedBox(
                            width: 170,
                            height: 130,
                            child: Center(
                                child: ElementSpirit(
                                    element: widget.element, size: 112))))),
                if (widget.sample)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(l.journeySample,
                          style: const TextStyle(fontSize: 11, color: muted))),
                Text(solved ? '$first → $next' : '$first → ?',
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w700, color: ink)),
                const SizedBox(height: 13),
                Text(l.journeyQuestion(first),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 22),
                LayoutBuilder(
                    builder: (context, c) => Wrap(
                            spacing: 10,
                            runSpacing: 11,
                            alignment: WrapAlignment.center,
                            children: [
                              for (final e in bazi.Element.values)
                                SizedBox(
                                    width: (c.maxWidth - 10) / 2,
                                    child: OutlinedButton(
                                        key: ValueKey(
                                            'element-answer-${e.name}'),
                                        onPressed: solved || busy
                                            ? null
                                            : () => choose(e),
                                        style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 13),
                                            disabledBackgroundColor:
                                                solved && e == answer
                                                    ? mintTint
                                                    : Colors.white,
                                            disabledForegroundColor:
                                                solved && e == answer
                                                    ? green
                                                    : muted,
                                            backgroundColor:
                                                solved && e == answer
                                                    ? mintTint
                                                    : wrong == e
                                                        ? amberTint
                                                        : Colors.white,
                                            side: BorderSide(
                                                color: solved && e == answer
                                                    ? green
                                                    : wrong == e
                                                        ? amber
                                                        : line,
                                                width: 2),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16))),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                  width: 11,
                                                  height: 11,
                                                  decoration: BoxDecoration(
                                                      color: elementColors[
                                                          e.index],
                                                      shape: BoxShape.circle)),
                                              const SizedBox(width: 9),
                                              Flexible(
                                                  child: Text(
                                                      elementLabel(l, e),
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight
                                                              .w600))),
                                              if (solved && e == answer) ...[
                                                const SizedBox(width: 7),
                                                const Icon(Icons.check,
                                                    size: 17, color: green)
                                              ],
                                            ])))
                            ])),
                const SizedBox(height: 14),
                if (!hint)
                  TextButton(
                      onPressed: () => setState(() => hint = true),
                      child: Text(l.journeyShowCycle)),
                if (hint)
                  Text(l.journeyCycle(first, next),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 12, height: 1.7, color: muted)),
              ]))),
      if (wrong != null || solved)
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                color: solved ? mintTint : amberTint,
                border: const Border(top: BorderSide(color: line))),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Semantics(
                  liveRegion: true,
                  child: Row(children: [
                    Icon(
                        solved
                            ? Icons.check_circle_rounded
                            : Icons.lightbulb_outline_rounded,
                        color: solved ? green : amber,
                        size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(
                            solved
                                ? (earned == 0
                                    ? l.journeyRemembered
                                    : l.journeyCorrect)
                                : l.journeyTryAgain,
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: solved ? green : amber))),
                    if (earned != null && earned! > 0)
                      Text(l.journeyReward(earned!),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: green)),
                  ])),
              if (failed)
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(l.journeySaveFailed,
                        style: const TextStyle(fontSize: 12, color: coral))),
              if (solved) ...[
                const SizedBox(height: 16),
                SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                        key: const ValueKey('quest-continue'),
                        onPressed: busy
                            ? null
                            : failed
                                ? save
                                : () => Navigator.pop(context, true),
                        child: busy
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text(
                                failed ? l.journeyRetrySave : l.journeyBack))),
              ],
            ])),
    ]);
  }
}

class _BurstPainter extends CustomPainter {
  final double progress;
  const _BurstPainter(this.progress);
  @override
  void paint(Canvas c, Size s) {
    if (progress <= 0 || progress >= 1) return;
    final radius = 38 + progress * 43;
    for (var i = 0; i < 10; i++) {
      final a = i * math.pi / 5 - .4;
      final p = Offset(s.width / 2 + math.cos(a) * radius,
          s.height / 2 + math.sin(a) * radius * .8);
      c.save();
      c.translate(p.dx, p.dy);
      c.rotate(a + progress);
      c.drawRRect(
          RRect.fromRectAndRadius(
              const Rect.fromLTWH(-2, -4, 4, 8), const Radius.circular(2)),
          Paint()
            ..color = accentColors[i % accentColors.length]
                .withValues(alpha: 1 - progress));
      c.restore();
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.progress != progress;
}
