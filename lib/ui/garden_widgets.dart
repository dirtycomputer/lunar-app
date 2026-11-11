import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/bazi.dart' as bazi;
import 'element_art.dart';
import 'garden_art.dart';

class GardenHeader extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  const GardenHeader({super.key, required this.title, this.actions = const []});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 12, 14),
        child: Row(children: [
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 24,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.8,
                      color: gardenInk))),
          ...actions,
          IconButton(
              tooltip: AppLocalizations.of(context)!.actionClose,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, color: gardenInk)),
        ]),
      );
}

class GardenFrame extends StatelessWidget {
  final Widget child;
  final double width;
  const GardenFrame({super.key, required this.child, this.width = 1120});
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < 620) {
      return Dialog.fullscreen(
          backgroundColor: gardenPaper, child: SafeArea(child: child));
    }
    return Dialog(
        backgroundColor: gardenPaper,
        insetPadding: const EdgeInsets.all(24),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: width,
                maxHeight:
                    math.min(870, MediaQuery.sizeOf(context).height - 48)),
            child: child));
  }
}

class SpiritCompanion extends StatefulWidget {
  final bazi.Element element;
  final double size;
  const SpiritCompanion({super.key, required this.element, this.size = 100});
  @override
  State<SpiritCompanion> createState() => _SpiritCompanionState();
}

class _SpiritCompanionState extends State<SpiritCompanion>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 650));
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
      button: true,
      label: AppLocalizations.of(context)!.gardenSayHello,
      child: InkWell(
        borderRadius: BorderRadius.circular(60),
        onTap: () {
          if (MediaQuery.disableAnimationsOf(context)) {
            controller.value = controller.value == .5 ? 0 : .5;
          } else {
            controller.forward(from: 0);
          }
        },
        child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) => Transform.translate(
                offset: Offset(0, -math.sin(controller.value * math.pi) * 13),
                child: Transform.rotate(
                    angle: math.sin(controller.value * math.pi * 4) * .07,
                    child: ElementSpirit(
                        element: widget.element, size: widget.size)))),
      ));
}

class GardenPill extends StatelessWidget {
  final String text;
  final IconData icon;
  const GardenPill({super.key, required this.text, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .85),
          border: Border.all(color: const Color(0xFFE7E7D6)),
          borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: gardenGold),
        const SizedBox(width: 6),
        Flexible(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: gardenInk)))
      ]));
}
