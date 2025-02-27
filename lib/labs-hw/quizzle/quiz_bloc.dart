import 'package:flutter_bloc/flutter_bloc.dart';
import 'quiz_loader.dart';

/// Events
abstract class QuizEvent {}

class LoadQuiz extends QuizEvent {}

class AnswerQuestion extends QuizEvent {
  final String selectedAnswer;
  AnswerQuestion(this.selectedAnswer);
}

class NextQuestion extends QuizEvent {}

/// State
class QuizState {
  final List<Map<String, dynamic>> questions;
  final int currentQuestionIndex;
  final int score;
  final bool showFeedback;
  final bool isCorrect;

  QuizState({
    required this.questions,
    this.currentQuestionIndex = 0,
    this.score = 0,
    this.showFeedback = false,
    this.isCorrect = false,
  });

  QuizState copyWith({
    List<Map<String, dynamic>>? questions,
    int? currentQuestionIndex,
    int? score,
    bool? showFeedback,
    bool? isCorrect,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      showFeedback: showFeedback ?? this.showFeedback,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}

/// BLoC Logic
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc() : super(QuizState(questions: [])) {
    on<LoadQuiz>((event, emit) async {
      List<Map<String, dynamic>> questions = await loadQuizData();
      emit(state.copyWith(questions: questions, currentQuestionIndex: 0, score: 0));
    });

    on<AnswerQuestion>((event, emit) {
      bool isCorrect = state.questions[state.currentQuestionIndex]['answer'] == event.selectedAnswer;
      emit(state.copyWith(
        isCorrect: isCorrect,
        score: isCorrect ? state.score + 1 : state.score,
        showFeedback: true,
      ));
    });

    on<NextQuestion>((event, emit) {
      if (state.currentQuestionIndex < state.questions.length - 1) {
        emit(state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1, showFeedback: false));
      }
    });
  }
}
