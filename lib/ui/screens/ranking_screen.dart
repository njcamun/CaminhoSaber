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
    final rankingService = Provider.of<RankingService>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final activeProfile = profileProvider.activeProfile;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

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

              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: rankingService.getLocalRankingStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Erro ao carregar o ranking:\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      );
                    }

                    final ranking = snapshot.data ?? [];

                    if (ranking.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Ainda não há exploradores no ranking.\nSê o primeiro!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => rankingService.refreshLocalRankingCache(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Atualizar Ranking'),
                            ),
                          ],
                        ),
                      );
                    }

                    return Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 15, 16, 30),
                          itemCount: ranking.length,
                          itemBuilder: (context, index) {
                            final item = ranking[index];
                            final bool isMe = activeProfile?.uid == item['profileUid'];
                            final bool isTop3 = index < 3;
                            
                            return _buildRankingItem(index + 1, item, isMe, isTop3, isTablet);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (activeProfile != null)
                _buildMyPositionDock(context, activeProfile, rankingService, isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyPositionDock(BuildContext context, activeProfile, RankingService service, bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade900.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 15, offset: const Offset(0, -4))],
        border: const Border(top: BorderSide(color: Colors.white24, width: 1)),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
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
                          FittedBox(fit: BoxFit.scaleDown, child: Text(activeProfile.nome, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
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
        ),
      ),
    );
  }

  Widget _buildRankingItem(int rank, Map<String, dynamic> item, bool isMe, bool isTop3, bool isTablet) {
    // Se não houver UID de perfil, tratamos como anónimo
    final String profileUid = item['profileUid'] ?? 'unknown';
    
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
              contentPadding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: 10),
              leading: _buildRankBadge(rank),
              title: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: isMe ? Colors.blue.shade200 : Colors.transparent, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: isTablet ? 26 : 22,
                      backgroundColor: Colors.blue.shade50,
                      child: ClipOval(
                        child: SafeAssetImage(
                          path: item['avatarPath'] ?? 'assets/avatars/avatar1.png',
                          fit: BoxFit.cover,
                          width: isTablet ? 52 : 44,
                          height: isTablet ? 52 : 44,
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
                            fontSize: isTablet ? 19 : 17,
                            color: isMe ? Colors.blue.shade900 : (isTop3 ? Colors.blueGrey.shade900 : Colors.black87),
                          ),
                        ),
                        if (isMe)
                          Text('Estás a brilhar!', style: TextStyle(color: Colors.blue.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
                        // Identificador discreto para debugging ou para diferenciar perfis com mesmo nome
                        if (item['parentUid'] == 'system_bot')
                          const Text('Explorador Virtual', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.normal)),
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
                          fontSize: isTablet ? 22 : 18,
                          color: isMe ? Colors.blue.shade900 : (isTop3 ? Colors.blue.shade800 : Colors.blue.shade700),
                        ),
                      ),
                    ],
                  ),
                  Text('PONTOS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueGrey.withOpacity(0.6))),
                  const SizedBox(height: 2),
                  // Mostra estrelas como métrica secundária
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(item['totalPoints'] / 250).floor()}',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.star, color: Colors.orange.shade700, size: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (rank == 1)
            Positioned(
              left: 5,
              top: 5,
              child: IgnorePointer(
                child: SizedBox(
                  width: isTablet ? 90 : 70,
                  height: isTablet ? 90 : 70,
                  child: Lottie.asset(
                    'assets/animations/festejo.json',
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
              ),
            ),
          
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
