// file: dealer_offer_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../deal_bloc.dart';

class DealerOfferSection extends StatelessWidget {
  final DealState state;
  const DealerOfferSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final dealerOffer = state.currentOffer;
    final showButtons = state.waitingForDealDecision && !state.gameOver;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(77),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Dealer\'s Offer: \$${dealerOffer.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showButtons) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () =>
                      context.read<DealBloc>().add(AcceptDeal()),
                  child: const Text('DEAL', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () =>
                      context.read<DealBloc>().add(RejectDeal()),
                  child: const Text('NO DEAL', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
