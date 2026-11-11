import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/bazi.dart' as bazi;
import 'design.dart';

/// A small painted companion. Its element is a chart symbol, never a score.
class ElementSpirit extends StatelessWidget {
  final bazi.Element element;
  final double size;
  final bool awake;
  const ElementSpirit(
      {super.key, required this.element, this.size = 108, this.awake = true});
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
      child: CustomPaint(
          size: Size.square(size),
          painter: SpiritPainter(element, awake: awake)));
}

class SpiritPainter extends CustomPainter {
  final bazi.Element element;
  final bool awake;
  const SpiritPainter(this.element, {this.awake = true});
  @override
  void paint(Canvas canvas, Size size) {
    final c = canvas;
    final s = size;
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
    c.drawPath(
        body,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              elementTints[element.index],
              color.withValues(alpha: .32)
            ],
            stops: const [0, .35, 1],
          ).createShader(const Rect.fromLTWH(10, 5, 85, 85)));
    c.drawPath(
        body,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.1
          ..strokeJoin = StrokeJoin.round);
    c.drawOval(const Rect.fromLTWH(28, 32, 11, 20),
        Paint()..color = Colors.white.withValues(alpha: .72));
    final eye = Paint()..color = ink;
    if (awake) {
      c.drawRRect(
          RRect.fromRectAndRadius(
              const Rect.fromLTWH(38, 48, 5, 8), const Radius.circular(3)),
          eye);
      c.drawRRect(
          RRect.fromRectAndRadius(
              const Rect.fromLTWH(59, 48, 5, 8), const Radius.circular(3)),
          eye);
    } else {
      for (final x in [37.0, 58.0]) {
        c.drawArc(
            Rect.fromLTWH(x, 48, 9, 7),
            0,
            math.pi,
            false,
            Paint()
              ..color = ink
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.3
              ..strokeCap = StrokeCap.round);
      }
    }
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
  bool shouldRepaint(SpiritPainter oldDelegate) =>
      oldDelegate.element != element || oldDelegate.awake != awake;
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
