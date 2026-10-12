import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/app/branded_opening_screen.dart';
import 'package:roundveil/l10n/generated/app_localizations.dart';
import 'package:roundveil/features/platform_shell/presentation/roundveil_shell.dart';

const _roundveilLocales = <Locale>[
  Locale('en'),
  Locale('sw'),
  Locale('ar'),
  Locale('hi'),
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
  Locale('ko'),
  Locale('pt'),
  Locale('es'),
  Locale('fr'),
  Locale('ja'),
  Locale('ur'),
  Locale('tr'),
];

class RoundveilApp extends StatefulWidget {
  const RoundveilApp({super.key});

  static const supportedLocales = _roundveilLocales;

  @override
  State<RoundveilApp> createState() => _RoundveilAppState();
}

class _RoundveilAppState extends State<RoundveilApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('en');
  bool _openingComplete = false;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ROUNDVEIL',
    debugShowCheckedModeBanner: false,
    theme: RoundveilThemeFactory.versionFive(dark: false),
    darkTheme: RoundveilThemeFactory.versionFive(dark: true),
    themeMode: _themeMode,
    locale: _locale,
    supportedLocales: RoundveilApp.supportedLocales,
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: _openingComplete
        ? RoundveilShell(
            onThemeChanged: (dark) => setState(
              () => _themeMode = dark ? ThemeMode.dark : ThemeMode.light,
            ),
            onLocaleChanged: (locale) => setState(() => _locale = locale),
            isDark: _themeMode != ThemeMode.light,
            locale: _locale,
          )
        : BrandedOpeningScreen(
            onFinished: () => setState(() => _openingComplete = true),
          ),
  );
}
