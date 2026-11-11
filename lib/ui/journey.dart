import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/journey.dart';
import 'design.dart';
export 'element_art.dart';
export 'element_garden.dart' show showJourney, showElementQuest;

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
            message: l.gardenTitle,
            excludeFromSemantics: true,
            child: Semantics(
                button: true,
                label: l.gardenTitle,
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
                                Text(l.gardenShort,
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
