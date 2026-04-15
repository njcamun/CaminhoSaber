// lib/models/disciplina_model.dart

class Disciplina {
  final String id;
  final String nome;
  final String categoria;
  final String descricao;
  final String animacao;
  final List<Capitulo>? capitulos;

  Disciplina({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.descricao,
    required this.animacao,
    this.capitulos,
  });

  factory Disciplina.fromJson(Map<String, dynamic> json) {
    var capitulosFromJson = json['quizzes'] as List?;
    List<Capitulo>? capituloList = capitulosFromJson?.map((i) => Capitulo.fromJson(i)).toList();

    return Disciplina(
      id: (json['id'] ?? '').toString(),
      nome: (json['nome'] ?? 'Sem Nome').toString(),
      categoria: (json['categoria'] ?? 'OUTROS').toString(),
      descricao: (json['descricao'] ?? '').toString(),
      animacao: (json['animacao'] ?? 'assets/images/default.png').toString(),
      capitulos: capituloList,
    );
  }
}

class Capitulo {
  final String capitulo;
  final String resumo;
  final String? quizId;

  Capitulo({
    required this.capitulo,
    required this.resumo,
    this.quizId,
  });

  factory Capitulo.fromJson(Map<String, dynamic> json) {
    return Capitulo(
      capitulo: (json['capitulo'] ?? 'Capítulo').toString(),
      resumo: (json['resumo'] ?? 'Quiz sobre o tema.').toString(),
      quizId: json['id']?.toString(),
    );
  }
}

class FlashCard {
  final String pergunta;
  final String resposta;

  FlashCard({
    required this.pergunta,
    required this.resposta,
  });
}
