import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'quiz_bloc.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quizzle - State Capitals')),
      body: BlocBuilder<QuizBloc, QuizState>(
        builder: (context, state) {
          if (state.questions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentQuestion = state.questions[state.currentQuestionIndex];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            color: state.showFeedback
                ? (state.isCorrect ? Colors.greenAccent.shade200 : Colors.redAccent.shade200)
                : Colors.white,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Question ${state.currentQuestionIndex + 1} / ${state.questions.length}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentQuestion['question'],
                      style: const TextStyle(fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    ...currentQuestion['options'].map<Widget>((option) {
                      bool isCorrectAnswer = option == currentQuestion['answer'];
                      bool isSelected = state.showFeedback;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? (isCorrectAnswer ? Colors.green : Colors.red)
                                : Colors.blue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          ),
                          onPressed: isSelected
                              ? null
                              : () {
                            context.read<QuizBloc>().add(AnswerQuestion(option));

                            // Flash screen and auto-advance after 1 second
                            Future.delayed(const Duration(milliseconds: 1000), () {
                              context.read<QuizBloc>().add(NextQuestion());
                            });
                          },
                          child: Text(option, style: const TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 20),
                    Text(
                      "Score: ${state.score} / ${state.currentQuestionIndex + 1}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
