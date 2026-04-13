// lib/models/quiz_model.dart

class PerguntaQuiz {
  final String pergunta;
  final List<String> opcoes;
  final String respostaCorreta;
  final String? dica; // Adiciona o campo 'dica' aqui

  PerguntaQuiz({
    required this.pergunta,
    required this.opcoes,
    required this.respostaCorreta,
    this.dica, // Adiciona o campo 'dica' ao construtor
  });

  factory PerguntaQuiz.fromJson(Map<String, dynamic> json) {
    return PerguntaQuiz(
      pergunta: json['pergunta'] as String,
      opcoes: List<String>.from(json['opcoes'] as List),
      respostaCorreta: json['respostaCorreta'] as String,
      dica: json['dica'] as String?, // Mapeia o campo 'dica' do JSON
    );
  }
}
