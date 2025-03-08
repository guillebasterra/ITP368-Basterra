// file: suitcase_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../deal_bloc.dart';

class SuitcaseGrid extends StatelessWidget {
  final DealState state;

  const SuitcaseGrid({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // 2 rows x 5 columns
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.assignedValues.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisExtent: 80,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return _buildSuitcaseButton(context, index);
      },
    );
  }

  Widget _buildSuitcaseButton(BuildContext context, int index) {
    final bloc = context.read<DealBloc>();
    final isHeld = (index == state.playerSuitcase);
    final isRevealed = state.revealed[index];

    return GestureDetector(
      onTap: () {
        if (!state.gameOver) {
          if (state.playerSuitcase == null) {
            // pick your suitcase
            bloc.add(PickInitialSuitcase(index));
          } else {
            // reveal if allowed
            if (!state.waitingForDealDecision && !isRevealed && !isHeld) {
              bloc.add(RevealSuitcase(index));
            }
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isHeld
              ? Colors.orange
              : (isRevealed ? Colors.grey.shade300 : Colors.white),
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            isHeld
                ? 'YOUR\nCASE'
                : 'Case ${index + 1}'
                '${isRevealed ? "\n\$${state.assignedValues[index]!.toStringAsFixed(0)}" : ""}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isHeld ? 14 : 13,
              fontWeight: isHeld ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
