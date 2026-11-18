import 'package:flutter/material.dart';
import '../l10n/bazi_labels.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/bazi.dart' as bazi;
import '../services/intent_flow.dart';
import '../services/journey.dart' show supportedElement;
import 'design.dart';
import 'profile_avatar.dart';

class MatchListTile extends StatelessWidget {
  final bazi.MatchResult match;
  final bazi.EnergyChart mine;
  final bool saved;
  final VoidCallback onOpen, onSave;

  const MatchListTile({
    super.key,
    required this.match,
    required this.mine,
    required this.saved,
    required this.onOpen,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = match.person;
    final first = elementLabel(l, mine.dayElement);
    final second = elementLabel(l, match.chart.dayElement);
    final mineSupportsTheirs =
        supportedElement(mine.dayElement) == match.chart.dayElement;
    final myDaySign = branchLabel(l, mine.pillars[2]);
    final theirDaySign = branchLabel(l, match.chart.pillars[2]);
    final reason = switch (matchReason(match)) {
      MatchReason.balance => l.flowReasonBalance,
      MatchReason.support => mineSupportsTheirs
          ? l.flowReasonSupport(first, second)
          : l.flowReasonSupport(second, first),
      MatchReason.shared => l.flowReasonShared(first),
      MatchReason.branches => myDaySign == theirDaySign
          ? l.flowReasonSameSign(myDaySign)
          : l.flowReasonBranches(myDaySign, theirDaySign),
      MatchReason.contrast => l.flowReasonContrast(first, second),
    };
    final save = IconButton(
      tooltip: saved ? l.unsave(p.name) : l.saveTo(p.name),
      onPressed: onSave,
      icon: Icon(saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 21, color: saved ? coral : muted),
    );
    final score = Text(l.harmonyPct(match.score),
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: green));
    final why = Text(reason,
        style: const TextStyle(fontSize: 14, height: 1.45, color: ink));
    return InkWell(
      onTap: onOpen,
      child: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 760 &&
            MediaQuery.textScalerOf(context).scale(14) < 20;
        final avatarSize = wide ? 54.0 : 46.0;
        final identity = Row(children: [
          ExcludeSemantics(
            child: ClipOval(
                child: ProfileAvatar(p, width: avatarSize, height: avatarSize)),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('${p.name}, ${p.age}',
                    style: const TextStyle(
                        fontSize: 18,
                        height: 1.22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -.45)),
                const SizedBox(height: 3),
                Text(
                    wide && p.occupation.isNotEmpty
                        ? '${p.location} · ${p.occupation}'
                        : p.location,
                    style: const TextStyle(fontSize: 13, color: muted)),
              ])),
        ]);
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: wide ? 22 : 16, vertical: wide ? 14 : 12),
          child: wide
              ? Row(children: [
                  Expanded(flex: 5, child: identity),
                  const SizedBox(width: 24),
                  Expanded(flex: 6, child: why),
                  const SizedBox(width: 20),
                  Expanded(
                      flex: 3,
                      child: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: score)),
                  const SizedBox(width: 8),
                  save,
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Expanded(child: identity), save]),
                  const SizedBox(height: 8),
                  why,
                  const SizedBox(height: 6),
                  score,
                ]),
        );
      }),
    );
  }
}
