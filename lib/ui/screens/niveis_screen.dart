// lib/ui/screens/niveis_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:caminho_do_saber/models/disciplina_model.dart';
import 'package:caminho_do_saber/services/progresso_service.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/ui/screens/quiz_screen.dart';
import 'package:caminho_do_saber/models/quiz_model.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/ui/widgets/safe_asset_image.dart';

class NiveisScreen extends StatefulWidget {
  final Disciplina disciplina;
  final List<Disciplina> todasDisciplinas;

  const NiveisScreen({
    super.key,
    required this.disciplina,
    required this.todasDisciplinas,
  });

  @override
  State<NiveisScreen> createState() => _NiveisScreenState();
}

class _NiveisScreenState extends State<NiveisScreen> {
  late final ProgressoService _progressoService;
  Map<String, int> _progressoCapitulos = {};
  List<Capitulo> _capitulos = [];
  Map<String, List<PerguntaQuiz>> _quizzes = {};
  Map<String, List<FlashCard>> _flashCardsPorQuiz = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _progressoService = Provider.of<ProgressoService>(context, listen: false);
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await _loadQuizzes();
      await _loadProgresso();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar níveis: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadQuizzes() async {
    try {
      final String assetPath = 'assets/data/${widget.disciplina.id}.json';
      final String jsonString = await rootBundle.loadString(assetPath);
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

      final List<dynamic>? quizzesJson = jsonMap['quizzes'];
      if (quizzesJson != null) {
        final List<Capitulo> loadedCapitulos = [];
        final Map<String, List<PerguntaQuiz>> loadedQuizzes = {};
        final Map<String, List<FlashCard>> generatedFlashCards = {};

        for (var quiz in quizzesJson) {
          final quizId = quiz['id'] as String;
          final List<dynamic> perguntasJson = quiz['perguntas'];
          final List<PerguntaQuiz> perguntas = perguntasJson.map((perguntaJson) => PerguntaQuiz.fromJson(perguntaJson)).toList();

          final List<FlashCard> flashCardsDoQuiz = perguntas.map((pergunta) => FlashCard(
            pergunta: pergunta.pergunta,
            resposta: pergunta.respostaCorreta,
          )).toList();

          loadedCapitulos.add(Capitulo.fromJson(quiz));
          loadedQuizzes[quizId] = perguntas;
          generatedFlashCards[quizId] = flashCardsDoQuiz;
        }

        setState(() {
          _quizzes = loadedQuizzes;
          _capitulos = loadedCapitulos;
          _flashCardsPorQuiz = generatedFlashCards;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar dados da disciplina: $e');
      }
    }
  }

  Future<void> _loadProgresso() async {
    try {
      final progresso = await _progressoService.getProgresso(widget.disciplina.id);
      if (mounted) {
        setState(() {
          _progressoCapitulos = progresso;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar progresso dos níveis: $e');
      }
      if (mounted) {
        setState(() {
          _progressoCapitulos = {};
        });
      }
    }
  }

  int _getEstrelas(int pontuacao, int totalPontosPossiveis) {
    if (totalPontosPossiveis <= 0) return 0;
    final percentagem = (pontuacao / totalPontosPossiveis) * 100;
    if (percentagem >= 100) return 5;
    if (percentagem >= 90) return 4;
    if (percentagem >= 80) return 3;
    if (percentagem >= 70) return 2;
    if (percentagem >= 60) return 1;
    return 0;
  }

  bool _isNivelDesbloqueado(int capituloIndex, int pontuacaoAnterior, int totalPontosAnterior) {
    if (capituloIndex == 0) return true;
    if (totalPontosAnterior == 0) return false;
    final percentagem = (pontuacaoAnterior / totalPontosAnterior) * 100;
    return percentagem >= 80;
  }

  Widget _buildNivelCard(BuildContext context, int index) {
    final capitulo = _capitulos[index];
    final quizPerguntas = _quizzes[capitulo.quizId] ?? [];
    final totalPontosPossiveis = quizPerguntas.length * 5;

    final progressoKey = '${widget.disciplina.id}_capitulo_${index + 1}';
    final pontuacao = _progressoCapitulos[progressoKey] ?? 0;
    final estrelas = _getEstrelas(pontuacao, totalPontosPossiveis);

    final pontuacaoAnterior = index > 0
        ? _progressoCapitulos['${widget.disciplina.id}_capitulo_$index'] ?? 0
        : 0;

    final totalPontosAnterior = index > 0
        ? (_quizzes[_capitulos[index - 1].quizId]?.length ?? 0) * 5
        : 0;

    final isUnlocked = _isNivelDesbloqueado(index, pontuacaoAnterior, totalPontosAnterior);
    final size = MediaQuery.of(context).size;

    return InkWell(
      onTap: isUnlocked && quizPerguntas.isNotEmpty
          ? () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => QuizScreen(
                    perguntas: quizPerguntas,
                    disciplinaId: widget.disciplina.id,
                    capituloIndex: index + 1,
                    flashCards: _flashCardsPorQuiz[capitulo.quizId] ?? [],
                  ),
                ),
              );
              await _loadData();
            }
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isUnlocked ? 'Nenhuma pergunta disponível.' : 'Nível bloqueado! Completa o anterior com 80%+.'),
                  duration: const Duration(milliseconds: 800),
                ),
              );
            },
      child: Card(
        elevation: isUnlocked ? 4 : 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            gradient: LinearGradient(
              colors: isUnlocked
                  ? [Colors.blue.shade400, Colors.blue.shade800]
                  : [Colors.grey.shade300, Colors.grey.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              if (isUnlocked)
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: size.width * 0.12 > 48 ? 48 : size.width * 0.12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          capitulo.capitulo,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (starIndex) => Icon(
                          starIndex < estrelas ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: size.width * 0.04 > 18 ? 18 : size.width * 0.04,
                        )),
                      ),
                    ],
                  ),
                )
              else
                Stack(
                  children: [
                    // Nível no canto superior para evitar confusão com o cadeado central
                    Positioned(
                      top: 10,
                      left: 12,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    const Center(
                      child: Icon(Icons.lock_rounded, color: Colors.black26, size: 48),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10, left: 6, right: 6),
                        child: Text(
                          capitulo.capitulo,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withValues(alpha: 0.2),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final headerHeight = size.height * 0.3 > 250 ? 250.0 : size.height * 0.3;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.disciplina.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: BackgroundContainer(
        baseColor: widget.disciplina.categoria.toUpperCase() == 'CIÊNCIAS' ? Colors.green : Colors.blue,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Stack(
                    children: [
                      Hero(
                        tag: 'disciplina_bg_${widget.disciplina.id}',
                        child: SizedBox(height: headerHeight, width: double.infinity, child: SafeAssetImage(path: widget.disciplina.animacao, fit: BoxFit.cover)),
                      ),
                      Container(
                        height: headerHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent, Colors.blue.withValues(alpha: 0.8)],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20, left: 20, right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(fit: BoxFit.scaleDown, child: Text(widget.disciplina.nome, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))),
                            Text(widget.disciplina.descricao, style: const TextStyle(color: Colors.white70, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet ? 4 : 3, 
                        childAspectRatio: 0.9, 
                        crossAxisSpacing: 12, 
                        mainAxisSpacing: 12
                      ),
                      itemCount: _capitulos.length,
                      itemBuilder: (context, index) => _buildNivelCard(context, index),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
