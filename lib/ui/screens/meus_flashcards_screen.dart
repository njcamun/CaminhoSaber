// lib/ui/screens/meus_flashcards_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/database/database.dart';
import 'package:caminho_do_saber/services/flashcard_service.dart';
import 'package:caminho_do_saber/ui/screens/flash_card_screen.dart';
import 'package:caminho_do_saber/providers/profile_provider.dart';
import 'package:caminho_do_saber/models/disciplina_model.dart' as model;

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
    final formKey = GlobalKey<FormState>();
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
                title: const Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('Novo Flashcard', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            initialValue: selectedCategoria,
                            decoration: InputDecoration(
                              labelText: 'Disciplina',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              prefixIcon: const Icon(Icons.category_outlined),
                            ),
                            items: _categorias.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                            onChanged: (val) => setStateDialog(() => selectedCategoria = val!),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: perguntaController,
                            decoration: InputDecoration(
                              labelText: 'Pergunta',
                              hintText: 'O que queres memorizar?',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              prefixIcon: const Icon(Icons.help_outline),
                            ),
                            maxLines: 2,
                            validator: (value) => (value == null || value.isEmpty) ? 'Escreve uma pergunta.' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: respostaController,
                            decoration: InputDecoration(
                              labelText: 'Resposta',
                              hintText: 'A resposta mágica...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              prefixIcon: const Icon(Icons.check_circle_outline),
                            ),
                            maxLines: 3,
                            validator: (value) => (value == null || value.isEmpty) ? 'Escreve a resposta.' : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
                        final flashcardService = Provider.of<FlashcardService>(context, listen: false);
                        
                        await flashcardService.addFlashcard(
                          pergunta: perguntaController.text,
                          resposta: respostaController.text,
                          profileUid: profileProvider.activeProfile?.uid ?? '',
                          parentUid: profileProvider.activeProfile?.parentUid ?? '',
                          disciplinaId: selectedCategoria,
                        );

                        if (mounted) {
                          Navigator.of(dialogContext).pop();
                          _refreshFlashcards();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Flashcard criado com alegria!'), behavior: SnackBarBehavior.floating),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.play_circle_outline, color: Colors.green),
                title: const Text('Estudar este cartão'),
                onTap: () {
                  Navigator.pop(context);
                  _estudarCartao(flashcard);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.blue),
                title: const Text('Editar este cartão'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditFlashcardDialog(flashcard);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remover cartão', style: TextStyle(color: Colors.red)),
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
    final formKey = GlobalKey<FormState>();
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
                title: const Row(
                  children: [
                    Icon(Icons.edit_note, color: Colors.orange),
                    SizedBox(width: 10),
                    Text('Editar Flashcard', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            initialValue: selectedCategoria,
                            decoration: InputDecoration(
                              labelText: 'Disciplina',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            items: _categorias.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                            onChanged: (val) => setStateDialog(() => selectedCategoria = val!),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: perguntaController,
                            decoration: InputDecoration(
                              labelText: 'Pergunta',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            maxLines: 2,
                            validator: (value) => (value == null || value.isEmpty) ? 'Escreve uma pergunta.' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: respostaController,
                            decoration: InputDecoration(
                              labelText: 'Resposta',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            maxLines: 3,
                            validator: (value) => (value == null || value.isEmpty) ? 'Escreve a resposta.' : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(child: const Text('Cancelar', style: TextStyle(color: Colors.grey)), onPressed: () => Navigator.of(dialogContext).pop()),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Atualizar'),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final flashcardService = Provider.of<FlashcardService>(context, listen: false);
                        
                        final updatedFlashcard = UserFlashcard(
                          id: flashcard.id,
                          pergunta: perguntaController.text,
                          resposta: respostaController.text,
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
                              const SnackBar(content: Text('Flashcard atualizado!'), behavior: SnackBarBehavior.floating),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), behavior: SnackBarBehavior.floating));
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
      titulo: 'Meu Cartão',
      flashCards: [model.FlashCard(pergunta: flashcard.pergunta, resposta: flashcard.resposta)],
    )));
  }

  void _estudarTodos(List<UserFlashcard> flashcards) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => FlashCardScreen(
      titulo: 'Meus Cartões',
      flashCards: flashcards.map((f) => model.FlashCard(pergunta: f.pergunta, resposta: f.resposta)).toList(),
    )));
  }

  Future<void> _deleteFlashcard(UserFlashcard flashcard) async {
    final bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: const Text('Remover Cartão?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Tens a certeza que queres apagar este flashcard? Não poderás recuperá-lo.'),
          actions: <Widget>[
            TextButton(child: const Text('Manter', style: TextStyle(color: Colors.grey)), onPressed: () => Navigator.of(context).pop(false)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Remover'),
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
            const SnackBar(content: Text('Cartão removido.'), behavior: SnackBarBehavior.floating),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), behavior: SnackBarBehavior.floating));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Cartões', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
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
                              Icon(Icons.style_outlined, size: 80, color: Colors.white.withOpacity(0.5)),
                              const SizedBox(height: 20),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: const Text(
                                  'Ainda não criaste cartões para este perfil.\nCria o teu primeiro para começar!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w500),
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
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _estudarTodos(allCards),
                                icon: const Icon(Icons.school_rounded),
                                label: const Text('Estudar Tudo deste Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.9),
                                  foregroundColor: Colors.blue.shade800,
                                  minimumSize: const Size(double.infinity, 55),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  elevation: 4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...groupedCards.entries.map((entry) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0, left: 4.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            entry.key.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Expanded(child: Divider(color: Colors.white24, thickness: 1.5)),
                                        ],
                                      ),
                                    ),
                                    ...entry.value.map((flashcard) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: Card(
                                        elevation: 4,
                                        shadowColor: Colors.black26,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        color: Colors.white.withOpacity(0.95),
                                        child: InkWell(
                                          onTap: () => _estudarCartao(flashcard),
                                          onLongPress: () => _showFlashcardOptions(flashcard),
                                          borderRadius: BorderRadius.circular(20),
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                            title: Text(
                                              flashcard.pergunta,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            trailing: const Icon(Icons.play_circle_fill, color: Colors.blueAccent, size: 30),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateFlashcardDialog,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo Cartão', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
