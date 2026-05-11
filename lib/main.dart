import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:language_learning_app/app_theme.dart';
import 'package:language_learning_app/login_screen.dart';
import 'package:provider/provider.dart';

import 'app_provider.dart';
import 'home_screen.dart';
import 'language_select_screen.dart';
import 'onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const LexiconApp());
}

class LexiconApp extends StatelessWidget {
  const LexiconApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..init(),
      child: MaterialApp(
        title: 'Lexicon',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _Splash(),
        routes: {
          '/onboarding':      (_) => const OnboardingScreen(),
          '/login':           (_) => const LoginScreen(),
          '/language-select': (_) => const LanguageSelectScreen(),
          '/home':            (_) => const HomeScreen(),
          '/progress':        (_) => const ProgressScreen(),
          '/achievements':    (_) => const AchievementsScreen(),
          '/favorites':       (_) => const FavoritesScreen(),
          '/settings':        (_) => const SettingsScreen(),
          '/daily-lesson':    (_) => const DailyLessonScreen(),
        },
      ),
    );
  }
}

/// Splash decides where to navigate based on onboarding state
class _Splash extends StatefulWidget {
  const _Splash();

  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final provider = context.read<AppProvider>();
    if (!provider.hasCompletedOnboarding) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else if (provider.selectedLanguage == null) {
      Navigator.pushReplacementNamed(context, '/language-select');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6C63FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: Text('ल', style: TextStyle(fontSize: 52, color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Lexicon',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
            ),
            const SizedBox(height: 8),
            Text(
              'Master Indian Languages',
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}