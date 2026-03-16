import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme_manager.dart';
import 'core/language_manager.dart';
import 'core/app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/catch_provider.dart';

// GLOBAL YÖNETİCİLER (geriye uyumluluk — yeni kodda Provider kullanın)
final ThemeManager themeManager = ThemeManager();
final LanguageManager languageManager = LanguageManager();

// Supabase Client Erişimi
final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://celkzibnupgacoesaxse.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNlbGt6aWJudXBnYWNvZXNheHNlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA1MDg1NjcsImV4cCI6MjA4NjA4NDU2N30.5cUu8uhqE2bLYhZZLwMFUVKhCPDt59UCCzCq4Wh3D_c',
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeManager),
        ChangeNotifierProvider.value(value: languageManager),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CatchProvider()),
      ],
      child: Consumer2<ThemeManager, LanguageManager>(
        builder: (context, theme, lang, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Neer',
            themeMode: theme.themeMode,
            theme: theme.lightTheme,
            darkTheme: theme.darkTheme,
            locale: lang.locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('tr', 'TR'),
              Locale('en', 'US'),
            ],
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
