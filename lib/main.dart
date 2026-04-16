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
import 'package:caminho_do_saber/services/audio_service.dart';
import 'package:caminho_do_saber/providers/pomodoro_provider.dart';
import 'package:caminho_do_saber/ui/screens/home_screen.dart';
import 'package:caminho_do_saber/ui/screens/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:caminho_do_saber/database/database.dart';

final GlobalKey<ScaffoldMessengerState> globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Inicialização do Firebase com tratamento de erro para Web/GitHub
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10), onTimeout: () {
      debugPrint('Firebase initialization timed out');
      return Firebase.app(); // Tenta retornar a app padrão se já existir
    });

    // Capturador Global de Erros
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _showErrorOverlay(details.exceptionAsString());
    };

    // Garantir apenas orientação vertical
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final driftDb = AppDatabase();
    final audioService = AudioService();
    // Não bloqueamos o arranque da app se o áudio falhar (comum no Web)
    audioService.init().catchError((e) => debugPrint('Erro Audio: $e'));

    runApp(
      MultiProvider(
        providers: [
          Provider(create: (_) => AuthService()),
          Provider.value(value: driftDb),
          Provider.value(value: audioService),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider(driftDb)),
          Provider(create: (_) => DisciplinaService()),
          Provider(create: (_) => RankingService()),
          ChangeNotifierProvider(create: (_) => DictionaryService()),
          ChangeNotifierProvider(create: (_) => PomodoroProvider()),
          ChangeNotifierProxyProvider<ProfileProvider, ProgressoService>(
            create: (context) => ProgressoService(driftDb, context.read<ProfileProvider>()),
            update: (context, profile, previous) {
              final service = previous ?? ProgressoService(driftDb, profile);
              service.updateProvider(profile);
              profile.setProgressoService(service);
              return service;
            },
          ),
          ChangeNotifierProxyProvider<ProfileProvider, FlashcardService>(
            create: (context) => FlashcardService(driftDb, context.read<ProfileProvider>()),
            update: (context, profile, previous) {
              final service = previous ?? FlashcardService(driftDb, profile);
              service.updateProvider(profile);
              return service;
            },
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    debugPrint('ERRO FATAL NO MAIN: $e');
    // Se falhar tudo, tenta mostrar uma tela de erro básica em vez de ficar branca
    runApp(MaterialApp(home: Scaffold(body: Center(child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Text('Erro ao carregar a aplicação: $e\n\nPor favor, recarregue a página.', textAlign: TextAlign.center),
    )))));
  }
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
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (globalMessengerKey.currentState != null) {
      globalMessengerKey.currentState!.showSnackBar(
        SnackBar(
          content: Text('ERRO CAPTURADO:\n$error', style: const TextStyle(fontSize: 12)),
          backgroundColor: Colors.red.shade900,
          duration: const Duration(seconds: 10),
          action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
        ),
      );
    }
  });
}
