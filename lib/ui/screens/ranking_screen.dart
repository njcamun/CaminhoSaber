// lib/ui/screens/ranking_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/services/ranking_service.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/ui/widgets/safe_asset_image.dart';
import 'package:caminho_do_saber/providers/profile_provider.dart';
import 'package:lottie/lottie.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rankingService = RankingService();
    final profileProvider = Provider.of<ProfileProvider>(context);
    final activeProfile = profileProvider.activeProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Exploradores', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: BackgroundContainer(
        child: SizedBox.expand(
          child: Column(
            children: [
              // Barra informativa com total de alunos
              StreamBuilder<int>(
                stream: rankingService.getTotalExplorersStream(),
                builder: (context, snapshot) {
                  final total = snapshot.data ?? 0;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      border: const Border(bottom: BorderSide(color: Colors.white24)),
                    ),
                    child: Text(
                      'Total de exploradores no mundo: $total',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                    ),
                  );
                }
              ),

              // Lista do Ranking
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: rankingService.getGlobalTop10Stream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text('Erro ao carregar o ranking', style: TextStyle(color: Colors.white)));
                    }

                    final ranking = snapshot.data ?? [];

                    if (ranking.isEmpty) {
                      return const Center(
                        child: Text('Ainda não há exploradores no ranking.\nSê o primeiro!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 15, 16, 30),
                      itemCount: ranking.length,
                      itemBuilder: (context, index) {
                        final item = ranking[index];
                        final bool isMe = activeProfile?.uid == item['profileUid'];
                        final bool isTop3 = index < 3;
                        
                        return _buildRankingItem(index + 1, item, isMe, isTop3);
                      },
                    );
                  },
                ),
              ),

              // Card fixo "Minha Posição" no fundo (Dock)
              if (activeProfile != null)
                _buildMyPositionDock(context, activeProfile, rankingService),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyPositionDock(BuildContext context, activeProfile, RankingService service) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade900.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 15, offset: const Offset(0, -4))],
        border: const Border(top: BorderSide(color: Colors.white24, width: 1)),
      ),
      child: StreamBuilder<int>(
        stream: service.getProfileRankStream(activeProfile.uid),
        builder: (context, snapshot) {
          final myRank = snapshot.data ?? 0;
          return SafeArea(
            top: false,
            child: Row(
              children: [
                _buildRankBadge(myRank, isSmall: true),
                const SizedBox(width: 15),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white10,
                    child: ClipOval(child: SafeAssetImage(path: activeProfile.avatarAssetPath, fit: BoxFit.cover)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('A TUA CLASSIFICAÇÃO', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                      Text(activeProfile.nome, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.amber.withOpacity(0.5))),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text('TU', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildRankingItem(int rank, Map<String, dynamic> item, bool isMe, bool isTop3) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Card(
            elevation: isMe ? 10 : 2,
            shadowColor: isMe ? Colors.blue.withOpacity(0.6) : Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(
                color: isMe ? Colors.blue.shade400 : (rank == 1 ? Colors.amber.shade300 : Colors.transparent),
                width: isMe || rank == 1 ? 2.5 : 0,
              ),
            ),
            color: isMe ? Colors.blue.shade50.withOpacity(0.98) : Colors.white.withOpacity(0.95),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: _buildRankBadge(rank),
              title: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: isMe ? Colors.blue.shade200 : Colors.transparent, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.blue.shade50,
                      child: ClipOval(
                        child: SafeAssetImage(
                          path: item['avatarPath'] ?? 'assets/avatars/avatar1.png',
                          fit: BoxFit.cover,
                          width: 44,
                          height: 44,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] ?? 'Anónimo',
                          style: TextStyle(
                            fontWeight: isMe || isTop3 ? FontWeight.bold : FontWeight.w600,
                            fontSize: 17,
                            color: isMe ? Colors.blue.shade900 : (isTop3 ? Colors.blueGrey.shade900 : Colors.black87),
                          ),
                        ),
                        if (isMe)
                          Text('Estás a brilhar!', style: TextStyle(color: Colors.blue.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item['totalPoints']}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: isMe ? Colors.blue.shade900 : (isTop3 ? Colors.blue.shade800 : Colors.blue.shade700),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.star,
                        color: isMe ? Colors.blue.shade900 : Colors.amber.shade700,
                        size: 18,
                      ),
                    ],
                  ),
                  Text('ESTRELAS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueGrey.withOpacity(0.6))),
                ],
              ),
            ),
          ),
          
          // Efeito de partículas/brilho À FRENTE do cartão APENAS para o Top 1 (Líder)
          // Colocado de forma menor e alinhado ao badge do líder
          if (rank == 1)
            Positioned(
              left: 5,
              top: 5,
              child: IgnorePointer(
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: Lottie.asset(
                    'assets/animations/festejo.json',
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
              ),
            ),
          
          // Selo Especial para o Top 1
          if (rank == 1)
            Positioned(
              top: -8,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: const Text('LÍDER', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank, {bool isSmall = false}) {
    Color badgeColor;
    IconData? icon;

    switch (rank) {
      case 1:
        badgeColor = Colors.amber.shade600;
        icon = Icons.emoji_events;
        break;
      case 2:
        badgeColor = Colors.grey.shade400;
        icon = Icons.emoji_events;
        break;
      case 3:
        badgeColor = Colors.brown.shade400;
        icon = Icons.emoji_events;
        break;
      default:
        badgeColor = isSmall ? Colors.white24 : Colors.blue.shade100;
        icon = null;
    }

    return Container(
      width: isSmall ? 35 : 42,
      height: isSmall ? 35 : 42,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        boxShadow: [
          if (rank <= 3) BoxShadow(color: badgeColor.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)
        ],
      ),
      alignment: Alignment.center,
      child: icon != null 
        ? Icon(icon, color: Colors.white, size: isSmall ? 18 : 24)
        : Text(rank == 0 ? '-' : '$rank', 
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isSmall ? Colors.white : Colors.blueGrey.shade700,
              fontSize: isSmall ? 14 : 18
            )),
    );
  }
}
