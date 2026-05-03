// lib/ui/screens/capitulos_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/models/disciplina_model.dart';
import 'package:caminho_do_saber/services/progresso_service.dart';
import 'package:caminho_do_saber/services/disciplina_service.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/ui/screens/conteudo_screen.dart';
import 'package:caminho_do_saber/models/conteudo_disciplina_model.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';
import 'package:caminho_do_saber/ui/widgets/safe_asset_image.dart';
import 'package:caminho_do_saber/ui/widgets/neumorphic_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/scale_press_wrapper.dart';

import 'package:caminho_do_saber/ui/widgets/edu_loading_widget.dart';

class CapitulosScreen extends StatefulWidget {
  final Disciplina disciplina;

  const CapitulosScreen({
    super.key,
    required this.disciplina,
  });

  @override
  State<CapitulosScreen> createState() => _CapitulosScreenState();
}

class _CapitulosScreenState extends State<CapitulosScreen> {
  late Future<List<ConteudoCapitulo>> _capitulosFuture;

  @override
  void initState() {
    super.initState();
    _capitulosFuture = context.read<DisciplinaService>().getCapitulos(widget.disciplina.id);
  }

  void _onCapituloTap(ConteudoCapitulo capitulo, bool isAccessible) {
    if (!isAccessible) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CONCLUI O CAPÍTULO ANTERIOR PARA DESBLOQUEAR!'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ConteudoScreen(
        titulo: capitulo.titulo,
        conteudo: capitulo.conteudo,
        capituloId: '${widget.disciplina.id}_${capitulo.id}',
      ),
    )).then((_) => setState(() {})); 
  }

  @override
  Widget build(BuildContext context) {
    final progressoService = context.watch<ProgressoService>();
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final expandedHeaderHeight = size.height * 0.3 > 250 ? 250.0 : size.height * 0.3;

    return Scaffold(
      body: BackgroundContainer(
        child: FutureBuilder<List<ConteudoCapitulo>>(
          future: _capitulosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return EduLoadingWidget(message: 'BAIXANDO LIÇÕES DA NUVEM...');
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('NENHUM CONTEÚDO DISPONÍVEL.'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.grey)));
            }

            final capitulos = snapshot.data!;
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: expandedHeaderHeight,
                    pinned: true,
                    elevation: 4,
                    shadowColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundColor: AppColors.primary,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      title: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: innerBoxIsScrolled ? 1.0 : 0.0,
                        child: Text(
                          widget.disciplina.nome.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: 'disciplina_bg_cap_${widget.disciplina.id}',
                            child: SafeAssetImage(path: widget.disciplina.animacao, fit: BoxFit.cover),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.white,
                                  Colors.white.withValues(alpha: 0.4),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.3, 0.7],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 25,
                            left: 20,
                            right: 20,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: innerBoxIsScrolled ? 0.0 : 1.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('MODO ESTUDO'.toUpperCase(),
                                      style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
                                  Text(
                                    widget.disciplina.nome.toUpperCase(),
                                    style: const TextStyle(color: AppColors.primary, fontSize: 26, fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 3 : 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: capitulos.length,
                itemBuilder: (context, index) {
                  final capitulo = capitulos[index];
                  final uniqueId = '${widget.disciplina.id}_${capitulo.id}';
                  final isCompleted = progressoService.isCapituloConcluido(uniqueId);
                  final score = progressoService.progressoPorCapitulo[uniqueId] ?? 0;

                  final previousId = index > 0 ? '${widget.disciplina.id}_${capitulos[index - 1].id}' : null;
                  final bool isAccessible = index == 0 || (previousId != null && progressoService.isCapituloConcluido(previousId));

                  return _buildCapituloCard(context, index, capitulo, isCompleted, isAccessible, score);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCapituloCard(BuildContext context, int index, ConteudoCapitulo capitulo, bool isCompleted, bool isAccessible, int score) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ScalePressWrapper(
        onTap: () => _onCapituloTap(capitulo, isAccessible),
        child: NeumorphicWrapper(
          baseColor: Colors.white,
          borderRadius: 25,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAccessible ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle_rounded : (isAccessible ? Icons.menu_book_rounded : Icons.lock_rounded),
                    color: isCompleted ? AppColors.success : (isAccessible ? AppColors.primary : Colors.grey),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'CAPÍTULO ${index + 1}'.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isAccessible ? AppColors.primary : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  capitulo.titulo.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isAccessible ? Colors.black87 : Colors.grey.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isCompleted) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars_rounded, color: AppColors.accent, size: 14),
                      const SizedBox(width: 4),
                      Text('CONCLUÍDO'.toUpperCase(), style: const TextStyle(color: AppColors.accent, fontSize: 9, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
