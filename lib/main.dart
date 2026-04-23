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
import 'package:caminho_do_saber/ui/theme/app_colors.dart';
import 'package:caminho_do_saber/ui/screens/home_screen.dart';
import 'package:caminho_do_saber/ui/screens/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:caminho_do_saber/database/database.dart';

final GlobalKey<ScaffoldMessengerState> globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Inicialização do Firebase primeiro
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configuração de orientação (apenas nativo, mas seguro no web)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    AppDatabase? driftDb;
    try {
      driftDb = AppDatabase();
    } catch (e) {
      debugPrint('[Drift] Erro ao carregar base de dados. Usando Fallback.');
    }

    final audioService = AudioService();
    audioService.init().catchError((e) => debugPrint("Erro AudioService: $e"));

    runApp(
      MultiProvider(
        providers: [
          Provider(create: (_) => AuthService()),
          if (driftDb != null) Provider.value(value: driftDb),
          Provider.value(value: audioService),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider(driftDb)),
          Provider(create: (_) => DisciplinaService()),
          Provider<RankingService>(
            create: (context) => RankingService(driftDb),
            dispose: (_, service) => service.dispose(),
          ),
          ChangeNotifierProvider(create: (_) => DictionaryService()),
          ChangeNotifierProvider(create: (_) => PomodoroProvider()),
          ChangeNotifierProxyProvider2<ProfileProvider, RankingService, ProgressoService>(
            create: (context) => ProgressoService(driftDb, context.read<ProfileProvider>(), context.read<RankingService>()),
            update: (context, profile, ranking, previous) {
              if (previous == null) return ProgressoService(driftDb, profile, ranking);
              previous.updateProvider(profile);
              profile.setProgressoService(previous);
              return previous;
            },
          ),
          ChangeNotifierProxyProvider<ProfileProvider, FlashcardService>(
            create: (context) => FlashcardService(driftDb, context.read<ProfileProvider>()),
            update: (context, profile, previous) {
              if (previous == null) return FlashcardService(driftDb, profile);
              previous.updateProvider(profile);
              return previous;
            },
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stack) {
    debugPrint("ERRO FATAL NO MAIN: $e\n$stack");
    // Em caso de erro catastrófico, tentamos rodar uma app mínima de erro
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text("Erro ao iniciar aplicação: $e")))));
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
                      color: AppColors.accent.withValues(alpha: 0.15),
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
        content: Text('ERRO CAPTURADO:\n$error', style: const TextStyle(fontSize: 12)),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 10),
        action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
      ),
    );
  }
}
