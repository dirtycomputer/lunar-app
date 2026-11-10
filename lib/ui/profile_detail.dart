import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/bazi_labels.dart';
import '../services/app_state.dart';
import '../services/bazi.dart' as bazi;
import '../services/platform_contracts.dart';
import '../studio/glossary.dart';
import 'design.dart';
import 'social_pages.dart';

String localizedReasonLabel(AppLocalizations l10n, ReportReason r) =>
    switch (r) {
      ReportReason.harassment => l10n.reasonHarassment,
      ReportReason.nudityOrSexual => l10n.reasonNudity,
      ReportReason.nonConsensualImagery => l10n.reasonNcii,
      ReportReason.underage => l10n.reasonUnderage,
      ReportReason.impersonation => l10n.reasonImpersonation,
      ReportReason.csae => l10n.reasonCsae,
      ReportReason.spamOrScam => l10n.reasonSpam,
      ReportReason.other => l10n.reasonOther,
    };

Future<void> showProfileDetail(
        BuildContext context, AppState state, bazi.MatchResult match,
        {VoidCallback? onCompare}) =>
    showDialog<void>(
        context: context,
        builder: (_) => _ProfileDetail(
            state: state,
            match: match,
            onCompare: onCompare,
            onChat: () => showLocalConversation(context, state, match.person)));

