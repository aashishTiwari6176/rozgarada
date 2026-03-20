import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rojgar/floating_navbar.dart';
import 'package:rojgar/localization/app_localizations.dart';
import 'package:rojgar/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedCode = prefs.getString('language_code') ?? 'en';
  final bool isLoggedIn = prefs.getInt('candidate_id') != null;
  runApp(MyApp(initialLocale: Locale(savedCode), isLoggedIn: isLoggedIn));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initialLocale, required this.isLoggedIn});

  final Locale initialLocale;
  final bool isLoggedIn;

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
    _isLoggedIn = widget.isLoggedIn;
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    setState(() {
      _locale = locale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RozgarAdda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: _isLoggedIn ? const FloatingNavbarScreen() : const SplashScreen(),
    );
  }
}
