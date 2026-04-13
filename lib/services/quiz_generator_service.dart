// lib/services/quiz_generator_service.dart

import 'package:caminho_do_saber/models/quiz_model.dart';
import 'package:html/parser.dart' show parse;

class QuizGeneratorService {
  
  /// Gera uma lista de perguntas a partir de um texto em formato HTML
  List<PerguntaQuiz> generateQuizFromContent(String htmlContent, String chapterTitle) {
    List<PerguntaQuiz> generatedQuestions = [];
    final document = parse(htmlContent);
    
    // 1. Tentar gerar perguntas baseadas em definições (negritos <b>)
    final boldTerms = document.querySelectorAll('b');
    for (var term in boldTerms) {
      String word = term.text.trim();
      if (word.length > 3 && word.length < 20) {
        // Tenta encontrar o contexto ao redor (parágrafo pai)
        String definition = term.parent?.text ?? "";
        if (definition.contains(word) && definition.length > word.length + 10) {
          generatedQuestions.add(PerguntaQuiz(
            pergunta: "De acordo com o texto sobre $chapterTitle, o que define '$word'?",
            opcoes: _generateOptions(word, ["Uma regra", "Um exemplo", "Um sentimento", "Uma ação"]),
            respostaCorreta: _getCorrectDefinitionSnippet(word, definition),
            dica: "Presta atenção aos termos destacados no início do capítulo.",
          ));
        }
      }
    }

    // 2. Tentar gerar perguntas baseadas em listas (<li>)
    final listItems = document.querySelectorAll('li');
    if (listItems.length >= 4) {
      List<String> items = listItems.map((e) => e.text.split(':').first.trim()).toList();
      items.shuffle();
      
      generatedQuestions.add(PerguntaQuiz(
        pergunta: "Qual destes elementos foi mencionado como parte importante deste capítulo?",
        opcoes: [items[0], "Algo não relacionado", "Uma distração", "Nenhuma das anteriores"],
        respostaCorreta: items[0],
        dica: "Revê as listas de pontos importantes no conteúdo.",
      ));
    }

    // Limitar a 5 a 10 perguntas e baralhar
    generatedQuestions.shuffle();
    return generatedQuestions.take(10).toList();
  }

  List<String> _generateOptions(String correct, List<String> distractors) {
    List<String> options = [correct];
    distractors.shuffle();
    options.addAll(distractors.take(3));
    options.shuffle();
    return options;
  }

  String _getCorrectDefinitionSnippet(String word, String fullText) {
    // Lógica simples para pegar a frase onde a palavra aparece
    return fullText.split('.').firstWhere((s) => s.contains(word), orElse: () => fullText).trim();
  }
}
