import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../services/app_state.dart';
import 'design.dart';

void showLanguagePicker(BuildContext context, AppState state) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext)!;
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final current = state.localeOverride;
          return AlertDialog(
            title: Text(l10n.languageTitle),
            contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
            content: SizedBox(
              width: 320,
              height: 460,
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(l10n.languageSystem),
                    trailing:
                        current == null ? const Icon(Icons.check, color: blue) : null,
                    onTap: () {
                      state.setLocale(null);
                      setDialogState(() {});
                    },
                  ),
                  const Divider(height: 1),
                  for (final locale in AppLocalizations.supportedLocales)
                    ListTile(
                      dense: true,
                      title: Text(
                        lookupAppLocalizations(locale).languageName,
                        textDirection: _textDirection(locale),
                      ),
                      trailing: current == locale
                          ? const Icon(Icons.check, color: blue)
                          : null,
                      onTap: () {
                        state.setLocale(locale);
                        setDialogState(() {});
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.actionClose),
              ),
            ],
          );
        },
      );
    },
  );
}

TextDirection _textDirection(Locale locale) =>
    const {'ar', 'he', 'fa', 'ur'}.contains(locale.languageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
