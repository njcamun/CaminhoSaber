// lib/ui/screens/conquistas_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/services/progresso_service.dart';
import 'package:caminho_do_saber/services/ranking_service.dart';
import 'package:caminho_do_saber/services/disciplina_service.dart';
import 'package:caminho_do_saber/providers/profile_provider.dart';
import 'package:caminho_do_saber/ui/widgets/safe_asset_image.dart';
import 'package:caminho_do_saber/ui/screens/ranking_screen.dart';
import 'package:caminho_do_saber/ui/widgets/points_progress_bar.dart';
import 'package:caminho_do_saber/ui/widgets/animated_stat_icon.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';
import 'package:caminho_do_saber/ui/widgets/neumorphic_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/scale_press_wrapper.dart';
import 'package:lottie/lottie.dart';
import 'package:caminho_do_saber/ui/widgets/edu_loading_widget.dart';

class ConquistasScreen extends StatefulWidget {
  const ConquistasScreen({super.key});

  @override
  State<ConquistasScreen> createState() => _ConquistasScreenState();
}

class _ConquistasScreenState extends State<ConquistasScreen> {
  late Future<List<DisciplinaMetadata>> _disciplinasMetadataFuture;

  @override
  void initState() {
    super.initState();
    _disciplinasMetadataFuture = context.read<DisciplinaService>().getDisciplinasMetadata();
  }

  void _showInfoDialog(BuildContext context, String title, String content, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Flexible(child: Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
            ],
          ),
          content: Text(content.toUpperCase(), style: const TextStyle(fontSize: 12, height: 1.5, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('INCRÍVEL!'.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('CONQUISTAS'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        backgroundColor: AppColors.primary,
        elevation: 4,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      body: BackgroundContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 25, 16, 40),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle('MEU PERFIL'),
                  _buildProfileCard(),
                  
                  const SizedBox(height: 25),
                  _buildSectionTitle('CLASSIFICAÇÃO'),
                  _buildRankingCard(context),
                  
                  const SizedBox(height: 25),
                  _buildSectionTitle('EVOLUÇÃO'),
                  _buildPointsProgressBar(context),
                  
                  const SizedBox(height: 25),
                  _buildSectionTitle('ESTATÍSTICAS'),
                  _buildChallengeStats(),
                  
                  const SizedBox(height: 25),
                  _buildSectionTitle('SALA DE TROFÉUS'),
                  _buildTrophyGalleryDetailed(isTablet),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(title.toUpperCase(),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.primary)),
    );
  }

