// lib/ui/screens/meus_flashcards_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, HapticFeedback;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/database/database.dart';
import 'package:caminho_do_saber/services/flashcard_service.dart';
import 'package:caminho_do_saber/ui/screens/flash_card_screen.dart';
import 'package:caminho_do_saber/providers/profile_provider.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';
import 'package:caminho_do_saber/models/disciplina_model.dart' as model;
import 'package:caminho_do_saber/ui/widgets/neumorphic_wrapper.dart';
import 'package:caminho_do_saber/ui/widgets/scale_press_wrapper.dart';
import 'package:lottie/lottie.dart';

class MeusFlashcardsScreen extends StatefulWidget {
  const MeusFlashcardsScreen({super.key});

  @override
  State<MeusFlashcardsScreen> createState() => _MeusFlashcardsScreenState();
}

class _MeusFlashcardsScreenState extends State<MeusFlashcardsScreen> {
  late Future<List<UserFlashcard>> _flashcardsFuture;
  List<String> _categorias = ['OUTROS'];

  @override
  void initState() {
    super.initState();
    _loadCategorias();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshFlashcards();
  }

  Future<void> _loadCategorias() async {
    try {
      final String response = await rootBundle.loadString('assets/data/disciplinas.json');
      final List<dynamic> data = json.decode(response);
      final categorias = data.map((json) => json['categoria'] as String).toSet().toList();
      if (mounted) {
        setState(() {
          _categorias = [...categorias, 'OUTROS'];
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar categorias: $e');
    }
  }

  Future<void> _refreshFlashcards() async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final flashcardService = Provider.of<FlashcardService>(context, listen: false);
    final profileUid = profileProvider.activeProfile?.uid ?? '';
    setState(() {
      _flashcardsFuture = flashcardService.loadFlashcardsForProfile(profileUid);
    });
  }

  void _showCreateFlashcardDialog() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final perguntaController = TextEditingController();
    final respostaController = TextEditingController();
    String selectedCategoria = _categorias.first;
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                title: Row(
                  children: [
                    const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 28),
                    const SizedBox(width: 10),
                    Expanded(child: Text('NOVO FLASHCARD'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
                  ],
                ),
                content: Container(
                  width: size.width * 0.85 > 500 ? 500 : size.width * 0.85,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<String>(
                            value: selectedCategoria,
                            decoration: InputDecoration(
                              labelText: 'DISCIPLINA'.toUpperCase(),
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                              prefixIcon: const Icon(Icons.category_outlined),
                            ),
                            items: _categorias.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.toUpperCase()))).toList(),
                            onChanged: (val) => setStateDialog(() => selectedCategoria = val!),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: perguntaController,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              labelText: 'PERGUNTA'.toUpperCase(),
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              hintText: 'O QUE QUERES MEMORIZAR?',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                              prefixIcon: const Icon(Icons.help_outline),
                            ),
                            maxLines: 2,
                            validator: (value) => (value == null || value.isEmpty) ? 'ESCREVE UMA PERGUNTA.' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: respostaController,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              labelText: 'RESPOSTA'.toUpperCase(),
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              hintText: 'A RESPOSTA MÁGICA...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                              prefixIcon: const Icon(Icons.check_circle_outline),
                            ),
                            maxLines: 3,
                            validator: (value) => (value == null || value.isEmpty) ? 'ESCREVE A RESPOSTA.' : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text('CANCELAR'.toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w900)),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: Text('GUARDAR'.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
                        final flashcardService = Provider.of<FlashcardService>(context, listen: false);
                        
                        await flashcardService.addFlashcard(
                          pergunta: perguntaController.text.trim(),
                          resposta: respostaController.text.trim(),
                          profileUid: profileProvider.activeProfile?.uid ?? '',
                          parentUid: profileProvider.activeProfile?.parentUid ?? '',
                          disciplinaId: selectedCategoria,
                        );

                        if (mounted) {
                          Navigator.of(dialogContext).pop();
                          _refreshFlashcards();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('FLASHCARD CRIADO COM ALEGRIA!'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              );
            }
        );
      },
    );
  }

  void _showFlashcardOptions(UserFlashcard flashcard) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.play_circle_outline, color: AppColors.success)),
                title: Text('ESTUDAR ESTE CARTÃO'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                onTap: () {
                  Navigator.pop(context);
                  _estudarCartao(flashcard);
                },
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.edit_outlined, color: AppColors.primary)),
                title: Text('EDITAR ESTE CARTÃO'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                onTap: () {
                  Navigator.pop(context);
                  _showEditFlashcardDialog(flashcard);
                },
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.delete_outline, color: AppColors.error)),
                title: Text('REMOVER CARTÃO'.toUpperCase(), style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w900, fontSize: 13)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteFlashcard(flashcard);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditFlashcardDialog(UserFlashcard flashcard) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final perguntaController = TextEditingController(text: flashcard.pergunta);
    final respostaController = TextEditingController(text: flashcard.resposta);
    String selectedCategoria = flashcard.disciplinaId;
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
            builder: (context, setStateDialog) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                title: Row(
                  children: [
                    const Icon(Icons.edit_note, color: AppColors.accent, size: 28),
                    const SizedBox(width: 10),
                    Expanded(child: Text('EDITAR FLASHCARD'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
                  ],
                ),
                content: Container(
                  width: size.width * 0.85 > 500 ? 500 : size.width * 0.85,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<String>(
                            value: selectedCategoria,
                            decoration: InputDecoration(
                              labelText: 'DISCIPLINA'.toUpperCase(),
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            items: _categorias.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.toUpperCase()))).toList(),
                            onChanged: (val) => setStateDialog(() => selectedCategoria = val!),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: perguntaController,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              labelText: 'PERGUNTA'.toUpperCase(),
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            maxLines: 2,
                            validator: (value) => (value == null || value.isEmpty) ? 'ESCREVE UMA PERGUNTA.' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: respostaController,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              labelText: 'RESPOSTA'.toUpperCase(),
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                            maxLines: 3,
                            validator: (value) => (value == null || value.isEmpty) ? 'ESCREVE A RESPOSTA.' : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(child: Text('CANCELAR'.toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w900)), onPressed: () => Navigator.of(dialogContext).pop()),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: Text('ATUALIZAR'.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final flashcardService = Provider.of<FlashcardService>(context, listen: false);
                        
                        final updatedFlashcard = UserFlashcard(
                          id: flashcard.id,
                          pergunta: perguntaController.text.trim(),
                          resposta: respostaController.text.trim(),
                          profileUid: flashcard.profileUid,
                          parentUid: flashcard.parentUid,
                          disciplinaId: selectedCategoria,
                          dataCriacao: flashcard.dataCriacao,
                        );

                        try {
                          await flashcardService.updateFlashcard(updatedFlashcard);
                          if (mounted) {
                            Navigator.of(dialogContext).pop();
                            _refreshFlashcards();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('FLASHCARD ATUALIZADO!'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), backgroundColor: AppColors.primary),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ERRO: $e'.toUpperCase())));
                          }
                        }
                      }
                    },
                  ),
                ],
              );
            }
        );
      },
    );
  }

  void _estudarCartao(UserFlashcard flashcard) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => FlashCardScreen(
      titulo: 'MEU CARTÃO',
      flashCards: [model.FlashCard(pergunta: flashcard.pergunta, resposta: flashcard.resposta)],
    )));
  }

  void _estudarTodos(List<UserFlashcard> flashcards) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => FlashCardScreen(
      titulo: 'MEUS CARTÕES',
      flashCards: flashcards.map((f) => model.FlashCard(pergunta: f.pergunta, resposta: f.resposta)).toList(),
    )));
  }

  Future<void> _deleteFlashcard(UserFlashcard flashcard) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Row(
            children: [
              const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 28),
              const SizedBox(width: 10),
              Text('REMOVER CARTÃO?'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          content: Text('TENS A CERTEZA QUE QUERES APAGAR ESTE FLASHCARD? NÃO PODERÁS RECUPERÁ-LO.'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey)),
          actions: <Widget>[
            TextButton(child: Text('MANTER'.toUpperCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w900)), onPressed: () => Navigator.of(context).pop(false)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
              child: Text('REMOVER'.toUpperCase(), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirm) {
      try {
        final flashcardService = Provider.of<FlashcardService>(context, listen: false);
        await flashcardService.deleteFlashcard(flashcard.id);
        if (mounted) {
          _refreshFlashcards();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('CARTÃO REMOVIDO.'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), backgroundColor: AppColors.error),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ERRO: $e'.toUpperCase())));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MEUS CARTÕES'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: false,
      ),
      body: BackgroundContainer(
        child: SizedBox.expand(
          child: Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                return FutureBuilder<List<UserFlashcard>>(
                  future: _flashcardsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset('assets/animations/arcade.json', height: 150, repeat: true),
                              const SizedBox(height: 20),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'AINDA NÃO CRIASTE CARTÕES.\nCRIA O TEU PRIMEIRO PARA COMEÇAR!'.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final allCards = snapshot.data!;
                    final Map<String, List<UserFlashcard>> groupedCards = {};
                    for (var card in allCards) {
                      groupedCards.putIfAbsent(card.disciplinaId, () => []).add(card);
                    }

                    return Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ScalePressWrapper(
                                onTap: () => _estudarTodos(allCards),
                                child: NeumorphicWrapper(
                                  baseColor: Colors.white,
                                  borderRadius: 25,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.school_rounded, color: AppColors.primary, size: 28),
                                        const SizedBox(width: 15),
                                        Text('ESTUDAR TUDO AGORA'.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...groupedCards.entries.map((entry) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 30.0, bottom: 12.0, left: 8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            entry.key.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.primary,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(child: Divider(color: AppColors.primary.withValues(alpha: 0.2), thickness: 2)),
                                        ],
                                      ),
                                    ),
                                    ...entry.value.map((flashcard) => Padding(
                                      key: ValueKey('flashcard_${flashcard.id}'),
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: NeumorphicWrapper(
                                        baseColor: Colors.white,
                                        borderRadius: 25,
                                        child: InkWell(
                                          onTap: () => _estudarCartao(flashcard),
                                          onLongPress: () {
                                            HapticFeedback.heavyImpact();
                                            _showFlashcardOptions(flashcard);
                                          },
                                          borderRadius: BorderRadius.circular(25),
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                            title: Text(
                                              flashcard.pergunta.toUpperCase(),
                                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black87),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            subtitle: Text('PRESTA ATENÇÃO AO LONGO CLIQUE PARA OPÇÕES'.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                                            trailing: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                                              child: const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 24),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
          ),
        ),
      ),
      floatingActionButton: ScalePressWrapper(
        onTap: _showCreateFlashcardDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Text('NOVO CARTÃO'.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
