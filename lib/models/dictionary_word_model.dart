// lib/models/dictionary_word_model.dart

class DictionaryWord {
  final String palavra;
  final String classe;
  final String significado;
  final String sinonimo;
  final String antonimo;
  final String exemplo;

  DictionaryWord({
    required this.palavra,
    required this.classe,
    required this.significado,
    required this.sinonimo,
    required this.antonimo,
    required this.exemplo,
  });

  factory DictionaryWord.fromJson(Map<String, dynamic> json) {
    return DictionaryWord(
      palavra: json['palavra'] ?? 'N/A',
      classe: json['classe'] ?? 'N/A',
      significado: json['significado'] ?? 'N/A',
      sinonimo: json['sinonimo'] ?? 'N/A',
      antonimo: json['antonimo'] ?? 'N/A',
      exemplo: json['exemplo'] ?? 'N/A',
    );
  }
}
