// lib/models/flashcard_model.dart

class Flashcard {
  final String frente;
  final String verso;

  Flashcard({
    required this.frente,
    required this.verso,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      frente: json['frente'],
      verso: json['verso'],
    );
  }
}
