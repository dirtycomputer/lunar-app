import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/bazi.dart' as bazi;
import '../l10n/generated/app_localizations.dart';
import '../l10n/bazi_labels.dart';
import 'design.dart';
import 'element_art.dart';

const gardenPaper = Color(0xFFF3F7F4);
const gardenInk = Color(0xFF294E43);
const gardenGold = Color(0xFFC58B37);
const gardenPositions = [
  Offset(.22, .32),
  Offset(.63, .22),
  Offset(.80, .57),
  Offset(.56, .80),
  Offset(.20, .72)
];

/// All artwork is original vector drawing; no image network or animation loop.
class GardenScene extends StatelessWidget {
  final Set<bazi.Element> collected;
  final int discoveries;
  final ValueChanged<bazi.Element> onExplore;
  const GardenScene(
      {super.key,
      required this.collected,
      required this.discoveries,
      required this.onExplore});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth;
      final height = width * .82;
      return SizedBox(
          height: height,
          child: Stack(children: [
            Positioned.fill(
                child: ExcludeSemantics(
                    child: CustomPaint(
                        painter: GardenPainter(collected, discoveries)))),
            for (final element in bazi.Element.values)
              Positioned(
                left: width * gardenPositions[element.index].dx - 34,
                top: height * gardenPositions[element.index].dy - 39,
                child: Tooltip(
                    message: elementLabel(l, element),
                    child: Semantics(
                      button: true,
                      label: '${elementLabel(l, element)}, ${l.gardenGuide}',
                      child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            key: ValueKey('habitat-${element.name}'),
                            borderRadius: BorderRadius.circular(32),
                            onTap: () => onExplore(element),
                            child: SizedBox(
                                width: 68,
                                height: 78,
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                          color: gardenPaper.withValues(
                                              alpha: .94),
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Text(elementLabel(l, element),
                                          textScaler: TextScaler.noScaling,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: gardenInk,
                                              fontWeight: FontWeight.w700))),
                                )),
                          )),
                    )),
              ),
          ]));
    });
  }
}

