// file: instructions_box.dart
import 'package:flutter/material.dart';

class InstructionsBox extends StatelessWidget {
  const InstructionsBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(77), // ~30% black
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Pick 1 suitcase, open others 1 at a time.\n'
            'After each reveal, Dealer offers an amount.\n'
            'DEAL or NO DEAL. If only your case is left & you reject, game ends.\n'
            '[Keyboard: 1..0 to pick/reveal, D=Deal, N=NoDeal]',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
