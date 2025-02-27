import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Reads quiz data from a file and parses it into a list of question-answer pairs
Future<List<Map<String, dynamic>>> loadQuizData() async {
  String fileContent = await rootBundle.loadString('assets/StateCapitols.txt');
  List<String> lines = LineSplitter.split(fileContent).toList();

  if (lines.length < 2) return [];

  List<Map<String, dynamic>> questions = [];
  List<String> allAnswers = [];

  for (var i = 1; i < lines.length; i++) {
    List<String> parts = lines[i].split(',');
    if (parts.length == 2) {
      allAnswers.add(parts[1]);
    }
  }

  for (var i = 1; i < lines.length; i++) {
    List<String> parts = lines[i].split(',');
    if (parts.length == 2) {
      String question = "What is the capital of ${parts[0]}?";
      String answer = parts[1];
      questions.add({
        'question': question,
        'answer': answer,
        'options': _generateOptions(answer, allAnswers)
      });
    }
  }
  return questions;
}

/// Generates exactly 4 options (1 correct, 3 random wrong)
List<String> _generateOptions(String correctAnswer, List<String> allAnswers) {
  List<String> options = [correctAnswer];
  allAnswers.shuffle();
  for (var ans in allAnswers) {
    if (options.length < 4 && ans != correctAnswer) {
      options.add(ans);
    }
  }
  while (options.length < 4) {
    options.add("Unknown"); // Just in case
  }
  options.shuffle();
  return options;
}
