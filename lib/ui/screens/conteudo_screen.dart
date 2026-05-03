// lib/ui/screens/conteudo_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/services/progresso_service.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';
import 'package:caminho_do_saber/ui/widgets/neumorphic_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/scale_press_wrapper.dart';
import 'package:caminho_do_saber/services/audio_service.dart';

class ConteudoScreen extends StatefulWidget {
  final String titulo;
  final String conteudo;
  final String capituloId; 

  const ConteudoScreen({
    super.key,
    required this.titulo,
    required this.conteudo,
    required this.capituloId,
  });

  @override
  State<ConteudoScreen> createState() => _ConteudoScreenState();
}

class _ConteudoScreenState extends State<ConteudoScreen> {
  @override
  Widget build(BuildContext context) {
    final progressoService = Provider.of<ProgressoService>(context);
    final bool isCompleted = progressoService.isCapituloConcluido(widget.capituloId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.titulo.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.1),
        ),
        centerTitle: false, // Padronizado Educlass Aura
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BackgroundContainer(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 25, 16, 40),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle('LIÇÃO DO DIA'),
                  NeumorphicWrapper(
                    baseColor: Colors.white,
                    borderRadius: 30,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isCompleted ? AppColors.success.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isCompleted ? Icons.verified_rounded : Icons.auto_stories_rounded, 
                                  color: isCompleted ? AppColors.success : AppColors.primary,
                                  size: 24
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  (isCompleted ? 'CONTEÚDO CONCLUÍDO!' : 'EXPLORANDO O CONHECIMENTO').toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: isCompleted ? AppColors.success : AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Divider(thickness: 1.5, color: Colors.black12),
                          ),
                          Html(
                            data: widget.conteudo,
                            style: {
                              "body": Style(
                                fontSize: FontSize(17.0),
                                lineHeight: const LineHeight(1.6),
                                color: Colors.black87,
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                                fontWeight: FontWeight.w500,
                              ),
                              "p": Style(margin: Margins.only(bottom: 15)),
                              "strong": Style(color: AppColors.primary, fontWeight: FontWeight.w900),
                              "h1": Style(fontSize: FontSize(24.0), fontWeight: FontWeight.w900, color: AppColors.primary, margin: Margins.only(top: 15, bottom: 10)),
                              "h2": Style(fontSize: FontSize(20.0), fontWeight: FontWeight.w900, color: AppColors.primary, margin: Margins.only(top: 12, bottom: 8)),
                              "li": Style(margin: Margins.only(bottom: 8)),
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  Center(
                    child: ScalePressWrapper(
                      onTap: () async {
                        if (!isCompleted) {
                          const int pontosLeitura = 15; 
                          await progressoService.saveProgresso(widget.capituloId, pontosLeitura, tipo: 'leitura');
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('INCRÍVEL! CONCLUÍSTE ESTE CAPÍTULO E GANHASTE $pontosLeitura PONTOS!'.toUpperCase(), 
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.success,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              ),
                            );
                          }
                        }
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        decoration: BoxDecoration(
                          color: isCompleted ? AppColors.success : AppColors.primary,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade400.withValues(alpha: 0.28),
                              blurRadius: 10,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isCompleted ? Icons.check_circle_rounded : Icons.star_rounded, 
                              color: Colors.white, 
                              size: 24
                            ),
                            const SizedBox(width: 12),
                            Text(
                              (isCompleted ? 'LEITURA CONCLUÍDA' : 'CONCLUIR LIÇÃO').toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
}
