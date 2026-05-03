// lib/ui/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:caminho_do_saber/models/disciplina_model.dart';
import 'package:caminho_do_saber/services/progresso_service.dart';
import 'package:caminho_do_saber/services/dictionary_service.dart';
import 'package:caminho_do_saber/models/dictionary_word_model.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';
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
import 'package:caminho_do_saber/ui/widgets/points_progress_bar.dart';
import 'package:caminho_do_saber/ui/widgets/neumorphic_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/retro_crt_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/animated_stat_icon.dart';
import 'package:caminho_do_saber/services/ranking_service.dart';
import 'package:caminho_do_saber/services/content_provider_service.dart';
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

    // Sincronização automática
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;
      final progressoService = context.read<ProgressoService>();
      final rankingService = context.read<RankingService>();
      await progressoService.syncWithCloud();
      if (!mounted) return;
      await rankingService.refreshLocalRankingCache();
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
    if (!mounted) return;
    if (state == AppLifecycleState.resumed) {
      context.read<RankingService>().refreshLocalRankingCache();
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'BOM DIA';
    if (hour < 18) return 'BOA TARDE';
    return 'BOA NOITE';
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 18) return Icons.wb_cloudy_rounded;
    return Icons.nightlight_round;
  }

  Future<List<Disciplina>> _loadDisciplinas() async {
    try {
      final contentProvider = context.read<ContentProviderService>();
      final String response = await contentProvider.getContent('disciplinas.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => Disciplina.fromJson(json)).toList();
    } catch (e) {
      debugPrint('[HomeScreen] Erro ao carregar disciplinas: $e');
      return [];
    }
  }

  Map<String, List<Disciplina>> _groupDisciplinas(List<Disciplina> disciplinas) {
    final Map<String, List<Disciplina>> grouped = {};
    for (var d in disciplinas) {
      final cat = d.categoria.toUpperCase();
      grouped.putIfAbsent(cat, () => []).add(d);
    }
    return grouped;
  }

  void _showProfileSwitcher(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            const Icon(Icons.group_rounded, color: AppColors.primary, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text('QUEM VAI ESTUDAR HOJE?'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: profileProvider.allProfiles.length,
            itemBuilder: (context, i) {
              final p = profileProvider.allProfiles[i];
              final active = p.uid == profileProvider.activeProfile?.uid;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: ClipOval(
                    child: SafeAssetImage(path: p.avatarAssetPath, fit: BoxFit.cover),
                  ),
                ),
                title: Text(p.nome.toUpperCase(), style: TextStyle(fontWeight: active ? FontWeight.w900 : FontWeight.normal)),
                trailing: active ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                onTap: () {
                  profileProvider.setActiveProfile(p);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('FECHAR'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            const Icon(Icons.info_rounded, color: AppColors.primary, size: 28),
            const SizedBox(width: 10),
            Text('COMO FUNCIONA?'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpItem(Icons.menu_book, AppColors.primary, 'EXPLORAÇÃO', 'Navega pelas seções verticais para encontrar as disciplinas de cada área.'),
              _buildHelpItem(Icons.stars, AppColors.accent, 'PROGRESSO', 'Completa capítulos para ganhar pontos. A cada 250 pontos, conquistas uma nova Estrela!'),
              _buildHelpItem(Icons.videogame_asset, AppColors.tertiary, 'MODO ARCADE', 'Testa a tua velocidade e precisão em desafios retro com recordes por disciplina.'),
              _buildHelpItem(Icons.style, AppColors.secondary, 'FLASHCARDS', 'Memoriza conceitos importantes com o teu baralho personalizado de cartões.'),
              _buildHelpItem(Icons.local_fire_department, AppColors.accent, 'OFENSIVAS', 'Mantém a tua sequência de estudo diário (streak) para ganhar bónus especiais.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ENTENDIDO'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, Color color, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color)),
                const SizedBox(height: 2),
                Text(desc.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Disciplina>>(
      future: _disciplinasFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final disciplinas = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            title: Image.asset('assets/icons/logo_L_branco.png', height: 160, errorBuilder: (c,e,s) => const Text('EDUCLASS', style: TextStyle(fontWeight: FontWeight.w900))),
            centerTitle: false,
            elevation: 4,
            actions: [
              Consumer<PomodoroProvider>(
                builder: (context, pomodoro, _) => pomodoro.isHabilitado 
                  ? Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [
                        Icon(pomodoro.status == PomodoroStatus.foco ? Icons.timer : Icons.coffee, size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(pomodoro.tempoFormatado, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                      ]),
                    ) 
                  : const SizedBox.shrink()
              ),
              IconButton(icon: const Icon(Icons.group_rounded, color: Colors.white), onPressed: () => _showProfileSwitcher(context)),
              IconButton(icon: const Icon(Icons.help_outline_rounded, color: Colors.white), onPressed: () => _showHelpDialog(context)),
            ],
          ),
          body: BackgroundContainer(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  // PAINEL DO HERÓI (USER CARD)
                  _buildHeroCard(context),
                  
                  const SizedBox(height: 25),
                  
                  // GRELHA DE AÇÃO RÁPIDA
                  _buildActionGrid(context, disciplinas),

                  const SizedBox(height: 25),

                  // CARD PALAVRA DO DIA
                  _buildDictionaryCard(context),

                  const SizedBox(height: 25),

                  // EXPLORAÇÃO POR CATEGORIAS
                  _buildCategorySections(context, disciplinas),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Consumer2<ProfileProvider, ProgressoService>(
      builder: (context, profile, progresso, _) {
        if (profile.activeProfile == null) return const SizedBox.shrink();
        final p = profile.activeProfile!;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: NeumorphicWrapper(
            baseColor: Colors.white,
            borderRadius: 25,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: ClipOval(
                            child: SafeAssetImage(
                              path: p.avatarAssetPath,
                              fit: BoxFit.cover,
                              width: 70,
                              height: 70,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(_getGreetingIcon(), size: 14, color: AppColors.accent),
                              const SizedBox(width: 5),
                              Text(_getGreeting(), style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 12)),
                            ]),
                            Text(p.nome.toUpperCase(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
                          ],
                        ),
                      ),
                      // Stats Gamificados
                      InkWell(
                        onTap: () => _showStatInfoDialog(
                          title: 'Ofensiva Diária',
                          description: 'Representa a tua consistência no estudo. Mostra quantos dias seguidos tens mantido o teu foco!',
                          howToGain: 'Estuda todos os dias! Se completares 6 dias seguidos, recebes um super bónus de 500 Pontos!',
                          lottieAsset: 'assets/animations/fire.json',
                          color: AppColors.accent,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        child: _buildStat(progresso.currentStreak, 'assets/animations/fire.json', AppColors.accent),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showStatInfoDialog(
                          title: 'Diamantes Azuis',
                          description: 'Uma moeda rara e valiosa conquistada pelos estudantes mais dedicados.',
                          howToGain: 'Ganha 1 diamante a cada 50 estrelas que conquistares! Usa-os para desbloquear desafios especiais.',
                          lottieAsset: 'assets/animations/Diamond.json',
                          color: Colors.cyan,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        child: _buildStat(progresso.totalDiamantes, 'assets/animations/Diamond.json', Colors.cyan),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showStatInfoDialog(
                          title: 'Estrelas de Sabedoria',
                          description: 'Representam o teu progresso total e o brilho do teu conhecimento acumulado.',
                          howToGain: 'Completa lições e acerta nos Quizzes! Cada 250 Pontos que ganhas transforma-se numa nova Estrela.',
                          lottieAsset: 'assets/animations/Star.json',
                          color: AppColors.accent,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        child: _buildStat(progresso.totalStarsDisplay, 'assets/animations/Star.json', AppColors.accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Barras de Progresso Duplas
                  _buildProgressRow(
                    'ESTRELAS', 
                    progresso.totalStarsTotal.toDouble(), 
                    progresso.getNextLevelProgress(progresso.totalStarsTotal), 
                    null, 
                    gradientColors: [AppColors.tertiary, Color(0xFFE082FF)] // Roxo Educlass -> Roxo Claro
                  ),
                  const SizedBox(height: 12),
                  _buildProgressRow(
                    'PONTOS', 
                    (progresso.totalPontosAcumulados % 250).toDouble(), 
                    250, 
                    null, 
                    gradientColors: [AppColors.orange, AppColors.accent] // Restaurado: Laranja -> Amarelo
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(int val, String anim, Color color) {
    return Column(children: [
      Lottie.asset(anim, height: 35, repeat: true),
      Text('$val', style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 14)),
    ]);
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
            Lottie.asset(lottieAsset, height: 80, repeat: true),
            const SizedBox(height: 10),
            Text(title.toUpperCase(), textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, color: color)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 15),
            Text('COMO CONQUISTAR:'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: color)),
            const SizedBox(height: 5),
            Text(howToGain.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ENTENDIDO'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, double cur, double next, Color? color, {List<Color>? gradientColors}) {
    final displayColor = color ?? gradientColors?.first ?? AppColors.primary;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: displayColor.withValues(alpha: 0.8))),
        Text('${cur.toInt()}/${next.toInt()}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: displayColor)),
      ]),
      PointsProgressBar(currentPoints: cur, nextLevelPoints: next, color: color, gradientColors: gradientColors),
    ]);
  }

  Widget _buildActionGrid(BuildContext context, List<Disciplina> d) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(children: [
            _buildNavBtn(context, 'CONQUISTAS', Icons.emoji_events, AppColors.accent, () => Navigator.push(context, MaterialPageRoute(builder: (c)=>const ConquistasScreen()))),
            _buildNavBtn(context, 'ESTUDE', Icons.menu_book, AppColors.primary, () => Navigator.push(context, MaterialPageRoute(builder: (c)=>EstudeScreen(disciplinas: d)))),
            _buildNavBtn(context, 'CARTÕES', Icons.style, AppColors.tertiary, () => Navigator.push(context, MaterialPageRoute(builder: (c)=>const MeusFlashcardsScreen()))),
            _buildNavBtn(context, 'AJUSTES', Icons.settings, Colors.blueGrey, () => Navigator.push(context, MaterialPageRoute(builder: (c)=>const DefinicoesScreen()))),
          ]),
          const SizedBox(height: 15),
          Row(children: [
            Expanded(child: _buildModeBtn(context, 'DESAFIO DIÁRIO', Icons.auto_awesome, AppColors.accent, () => Navigator.push(context, MaterialPageRoute(builder: (c)=>const DailyChallengeScreen())))),
            const SizedBox(width: 15),
            Expanded(child: _buildModeBtn(context, 'MODO ARCADE', Icons.videogame_asset, AppColors.tertiary, () => _showArcadeArenaPicker(context, d))),
          ]),
        ],
      ),
    );
  }

  Widget _buildNavBtn(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ScalePressWrapper(
          onTap: onTap,
          child: NeumorphicWrapper(
            baseColor: color,
            borderRadius: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Column(children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(height: 5),
                FittedBox(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9))),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeBtn(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return ScalePressWrapper(
      onTap: onTap,
      child: NeumorphicWrapper(
        baseColor: Colors.white,
        borderRadius: 20,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.1)),
          ]),
        ),
      ),
    );
  }

  Widget _buildDictionaryCard(BuildContext context) {
    return Consumer<DictionaryService>(
      builder: (context, service, _) {
        final word = service.wordOfTheDay;
        if (word == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: NeumorphicWrapper(
            baseColor: Colors.white,
            borderRadius: 25,
            child: InkWell(
              onTap: () => _showWordDetailsDialog(context, word),
              borderRadius: BorderRadius.circular(25),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: const Text('PALAVRA DO DIA', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 10)),
                    ),
                    IconButton(icon: const Icon(Icons.volume_up, color: AppColors.primary), onPressed: () => service.speakWord(word.palavra)),
                  ]),
                  Text(word.palavra.toUpperCase(), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 1.5)),
                  const SizedBox(height: 5),
                  Text(word.significado.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 13)),
                ]),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showWordDetailsDialog(BuildContext context, DictionaryWord word) {
    final service = context.read<DictionaryService>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            const Icon(Icons.translate_rounded, color: AppColors.secondary, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                word.palavra.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.secondary),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up_rounded, color: AppColors.secondary, size: 28),
              onPressed: () => service.speakWord("${word.palavra}. ${word.significado}"),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.info_outline, 'SIGNIFICADO', word.significado, AppColors.primary),
            if (word.sinonimo.isNotEmpty && word.sinonimo != 'N/A')
              _buildDetailRow(Icons.compare_arrows_rounded, 'SINÓNIMOS', word.sinonimo, AppColors.success),
            if (word.exemplo.isNotEmpty && word.exemplo != 'N/A')
              _buildDetailRow(Icons.lightbulb_outline, 'EXEMPLO', word.exemplo, AppColors.accent),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ENTENDIDO'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.secondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String content, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 14, color: color), const SizedBox(width: 6), Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: color))]),
          const SizedBox(height: 2),
          Text(content.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildCategorySections(BuildContext context, List<Disciplina> disciplinas) {
    final grouped = _groupDisciplinas(disciplinas);
    return Column(
      children: grouped.entries.map((entry) => Container(
        margin: const EdgeInsets.only(bottom: 30), // Removidas margens laterais para expandir além da tela
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: AppShadows.topShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25, top: 25, bottom: 5),
              child: Row(
                children: [
                  Text(entry.key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: 2)),
                  const SizedBox(width: 12),
                  Expanded(child: Divider(color: AppColors.primary.withValues(alpha: 0.1), thickness: 2.5)),
                ],
              ),
            ),
            SizedBox(
              height: 290,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
                itemCount: entry.value.length,
                itemBuilder: (context, i) => _buildDisciplinaCard(context, entry.value[i]),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildDisciplinaCard(BuildContext context, Disciplina d) {
    final progresso = context.read<ProgressoService>();
    final complete = (d.capitulos?.length ?? 0) > 0 && progresso.getProgressoDisciplina(d.id) == d.capitulos!.length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: ScalePressWrapper(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c)=>NiveisScreen(disciplina: d, todasDisciplinas: const []))),
        child: Container(
          width: 192,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SafeAssetImage(path: d.animacao, fit: BoxFit.cover),
              _ShimmerOverlay(),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.white, // Sólido na base
                      Colors.white, // Início da transparência aos 30%
                      Colors.white.withValues(alpha: 0.0), // Transparente no topo
                    ],
                    stops: const [0.0, 0.3, 0.9],
                  ),
                ),
              ),
              Positioned(
                bottom: 15, left: 10, right: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      d.nome.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (d.descricao.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        d.descricao.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF007A9E), // Um azul mais escuro e legível para a descrição
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (complete)
                const Positioned(top: 10, right: 10, child: Icon(Icons.workspace_premium, color: AppColors.accent, size: 30)),
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
      barrierLabel: 'Arcade',
      barrierColor: Colors.black.withValues(alpha: 0.9),
      pageBuilder: (context, _, __) => RetroCRTWrapper(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _CyberGridBackgroundPainter())),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ARENA ARCADE', style: TextStyle(color: AppColors.tertiary, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 5, shadows: [Shadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 7)])),
                    const SizedBox(height: 40),
                    SizedBox(
                      height: 350,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        itemCount: disciplinas.length,
                        itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: _ModernArcadeCard(disciplina: disciplinas[i], index: i, onTap: () {
                            Navigator.pop(context);
                            _startArcade(context, disciplinas[i]);
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    ScalePressWrapper(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white, width: 2)),
                        child: const Text('VOLTAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startArcade(BuildContext context, Disciplina d) async {
    final contentProvider = context.read<ContentProviderService>();
    final String response = await contentProvider.getContent('${d.id}.json');
    final Map<String, dynamic> data = json.decode(response);
    final List<PerguntaQuiz> questions = (data['quizzes'] as List).expand((q) => (q['perguntas'] as List).map((p) => PerguntaQuiz.fromJson(p))).toList()..shuffle();
    if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (c)=>ArcadeQuizScreen(perguntas: questions, disciplinaNome: d.nome, disciplinaId: d.id)));
  }
}