  Widget _buildProfileCard() {
    return Consumer2<ProfileProvider, ProgressoService>(
      builder: (context, profileProvider, ps, child) {
        if (profileProvider.isLoading || profileProvider.activeProfile == null) return const Center(child: CircularProgressIndicator());
        final p = profileProvider.activeProfile!;
        return NeumorphicWrapper(
          baseColor: Colors.white,
          borderRadius: 25,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
                  child: CircleAvatar(radius: 30, backgroundColor: Colors.blue.shade50, child: ClipOval(child: SafeAssetImage(path: p.avatarAssetPath, fit: BoxFit.cover))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.nome.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                      Text('EXPLORADOR DO SABER'.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.blueGrey, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                Lottie.asset('assets/animations/Star.json', height: 50, repeat: true),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRankingCard(BuildContext context) {
    final activeProfile = context.read<ProfileProvider>().activeProfile;
    if (activeProfile == null) return const SizedBox.shrink();
    return ScalePressWrapper(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RankingScreen())),
      child: NeumorphicWrapper(
        baseColor: Colors.white,
        borderRadius: 25,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.accent, size: 32),
              const SizedBox(width: 16),
              Expanded(child: Text('POSIÇÃO NO RANKING'.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black87))),
              StreamBuilder<int>(
                stream: context.read<RankingService>().getProfileRankStream(activeProfile.uid),
                builder: (context, snapshot) {
                  String rank = (snapshot.hasData) ? (snapshot.data == 0 ? 'N/A' : '#${snapshot.data}') : '...';
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(25)),
                    child: Text(rank, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.accent)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointsProgressBar(BuildContext context) {
    return Consumer<ProgressoService>(
      builder: (context, ps, child) {
        final current = ps.totalStarsTotal;
        final next = ps.getNextLevelProgress(current);
        final title = ps.getLevelName(current);

        Color classColor = AppColors.tertiary;
        
        return NeumorphicWrapper(
          baseColor: Colors.white,
          borderRadius: 25,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.tertiary.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.military_tech_rounded, color: AppColors.tertiary, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('NÍVEL DE EVOLUÇÃO', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.tertiary, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text('$current / ${next.toInt()} ESTRELAS'.toUpperCase(), style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                PointsProgressBar(
                  currentPoints: current.toDouble(),
                  nextLevelPoints: next,
                  gradientColors: [AppColors.tertiary, const Color(0xFFE082FF)],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChallengeStats() {
    return Consumer<ProgressoService>(
      builder: (context, ps, child) {
        final stats = [
          {'label': 'PONTOS', 'value': ps.totalPontosAcumulados, 'icon': Icons.bolt_rounded, 'color': Colors.amber.shade700},
          {'label': 'ESTRELAS', 'value': ps.totalStarsTotal, 'anim': 'assets/animations/Star.json', 'color': AppColors.accent},
          {'label': 'DIAMANTES', 'value': ps.totalDiamantes, 'anim': 'assets/animations/Diamond.json', 'color': Colors.cyan},
          {'label': 'OFENSIVA', 'value': ps.currentStreak, 'anim': 'assets/animations/fire.json', 'color': AppColors.accent},
        ];

        return NeumorphicWrapper(
          baseColor: Colors.white,
          borderRadius: 25,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Wrap(
              spacing: 15,
              runSpacing: 20,
              alignment: WrapAlignment.spaceAround,
              children: stats.map((s) => Container(
                width: 75,
                child: Column(
                  children: [
                    s.containsKey('anim')
                        ? Lottie.asset(s['anim'] as String, height: 40, repeat: true)
                        : Container(
                            height: 40,
                            alignment: Alignment.center,
                            child: Icon(s['icon'] as IconData, size: 35, color: s['color'] as Color),
                          ),
                    const SizedBox(height: 5),
                    Text('${s['value']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: s['color'] as Color)),
                    Text((s['label'] as String).toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
                  ],
                ),
              )).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrophyGalleryDetailed(bool isTablet) {
    return FutureBuilder<List<DisciplinaMetadata>>(
      future: _disciplinasMetadataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: EduLoadingWidget(message: 'A CARREGAR TROFÉUS...'),
          );
        }
        if (!snapshot.hasData) return const SizedBox.shrink();
        final ps = context.watch<ProgressoService>();
        final all = snapshot.data!;
        
        return Column(
          children: [
            _buildTrophyShelf('Mestria em Estudo', Icons.auto_stories_rounded, AppColors.secondary, all, ps, true, isTablet),
            const SizedBox(height: 20),
            _buildTrophyShelf('Mestria em Quizzes', Icons.quiz_rounded, AppColors.accent, all, ps, false, isTablet),
          ],
        );
      },
    );
  }

  Widget _buildTrophyShelf(String title, IconData icon, Color color, List<DisciplinaMetadata> items, ProgressoService ps, bool isStudy, bool isTablet) {
    return NeumorphicWrapper(
      baseColor: Colors.white,
      borderRadius: 25,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(title.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 14)),
              ],
            ),
            const Divider(height: 25),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 6 : 4, 
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 0.8
              ),
              itemBuilder: (context, index) {
                final d = items[index];
                final atual = isStudy ? ps.getProgressoLeituras(d.id) : ps.getProgressoQuizzes(d.id);
                final total = isStudy ? d.totalLeituras : d.totalQuizzes;
                final double percent = (total > 0) ? (atual / total).clamp(0.0, 1.0) : 0.0;
                final bool isUnlocked = percent >= 1.0;

                return _buildTrophyMedallion(context, d.nome, isUnlocked ? color : Colors.grey.shade300, isUnlocked, percent, color);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrophyMedallion(BuildContext context, String nome, Color trophyColor, bool isUnlocked, double percent, Color highlightColor) {
    return ScalePressWrapper(
      onTap: () {
        if (isUnlocked) {
          _showInfoDialog(context, 'TROFÉU DE $nome', 'CONQUISTASTE ESTE TROFÉU AO DOMINAR COMPLETAMENTE ESTA DISCIPLINA!', Icons.emoji_events_rounded, trophyColor);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('PROGRESSO EM ${nome.toUpperCase()}: ${(percent * 100).toInt()}% CONCLUÍDO!'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: highlightColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ));
        }
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (!isUnlocked && percent > 0)
                SizedBox(width: 44, height: 44, child: CircularProgressIndicator(value: percent, strokeWidth: 3, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation<Color>(highlightColor))),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  color: isUnlocked ? trophyColor.withValues(alpha: 0.1) : Colors.grey.shade100,
                ),
                child: CircleAvatar(
                  radius: 18, 
                  backgroundColor: isUnlocked ? Colors.white : Colors.grey.shade100, 
                  child: Icon(Icons.emoji_events_rounded, color: isUnlocked ? trophyColor : Colors.grey.shade300, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          FittedBox(child: Text(nome.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: isUnlocked ? Colors.black87 : Colors.grey))),
        ],
      ),
    );
  }
}
