// lib/ui/screens/estude_screen.dart

import 'package:flutter/material.dart';
import 'package:caminho_do_saber/models/disciplina_model.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/ui/screens/capitulos_screen.dart';
import 'package:caminho_do_saber/ui/widgets/safe_asset_image.dart';

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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estude', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: BackgroundContainer(
        child: SizedBox.expand(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: groupedDisciplinas.entries.map((entry) {
                final categoria = entry.key;
                final disciplinasDaCategoria = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0, left: 4.0),
                      child: Row(
                        children: [
                          Text(
                            categoria,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(child: Divider(color: Colors.white24, thickness: 1.5)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: isTablet ? 220 : 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: disciplinasDaCategoria.length,
                        itemBuilder: (context, index) {
                          final disciplina = disciplinasDaCategoria[index];
                          return _buildDisciplinaCard(context, disciplina, isTablet);
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisciplinaCard(BuildContext context, Disciplina disciplina, bool isTablet) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CapitulosScreen(disciplina: disciplina),
          ));
        },
        child: Container(
          width: isTablet ? 300 : size.width * 0.65 > 260 ? 260 : size.width * 0.65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                SafeAssetImage(path: disciplina.animacao, fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          disciplina.nome,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        disciplina.descricao,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
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
      ),
    );
  }
}
