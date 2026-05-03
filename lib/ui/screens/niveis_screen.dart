// lib/ui/screens/niveis_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:caminho_do_saber/models/disciplina_model.dart';
import 'package:caminho_do_saber/services/progresso_service.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/ui/screens/quiz_screen.dart';
import 'package:caminho_do_saber/ui/screens/capitulos_screen.dart';
import 'package:caminho_do_saber/ui/screens/conteudo_screen.dart';
import 'package:caminho_do_saber/services/disciplina_service.dart';
import 'package:caminho_do_saber/models/conteudo_disciplina_model.dart';
import 'package:caminho_do_saber/models/quiz_model.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';
import 'package:caminho_do_saber/ui/widgets/safe_asset_image.dart';
import 'package:caminho_do_saber/ui/widgets/neumorphic_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/scale_press_wrapper.dart';
import 'package:caminho_do_saber/services/content_provider_service.dart';
import 'package:caminho_do_saber/ui/widgets/edu_loading_widget.dart';

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

  Future<void> _loadData() async {
    try {
      await _loadQuizzes();
      await _loadProgresso();
    } catch (e) {
      if (kDebugMode) print('Erro ao carregar níveis: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadQuizzes() async {
    try {
      final contentProvider = context.read<ContentProviderService>();
      final String jsonString = await contentProvider.getContent('${widget.disciplina.id}.json');
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
      if (kDebugMode) print('Erro ao carregar dados da disciplina: $e');
    }
  }

  Future<void> _loadProgresso() async {
    try {
      final progresso = await _progressoService.getProgresso(widget.disciplina.id);
      if (mounted) setState(() => _progressoCapitulos = progresso);
    } catch (e) {
      if (mounted) setState(() => _progressoCapitulos = {});
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

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ScalePressWrapper(
        onTap: isUnlocked && quizPerguntas.isNotEmpty
            ? () async {
                if (pontuacao == 0) {
                  final bool? goDirect = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      title: Row(
                        children: [
                          const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 28),
                          const SizedBox(width: 10),
                          Expanded(child: Text('PREPARAÇÃO'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
                        ],
                      ),
                      content: Text(
                        'RECOMENDAMOS QUE FAÇAS A LEITURA DO CONTEÚDO ANTES DE COMEÇAR O QUIZ. LEMBRA-TE QUE TAMBÉM GANHAS PONTOS AO ESTUDAR AS LIÇÕES!'.toUpperCase(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('IR DIRETO'.toUpperCase(), style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w900)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('LER AGORA'.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
                        ),
                      ],
                    ),
                  );

                  if (goDirect == null) return;
                  if (!goDirect) {
                    if (!mounted) return;
                    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => CapitulosScreen(disciplina: widget.disciplina)));
                    return;
                  }
                }

                if (!mounted) return;
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      perguntas: quizPerguntas,
                      disciplinaId: widget.disciplina.id,
                      disciplina: widget.disciplina,
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
                    content: Text((isUnlocked ? 'NENHUMA PERGUNTA DISPONÍVEL.' : 'NÍVEL BLOQUEADO! COMPLETA O ANTERIOR COM 80%+ .').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
        child: NeumorphicWrapper(
          baseColor: Colors.white,
          borderRadius: 25,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                if (isUnlocked)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: size.width * 0.08,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          capitulo.capitulo.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (starIndex) => Icon(
                            starIndex < estrelas ? Icons.stars_rounded : Icons.star_outline_rounded,
                            color: starIndex < estrelas ? AppColors.accent : Colors.grey.withValues(alpha: 0.3),
                            size: 16,
                          )),
                        ),
                      ],
                    ),
                  )
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_rounded, color: Colors.grey.withValues(alpha: 0.5), size: 32),
                        const SizedBox(height: 4),
                        Text(
                          'NÍVEL ${index + 1}'.toUpperCase(),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.withValues(alpha: 0.5)),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final expandedHeaderHeight = size.height * 0.3 > 250 ? 250.0 : size.height * 0.3;

    return Scaffold(
      body: BackgroundContainer(
        child: _isLoading
            ? EduLoadingWidget(message: 'BAIXANDO NOVOS DESAFIOS...')
            : NestedScrollView(
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
                              tag: 'disciplina_bg_${widget.disciplina.id}',
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
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: innerBoxIsScrolled ? 0.0 : 1.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.disciplina.nome.toUpperCase(),
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    Text(
                                      widget.disciplina.descricao.toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF007A9E),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 4 : 3,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _capitulos.length,
                  itemBuilder: (context, index) => _buildNivelCard(context, index),
                ),
              ),
      ),
    );
  }
}
