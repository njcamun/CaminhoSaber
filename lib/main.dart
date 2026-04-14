import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/providers/profile_provider.dart';
import 'package:caminho_do_saber/providers/theme_provider.dart';
import 'package:caminho_do_saber/services/auth_service.dart';
import 'package:caminho_do_saber/services/progresso_service.dart';
import 'package:caminho_do_saber/services/dictionary_service.dart';
import 'package:caminho_do_saber/services/disciplina_service.dart';
import 'package:caminho_do_saber/services/ranking_service.dart';
import 'package:caminho_do_saber/services/flashcard_service.dart';
import 'package:caminho_do_saber/providers/pomodoro_provider.dart';
import 'package:caminho_do_saber/ui/screens/home_screen.dart';
import 'package:caminho_do_saber/ui/screens/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'dart:ui';

import 'package:caminho_do_saber/database/database.dart';

final GlobalKey<ScaffoldMessengerState> globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
    }

    // Capturador Global de Erros para facilitar o debug em Web
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _showErrorOverlay('Flutter Error: ${details.exceptionAsString()}');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Global Error: $error\n$stack');
      _showErrorOverlay('Global Error: $error');
      return true;
    };

    /* try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } catch (e) {
      debugPrint('Orientation error: $e');
    } */

    debugPrint('Initializing Drift...');
    final driftDb = AppDatabase();
    debugPrint('Drift DB instance created.');

    runApp(
      MultiProvider(
        providers: [
          Provider(create: (_) { debugPrint('Creating AuthService...'); return AuthService(); }),
          Provider.value(value: driftDb),
          ChangeNotifierProvider(create: (_) { debugPrint('Creating ThemeProvider...'); return ThemeProvider(); }),
          ChangeNotifierProvider(create: (_) { debugPrint('Creating ProfileProvider...'); return ProfileProvider(driftDb); }),
          Provider(create: (_) => DisciplinaService()),
          Provider(create: (_) => RankingService()),
          ChangeNotifierProvider(create: (_) => DictionaryService()),
          ChangeNotifierProvider(create: (_) => PomodoroProvider()),
          ChangeNotifierProxyProvider<ProfileProvider, ProgressoService>(
            create: (context) {
               debugPrint('Creating ProgressoService...');
               return ProgressoService(driftDb, null);
            },
            update: (context, profile, previous) {
              debugPrint('Updating ProgressoService Proxy...');
              final service = previous ?? ProgressoService(driftDb, null);
              service.updateProvider(profile);
              return service;
            },
          ),
          ChangeNotifierProxyProvider<ProfileProvider, FlashcardService>(
            create: (context) {
              debugPrint('Creating FlashcardService...');
              return FlashcardService(driftDb, null);
            },
            update: (context, profile, previous) {
               debugPrint('Updating FlashcardService Proxy...');
               final service = previous ?? FlashcardService(driftDb, null);
               service.updateProvider(profile);
               return service;
            },
          ),
        ],
        child: const MyApp(),
      ),
    );
    debugPrint('runApp executed.');
  }, (error, stack) {
    debugPrint('ZONED ERROR: $error\n$stack');
    _showErrorOverlay('Zoned Error: $error');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final authService = Provider.of<AuthService>(context, listen: false);
        final user = authService.currentUser;

        return MaterialApp(
          title: 'Caminho do Saber',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: globalMessengerKey,
          theme: themeProvider.themeData,
          home: user != null ? const HomeScreen() : const LoginScreen(),
          builder: (context, child) {
            return Stack(
              children: [
                if (child != null) child,
                if (themeProvider.isBlueLightFilterEnabled)
                  IgnorePointer(
                    child: Container(
                      color: Colors.orange.withValues(alpha: 0.15),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

void _showErrorOverlay(String error) {
  if (globalMessengerKey.currentState != null) {
    globalMessengerKey.currentState!.showSnackBar(
      SnackBar(
        content: Text('ERRO V2 CAPTURADO:\n$error', style: const TextStyle(fontSize: 12)),
        backgroundColor: Colors.red.shade900,
        duration: const Duration(seconds: 10),
        action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
      ),
    );
  }
}
