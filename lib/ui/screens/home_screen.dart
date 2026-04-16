// lib/ui/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:caminho_do_saber/models/disciplina_model.dart';
import 'package:caminho_do_saber/services/progresso_service.dart';
import 'package:caminho_do_saber/services/dictionary_service.dart';
import 'package:caminho_do_saber/models/dictionary_word_model.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/ui/screens/definicoes_screen.dart';
import 'package:caminho_do_saber/ui/screens/niveis_screen.dart';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/providers/profile_provider.dart';
import 'package:caminho_do_saber/ui/screens/conquistas_screen.dart';
import 'package:caminho_do_saber/ui/screens/meus_flashcards_screen.dart';
import 'package:caminho_do_saber/ui/screens/estude_screen.dart';
import 'package:caminho_do_saber/ui/widgets/safe_asset_image.dart';
import 'package:caminho_do_saber/ui/screens/daily_challenge_screen.dart';
import 'package:caminho_do_saber/ui/screens/arcade_quiz_screen.dart';
import 'package:caminho_do_saber/models/quiz_model.dart';
import 'package:caminho_do_saber/providers/pomodoro_provider.dart';
import 'package:caminho_do_saber/ui/widgets/scale_press_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/xp_progress_bar.dart';
import 'package:caminho_do_saber/ui/widgets/neumorphic_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/streak_fire.dart';
import 'package:caminho_do_saber/ui/widgets/punch_counter.dart';
import 'package:caminho_do_saber/ui/widgets/retro_crt_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/animated_stat_icon.dart';
import 'package:caminho_do_saber/services/ranking_service.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late Future<List<Disciplina>> _disciplinasFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _disciplinasFuture = _loadDisciplinas();
    context.read<DictionaryService>().loadDictionary();

    // Sincronização automática no arranque
    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        await context.read<ProgressoService>().syncWithCloud();
        // Baixamos o ranking atualizado para o banco local
        await context.read<RankingService>().refreshLocalRankingCache();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      context.read<DictionaryService>().loadDictionary();
      context.read<RankingService>().refreshLocalRankingCache();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      context.read<ProgressoService>().syncWithCloud();
    }
  }

  String _getAdaptiveGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 18) return Icons.wb_cloudy_rounded;
    return Icons.nightlight_round;
  }

  Future<List<Disciplina>> _loadDisciplinas() async {
    final String response = await rootBundle.loadString('assets/data/disciplinas.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Disciplina.fromJson(json)).toList();
  }

  Map<String, List<Disciplina>> _groupDisciplinas(List<Disciplina> disciplinas) {
    final Map<String, List<Disciplina>> grouped = {};
    for (var disciplina in disciplinas) {
      final categoria = disciplina.categoria.toUpperCase();
      if (!grouped.containsKey(categoria)) {
        grouped[categoria] = [];
      }
      grouped[categoria]!.add(disciplina);
    }
    return grouped;
  }

  void _showProfileSwitcherDialog(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Column(
            children: [
              const Icon(Icons.people_alt_rounded, size: 40, color: Colors.blue),
              const SizedBox(height: 10),
              Text('Quem vai estudar hoje?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.width * 0.05)),
              const Text('Escolhe o teu perfil para continuar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: size.height * 0.4),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: profileProvider.allProfiles.length,
                itemBuilder: (context, index) {
                  final profile = profileProvider.allProfiles[index];
                  final bool isActive = profile.uid == profileProvider.activeProfile?.uid;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: InkWell(
                      onTap: () {
                        profileProvider.setActiveProfile(profile);
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.blue.withValues(alpha: 0.1) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: isActive ? Colors.blue : Colors.grey.shade300, width: 2),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: size.width * 0.06,
                              backgroundColor: Colors.blue.shade100,
                              child: ClipOval(
                                child: SafeAssetImage(
                                  path: profile.avatarAssetPath,
                                  fit: BoxFit.cover,
                                  width: size.width * 0.12,
                                  height: size.width * 0.12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                profile.nome,
                                style: TextStyle(
                                  fontSize: size.width * 0.045,
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                  color: isActive ? Colors.blue.shade800 : Colors.black87,
                                ),
                              ),
                            ),
                            if (isActive) Icon(Icons.check_circle_rounded, color: Colors.blue, size: size.width * 0.07),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gere os teus perfis nos Ajustes!'), behavior: SnackBarBehavior.floating),
                    );
                  },
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Novo perfil?', style: TextStyle(fontSize: 12)),
                ),
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar')),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber.shade700),
              const SizedBox(width: 10),
              const Text('Como Funciona?', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bem-vindo ao Caminho do Saber! Aqui o teu estudo vira uma aventura. Vê como podes brilhar:',
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                _buildHelpItem(Icons.menu_book_rounded, Colors.blue, 'Explora e Aprende', 'Escolhe uma disciplina e mergulha nos capítulos. Cada leitura abre uma nova porta para o conhecimento!'),
                _buildHelpItem(Icons.quiz_rounded, Colors.orange, 'Desafia a tua Mente', 'Depois de ler, testa o que aprendeste com o Quiz. Acerta nas perguntas para ganhar muitos pontos e medalhas!'),
                _buildHelpItem(Icons.translate_rounded, Colors.teal, 'Palavra do Dia', 'Descobre termos fascinantes no Dicionário. Aprender palavras novas todos os dias torna-te um verdadeiro sábio!'),
                _buildHelpItem(Icons.style_rounded, Colors.purple, 'Cria os teus Cartões', 'Usa os Flashcards para memorizar a matéria de forma divertida. Podes até criar os teus próprios cartões mágicos!'),
                _buildHelpItem(Icons.emoji_events_rounded, Colors.amber.shade800, 'Sobe no Ranking', 'Ganha pontos em todos os teus perfis para subir de nível e ver o teu nome brilhar no topo do ranking global!'),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Vamos a isto!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpItem(IconData icon, Color color, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(desc, style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.3))])),
        ],
      ),
    );
  }

  void _handleDailyChallengeClick(BuildContext context, int totalPontos) {
    if (totalPontos < 1000) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock_rounded, color: Colors.orange),
              SizedBox(width: 10),
              Text('Acesso Bloqueado', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Precisas de chegar ao nível Aventureiro (1000 estrelas) para desbloquear os desafios!\n\nContinua a estudar através dos Quizzes e das Leituras Diárias para ganhar mais estrelas.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Vou estudar!', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DailyChallengeScreen()));
    }
  }

  void _showStatInfoDialog({
    required String title,
    required String description,
    required String howToGain,
    required String lottieAsset,
    required Color color,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Column(
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: Lottie.asset(lottieAsset, repeat: true),
            ),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 15),
            const Text('Como conquistar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 5),
            Text(howToGain, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido!', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, List<Disciplina> disciplinas) {
    final groupedDisciplinas = _groupDisciplinas(disciplinas);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: BackgroundContainer(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. CARD DE UTILIZADOR
              Consumer2<ProfileProvider, ProgressoService>(
                builder: (context, profileProvider, progressoService, child) {
                  if (profileProvider.isLoading || profileProvider.activeProfile == null) return const Center(child: CircularProgressIndicator());
                  final activeProfile = profileProvider.activeProfile!;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: NeumorphicWrapper(
                      baseColor: Colors.white.withValues(alpha: 0.95),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: size.width * 0.08 > 40 ? 40 : size.width * 0.08,
                                  backgroundColor: Colors.blue.shade100,
                                  child: ClipOval(child: SafeAssetImage(path: activeProfile.avatarAssetPath, fit: BoxFit.cover)),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(_getGreetingIcon(), size: 16, color: Colors.orangeAccent),
                                          const SizedBox(width: 4),
                                          Text('${_getAdaptiveGreeting()},', style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
                                        ],
                                      ),
                                      Text('${activeProfile.nome}!', style: TextStyle(fontSize: size.width * 0.055 > 24 ? 24 : size.width * 0.055, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                                    ],
                                  ),
                                ),
                                // Streak Fire (Dinâmico)
                                InkWell(
                                  onTap: () => _showStatInfoDialog(
                                    title: 'Ofensiva Diária',
                                    description: 'Representa a tua consistência no estudo. Mostra quantos dias seguidos tens mantido o teu foco!',
                                    howToGain: 'Estuda todos os dias! Se completares 6 dias seguidos, recebes um super bónus de 500 XP!',
                                    lottieAsset: 'assets/animations/fire.json',
                                    color: Colors.orange,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  child: StreakFire(days: progressoService.currentStreak, isActive: progressoService.currentStreak > 0),
                                ),
                                const SizedBox(width: 8),
                                // Diamantes Animados
                                InkWell(
                                  onTap: () => _showStatInfoDialog(
                                    title: 'Diamantes Azuis',
                                    description: 'Uma moeda rara e valiosa conquistada pelos estudantes mais dedicados.',
                                    howToGain: 'Ganha 1 diamante a cada 50 estrelas que conquistares! Usa-os para desbloquear desafios especiais.',
                                    lottieAsset: 'assets/animations/Diamond.json',
                                    color: Colors.cyan,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  child: AnimatedStatIcon(
                                    lottieAsset: 'assets/animations/Diamond.json',
                                    value: progressoService.totalDiamantes,
                                    fallbackColor: Colors.cyan,
                                    fallbackIcon: Icons.diamond_rounded,
                                    size: 45,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Estrelas Animadas
                                InkWell(
                                  onTap: () => _showStatInfoDialog(
                                    title: 'Estrelas de Sabedoria',
                                    description: 'Representam o teu progresso total e o brilho do teu conhecimento acumulado.',
                                    howToGain: 'Completa lições e acerta nos Quizzes! Cada 250 XP que ganhas transforma-se numa nova Estrela.',
                                    lottieAsset: 'assets/animations/desafio.json',
                                    color: Colors.orangeAccent,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  child: AnimatedStatIcon(
                                    lottieAsset: 'assets/animations/desafio.json', // Usando desafio.json como representação de estrela/troféu
                                    value: progressoService.totalStarsDisplay,
                                    fallbackColor: Colors.orangeAccent,
                                    fallbackIcon: Icons.stars,
                                    size: 45,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Nível: ${progressoService.getLevelName(progressoService.totalStarsTotal)}',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900, fontSize: 14),
                                ),
                                Text(
                                  '${progressoService.totalStarsTotal} / ${progressoService.getNextLevelXP(progressoService.totalStarsTotal).toInt()} Estrelas',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade700),
                                ),
                              ],
                            ),
                            XPProgressBar(
                              currentXP: progressoService.totalStarsTotal.toDouble(),
                              nextLevelXP: progressoService.getNextLevelXP(progressoService.totalStarsTotal),
                              color: Colors.orangeAccent,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progresso para Estrela',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.blueGrey.shade400),
                                ),
                                Text(
                                  '${progressoService.totalXP % 250} / 250 XP',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                                ),
                              ],
                            ),
                            XPProgressBar(
                              currentXP: (progressoService.totalXP % 250).toDouble(),
                              nextLevelXP: 250,
                              color: Colors.blueAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 2. BOTÕES DE NAVEGAÇÃO
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _buildNavCard(context, 'Conquistas', Icons.emoji_events_rounded, Colors.amber.shade800, () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ConquistasScreen()))),
                  _buildNavCard(context, 'Estude', Icons.auto_stories_rounded, Colors.blue.shade800, () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => EstudeScreen(disciplinas: disciplinas)))),
                  _buildNavCard(context, 'Cartões', Icons.style_rounded, Colors.purple.shade800, () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MeusFlashcardsScreen()))),
                  _buildNavCard(context, 'Ajustes', Icons.settings_suggest_rounded, Colors.grey.shade800, () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DefinicoesScreen()))),
                ]),
              ),

              // 2.1 DESAFIOS RÁPIDOS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Consumer<ProgressoService>(
                  builder: (context, progressoService, child) {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildModeActionCard(
                            context,
                            'Desafio Diário',
                            Icons.auto_awesome_rounded,
                            Colors.orange.shade800,
                            () => _handleDailyChallengeClick(context, progressoService.totalPontos)
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModeActionCard(
                            context,
                            'Modo Arcade',
                            Icons.videogame_asset_rounded,
                            Colors.purple.shade700,
                            () => _showArcadeArenaPicker(context, disciplinas)
                          ),
                        ),
                      ],
                    );
                  }
                ),
              ),

              // 3. CARD DO DICIONÁRIO
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Consumer<DictionaryService>(
                  builder: (context, dictionaryService, child) {
                    final word = dictionaryService.wordOfTheDay;
                    if (word == null && !dictionaryService.isLoading) return const SizedBox.shrink();
                    return _buildDictionaryCard(context, word, dictionaryService.isLoading);
                  },
                ),
              ),

              // 4. LISTA DE DISCIPLINAS
              Consumer<ProgressoService>(
                builder: (context, progressoService, child) {
                  return Column(
                    children: groupedDisciplinas.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                children: [
                                  Text(
                                    entry.key,
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: theme.colorScheme.onSurface),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.3), thickness: 1.5)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: isTablet ? 300 : 260,
                              child: ListView.builder(
                                padding: const EdgeInsets.only(left: 16),
                                scrollDirection: Axis.horizontal,
                                itemCount: entry.value.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: _buildDisciplinaCard(entry.value[index], disciplinas, progressoService),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDictionaryCard(BuildContext context, DictionaryWord? word, bool isLoading) {
    final dictionaryService = context.read<DictionaryService>();
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * 0.85 > 400 ? 400.0 : size.width * 0.85;

    return InkWell(
      onTap: word != null ? () => _showWordDetailsDialog(context, word) : () {},
      child: SizedBox(
        height: 225,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(bottom: 5, child: Transform.rotate(angle: 0.15, child: Card(color: Colors.teal.shade900.withValues(alpha: 0.4), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: SizedBox(width: cardWidth * 0.9, height: 175)))),
            Positioned(bottom: 10, child: Transform.rotate(angle: -0.08, child: Card(color: Colors.teal.shade800.withValues(alpha: 0.6), elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: SizedBox(width: cardWidth, height: 180)))),
            Card(
              color: Colors.teal.shade700,
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: isLoading || word == null
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)), child: const Text('PALAVRA DO DIA', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.volume_up_rounded, color: Colors.white70),
                          onPressed: () => dictionaryService.speakWord(word.palavra),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                          tooltip: 'Nova Palavra (IA)',
                          onPressed: () => dictionaryService.loadDictionary(force: true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FittedBox(fit: BoxFit.scaleDown, child: Text(word.palavra, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white))),
                    Text('(${word.classe.toLowerCase()})', style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.white70)),
                    const SizedBox(height: 10),
                    Text(word.significado, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWordDetailsDialog(BuildContext context, DictionaryWord word) {
    final dictionaryService = context.read<DictionaryService>();
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.translate_rounded, size: 30, color: Colors.teal),
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: FittedBox(fit: BoxFit.scaleDown, child: Text(word.palavra, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.teal))),
            )),
            IconButton(
              icon: const Icon(Icons.volume_up_rounded, color: Colors.teal, size: 30),
              onPressed: () => dictionaryService.speakWord("${word.palavra}. ${word.significado}"),
            ),
          ],
        ),
        content: SizedBox(
          width: size.width * 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailSection(Icons.info_outline, 'Significado', word.significado, Colors.blue),
                if (word.sinonimo.isNotEmpty) _buildDetailSection(Icons.compare_arrows_rounded, 'Sinónimo', word.sinonimo, Colors.green),
                if (word.antonimo.isNotEmpty) _buildDetailSection(Icons.swap_horiz_rounded, 'Antónimo', word.antonimo, Colors.orange),
                _buildDetailSection(Icons.lightbulb_outline, 'Exemplo', word.exemplo, Colors.amber, isItalic: true),
              ],
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar', style: TextStyle(fontWeight: FontWeight.bold)))],
      ),
    );
  }

  Widget _buildDetailSection(IconData icon, String title, String content, Color color, {bool isItalic = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26.0),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 16,
                fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: NeumorphicWrapper(
            baseColor: color,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Column(
                children: [
                  Icon(icon, size: 24, color: Colors.white),
                  const SizedBox(height: 8),
                  FittedBox(fit: BoxFit.scaleDown, child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: NeumorphicWrapper(
        baseColor: Colors.white.withValues(alpha: 0.95),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              FittedBox(fit: BoxFit.scaleDown, child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisciplinaCard(Disciplina disciplina, List<Disciplina> todasDisciplinas, ProgressoService progressoService) {
    final int totais = disciplina.capitulos?.length ?? 0;
    final int atuais = progressoService.getProgressoDisciplina(disciplina.id);
    final bool completa = totais > 0 && atuais == totais;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => NiveisScreen(disciplina: disciplina, todasDisciplinas: todasDisciplinas),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      )),
      child: Container(
        width: size.width * 0.45 > 200 ? 200 : size.width * 0.45,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'disciplina_bg_${disciplina.id}',
                child: SafeAssetImage(path: disciplina.animacao, fit: BoxFit.cover)
              ),
              Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)]))),
              Positioned(bottom: 12, left: 12, right: 12, child: Column(children: [FittedBox(fit: BoxFit.scaleDown, child: Text(disciplina.nome, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white))), const SizedBox(height: 4), Text(disciplina.descricao, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis)])),
              if (completa)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                    child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 20),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showArcadeArenaPicker(BuildContext context, List<Disciplina> disciplinas) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ArcadePicker',
      barrierColor: Colors.black.withValues(alpha: 0.95),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        final size = MediaQuery.of(context).size;
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: anim1,
            child: RetroCRTWrapper(
              child: Material(
                color: Colors.transparent,
                child: Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _CyberGridBackgroundPainter())),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ESCOLHA DA ARENA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.yellow,
                            fontSize: size.width * 0.08 > 32 ? 32 : size.width * 0.08,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            shadows: const [
                              Shadow(color: Colors.red, offset: Offset(3, 3)),
                              Shadow(color: Colors.blue, offset: Offset(-2, -2)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'PREPARA-TE PARA O DESAFIO',
                          style: TextStyle(color: Colors.cyanAccent, fontSize: 12, letterSpacing: 3, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          height: size.height * 0.5 > 400 ? 400 : size.height * 0.5,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            physics: const BouncingScrollPhysics(),
                            itemCount: disciplinas.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 30),
                                child: _ModernArcadeCard(
                                  disciplina: disciplinas[index],
                                  index: index,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _loadAllQuestionsAndStartArcade(context, disciplinas[index]);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                        ScalePressWrapper(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [
                                BoxShadow(color: Colors.black, offset: Offset(4, 4)),
                              ],
                            ),
                            child: const Text(
                              'VOLTAR AO INÍCIO',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadAllQuestionsAndStartArcade(BuildContext context, Disciplina d) async {
    try {
      final String response = await rootBundle.loadString('assets/data/${d.id}.json');
      final Map<String, dynamic> data = json.decode(response);
      final List<dynamic> quizzes = data['quizzes'] ?? [];

      List<PerguntaQuiz> allQuestions = [];
      for (var quiz in quizzes) {
        final List<dynamic> perguntasJson = quiz['perguntas'] ?? [];
        allQuestions.addAll(perguntasJson.map((p) => PerguntaQuiz.fromJson(p)).toList());
      }

      if (allQuestions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Esta disciplina ainda não tem desafios arcade!')));
        return;
      }

      allQuestions.shuffle();

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ArcadeQuizScreen(perguntas: allQuestions, disciplinaNome: d.nome, disciplinaId: d.id),
      ));
    } catch (e) {
      debugPrint('Erro Arcade: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Disciplina>>(
      future: _disciplinasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        if (snapshot.hasError) return Scaffold(body: Center(child: Text('Erro: ${snapshot.error}')));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Scaffold(body: Center(child: Text('Nenhuma disciplina encontrada.')));
        return Scaffold(
          appBar: AppBar(
            title: const Text('Caminho do Saber', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.blue,
            elevation: 4,
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            actions: [
              Consumer<PomodoroProvider>(
                builder: (context, pomodoro, child) {
                  if (!pomodoro.isHabilitado) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          pomodoro.status == PomodoroStatus.foco ? Icons.timer_rounded : Icons.coffee_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          pomodoro.tempoFormatado,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
              IconButton(icon: const Icon(Icons.group_add_outlined), tooltip: 'Trocar Perfil', onPressed: () => _showProfileSwitcherDialog(context)),
              IconButton(icon: const Icon(Icons.help_outline), tooltip: 'Como Funciona?', onPressed: () => _showHelpDialog(context)),
              const SizedBox(width: 8),
            ],
          ),
          body: _buildHomeTab(context, snapshot.data!),
        );
      },
    );
  }
}

class _ModernArcadeCard extends StatefulWidget {
  final Disciplina disciplina;
  final int index;
  final VoidCallback onTap;

  const _ModernArcadeCard({
    required this.disciplina,
    required this.index,
    required this.onTap,
  });

  @override
  State<_ModernArcadeCard> createState() => _ModernArcadeCardState();
}

class _ModernArcadeCardState extends State<_ModernArcadeCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2 + (widget.index % 2)),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: ScalePressWrapper(
        onTap: widget.onTap,
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.cyanAccent, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                SafeAssetImage(path: widget.disciplina.animacao, fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.purple.withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.9),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 10,
                  right: 10,
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.disciplina.nome.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 1.2,
                            shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 8)]
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 2,
                        width: 60,
                        color: Colors.cyanAccent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CyberGridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (double i = 0; i <= size.width; i += 40) {
      canvas.drawLine(
        Offset(i, size.height * 0.6),
        Offset(i * 2 - size.width / 2, size.height),
        paint,
      );
    }

    for (double i = size.height * 0.6; i <= size.height; i += 20) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint..color = Colors.purple.withValues(alpha: (i - size.height * 0.6) / (size.height * 0.4) * 0.2),
      );
    }

    final glowPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.05)
      ..strokeWidth = 2;
    for (double i = 0; i < size.height; i += 100) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
