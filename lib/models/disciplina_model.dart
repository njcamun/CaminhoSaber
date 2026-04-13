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
      id: json['id'] as String,
      nome: json['nome'] as String,
      categoria: json['categoria'] as String,
      descricao: json['descricao'] as String,
      animacao: json['animacao'] as String,
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
      capitulo: json['capitulo'] as String,
      resumo: json['resumo'] as String? ?? 'Quiz sobre o tema.',
      quizId: json['id'] as String?,
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
