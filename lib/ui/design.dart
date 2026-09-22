import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/bazi.dart' as bazi;

const ink = Color(0xFF273653);
const muted = Color(0xFF64708A);
const green = Color(0xFF35695D);
const blue = Color(0xFF355CA8);
const violet = Color(0xFF76509D);
const coral = Color(0xFFAB5145);
const amber = Color(0xFF87621D);
const line = Color(0xFFE1E6F0);
const canvas = Color(0xFFF5F6FC);
const blueTint = Color(0xFFEBF1FF);
const lavenderTint = Color(0xFFF1EBFA);
const coralTint = Color(0xFFFBEDE7);
const amberTint = Color(0xFFFAF3DF);
const mintTint = Color(0xFFEAF4EE);
const accentColors = [blue, violet, coral, green, amber];
const accentTints = [blueTint, lavenderTint, coralTint, mintTint, amberTint];
const elementColors = [
  Color(0xFF357258),
  Color(0xFFB04E42),
  Color(0xFF886517),
  Color(0xFF626A91),
  Color(0xFF326BA5)
];
const elementTints = [mintTint, coralTint, amberTint, lavenderTint, blueTint];

ThemeData lunarTheme() => ThemeData(
      useMaterial3: true,
      fontFamily: 'Manrope',
      fontFamilyFallback: const ['NotoSansSC'],
      scaffoldBackgroundColor: canvas,
      colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          primary: blue,
          secondary: violet,
          tertiary: coral,
          surface: canvas,
          onSurface: ink),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w600,
            letterSpacing: -1.6,
            color: blue),
        headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -1,
            color: blue),
        titleLarge: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w600,
            letterSpacing: -.6,
            color: ink),
        titleMedium:
            TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ink),
        bodyLarge: TextStyle(fontSize: 15, height: 1.6, color: ink),
        bodyMedium: TextStyle(fontSize: 13, height: 1.55, color: ink),
        bodySmall: TextStyle(fontSize: 11, height: 1.5, color: muted),
      ),
      dividerColor: line,
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        textStyle: const TextStyle(
            fontFamily: 'Manrope', fontWeight: FontWeight.w600, fontSize: 13),
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        side: const BorderSide(color: line),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      )),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(17),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: line)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: line)),
      ),
    );

class FlowerLogo extends StatelessWidget {
  final double size;
  const FlowerLogo({super.key, this.size = 34});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _FlowerPainter());
}

class _FlowerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    for (int i = 0; i < 5; i++) {
      canvas.save();
      canvas.rotate(i * 2 * math.pi / 5);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(0, -size.width * .23),
              width: size.width * .31,
              height: size.width * .55),
          Paint()..color = green);
      canvas.restore();
    }
    canvas.drawCircle(Offset.zero, size.width * .09,
        Paint()..color = const Color(0xFFF0F5E6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Surface extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double radius;
  const Surface(
      {super.key,
      required this.child,
      this.color = Colors.white,
      this.padding = const EdgeInsets.all(24),
      this.radius = 24});
  @override
  Widget build(BuildContext context) => Container(
      padding: padding,
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: line)),
      child: child);
}

class ElementPill extends StatelessWidget {
  final bazi.Element element;
  final String? label;
  const ElementPill(this.element, {super.key, this.label});
  @override
  Widget build(BuildContext context) {
    final color = elementColors[element.index];
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(elementIcon(element), size: 13, color: color),
          const SizedBox(width: 5),
          Text(label ?? element.label,
              style: TextStyle(
                  color: Color.lerp(color, ink, .4),
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ]));
  }
}

IconData elementIcon(bazi.Element element) => [
      Icons.spa_outlined,
      Icons.local_fire_department_outlined,
      Icons.landscape_outlined,
      Icons.diamond_outlined,
      Icons.water_drop_outlined
    ][element.index];

class OrbitArt extends StatelessWidget {
  const OrbitArt({super.key});
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        return Center(
            child: SizedBox.square(
                dimension: size,
                child: Stack(children: [
                  Positioned.fill(child: CustomPaint(painter: _OrbitPainter())),
                  for (int i = 0; i < 5; i++)
                    Positioned(
                        left: size *
                                (.5 +
                                    .355 *
                                        math.cos(-math.pi / 2 +
                                            i * math.pi * 2 / 5)) -
                            22,
                        top:
                            size * (.5 + .355 * math.sin(-math.pi / 2 + i * math.pi * 2 / 5)) -
                                22,
                        child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                color: Color.lerp(
                                    elementColors[i], Colors.white, .70),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: .8),
                                    width: 2)),
                            child: Icon(elementIcon(bazi.Element.values[i]),
                                size: 21, color: elementColors[i]))),
                  Center(
                      child: Container(
                          width: size * .42,
                          height: size * .42,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF8FAF1),
                              border:
                                  Border.all(color: Colors.white, width: 2)),
                          child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FlowerLogo(size: 44),
                                SizedBox(height: 9),
                                Text('a little cosmic chemistry',
                                    style: TextStyle(
                                        fontSize: 7.5,
                                        color: green,
                                        letterSpacing: .2)),
                              ]))),
                ])));
      });
}

class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * .355;
    final paint = Paint()
      ..color = green.withValues(alpha: .16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(c, r, paint);
    canvas.drawCircle(c, r * .75, paint..color = green.withValues(alpha: .065));
    for (int i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * math.pi * 2 / 5;
      final b = a + math.pi * 4 / 5;
      canvas.drawLine(
          c + Offset(math.cos(a), math.sin(a)) * r,
          c + Offset(math.cos(b), math.sin(b)) * r,
          paint..color = green.withValues(alpha: .09));
    }
    for (final d in [
      Offset(size.width * .10, size.height * .24),
      Offset(size.width * .87, size.height * .19),
      Offset(size.width * .91, size.height * .72),
      Offset(size.width * .22, size.height * .90)
    ]) {
      canvas.drawLine(d - const Offset(3, 0), d + const Offset(3, 0),
          paint..color = green.withValues(alpha: .45));
      canvas.drawLine(d - const Offset(0, 3), d + const Offset(0, 3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ElementRing extends StatelessWidget {
  final bazi.EnergyChart chart;
  final double size;
  const ElementRing({super.key, required this.chart, this.size = 170});
  @override
  Widget build(BuildContext context) => Semantics(
      label: '${chart.identity} day master',
      child: SizedBox.square(
          dimension: size,
          child: CustomPaint(
              painter: _RingPainter(chart.distribution),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(elementIcon(chart.dayElement),
                        color: elementColors[chart.dayElement.index], size: 28),
                    const SizedBox(height: 5),
                    Text(chart.identity,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const Text('YOUR DAY MASTER',
                        style: TextStyle(
                            fontSize: 7.5, letterSpacing: 1.1, color: muted)),
                  ]))));
}

class _RingPainter extends CustomPainter {
  final List<double> distribution;
  _RingPainter(this.distribution);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(9, 9, size.width - 18, size.height - 18);
    var angle = -math.pi / 2;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, p..color = line);
    for (var i = 0; i < 5; i++) {
      final sweep = distribution[i] * math.pi * 2;
      if (sweep > .06) {
        canvas.drawArc(rect, angle + .035, sweep - .07, false,
            p..color = elementColors[i]);
      }
      angle += sweep;
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.distribution != distribution;
}

void showToast(BuildContext context, String text) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      width: MediaQuery.sizeOf(context).width > 600 ? 460 : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))));
}
