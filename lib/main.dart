import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// 🔥 Firebase Kütüphanelerini SİL
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// 🔥 Supabase Ekle
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme_manager.dart';
import 'core/language_manager.dart';
import 'core/constants.dart';

import 'main_layout.dart';
import 'screens/login_screen.dart';

// GLOBAL YÖNETİCİLER
final ThemeManager themeManager = ThemeManager();
final LanguageManager languageManager = LanguageManager();

// 🔥 Supabase Client Erişimi (Tüm uygulama buradan erişecek)
final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 FIREBASE YERİNE SUPABASE BAŞLATILIYOR
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
    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, _) {
        return ListenableBuilder(
          listenable: languageManager,
          builder: (context, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Neer',
              themeMode: themeManager.themeMode, 
              theme: themeManager.lightTheme, 
              darkTheme: themeManager.darkTheme,
              locale: languageManager.locale,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('tr', 'TR'),
                Locale('en', 'US'),
              ],
              home: const AuthGate(),
            );
          },
        );
      },
    );
  }
}

// 🚨 YENİ AUTH GATE (SUPABASE VERSİYONU)
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Supabase oturum durumunu dinlemek için Stream
  late final Stream<AuthState> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = supabase.auth.onAuthStateChange;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authStream,
      builder: (context, snapshot) {
        // Yükleniyor durumu (Opsiyonel, Supabase genelde anlık yanıt verir)
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
        }

        final session = snapshot.data?.session;

        // Oturum varsa Ana Ekrana, yoksa Giriş Ekranına
        if (session != null) {
          return const MainLayout();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}