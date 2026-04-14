// lib/ui/screens/conteudo_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/services/progresso_service.dart';

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
          widget.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: BackgroundContainer(
        child: SizedBox.expand(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 8,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white.withOpacity(0.95),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCompleted ? Icons.verified_rounded : Icons.auto_stories_rounded, 
                              color: isCompleted ? Colors.green : Colors.blue, 
                              size: 28
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isCompleted ? 'Conteúdo Concluído!' : 'Explorando o Conhecimento',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted ? Colors.green.shade800 : Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(thickness: 1.5),
                        ),
                        kIsWeb 
                        ? SelectableText(
                            widget.conteudo.replaceAll(RegExp(r'<[^>]*>'), ''),
                            style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                          )
                        : Html(
                            data: widget.conteudo,
                            style: {
                              "body": Style(
                                fontSize: FontSize(16.0),
                                lineHeight: const LineHeight(1.5),
                                color: Colors.black87,
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                              ),
                              "p": Style(margin: Margins.only(bottom: 12)),
                              "strong": Style(color: Colors.blue.shade900, fontWeight: FontWeight.bold),
                              "h1": Style(fontSize: FontSize(22.0), fontWeight: FontWeight.bold, margin: Margins.only(top: 10, bottom: 10)),
                              "h2": Style(fontSize: FontSize(20.0), fontWeight: FontWeight.bold, margin: Margins.only(top: 8, bottom: 8)),
                              "li": Style(margin: Margins.only(bottom: 6)),
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        if (!isCompleted) {
                          // Define o XP da leitura (ex: 15 XP para 3 estrelas se for a primeira vez)
                          // Atualmente o sistema usa 5 XP fixos, mas vamos recompensar mais pela leitura 
                          // para incentivar o estudo antes do quiz.
                          const int xpLeitura = 15; 
                          await progressoService.saveProgresso(widget.capituloId, xpLeitura, tipo: 'leitura');
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Incrível! Concluíste este capítulo e ganhaste $xpLeitura XP!'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          color: isCompleted ? Colors.green.withOpacity(0.9) : Colors.blue.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white30, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, 
                              color: Colors.white, 
                              size: 24
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isCompleted ? 'LEITURA CONCLUÍDA' : 'CONCLUIR LEITURA',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
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