class _ProfileDetail extends StatelessWidget {
  final AppState state;
  final bazi.MatchResult match;
  final VoidCallback? onCompare;
  final VoidCallback onChat;
  const _ProfileDetail(
      {required this.state,
      required this.match,
      required this.onChat,
      this.onCompare});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = match.person;
    return ListenableBuilder(
        listenable: state,
        builder: (context, _) => Dialog(
              backgroundColor: canvas,
              insetPadding: const EdgeInsets.all(18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        SizedBox(
                            height: 265,
                            child: Stack(fit: StackFit.expand, children: [
                              Image.asset(p.image,
                                  fit: BoxFit.cover,
                                  alignment: const Alignment(0, -.5)),
                              const DecoratedBox(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                    Colors.transparent,
                                    Colors.black54
                                  ]))),
                              Positioned(
                                  right: 15,
                                  top: 15,
                                  child: IconButton.filledTonal(
                                      onPressed: () => Navigator.pop(context),
                                      tooltip: l10n.closeProfile,
                                      icon: const Icon(Icons.close, size: 20))),
                              Positioned(
                                  left: 26,
                                  bottom: 22,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('${p.name}, ${p.age}',
                                            style: const TextStyle(
                                                fontSize: 32,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600)),
                                        Text(p.location,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12)),
                                      ])),
                            ])),
                        Padding(
                            padding: const EdgeInsets.all(26),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    ElementPill(match.chart.dayElement,
                                        label:
                                            identityLabel(l10n, match.chart)),
                                    const Spacer(),
                                    const Icon(Icons.auto_awesome,
                                        size: 17, color: green),
                                    const SizedBox(width: 6),
                                    Text(l10n.harmonyPct(match.score),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: green))
                                  ]),
                                  const SizedBox(height: 20),
                                  Text(p.occupation,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const SizedBox(height: 10),
                                  Text(p.bio,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: muted,
                                          height: 1.8)),
                                  const SizedBox(height: 16),
                                  Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: p.interests
                                          .map((i) => Chip(
                                              label: Text(i,
                                                  style: const TextStyle(
                                                      fontSize: 11)),
                                              backgroundColor: Colors.white,
                                              side: const BorderSide(
                                                  color: line)))
                                          .toList()),
                                  const SizedBox(height: 22),
                                  const Divider(),
                                  const SizedBox(height: 20),
                                  Text(l10n.chemistryTitle,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 7),
                                  Text(
                                      l10n.meetsText(
                                          elementLabel(
                                              l10n, state.chart.dayElement),
                                          p.name,
                                          elementLabel(
                                              l10n, match.chart.dayElement)),
                                      style: const TextStyle(
                                          fontSize: 12, color: muted)),
                                  const SizedBox(height: 23),
                                  _factor(l10n.factorBalance, match.balance,
                                      l10n.factorBalanceDesc, elementColors[0],
                                      tint: elementTints[0],
                                      contextText: l10n.factorContext(
                                          l10n.factorBalance, match.balance)),
                                  _factor(
                                      l10n.factorConnection,
                                      match.connection,
                                      l10n.factorConnectionDesc,
                                      elementColors[4],
                                      tint: elementTints[4],
                                      termId: 'master',
                                      contextText: l10n.factorContext(
                                          l10n.factorConnection,
                                          match.connection)),
                                  _factor(
                                      l10n.factorResonance,
                                      match.resonance,
                                      l10n.factorResonanceDesc,
                                      elementColors[2],
                                      tint: elementTints[2],
                                      termId: 'combine',
                                      contextText: l10n.factorContext(
                                          l10n.factorResonance,
                                          match.resonance)),
                                  const SizedBox(height: 7),
                                  Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFEDF1E5),
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              const Icon(
                                                  Icons.chat_bubble_outline,
                                                  size: 16,
                                                  color: green),
                                              const SizedBox(width: 8),
                                              Text(l10n.starterTitle,
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: green))
                                            ]),
                                            const SizedBox(height: 8),
                                            Text(
                                                l10n.starterText(p
                                                    .interests.first
                                                    .toLowerCase()),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    height: 1.7,
                                                    color: green)),
                                          ])),
                                  const SizedBox(height: 20),
                                  Text(l10n.demoDisclaimer,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: muted,
                                          height: 1.7)),
                                  if (!state.chart.timeKnown)
                                    Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(l10n.timeApprox,
                                            style: const TextStyle(
                                                fontSize: 10, color: muted))),
                                  const SizedBox(height: 24),
                                  Wrap(spacing: 10, runSpacing: 10, children: [
                                    FilledButton.icon(
                                        onPressed: state.social.invitations
                                                .contains(p.id)
                                            ? null
                                            : () async {
                                                final ok = await state.social
                                                    .invite(p.id);
                                                if (context.mounted) {
                                                  showToast(
                                                      context,
                                                      ok
                                                          ? l10n
                                                              .socialInviteSaved
                                                          : l10n
                                                              .socialSaveFailed);
                                                }
                                              },
                                        icon: Icon(
                                            state.social.invitations
                                                    .contains(p.id)
                                                ? Icons.check
                                                : Icons
                                                    .person_add_alt_1_outlined,
                                            size: 17),
                                        label: Text(state.social.invitations
                                                .contains(p.id)
                                            ? l10n.socialPending
                                            : l10n.socialInvite(p.name))),
                                    OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          onChat();
                                        },
                                        icon: const Icon(
                                            Icons.chat_bubble_outline,
                                            size: 17),
                                        label: Text(l10n.socialSayHello)),
                                  ]),
                                  const SizedBox(height: 12),
                                  Text(l10n.socialLocalNotice,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: muted,
                                          height: 1.6)),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                      width: double.infinity,
                                      child: FilledButton.icon(
                                          onPressed: () async {
                                            final ok =
                                                await state.toggleSaved(p.id);
                                            if (context.mounted && !ok) {
                                              showToast(
                                                  context, l10n.couldNotSave);
                                            }
                                          },
                                          icon: Icon(
                                              state.saved.contains(p.id)
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              size: 18),
                                          label: Text(state.saved.contains(p.id)
                                              ? l10n.savedConnection
                                              : l10n.saveConnection))),
                                  if (onCompare != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              onCompare!();
                                            },
                                            icon: const Icon(
                                                Icons.grid_view_outlined,
                                                size: 18),
                                            label: Text(l10n.compareCharts),
                                          )),
                                    ),
                                  Center(
                                      child: TextButton(
                                          onPressed: () =>
                                              _showReportDialog(context, p.id),
                                          child: Text(l10n.reportProfile,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: coral)))),
                                  Center(
                                      child: TextButton(
                                          onPressed: () async {
                                            final ok = await state.hide(p.id);
                                            if (context.mounted) {
                                              if (ok) {
                                                Navigator.pop(context);
                                                showToast(context,
                                                    l10n.hideToast(p.name));
                                              } else {
                                                showToast(
                                                    context, l10n.hideFailed);
                                              }
                                            }
                                          },
                                          child: Text(l10n.actionHide,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: muted)))),
                                ])),
                      ]))),
            ));
  }

  Future<void> _showReportDialog(BuildContext context, String userId) async {
    final submitted = await showDialog<(ReportReason, String)>(
        context: context, builder: (_) => const _ReportDialog());
    if (submitted == null) return;
    final ok = await state.submitReport(userId, submitted.$1, submitted.$2);
    if (!context.mounted) return;
    if (ok) {
      await state.hide(userId);
      if (context.mounted) {
        Navigator.pop(context);
        showToast(context, AppLocalizations.of(context)!.reportReceivedToast);
      }
    } else {
      showToast(context, AppLocalizations.of(context)!.reportFailedToast);
    }
  }

  Widget _factor(String title, int score, String description, Color color,
          {Color? tint, String? termId, String? contextText}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: tint ?? Colors.transparent,
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: termId == null
                              ? Text(title,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600))
                              : TermLink(
                                  termId: termId,
                                  label: '$title ⓘ',
                                  contextText: contextText ??
                                      '$title contributed $score% to this harmony score.',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: ink))),
                      Text('$score%',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: color))
                    ]),
                    const SizedBox(height: 8),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                            value: score / 100,
                            color: color,
                            backgroundColor: Colors.white,
                            minHeight: 5)),
                    const SizedBox(height: 7),
                    Text(description,
                        style: const TextStyle(fontSize: 10, color: muted)),
                  ])));
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog();
  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final note = TextEditingController();
  var reason = ReportReason.harassment;
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
        backgroundColor: canvas,
        title: Text(l10n.reportProfile,
            style: const TextStyle(fontSize: 18, color: ink)),
        content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(l10n.reportIntro,
                      style: const TextStyle(
                          fontSize: 11, height: 1.7, color: muted)),
                  const SizedBox(height: 10),
                  for (final r in ReportReason.values)
                    RadioListTile<ReportReason>(
                        value: r,
                        groupValue: reason,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(localizedReasonLabel(l10n, r),
                            style: const TextStyle(fontSize: 12)),
                        onChanged: (v) => setState(() => reason = v!)),
                  TextField(
                      controller: note,
                      maxLines: 3,
                      maxLength: 500,
                      decoration: InputDecoration(
                          labelText: l10n.reportNoteHint, counterText: '')),
                ]))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.actionCancel)),
          FilledButton(
              onPressed: () => Navigator.pop(context, (reason, note.text)),
              child: Text(l10n.submitReport)),
        ]);
  }
}
