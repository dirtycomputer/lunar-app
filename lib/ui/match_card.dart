import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/bazi.dart' as bazi;
import '../services/intent_flow.dart';
import 'design.dart';

class MatchListTile extends StatelessWidget {
  final bazi.MatchResult match;
  final bool saved;
  final VoidCallback onOpen, onSave;
  const MatchListTile(
      {super.key,
      required this.match,
      required this.saved,
      required this.onOpen,
      required this.onSave});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final p = match.person;
    final reason = switch (matchReason(match)) {
      MatchReason.balance => l.flowReasonBalance,
      MatchReason.support => l.flowReasonSupport,
      MatchReason.shared => l.flowReasonShared,
      MatchReason.branches => l.flowReasonBranches,
      MatchReason.contrast => l.flowReasonContrast,
    };
    return Semantics(
        button: true,
        label: '${p.name}, ${p.age}, ${p.location}',
        child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
                onTap: onOpen,
                hoverColor: blue.withValues(alpha: .035),
                child: LayoutBuilder(builder: (context, c) {
                  final compact = c.maxWidth < 640;
                  final harmony = Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: mintTint,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(l.harmonyPct(match.score),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: green)));
                  return Padding(
                      padding: EdgeInsets.all(compact ? 14 : 20),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(p.image,
                                    width: compact ? 76 : 104,
                                    height: compact ? 108 : 128,
                                    fit: BoxFit.cover,
                                    alignment: const Alignment(0, -.3))),
                            SizedBox(width: compact ? 14 : 24),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Row(children: [
                                    Expanded(
                                        child: Text('${p.name}, ${p.age}',
                                            style: TextStyle(
                                                fontSize: compact ? 19 : 23,
                                                height: 1.25,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -.5))),
                                    IconButton(
                                        tooltip: saved
                                            ? l.unsave(p.name)
                                            : l.saveTo(p.name),
                                        onPressed: onSave,
                                        icon: Icon(
                                            saved
                                                ? Icons.favorite_rounded
                                                : Icons.favorite_border_rounded,
                                            size: 21,
                                            color: saved ? coral : muted))
                                  ]),
                                  Text(p.location,
                                      style: const TextStyle(
                                          fontSize: 12, color: muted)),
                                  const SizedBox(height: 12),
                                  Text(reason,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.5,
                                          color: ink)),
                                  const SizedBox(height: 14),
                                  Row(children: [
                                    Flexible(child: harmony),
                                    const SizedBox(width: 12),
                                    if (!compact)
                                      Expanded(
                                          child: Text(p.occupation,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 12, color: muted)))
                                    else
                                      const Spacer(),
                                    const Icon(Icons.arrow_forward_rounded,
                                        size: 20, color: blue)
                                  ])
                                ]))
                          ]));
                }))));
  }
}
