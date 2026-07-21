import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

// Theme Provider
class ThemeProvider extends ChangeNotifier {
  bool _isDark = true;
  bool get isDark => _isDark;
  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

class YearProvider extends ChangeNotifier {
  int _year = 2024;
  int get year => _year;
  void setYear(int year) {
    _year = year;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    print('Firebase init failed: $e');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => YearProvider()),
      ],
      child: const OneVoteApp(),
    ),
  );
}

class OneVoteApp extends StatelessWidget {
  const OneVoteApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'OneVote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}