// lib/ui/screens/ranking_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/services/ranking_service.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/ui/widgets/safe_asset_image.dart';
import 'package:caminho_do_saber/providers/profile_provider.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';
import 'package:caminho_do_saber/ui/widgets/neumorphic_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/scale_press_wrapper.dart';
import 'package:lottie/lottie.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rankingService = Provider.of<RankingService>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final activeProfile = profileProvider.activeProfile;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('RANKING GLOBAL'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: BackgroundContainer(
        child: Column(
          children: [
            // Header: Total de Exploradores
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: StreamBuilder<int>(
                stream: rankingService.getTotalExplorersStream(),
                builder: (context, snapshot) {
                  final total = snapshot.data ?? 0;
                  return NeumorphicWrapper(
                    baseColor: AppColors.primary,
                    borderRadius: 20,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'EXPLORADORES NO MUNDO: $total'.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.1),
                      ),
                    ),
                  );
                }
              ),
            ),

            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: rankingService.getLocalRankingStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final ranking = snapshot.data ?? [];

                  if (ranking.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset('assets/animations/arcade.json', height: 150),
                          Text('AINDA NÃO HÁ EXPLORADORES.\nSÊ O PRIMEIRO!'.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 20),
                          ScalePressWrapper(
                            onTap: () => rankingService.refreshLocalRankingCache(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(25)),
                              child: Text('ATUALIZAR'.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
                    itemCount: ranking.length,
                    itemBuilder: (context, index) {
                      final item = ranking[index];
                      final bool isMe = activeProfile?.uid == item['profileUid'];
                      return _buildRankingItem(index + 1, item, isMe, isTablet);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomSheet: activeProfile != null 
        ? _buildMyPositionDock(context, activeProfile, rankingService)
        : null,
    );
  }

  Widget _buildMyPositionDock(BuildContext context, activeProfile, RankingService service) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 50),
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF00B4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 17,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
      ),
      child: SafeArea(
        top: false,
        child: StreamBuilder<int>(
          stream: service.getProfileRankStream(activeProfile.uid),
          builder: (context, snapshot) {
            final myRank = snapshot.data ?? 0;
            return Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 4)],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    myRank == 0 ? '-' : '$myRank',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('A TUA CLASSIFICAÇÃO'.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                      Text(activeProfile.nome.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.accent, size: 20),
                      const SizedBox(width: 5),
                      Text('TU'.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildRankingItem(int rank, Map<String, dynamic> item, bool isMe, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          NeumorphicWrapper(
            baseColor: isMe ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
            borderRadius: 25,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: _buildRankBadge(rank),
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: ClipOval(child: SafeAssetImage(path: item['avatarPath'] ?? 'assets/avatars/avatar1.png', fit: BoxFit.cover)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['name']?.toString().toUpperCase() ?? 'EXPLORADOR',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: isMe ? AppColors.primary : Colors.black87),
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${item['totalPoints']}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary)),
                  Text('PONTOS'.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
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
                  width: 70,
                  height: 70,
                  child: Lottie.asset('assets/animations/festejo.json', fit: BoxFit.contain, repeat: true),
                ),
              ),
            ),
          
          if (rank == 1)
            Positioned(
              top: -8,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 3)],
                ),
                child: Text('LÍDER'.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    IconData? icon;

    switch (rank) {
      case 1:
        badgeColor = AppColors.accent; // Ouro / Âmbar
        icon = Icons.emoji_events;
        break;
      case 2:
        badgeColor = Colors.grey.shade400; // Prata
        icon = Icons.emoji_events;
        break;
      case 3:
        badgeColor = const Color(0xFFCD7F32); // Bronze
        icon = Icons.emoji_events;
        break;
      default:
        badgeColor = AppColors.primary.withValues(alpha: 0.2);
        icon = null;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: rank <= 3 ? badgeColor : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: rank <= 3 ? Colors.white : badgeColor, width: 2),
        boxShadow: [
          if (rank <= 3) BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 6, spreadRadius: 1)
        ],
      ),
      alignment: Alignment.center,
      child: icon != null 
        ? Icon(icon, color: Colors.white, size: 22)
        : Text(rank == 0 ? '-' : '$rank', 
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              fontSize: 16
            )),
    );
  }
}
