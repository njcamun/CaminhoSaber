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

  String _getUserClass(int totalPontos) {
    if (totalPontos >= 10001) return 'Mestre';
    if (totalPontos >= 5001) return 'Sábio';
    if (totalPontos >= 3001) return 'Aventureiro';
    return 'Aprendiz';
  }

  int _getNextLevelPoints(int totalPontos) {
    if (totalPontos >= 10001) return 20000;
    if (totalPontos >= 5001) return 10000;
    if (totalPontos >= 3001) return 5000;
    return 3000;
  }

  void _showInfoDialog(BuildContext context, String title, String content, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 12),
              Flexible(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
            ],
          ),
          content: Container(
            width: size.width * 0.8,
            child: Text(content, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Incrível!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Conquistas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        elevation: 4,
        foregroundColor: Colors.white,
      ),
      body: BackgroundContainer(
        child: SizedBox.expand(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 12),
                    _buildRankingCard(context),
                    const SizedBox(height: 20),
                    _buildPointsProgressBar(context),
                    const SizedBox(height: 24),

                    _buildSectionTitle(context, 'Desafios', textColor),
                    _buildChallengeStats(),
                    _buildArcadeRecords(),
                    const SizedBox(height: 24),

                    _buildSectionTitle(context, 'Troféus', textColor),
                    _buildTrophyGalleryDetailed(isTablet),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeStats() {
    return Consumer<ProgressoService>(
      builder: (context, ps, child) {
        return _buildTieredStatCard(
          title: 'Estatísticas Gerais',
          icon: Icons.analytics_rounded,
          items: [
            {
              'label': 'Total Pontos',
              'value': ps.totalPontosAcumulados,
              'color': Colors.blueAccent,
              'icon': Icons.bolt_rounded
            },
            {
              'label': 'Estrelas',
              'value': ps.totalStarsTotal,
              'color': Colors.orangeAccent,
              'lottieAsset': 'assets/animations/Star.json',
              'icon': Icons.stars_rounded
            },
            {
              'label': 'Diamantes',
              'value': ps.totalDiamantes,
              'color': Colors.cyan,
              'lottieAsset': 'assets/animations/Diamond.json',
              'icon': Icons.diamond_rounded
            },
            {
              'label': 'Ofensiva',
              'value': ps.currentStreak,
              'color': Colors.orange,
              'lottieAsset': 'assets/animations/fire.json',
              'icon': Icons.local_fire_department_rounded
            },
          ],
        );
      },
    );
  }

  Widget _buildTieredStatCard({
    required String title,
    required IconData icon,
    String? lottieAsset,
    required List<Map<String, dynamic>> items,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blueGrey, size: 24),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
              ],
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.spaceAround,
              children: items.map((item) {
                final String? itemLottie = item['lottieAsset'] as String? ?? lottieAsset;
                final IconData itemIcon = item['icon'] as IconData? ?? icon;
                final Color itemColor = item['color'] as Color;

                return Container(
                  width: 70,
                  child: Column(
                    children: [
                      itemLottie != null
                          ? AnimatedStatIcon(
                              lottieAsset: itemLottie,
                              value: item['value'] as int,
                              fallbackColor: itemColor,
                              fallbackIcon: itemIcon,
                              size: 45,
                            )
                          : Column(
                              children: [
                                Icon(itemIcon, color: itemColor, size: 32),
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('${item['value']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: itemColor.withOpacity(0.8))),
                                ),
                              ],
                            ),
                      const SizedBox(height: 4),
                      Text(
                        item['label'] as String, 
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrophyGalleryDetailed(bool isTablet) {
    return FutureBuilder<List<DisciplinaMetadata>>(
      future: _disciplinasMetadataFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final ps = context.watch<ProgressoService>();
        final all = snapshot.data!;
        
        return Column(
          children: [
            _buildTrophyShelf(
              title: 'Mestria em Estudo', 
              icon: Icons.auto_stories_rounded, 
              color: Colors.teal, 
              allItems: all, 
              ps: ps, 
              isStudyShelf: true,
              isTablet: isTablet
            ),
            const SizedBox(height: 16),
            _buildTrophyShelf(
              title: 'Mestria em Desafios', 
              icon: Icons.quiz_rounded, 
              color: Colors.orange, 
              allItems: all, 
              ps: ps, 
              isStudyShelf: false,
              isTablet: isTablet
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrophyShelf({
    required String title, 
    required IconData icon, 
    required Color color, 
    required List<DisciplinaMetadata> allItems, 
    required ProgressoService ps,
    required bool isStudyShelf,
    required bool isTablet
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color.withOpacity(0.8))),
              ],
            ),
            const Divider(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allItems.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 6 : 4, 
                mainAxisSpacing: 10, 
                crossAxisSpacing: 10, 
                childAspectRatio: 0.8
              ),
              itemBuilder: (context, index) {
                final d = allItems[index];
                final atual = isStudyShelf ? ps.getProgressoLeituras(d.id) : ps.getProgressoQuizzes(d.id);
                final total = isStudyShelf ? d.totalLeituras : d.totalQuizzes;
                final double percent = (total > 0) ? (atual / total).clamp(0.0, 1.0) : 0.0;
                final bool isUnlocked = percent >= 1.0;

                return _buildTrophyMedallionWithProgress(
                  context: context, 
                  nome: d.nome, 
                  trophyColor: isUnlocked ? color : Colors.grey.shade300, 
                  isUnlocked: isUnlocked,
                  percent: percent,
                  highlightColor: color
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrophyMedallionWithProgress({
    required BuildContext context, 
    required String nome, 
    required Color trophyColor, 
    required bool isUnlocked,
    required double percent,
    required Color highlightColor
  }) {
    IconData icon;
    switch (nome.toUpperCase()) {
      case 'MATEMÁTICA': case 'ARITMÉTICA': icon = Icons.calculate_rounded; break;
      case 'CIÊNCIAS': icon = Icons.science_rounded; break;
      case 'HISTÓRIA': icon = Icons.account_balance_rounded; break;
      case 'GEOGRAFIA': icon = Icons.public_rounded; break;
      default: icon = Icons.emoji_events_rounded;
    }

    return InkWell(
      onTap: () {
        if (isUnlocked) {
          _showInfoDialog(context, 'Troféu de $nome', 'Conquistaste este troféu ao dominar completamente esta disciplina!', icon, trophyColor);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Progresso em $nome: ${(percent * 100).toInt()}% concluído!'), 
            behavior: SnackBarBehavior.floating
          ));
        }
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (!isUnlocked && percent > 0)
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    value: null,
                    strokeWidth: 2,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
                  ),
                ),
              if (!isUnlocked && percent > 0)
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 4,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(highlightColor),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  gradient: isUnlocked 
                    ? LinearGradient(colors: [trophyColor.withOpacity(0.4), trophyColor], begin: Alignment.topLeft, end: Alignment.bottomRight)
                    : null,
                  color: !isUnlocked ? Colors.grey.shade200 : null,
                ),
                child: CircleAvatar(
                  radius: 18, 
                  backgroundColor: isUnlocked ? Colors.white : Colors.grey.shade100, 
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: (!isUnlocked && percent > 0) ? 0.3 : 1.0,
                        child: Icon(icon, color: isUnlocked ? trophyColor : Colors.grey.shade400, size: 20),
                      ),
                      if (!isUnlocked && percent > 0)
                        FittedBox(
                          child: Text(
                            '${(percent * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 9, 
                              fontWeight: FontWeight.w900, 
                              color: highlightColor,
                              shadows: const [Shadow(color: Colors.white, blurRadius: 2)]
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              nome, 
              textAlign: TextAlign.center, 
              style: TextStyle(fontSize: 8, fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal, color: isUnlocked ? Colors.black87 : Colors.grey), 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsProgressBar(BuildContext context) {
    return Consumer<ProgressoService>(
      builder: (context, ps, child) {
        final current = ps.totalPontos;
        final next = _getNextLevelPoints(current);
        final title = _getUserClass(current);

        Color classColor;
        IconData classIcon = Icons.military_tech_rounded;
        
        switch (title) {
          case 'Mestre': classColor = Colors.cyan; break;
          case 'Sábio': classColor = Colors.amber.shade600; break;
          case 'Aventureiro': classColor = Colors.blueGrey.shade400; break;
          default: classColor = Colors.brown.shade400;
        }
        
        return InkWell(
          onTap: () => _showInfoDialog(context, 'Nível: $title', 'Continua a estudar para subires de classe! Faltam ${(next - current).clamp(0, 99999)} pontos para o próximo título.', Icons.military_tech_rounded, classColor),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.white.withOpacity(0.95),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: classColor.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(classIcon, color: classColor, size: 36),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Classe: $title', style: TextStyle(fontWeight: FontWeight.bold, color: classColor, fontSize: 18)),
                            const SizedBox(height: 4),
                            Text('$current / $next Pontos para evoluir', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  PointsProgressBar(
                    currentPoints: current.toDouble(),
                    nextLevelPoints: next.toDouble(),
                    color: classColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard() {
    return Consumer2<ProfileProvider, ProgressoService>(
      builder: (context, profileProvider, ps, child) {
        if (profileProvider.isLoading || profileProvider.activeProfile == null) return const Center(child: CircularProgressIndicator());
        final activeProfile = profileProvider.activeProfile!;
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white.withOpacity(0.95),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.blue.shade200, width: 2)),
                  child: CircleAvatar(radius: 30, backgroundColor: Colors.blue.shade50, child: ClipOval(child: SafeAssetImage(path: activeProfile.avatarAssetPath, fit: BoxFit.cover, width: 60, height: 60))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(fit: BoxFit.scaleDown, child: Text(activeProfile.nome, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent))),
                      const Text('Explorador do Saber', style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                    ],
                  ),
                ),
                AnimatedStatIcon(
                  lottieAsset: 'assets/animations/Star.json',
                  value: ps.totalPontos,
                  fallbackColor: Colors.orangeAccent,
                  fallbackIcon: Icons.stars_rounded,
                  size: 50,
                ),
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
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RankingScreen())),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white.withOpacity(0.95),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: Colors.orange, size: 32),
              const SizedBox(width: 16),
              const Expanded(child: Text('Posição no Ranking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87))),
              StreamBuilder<int>(
                stream: context.read<RankingService>().getProfileRankStream(activeProfile.uid),
                builder: (context, snapshot) {
                  String rank = (snapshot.hasData) ? (snapshot.data == 0 ? 'N/A' : '#${snapshot.data}') : '...';
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.orange.shade200)),
                    child: Text(rank, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.orange)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArcadeRecords() {
    return FutureBuilder<List<DisciplinaMetadata>>(
      future: _disciplinasMetadataFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final ps = context.watch<ProgressoService>();
        final recordes = snapshot.data!.map((d) {
          final int pb = ps.progressoPorCapitulo['arcade_pb_${d.id}'] ?? 0;
          return {'nome': d.nome, 'pb': pb};
        }).where((r) => (r['pb'] as int) > 0).toList();

        if (recordes.isEmpty) return const SizedBox.shrink();
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white.withOpacity(0.95),
          child: Column(
            children: recordes.map((r) => ListTile(
              onTap: () => _showInfoDialog(context, 'Recorde: ${r['nome']}', 'Esta é a tua melhor pontuação de sempre no modo Arcade para a arena de ${r['nome']}!', Icons.videogame_asset_rounded, Colors.purple),
              leading: const Icon(Icons.videogame_asset_rounded, color: Colors.purple),
              title: Text(r['nome'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text('${r['pb']} pts', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.purple, fontSize: 16)),
            )).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 12.0, top: 8.0),
      child: Row(children: [
        Text(title.toUpperCase(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: color)),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: color.withOpacity(0.3))),
      ]),
    );
  }
}