class _ShimmerOverlay extends StatefulWidget {
  @override
  _ShimmerOverlayState createState() => _ShimmerOverlayState();
}

class _ShimmerOverlayState extends State<_ShimmerOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(); }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => FractionallySizedBox(
          widthFactor: 2,
          child: Transform.rotate(angle: 0.5, child: Transform.translate(offset: Offset(-1.0 + (_c.value * 2.0), 0), child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0)], stops: const [0.4, 0.5, 0.6]))))),
        ),
      ),
    );
  }
}

class _ModernArcadeCard extends StatefulWidget {
  final Disciplina disciplina;
  final int index;
  final VoidCallback onTap;
  const _ModernArcadeCard({required this.disciplina, required this.index, required this.onTap});
  @override
  _ModernArcadeCardState createState() => _ModernArcadeCardState();
}

class _ModernArcadeCardState extends State<_ModernArcadeCard> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _f;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: Duration(seconds: 2 + (widget.index % 2)))..repeat(reverse: true);
    _f = Tween<double>(begin: -10, end: 10).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOutSine));
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _f,
      builder: (context, child) => Transform.translate(offset: Offset(0, _f.value), child: child),
      child: ScalePressWrapper(
        onTap: widget.onTap,
        child: Container(
          width: 200,
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(25), border: Border.all(color: AppColors.tertiary, width: 2), boxShadow: [BoxShadow(color: Colors.grey.shade400.withValues(alpha: 0.35), blurRadius: 10)]),
          clipBehavior: Clip.antiAlias,
          child: Stack(fit: StackFit.expand, children: [
            SafeAssetImage(path: widget.disciplina.animacao, fit: BoxFit.cover),
            Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87]))),
            Positioned(bottom: 20, left: 10, right: 10, child: Text(widget.disciplina.nome.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.2))),
          ]),
        ),
      ),
    );
  }
}

class _CyberGridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = AppColors.tertiary.withValues(alpha: 0.1)..strokeWidth = 1;
    for (double i = 0; i <= size.width; i += 40) { canvas.drawLine(Offset(i, size.height * 0.6), Offset(i * 2 - size.width / 2, size.height), p); }
    for (double i = size.height * 0.6; i <= size.height; i += 20) { canvas.drawLine(Offset(0, i), Offset(size.width, i), p..color = AppColors.tertiary.withValues(alpha: (i - size.height * 0.6) / (size.height * 0.4) * 0.2)); }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
