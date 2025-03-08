// file: deal_or_no_deal_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../deal_bloc.dart'; // import relative path
import 'instructions_box.dart';
import 'suitcase_grid.dart';
import 'values_list.dart';
import 'dealer_offer_section.dart';

class DealOrNoDealScreen extends StatefulWidget {
  const DealOrNoDealScreen({super.key});

  @override
  State<DealOrNoDealScreen> createState() => _DealOrNoDealScreenState();
}

class _DealOrNoDealScreenState extends State<DealOrNoDealScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Request focus for keyboard events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final keyLabel = event.logicalKey.keyLabel.toLowerCase();
      final bloc = context.read<DealBloc>();
      final state = bloc.state;

      if (keyLabel == 'd') {
        if (state.waitingForDealDecision && !state.gameOver) {
          bloc.add(AcceptDeal());
        }
      } else if (keyLabel == 'n') {
        if (state.waitingForDealDecision && !state.gameOver) {
          bloc.add(RejectDeal());
        }
      } else if ('0123456789'.contains(keyLabel)) {
        final index = (keyLabel == '0') ? 9 : int.parse(keyLabel) - 1;
        if (index < 0 || index >= 10) return;

        if (!state.gameOver) {
          if (state.playerSuitcase == null) {
            bloc.add(PickInitialSuitcase(index));
          } else {
            if (!state.waitingForDealDecision &&
                !state.revealed[index] &&
                index != state.playerSuitcase) {
              bloc.add(RevealSuitcase(index));
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: BlocBuilder<DealBloc, DealState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Deal or No Deal'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context.read<DealBloc>().add(ResetGame()),
                ),
              ],
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF000000), Color(0xFFFF8C00)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(child: _buildBody(context, state)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, DealState state) {
    if (!state.gameInProgress) {
      return _buildStartScreen(context);
    } else if (state.gameOver) {
      return _buildGameOverScreen(context, state);
    } else {
      return _buildGameLayout(context, state);
    }
  }

  Widget _buildStartScreen(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
        onPressed: () => context.read<DealBloc>().add(StartGame()),
        child: const Text('START GAME', style: TextStyle(fontSize: 20)),
      ),
    );
  }

  Widget _buildGameOverScreen(BuildContext context, DealState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'GAME OVER!\nYou won \$${state.finalWinnings.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            onPressed: () => context.read<DealBloc>().add(StartGame()),
            child: const Text('PLAY AGAIN', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildGameLayout(BuildContext context, DealState state) {
    return Column(
      children: [
        // Use your custom instructions widget
        const InstructionsBox(),

        Expanded(
          child: Row(
            children: [
              // Suitcase Grid
              Expanded(
                flex: 3,
                child: SuitcaseGrid(state: state),
              ),
              // Values List
              Expanded(
                flex: 2,
                child: ValuesList(state: state),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Dealer Offer + Buttons
        DealerOfferSection(state: state),
        const SizedBox(height: 12),
      ],
    );
  }
}