class GardenPainter extends CustomPainter {
  final Set<bazi.Element> collected;
  final int discoveries;
  const GardenPainter(this.collected, this.discoveries);
  @override
  void paint(Canvas canvas, Size size) {
    final c = canvas;
    c.save();
    c.scale(size.width / 600, size.height / 492);
    final bounds = const Rect.fromLTWH(0, 0, 600, 492);
    c.drawRRect(
        RRect.fromRectAndRadius(bounds, const Radius.circular(32)),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFECF1E3), Color(0xFFF9F2DA), Color(0xFFE2EDDE)],
          ).createShader(bounds));
    c.save();
    c.clipRRect(RRect.fromRectAndRadius(bounds, const Radius.circular(32)));
    c.drawCircle(
        const Offset(447, 57), 37, Paint()..color = const Color(0xFFF3CE7C));
    c.drawCircle(const Offset(447, 57), 51,
        Paint()..color = const Color(0xFFF3CE7C).withValues(alpha: .14));
    _cloud(c, const Offset(70, 50), .8);
    _cloud(c, const Offset(320, 33), .55);
    final hills = Path()
      ..moveTo(-20, 142)
      ..quadraticBezierTo(92, 13, 207, 126)
      ..quadraticBezierTo(285, 39, 374, 124)
      ..quadraticBezierTo(478, 60, 620, 144)
      ..lineTo(620, 492)
      ..lineTo(-20, 492)
      ..close();
    c.drawPath(hills, Paint()..color = const Color(0xFFD8E2C8));
    final meadow = Path()
      ..moveTo(-20, 244)
      ..quadraticBezierTo(171, 154, 290, 211)
      ..quadraticBezierTo(430, 143, 620, 237)
      ..lineTo(620, 492)
      ..lineTo(-20, 492)
      ..close();
    c.drawPath(meadow, Paint()..color = const Color(0xFFEAF0D9));
    final river = Path()
      ..moveTo(340, 158)
      ..cubicTo(397, 230, 220, 240, 304, 328)
      ..cubicTo(362, 400, 262, 458, 229, 510)
      ..lineTo(308, 510)
      ..cubicTo(364, 419, 419, 395, 368, 320)
      ..cubicTo(304, 251, 465, 245, 379, 157)
      ..close();
    c.drawPath(river, Paint()..color = const Color(0xFFBADDD6));
    for (var i = 0; i < 8; i++) {
      final y = 220.0 + i * 32;
      c.drawArc(
          Rect.fromCenter(
              center: Offset(337 + math.sin(i) * 28, y), width: 28, height: 5),
          0,
          math.pi,
          false,
          Paint()
            ..color = Colors.white.withValues(alpha: .6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4);
    }
    final trail = Path()
      ..moveTo(120, 353)
      ..cubicTo(41, 253, 64, 150, 132, 157)
      ..cubicTo(230, 162, 246, 76, 378, 108)
      ..cubicTo(490, 130, 549, 190, 480, 280)
      ..cubicTo(458, 330, 394, 406, 336, 394)
      ..cubicTo(253, 377, 204, 415, 120, 353);
    c.drawPath(
        trail,
        Paint()
          ..color = const Color(0xFFFDF6DE)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 24
          ..strokeCap = StrokeCap.round);
    c.drawPath(
        trail,
        Paint()
          ..color = const Color(0xFFD8CCAA).withValues(alpha: .65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
    final metric = trail.computeMetrics().first;
    for (double d = 6; d < metric.length; d += 22) {
      c.drawCircle(metric.getTangentForOffset(d)!.position, 1.8,
          Paint()..color = const Color(0xFFB6AE8E));
    }
    // Arched timber bridge: the route and river meet here.
    c.save();
    c.translate(338, 358);
    c.rotate(-.32);
    c.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-40, -10, 80, 27), const Radius.circular(6)),
        Paint()..color = const Color(0xFFC49A64));
    for (var i = 0; i < 9; i++) {
      c.drawLine(
          Offset(-35 + i * 9, -9),
          Offset(-35 + i * 9, 16),
          Paint()
            ..color = const Color(0xFFA67A4F)
            ..strokeWidth = 1.3);
    }
    for (final y in [-13.0, 19.0]) {
      c.drawLine(
          Offset(-42, y),
          Offset(42, y),
          Paint()
            ..color = const Color(0xFF896B48)
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round);
    }
    c.restore();
    _grove(c, const Offset(72, 121), 1.05);
    _grove(c, const Offset(179, 127), .7);
    _grove(c, const Offset(51, 421), .8);
    _grove(c, const Offset(556, 373), .85);
    _island(c, const Offset(132, 157), const Color(0xFFA4C88F));
    _island(c, const Offset(378, 108), const Color(0xFFDEBB8B));
    _island(c, const Offset(480, 280), const Color(0xFFC7CD92));
    _island(c, const Offset(336, 394), const Color(0xFFB7C2C7));
    _island(c, const Offset(120, 354), const Color(0xFFA7CFC4));
    // Each habitat has its own silhouette and material.
    for (final offset in [const Offset(101, 153), const Offset(162, 164)]) {
      _sprout(c, offset, 1.3);
    }
    _hearth(c, const Offset(378, 132));
    for (var i = 0; i < 3; i++) {
      _flower(c, Offset(448 + i * 29, 291 + (i % 2) * 10),
          i.isEven ? const Color(0xFFE6B35F) : const Color(0xFFE3A99B), 1.15);
    }
    _rock(c, const Offset(303, 406), 24);
    _rock(c, const Offset(367, 410), 18);
    c.drawOval(Rect.fromCenter(center: Offset(120, 371), width: 93, height: 30),
        Paint()..color = const Color(0xFF79B9B7));
    for (var i = 0; i < 3; i++) {
      c.drawOval(
          Rect.fromCenter(
              center: Offset(118, 371), width: 62 + i * 17, height: 9 + i * 6),
          Paint()
            ..color = Colors.white.withValues(alpha: .36)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
    }
    for (final e in bazi.Element.values) {
      final p = gardenPositions[e.index];
      c.save();
      c.translate(p.dx * 600 - 28, p.dy * 492 - 55);
      if (collected.contains(e)) {
        c.drawCircle(const Offset(28, 30), 38,
            Paint()..color = const Color(0xFFFFE9A6).withValues(alpha: .38));
      }
      SpiritPainter(e, awake: collected.contains(e))
          .paint(c, const Size(56, 56));
      c.restore();
      if (collected.contains(e)) {
        _flower(c, Offset(p.dx * 600 + 36, p.dy * 492 + 10),
            elementColors[e.index], .7);
        _flower(c, Offset(p.dx * 600 - 35, p.dy * 492 + 8),
            const Color(0xFFE5B24F), .85);
      }
    }
    // Three lanterns represent the three discoveries, not luck or compatibility.
    for (var i = 0; i < 3; i++) {
      final p = Offset(228 + i * 25, 301 - i * 8);
      c.drawLine(
          p + const Offset(0, 2),
          p + const Offset(0, 28),
          Paint()
            ..color = const Color(0xFF8A9278)
            ..strokeWidth = 2);
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(center: p, width: 15, height: 20),
              const Radius.circular(5)),
          Paint()
            ..color = i < discoveries
                ? const Color(0xFFF5C064)
                : const Color(0xFFD2D8BD));
      if (i < discoveries) {
        c.drawCircle(p, 16,
            Paint()..color = const Color(0xFFF5C064).withValues(alpha: .14));
      }
    }
    for (var i = 0; i < 32; i++) {
      final x = 18.0 + (i * 71 % 565), y = 198.0 + (i * 47 % 275);
      if (i % 4 == 0) {
        _flower(c, Offset(x, y),
            i.isEven ? const Color(0xFFDBB25E) : const Color(0xFFE4A894), .38);
      } else {
        _grass(c, Offset(x, y));
      }
    }
    c.restore();
    c.restore();
  }

  void _cloud(Canvas c, Offset p, double scale) {
    c.save();
    c.translate(p.dx, p.dy);
    c.scale(scale);
    final paint = Paint()..color = Colors.white.withValues(alpha: .65);
    c.drawOval(const Rect.fromLTWH(-37, 0, 94, 19), paint);
    c.drawCircle(const Offset(-7, 0), 18, paint);
    c.drawCircle(const Offset(22, -3), 23, paint);
    c.restore();
  }

  void _island(Canvas c, Offset p, Color color) {
    c.drawOval(
        Rect.fromCenter(
            center: p + const Offset(0, 25), width: 116, height: 42),
        Paint()..color = gardenInk.withValues(alpha: .07));
    c.drawOval(
        Rect.fromCenter(
            center: p + const Offset(0, 15), width: 112, height: 42),
        Paint()..color = color);
    c.drawOval(
        Rect.fromCenter(center: p + const Offset(0, 8), width: 112, height: 38),
        Paint()..color = Color.lerp(color, Colors.white, .33)!);
  }

  void _grove(Canvas c, Offset p, double scale) {
    c.save();
    c.translate(p.dx, p.dy);
    c.scale(scale);
    c.drawLine(
        const Offset(0, 10),
        const Offset(0, 64),
        Paint()
          ..color = const Color(0xFF8C9C6D)
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round);
    for (final b in [
      const Offset(-17, 3),
      const Offset(13, -8),
      const Offset(19, 15),
      const Offset(-3, 23)
    ]) {
      c.drawOval(
          Rect.fromCenter(center: b, width: 42, height: 50),
          Paint()
            ..color =
                b.dx < 0 ? const Color(0xFF83AE86) : const Color(0xFFA8C69A));
      c.drawArc(
          Rect.fromCenter(center: b, width: 22, height: 30),
          3.7,
          1.3,
          false,
          Paint()
            ..color = Colors.white.withValues(alpha: .35)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke);
    }
    c.restore();
  }

  void _sprout(Canvas c, Offset p, double scale) {
    c.save();
    c.translate(p.dx, p.dy);
    c.scale(scale);
    c.drawLine(
        Offset.zero,
        const Offset(0, -16),
        Paint()
          ..color = green
          ..strokeWidth = 2);
    c.drawOval(const Rect.fromLTWH(-13, -18, 13, 7),
        Paint()..color = const Color(0xFF6B9A6D));
    c.drawOval(const Rect.fromLTWH(0, -24, 13, 8),
        Paint()..color = const Color(0xFF9AB57A));
    c.restore();
  }

  void _hearth(Canvas c, Offset p) {
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      c.drawOval(
          Rect.fromCenter(
              center: p + Offset(math.cos(a) * 22, math.sin(a) * 9),
              width: 17,
              height: 10),
          Paint()..color = const Color(0xFFB79674));
    }
    c.drawOval(Rect.fromCenter(center: p, width: 30, height: 15),
        Paint()..color = const Color(0xFFF3C16A));
  }

  void _rock(Canvas c, Offset p, double size) {
    final path = Path()
      ..moveTo(p.dx - size, p.dy)
      ..lineTo(p.dx - size * .5, p.dy - size * .8)
      ..lineTo(p.dx + size * .5, p.dy - size)
      ..lineTo(p.dx + size, p.dy)
      ..close();
    c.drawPath(path, Paint()..color = const Color(0xFF93A5B1));
    c.drawLine(
        Offset(p.dx - size * .5, p.dy - size * .8),
        Offset(p.dx, p.dy),
        Paint()
          ..color = const Color(0xFFC9D7D8)
          ..strokeWidth = 1.7);
  }

  void _flower(Canvas c, Offset p, Color color, double scale) {
    for (var i = 0; i < 5; i++) {
      final a = i * math.pi * 2 / 5;
      c.drawCircle(p + Offset(math.cos(a) * 5 * scale, math.sin(a) * 5 * scale),
          3.5 * scale, Paint()..color = color);
    }
    c.drawCircle(p, 2.2 * scale, Paint()..color = const Color(0xFFFFF7D7));
  }

  void _grass(Canvas c, Offset p) {
    final paint = Paint()
      ..color = const Color(0xFFA7BB93)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    c.drawLine(p, p + const Offset(-3, -6), paint);
    c.drawLine(p, p + const Offset(1, -8), paint);
    c.drawLine(p, p + const Offset(5, -4), paint);
  }

  @override
  bool shouldRepaint(GardenPainter oldDelegate) =>
      oldDelegate.discoveries != discoveries ||
      oldDelegate.collected.length != collected.length;
}
