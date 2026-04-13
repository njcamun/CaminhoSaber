// lib/models/conteudo_disciplina_model.dart

class ConteudoCapitulo {
  final String id;
  final String titulo;
  final String resumo;
  final String conteudo;
  final String? quizId; // Opcional, para futuros quizzes

  ConteudoCapitulo({
    required this.id,
    required this.titulo,
    required this.resumo,
    required this.conteudo,
    this.quizId,
  });

  factory ConteudoCapitulo.fromJson(Map<String, dynamic> json) {
    return ConteudoCapitulo(
      id: json['id'] as String,
      titulo: json['capitulo'] as String,
      resumo: json['resumo'] as String,
      conteudo: json['conteudo'] as String,
      quizId: json['quizId'] as String?,
    );
  }
}
