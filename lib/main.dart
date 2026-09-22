import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'l10n/generated/app_localizations.dart';
import 'services/app_state.dart';
import 'ui/app_shell.dart';
import 'ui/design.dart';

SemanticsHandle? webSemantics;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) webSemantics = SemanticsBinding.instance.ensureSemantics();
  tz.initializeTimeZones();
  final preferences = await SharedPreferences.getInstance();
  runApp(LunarApp(state: AppState(preferences)));
}

class LunarApp extends StatelessWidget {
  final AppState state;
  const LunarApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context)!.appTitle,
              debugShowCheckedModeBanner: false,
              theme: lunarTheme(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: state.localeOverride,
              localeResolutionCallback: (deviceLocale, supportedLocales) {
                // System Norwegian reports nb/nn; our ARB file is tagged 'no'.
                if (deviceLocale != null &&
                    const {'nb', 'nn'}.contains(deviceLocale.languageCode)) {
                  return const Locale('no');
                }
                return deviceLocale == null
                    ? const Locale('en')
                    : basicLocaleListResolution(
                        [deviceLocale], supportedLocales);
              },
              home: AppShell(state: state),
            ),
      );
}
