import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'l10n/generated/app_localizations.dart';
import 'services/app_state.dart';
import 'services/device_storage.dart';
import 'ui/app_shell.dart';
import 'ui/design.dart';

SemanticsHandle? webSemantics;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) webSemantics = SemanticsBinding.instance.ensureSemantics();
  tz.initializeTimeZones();
  runApp(const AppStartup());
}

class AppStartup extends StatefulWidget {
  final Future<SharedPreferences> Function()? loadPreferences;
  const AppStartup({super.key, this.loadPreferences});
  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  AppState? state;
  bool failed = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => failed = false);
    try {
      final preferences =
          await (widget.loadPreferences ?? SharedPreferences.getInstance)();
      if (!mounted) return;
      final storage = DeviceStorage(preferences);
      if (storage.deletionPending) await storage.reset(onMarked: () {});
      if (!mounted) return;
      setState(() => state = AppState(preferences));
    } catch (_) {
      if (mounted) setState(() => failed = true);
    }
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (state != null) return LunarApp(state: state!);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lunarTheme(),
      home: Scaffold(
          body: SafeArea(
              child: Center(
                  child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const FlowerLogo(size: 46),
          const SizedBox(height: 28),
          if (!failed)
            const CircularProgressIndicator()
          else ...[
            const Text('Could not open your saved data',
                textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton.icon(
                onPressed: load,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again')),
          ],
        ]),
      )))),
    );
  }
}

class LunarApp extends StatelessWidget {
  final AppState state;
  const LunarApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
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
                : basicLocaleListResolution([deviceLocale], supportedLocales);
          },
          home: AppShell(state: state),
        ),
      );
}
