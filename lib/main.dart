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

import 'package:caminho_do_saber/database/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Garantir apenas orientação vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final driftDb = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        Provider.value(value: driftDb),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider(driftDb)),
        Provider(create: (_) => DisciplinaService()),
        Provider(create: (_) => RankingService()),
        ChangeNotifierProvider(create: (_) => DictionaryService()),
        ChangeNotifierProvider(create: (_) => PomodoroProvider()),
        ChangeNotifierProxyProvider<ProfileProvider, ProgressoService>(
          create: (context) => ProgressoService(driftDb, context.read<ProfileProvider>()),
          update: (context, profile, previous) {
            final service = previous!..updateProvider(profile);
            profile.setProgressoService(service); // Vincula o serviço ao provider de perfil
            return service;
          },
        ),
        ChangeNotifierProxyProvider<ProfileProvider, FlashcardService>(
          create: (context) => FlashcardService(driftDb, context.read<ProfileProvider>()),
          update: (context, profile, previous) => previous!..updateProvider(profile),
        ),
      ],
      child: const MyApp(),
    ),
  );
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
