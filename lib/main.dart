import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme_manager.dart';
import 'core/language_manager.dart';
import 'core/constants.dart';

import 'main_layout.dart';
import 'screens/login_screen.dart';

// GLOBAL YÖNETİCİLER
final ThemeManager themeManager = ThemeManager();
final LanguageManager languageManager = LanguageManager();

// Supabase Client Erişimi (Tüm uygulama buradan erişecek)
final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('dotenv load failed: $e');
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ??
      const String.fromEnvironment('SUPABASE_URL');
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ??
      const String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    debugPrint('ERROR: Supabase credentials not found. '
        'Ensure .env file exists with SUPABASE_URL and SUPABASE_ANON_KEY.');
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
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