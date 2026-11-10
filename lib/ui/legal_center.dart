import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/app_state.dart';
import '../services/platform_contracts.dart';
import 'design.dart';

String localizedDocTitle(AppLocalizations l10n, LegalDocument doc) =>
    switch (doc.id) {
      'terms' => l10n.docTerms,
      'privacy' => l10n.docPrivacy,
      'community' => l10n.docCommunity,
      'safety' => l10n.docSafety,
      'csae' => l10n.docCsae,
      'deletion' => l10n.docDeletion,
      'subscription' => l10n.docSubscription,
      'moderation' => l10n.docModeration,
      _ => doc.title,
    };

Future<void> showLegalDocument(BuildContext context, LegalDocument doc) =>
    showDialog<void>(
        context: context,
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
              backgroundColor: canvas,
              title: Text(localizedDocTitle(l10n, doc),
                  style: const TextStyle(fontSize: 18, color: ink)),
              content: SizedBox(
                  width: 430,
                  child: SingleChildScrollView(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('v${doc.version} · ${doc.effective}',
                            style: const TextStyle(fontSize: 10, color: muted)),
                        const SizedBox(height: 14),
                        Text(doc.body,
                            style: const TextStyle(
                                fontSize: 12, height: 1.8, color: ink)),
                      ]))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.actionClose))
              ]);
        });

String _exportJson(AppState state) =>
    const JsonEncoder.withIndent('  ').convert({
      'app': 'Lunar',
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': {
        'name': state.name,
        'birth': state.birth.toJson(),
        'personalized': state.personalized,
      },
      'saved': state.saved.toList(),
      'hidden': state.hidden.toList(),
      'social': state.social.toJson(),
      'reports': state.reports.map((r) => r.toJson()).toList(),
      'consents': state.consentStore
          .all()
          .map((c) => {'id': c.id, 'version': c.version, 'at': c.at})
          .toList(),
    });

Future<void> showLegalCenter(BuildContext context, AppState state) =>
    showDialog<void>(
        context: context,
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
              backgroundColor: canvas,
              title: Text(l10n.legalCenterTitle),
              content: SizedBox(
                  width: 430,
                  child: SingleChildScrollView(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(l10n.legalCenterIntro,
                            style: const TextStyle(
                                fontSize: 11, height: 1.7, color: muted)),
                        const SizedBox(height: 8),
                        for (final doc in legalDocuments)
                          ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.description_outlined,
                                  size: 18,
                                  color: accentColors[
                                      legalDocuments.indexOf(doc) %
                                          accentColors.length]),
                              title: Text(localizedDocTitle(l10n, doc),
                                  style: const TextStyle(fontSize: 13)),
                              subtitle: Text('v${doc.version}',
                                  style: const TextStyle(
                                      fontSize: 10, color: muted)),
                              trailing: const Icon(Icons.chevron_right,
                                  size: 16, color: muted),
                              onTap: () => showLegalDocument(context, doc)),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: _exportJson(state)));
                              if (context.mounted) {
                                showToast(context, l10n.exportDoneToast);
                              }
                            },
                            icon: const Icon(Icons.download_outlined, size: 18),
                            label: Text(l10n.exportMyData)),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                            onPressed: () async {
                              final account = LocalAccountService(
                                  onLocalReset: state.reset,
                                  exportJson: () => _exportJson(state));
                              final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (inner) => AlertDialog(
                                          backgroundColor: canvas,
                                          title: Text(l10n.deleteConfirmTitle),
                                          content: Text(l10n.deleteConfirmBody),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(inner, false),
                                                child: Text(l10n.keepAccount)),
                                            FilledButton(
                                                onPressed: () =>
                                                    Navigator.pop(inner, true),
                                                style: FilledButton.styleFrom(
                                                    backgroundColor: coral),
                                                child: Text(
                                                    l10n.deleteEverything)),
                                          ]));
                              if (confirm != true) return;
                              final ok = await account.deleteAccount();
                              if (context.mounted) {
                                Navigator.pop(context);
                                showToast(
                                    context,
                                    ok
                                        ? l10n.deleteDoneToast
                                        : l10n.deleteFailedToast);
                              }
                            },
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: Text(l10n.deleteAccount)),
                      ]))),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.actionClose))
              ]);
        });
