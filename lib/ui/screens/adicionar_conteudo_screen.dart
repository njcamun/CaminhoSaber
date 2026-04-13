// lib/ui/screens/adicionar_conteudo_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      const SnackBar(content: Text('JSON da disciplina copiado para a área de transferência!')),
    );
  }

  void _showCreateConteudoDialog() {
    final formKey = GlobalKey<FormState>();
    final capituloController = TextEditingController();
    final resumoController = TextEditingController();
    final conteudoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Criar Novo Conteúdo'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: capituloController,
                    decoration: const InputDecoration(
                      labelText: 'Capítulo',
                      hintText: 'Ex: Nível 1 - Introdução',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: resumoController,
                    decoration: const InputDecoration(
                      labelText: 'Resumo',
                      hintText: 'Breve descrição.',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) => value!.isEmpty ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: conteudoController,
                    decoration: const InputDecoration(
                      labelText: 'Conteúdo (HTML/Texto)',
                      hintText: 'Podes usar tags HTML como <p>, <strong>...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 8,
                    validator: (value) => value!.isEmpty ? 'Obrigatório' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Exportar Apenas Este'),
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item copiado como JSON!')));
                }
              },
            ),
            ElevatedButton(
              child: const Text('Guardar'),
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
                leading: const Icon(Icons.copy_rounded),
                title: const Text('Copiar JSON'),
                onTap: () {
                  Navigator.of(context).pop();
                  Clipboard.setData(ClipboardData(text: const JsonEncoder.withIndent('  ').convert(conteudo.toJson())));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('JSON do capítulo copiado!')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showEditConteudoDialog(conteudo);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remover'),
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
    final formKey = GlobalKey<FormState>();
    final capituloController = TextEditingController(text: conteudo.capitulo);
    final resumoController = TextEditingController(text: conteudo.resumo);
    final conteudoController = TextEditingController(text: conteudo.conteudo);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Editar Conteúdo'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: capituloController, decoration: const InputDecoration(labelText: 'Capítulo', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  TextFormField(controller: resumoController, decoration: const InputDecoration(labelText: 'Resumo', border: OutlineInputBorder()), maxLines: 2),
                  const SizedBox(height: 16),
                  TextFormField(controller: conteudoController, decoration: const InputDecoration(labelText: 'Conteúdo', border: OutlineInputBorder()), maxLines: 5),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(dialogContext).pop()),
            ElevatedButton(
              child: const Text('Atualizar'),
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
        title: Text('${widget.disciplina.nome} (JSON Admin)'),
        backgroundColor: Colors.blueGrey.shade800,
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
              ? const Center(child: Text('Nenhum capítulo. Usa o + para criar.', style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  itemCount: _disciplina.capitulos.length,
                  itemBuilder: (context, index) {
                    final item = _disciplina.capitulos[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.white.withOpacity(0.9),
                      child: ListTile(
                        title: Text(item.capitulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(item.resumo, maxLines: 1, overflow: TextOverflow.ellipsis),
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
        backgroundColor: Colors.blueGrey.shade800,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
