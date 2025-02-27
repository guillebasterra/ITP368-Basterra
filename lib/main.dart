import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'labs-hw/quizzle/quiz_screen.dart';
import 'labs-hw/quizzle/quiz_bloc.dart';

void main() {
  runApp(const LabSelectorApp());
}

class LabSelectorApp extends StatelessWidget {
  const LabSelectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ITP 368 Labs',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LabSelectionScreen(),
    );
  }
}

class LabSelectionScreen extends StatelessWidget {
  const LabSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Lab')),
      body: ListView(
        children: [
          _buildLabButton(context, "Lab 1: Quizzle", const QuizScreen()),
        ],
      ),
    );
  }

  Widget _buildLabButton(BuildContext context, String label, Widget screen) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => QuizBloc()..add(LoadQuiz()), // Wrap QuizScreen with BlocProvider
                child: screen,
              ),
            ),
          );
        },
        child: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
