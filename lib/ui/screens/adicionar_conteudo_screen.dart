// lib/ui/screens/adicionar_conteudo_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';
import 'package:caminho_do_saber/ui/widgets/background_container.dart';
import 'package:caminho_do_saber/services/disciplina_file_service.dart';
import 'package:uuid/uuid.dart';

class AdicionarConteudoScreen extends StatefulWidget {
  final UserDisciplina disciplina;

  const AdicionarConteudoScreen({
    super.key,
    required this.disciplina,
  });

  @override
  State<AdicionarConteudoScreen> createState() => _AdicionarConteudoScreenState();
}

class _AdicionarConteudoScreenState extends State<AdicionarConteudoScreen> {
  final _disciplinaService = DisciplinaFileService();
  final _uuid = const Uuid();
  late UserDisciplina _disciplina;

  @override
  void initState() {
    super.initState();
    _disciplina = widget.disciplina;
  }

  // MÉTODO PARA COPIAR TODO O JSON DA DISCIPLINA ATUAL
  void _copyCompleteJson() {
    final jsonString = const JsonEncoder.withIndent('  ').convert(_disciplina.toJson());
    Clipboard.setData(ClipboardData(text: jsonString));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('JSON DA DISCIPLINA COPIADO!'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }

  void _showCreateConteudoDialog() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final capituloController = TextEditingController();
    final resumoController = TextEditingController();
    final conteudoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Row(
            children: [
              const Icon(Icons.add_box_rounded, color: AppColors.primary, size: 28),
              const SizedBox(width: 10),
              Text('CRIAR NOVO CONTEÚDO'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: capituloController,
                    decoration: InputDecoration(
                      labelText: 'CAPÍTULO'.toUpperCase(),
                      hintText: 'Ex: Nível 1 - Introdução'.toUpperCase(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    validator: (value) => value!.isEmpty ? 'OBRIGATÓRIO' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: resumoController,
                    decoration: InputDecoration(
                      labelText: 'RESUMO'.toUpperCase(),
                      hintText: 'Breve descrição.'.toUpperCase(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    maxLines: 2,
                    validator: (value) => value!.isEmpty ? 'OBRIGATÓRIO' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: conteudoController,
                    decoration: InputDecoration(
                      labelText: 'CONTEÚDO (HTML/TEXTO)'.toUpperCase(),
                      hintText: 'Podes usar tags HTML como <p>, <strong>...'.toUpperCase(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    maxLines: 8,
                    validator: (value) => value!.isEmpty ? 'OBRIGATÓRIO' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('EXPORTAR APENAS ESTE', style: TextStyle(fontWeight: FontWeight.w600)),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final item = {
                    'id': _uuid.v4(),
                    'capitulo': capituloController.text,
                    'resumo': resumoController.text,
                    'conteudo': conteudoController.text,
                  };
                  Clipboard.setData(ClipboardData(text: const JsonEncoder.withIndent('  ').convert(item)));
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ITEM COPIADO COMO JSON!'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600)),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                  );
                }
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: Text('GUARDAR', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final novoConteudo = UserCapitulo(
                    id: _uuid.v4(),
                    capitulo: capituloController.text,
                    resumo: resumoController.text,
                    conteudo: conteudoController.text,
                  );

                  try {
                    await _disciplinaService.addConteudoToDisciplina(widget.disciplina.id, novoConteudo);
                    if (mounted) {
                      setState(() => _disciplina.capitulos.add(novoConteudo));
                      Navigator.of(dialogContext).pop();
                    }
                  } catch (e) {
                    debugPrint('Erro: $e');
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showConteudoOptions(BuildContext context, UserCapitulo conteudo) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: AppColors.primary),
                title: Text('COPIAR JSON'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.of(context).pop();
                  Clipboard.setData(ClipboardData(text: const JsonEncoder.withIndent('  ').convert(conteudo.toJson())));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('JSON DO CAPÍTULO COPIADO!'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600)),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: Text('EDITAR'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.of(context).pop();
                  _showEditConteudoDialog(conteudo);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: Text('REMOVER'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.error)),
                onTap: () {
                  Navigator.of(context).pop();
                  _deleteConteudo(conteudo);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Métodos de edição e remoção mantidos conforme original...
  void _showEditConteudoDialog(UserCapitulo conteudo) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final capituloController = TextEditingController(text: conteudo.capitulo);
    final resumoController = TextEditingController(text: conteudo.resumo);
    final conteudoController = TextEditingController(text: conteudo.conteudo);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Row(
            children: [
              const Icon(Icons.edit_document, color: AppColors.primary, size: 28),
              const SizedBox(width: 10),
              Text('EDITAR CONTEÚDO'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: capituloController,
                    decoration: InputDecoration(
                      labelText: 'CAPÍTULO'.toUpperCase(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: resumoController,
                    decoration: InputDecoration(
                      labelText: 'RESUMO'.toUpperCase(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: conteudoController,
                    decoration: InputDecoration(
                      labelText: 'CONTEÚDO'.toUpperCase(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    maxLines: 5,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(child: const Text('CANCELAR', style: TextStyle(fontWeight: FontWeight.w600)), onPressed: () => Navigator.of(dialogContext).pop()),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('ATUALIZAR', style: TextStyle(fontWeight: FontWeight.w600)),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final updated = UserCapitulo(id: conteudo.id, capitulo: capituloController.text, resumo: resumoController.text, conteudo: conteudoController.text);
                  await _disciplinaService.updateConteudoInDisciplina(widget.disciplina.id, updated);
                  if (mounted) {
                    setState(() {
                      final idx = _disciplina.capitulos.indexWhere((c) => c.id == updated.id);
                      if (idx != -1) _disciplina.capitulos[idx] = updated;
                    });
                    Navigator.of(dialogContext).pop();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteConteudo(UserCapitulo conteudo) async {
    await _disciplinaService.deleteConteudoFromDisciplina(widget.disciplina.id, conteudo.id);
    if (mounted) setState(() => _disciplina.capitulos.removeWhere((c) => c.id == conteudo.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.disciplina.nome.toUpperCase()} (JSON ADMIN)', style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.code_rounded),
            tooltip: 'Copiar JSON Completo',
            onPressed: _copyCompleteJson,
          ),
        ],
      ),
      body: BackgroundContainer(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _disciplina.capitulos.isEmpty
              ? const Center(child: Text('NENHUM CAPÍTULO. USA O + PARA CRIAR.', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)))
              : ListView.builder(
                  itemCount: _disciplina.capitulos.length,
                  itemBuilder: (context, index) {
                    final item = _disciplina.capitulos[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.white.withValues(alpha: 0.95),
                      elevation: 4,
                      shadowColor: Colors.black.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      child: ListTile(
                        title: Text(item.capitulo.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        subtitle: Text(item.resumo, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.blueGrey)),
                        trailing: const Icon(Icons.settings_ethernet_rounded),
                        onTap: () => _showConteudoOptions(context, item),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateConteudoDialog,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
