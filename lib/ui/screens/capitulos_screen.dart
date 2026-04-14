// lib/ui/screens/capitulos_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/models/disciplina_model.dart';
import 'package:caminho_do_saber/services/progresso_service.dart';
import 'package:caminho_do_saber/services/disciplina_service.dart'; 
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/ui/screens/conteudo_screen.dart';
import 'package:caminho_do_saber/models/conteudo_disciplina_model.dart';

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
  late final ProgressoService _progressoService;
  late Future<List<ConteudoCapitulo>> _capitulosFuture;

  @override
  void initState() {
    super.initState();
    _progressoService = Provider.of<ProgressoService>(context, listen: false);
    _capitulosFuture = context.read<DisciplinaService>().getCapitulos(widget.disciplina.id);
  }

  void _onCapituloTap(ConteudoCapitulo capitulo, bool isAccessible) {
    if (!isAccessible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conclui o capítulo anterior para desbloquear!'),
          behavior: SnackBarBehavior.floating,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.disciplina.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: BackgroundContainer(
        child: FutureBuilder<List<ConteudoCapitulo>>(
          future: _capitulosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhum conteúdo disponível.', style: TextStyle(color: Colors.white)));
            }

            final capitulos = snapshot.data!;
            return GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
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

                return _buildNivelCard(context, capitulo, isCompleted, isAccessible, score);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNivelCard(BuildContext context, ConteudoCapitulo capitulo, bool isCompleted, bool isAccessible, int score) {
    Color borderColor;
    Color bgColor;
    IconData iconData = Icons.lock;
    
    // Mapeia score para estrelas (escala 1-3)
    int stars = 0;
    if (score >= 15) {
      stars = 3;
    } else if (score >= 10) stars = 2;
    else if (score >= 5) stars = 1;

    if(isCompleted) {
      borderColor = Colors.green.shade400;
      bgColor = Colors.green.shade50;
      iconData = Icons.check_circle_rounded;
    } else if (isAccessible) {
      borderColor = Colors.blue.shade400;
      bgColor = Colors.blue.shade50;
      iconData = Icons.play_circle_fill_rounded;
    } else {
      borderColor = Colors.grey.shade400;
      bgColor = Colors.grey.shade200;
    }

    return GestureDetector(
      onTap: () => _onCapituloTap(capitulo, isAccessible),
      child: Card(
        elevation: isAccessible ? 6 : 2,
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isCompleted) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => Icon(
                  i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: Colors.amber,
                  size: 20,
                )),
              ),
              const SizedBox(height: 4),
            ] else 
              Icon(iconData, color: borderColor, size: 40),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                capitulo.titulo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isAccessible ? FontWeight.bold : FontWeight.normal,
                  color: isAccessible ? Colors.black87 : Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
