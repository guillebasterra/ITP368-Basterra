// file: values_list.dart
import 'package:flutter/material.dart';
import '../deal_bloc.dart';

class ValuesList extends StatelessWidget {
  final DealState state;
  const ValuesList({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final amounts = state.allValues;
    return Container(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: amounts.map((value) {
          final isRevealed = _isAmountRevealed(value);
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            decoration: BoxDecoration(
              color: isRevealed ? Colors.grey.shade400 : Colors.yellow,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '\$${value.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                decoration: isRevealed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _isAmountRevealed(double value) {
    for (int i = 0; i < state.assignedValues.length; i++) {
      if (state.assignedValues[i] == value && state.revealed[i]) {
        return true;
      }
    }
    return false;
  }
}
