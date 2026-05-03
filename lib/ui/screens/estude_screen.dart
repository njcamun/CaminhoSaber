// lib/ui/screens/estude_screen.dart

import 'package:flutter/material.dart';
import 'package:caminho_do_saber/models/disciplina_model.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/ui/screens/capitulos_screen.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';
import 'package:caminho_do_saber/ui/widgets/safe_asset_image.dart';
import 'package:caminho_do_saber/ui/widgets/neumorphic_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/scale_press_wrapper.dart';

class EstudeScreen extends StatelessWidget {
  final List<Disciplina> disciplinas;
  const EstudeScreen({super.key, required this.disciplinas});

  Map<String, List<Disciplina>> _groupDisciplinasByCategory(List<Disciplina> allDisciplinas) {
    final Map<String, List<Disciplina>> groupedDisciplinas = {};
    for (var disciplina in allDisciplinas) {
      final categoria = disciplina.categoria.toUpperCase();
      if (!groupedDisciplinas.containsKey(categoria)) {
        groupedDisciplinas[categoria] = [];
      }
      groupedDisciplinas[categoria]!.add(disciplina);
    }
    return groupedDisciplinas;
  }

  @override
  Widget build(BuildContext context) {
    final groupedDisciplinas = _groupDisciplinasByCategory(disciplinas);
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('ESTUDE'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: false,
      ),
      body: BackgroundContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: groupedDisciplinas.entries.map((entry) {
              return Container(
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
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Divider(color: AppColors.primary.withValues(alpha: 0.1), thickness: 2.5)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 310, // Acomodar cards maiores com sombras
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
                        itemCount: entry.value.length,
                        itemBuilder: (context, index) {
                          return _buildDisciplinaCard(context, entry.value[index], isTablet);
                        },
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDisciplinaCard(BuildContext context, Disciplina disciplina, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: ScalePressWrapper(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CapitulosScreen(disciplina: disciplina),
          ));
        },
        child: Container(
          width: 220,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SafeAssetImage(path: disciplina.animacao, fit: BoxFit.cover),
              // Efeito de brilho
              _ShimmerStatic(), 
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.white,
                      Colors.white,
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.3, 0.8],
                  ),
                ),
              ),
              Positioned(
                bottom: 15,
                left: 15,
                right: 15,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        disciplina.nome.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      disciplina.descricao.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF007A9E),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
}

// Pequeno efeito de brilho estático se não quisermos carregar o controlador de animação aqui
class _ShimmerStatic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.4, 0.5, 0.6],
        ),
      ),
    );
  }
}
