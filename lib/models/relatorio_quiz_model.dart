// lib/models/relatorio_quiz_model.dart

class RelatorioQuiz {
  final int pontuacaoAdquirida;
  final int totalPerguntas;
  final int acertos;
  final double percentagemAcertos;
  final int estrelas;
  final int pontosTotalUsuario;

  RelatorioQuiz({
    required this.pontuacaoAdquirida,
    required this.totalPerguntas,
    required this.acertos,
    required this.percentagemAcertos,
    required this.estrelas,
    required this.pontosTotalUsuario,
  });
}
