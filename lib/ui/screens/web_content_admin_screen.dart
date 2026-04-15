// lib/ui/screens/web_content_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:caminho_do_saber/services/web_admin_service.dart';
import 'package:uuid/uuid.dart';

class WebContentAdminScreen extends StatefulWidget {
  const WebContentAdminScreen({super.key});

  @override
  State<WebContentAdminScreen> createState() => _WebContentAdminScreenState();
}

class _WebContentAdminScreenState extends State<WebContentAdminScreen> {
  String _disciplinaId = 'nova_disciplina';
  String _disciplinaNome = 'Nova Disciplina';
  final List<Map<String, dynamic>> _capitulos = [];

  void _addCapitulo() {
    setState(() {
      _capitulos.add({
        'id': 'nivel_${_capitulos.length + 1}',
        'capitulo': 'Nível ${_capitulos.length + 1}: ',
        'resumo': '',
        'conteudo': '',
      });
    });
  }

  void _saveJson() {
    final Map<String, dynamic> fullData = {
      'disciplina': _disciplinaNome,
      'capitulos': _capitulos,
    };
    WebAdminService.downloadJson(fullData, '${_disciplinaId}_conteudo.json');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Fábrica de Conteúdo Web - Caminho do Saber'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          ElevatedButton.icon(
            onPressed: _saveJson,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Descarregar JSON'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Row(
        children: [
          // BARRA LATERAL: Configurações da Disciplina
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DADOS DA DISCIPLINA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 20),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'ID do Arquivo',
                    hintText: 'Ex: gramatica',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => _disciplinaId = v,
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Nome da Disciplina',
                    hintText: 'Ex: Português - Gramática',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _disciplinaNome = v),
                ),
                const Divider(height: 60),
                const Text('INSTRUÇÕES:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('1. Preenche os dados à direita.\n2. Podes usar HTML (<p>, <strong>).\n3. Clica em Descarregar JSON.\n4. Move o arquivo para assets/data/.', style: TextStyle(fontSize: 13, height: 1.5)),
                const Spacer(),
                Text('Total de Capítulos: ${_capitulos.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
          ),
          // ÁREA PRINCIPAL: Editor de Capítulos
          Expanded(
            child: Container(
              color: Colors.grey.shade200,
              child: _capitulos.isEmpty 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.library_books_rounded, size: 100, color: Colors.grey.shade400),
                        const SizedBox(height: 20),
                        const Text('Nenhum capítulo adicionado.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        const SizedBox(height: 10),
                        ElevatedButton(onPressed: _addCapitulo, child: const Text('Adicionar Primeiro Capítulo')),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(40),
                    itemCount: _capitulos.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 40),
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.indigo,
                                    child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: _capitulos[index]['capitulo'],
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      decoration: const InputDecoration(labelText: 'Título do Nível/Capítulo'),
                                      onChanged: (v) => _capitulos[index]['capitulo'] = v,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                                    onPressed: () => setState(() => _capitulos.removeAt(index)),
                                  )
                                ],
                              ),
                              const SizedBox(height: 25),
                              TextFormField(
                                initialValue: _capitulos[index]['resumo'],
                                decoration: const InputDecoration(
                                  labelText: 'Resumo Curto (Aparece na lista de níveis)',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (v) => _capitulos[index]['resumo'] = v,
                              ),
                              const SizedBox(height: 25),
                              TextFormField(
                                initialValue: _capitulos[index]['conteudo'],
                                maxLines: 12,
                                decoration: const InputDecoration(
                                  labelText: 'Conteúdo da Aula (Texto ou HTML)',
                                  hintText: 'Podes colar textos longos aqui...',
                                  border: OutlineInputBorder(),
                                  alignLabelWithHint: true,
                                ),
                                onChanged: (v) => _capitulos[index]['conteudo'] = v,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: _capitulos.isNotEmpty 
        ? FloatingActionButton.extended(
            onPressed: _addCapitulo,
            label: const Text('Adicionar Novo Capítulo'),
            icon: const Icon(Icons.add),
            backgroundColor: Colors.indigo,
          )
        : null,
    );
  }
}
