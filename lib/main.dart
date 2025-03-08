import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'labs-hw/quizzle/quiz_screen.dart';
import 'labs-hw/quizzle/quiz_bloc.dart';
import 'labs-hw/dealnodeal/views/deal_or_no_deal_screen.dart';
import 'labs-hw/dealnodeal/deal_bloc.dart';
//import 'labs-hw/dealnodeal/...

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
          _buildLabButton(
            context,
            "Quizzle",
            BlocProvider(
              create: (context) => QuizBloc()..add(LoadQuiz()),
              child: const QuizScreen(),
            ),
          ),
          _buildLabButton(
            context,
            "Deal or No Deal",
            BlocProvider(
              create: (context) => DealBloc(),
              child: const DealOrNoDealScreen(),
            ),
          ),
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
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
