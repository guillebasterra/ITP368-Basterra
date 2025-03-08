import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

//
// Events
//
abstract class DealEvent {}

class LoadGame extends DealEvent {}
class StartGame extends DealEvent {}
class PickInitialSuitcase extends DealEvent {
  final int suitcaseIndex;
  PickInitialSuitcase(this.suitcaseIndex);
}
class RevealSuitcase extends DealEvent {
  final int suitcaseIndex;
  RevealSuitcase(this.suitcaseIndex);
}
class AcceptDeal extends DealEvent {}
class RejectDeal extends DealEvent {}
class ResetGame extends DealEvent {}

//
// State
//
class DealState {
  final List<double> allValues;         // Possible amounts [1,5,10,100, ...]
  final List<double?> assignedValues;   // assignedValues[i] = hidden amount in suitcase i
  final bool gameInProgress;
  final int? playerSuitcase;           // Index of player's chosen suitcase
  final List<bool> revealed;           // Which suitcases have been opened
  final double currentOffer;           // Dealer's current offer
  final bool waitingForDealDecision;   // Are we waiting for user to accept/reject?
  final bool gameOver;
  final double finalWinnings;          // The final money the player ends up with
  final double? finalCaseValue;        // The actual value that was in the player's suitcase

  DealState({
    required this.allValues,
    required this.assignedValues,
    required this.gameInProgress,
    required this.playerSuitcase,
    required this.revealed,
    required this.currentOffer,
    required this.waitingForDealDecision,
    required this.gameOver,
    required this.finalWinnings,
    required this.finalCaseValue,
  });

  DealState copyWith({
    List<double>? allValues,
    List<double?>? assignedValues,
    bool? gameInProgress,
    int? playerSuitcase,
    List<bool>? revealed,
    double? currentOffer,
    bool? waitingForDealDecision,
    bool? gameOver,
    double? finalWinnings,
    double? finalCaseValue,
  }) {
    return DealState(
      allValues: allValues ?? this.allValues,
      assignedValues: assignedValues ?? this.assignedValues,
      gameInProgress: gameInProgress ?? this.gameInProgress,
      playerSuitcase: playerSuitcase ?? this.playerSuitcase,
      revealed: revealed ?? this.revealed,
      currentOffer: currentOffer ?? this.currentOffer,
      waitingForDealDecision:
      waitingForDealDecision ?? this.waitingForDealDecision,
      gameOver: gameOver ?? this.gameOver,
      finalWinnings: finalWinnings ?? this.finalWinnings,
      finalCaseValue: finalCaseValue ?? this.finalCaseValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignedValues': assignedValues.map((v) => v?.toString()).toList(),
      'gameInProgress': gameInProgress,
      'playerSuitcase': playerSuitcase,
      'revealed': revealed,
      'currentOffer': currentOffer,
      'waitingForDealDecision': waitingForDealDecision,
      'gameOver': gameOver,
      'finalWinnings': finalWinnings,
      'finalCaseValue': finalCaseValue?.toString(),
    };
  }

  factory DealState.fromJson(Map<String, dynamic> json) {
    // The allValues list is fixed:
    final fixedAllValues = const [
      1.0, 5.0, 10.0, 100.0, 1000.0,
      5000.0, 10000.0, 100000.0, 500000.0, 1000000.0,
    ];

    return DealState(
      allValues: fixedAllValues,
      assignedValues: (json['assignedValues'] as List<dynamic>)
          .map<double?>((v) => v == null ? null : double.tryParse(v))
          .toList(),
      gameInProgress: json['gameInProgress'] as bool,
      playerSuitcase: json['playerSuitcase'] as int?,
      revealed:
      (json['revealed'] as List<dynamic>).map((e) => e as bool).toList(),
      currentOffer: (json['currentOffer'] as num).toDouble(),
      waitingForDealDecision: json['waitingForDealDecision'] as bool,
      gameOver: json['gameOver'] as bool,
      finalWinnings: (json['finalWinnings'] as num).toDouble(),
      finalCaseValue: json['finalCaseValue'] == null
          ? null
          : double.tryParse(json['finalCaseValue']),
    );
  }
}

//
// BLoC
//
class DealBloc extends Bloc<DealEvent, DealState> {
  DealBloc()
      : super(
    DealState(
      allValues: const [
        1.0, 5.0, 10.0, 100.0, 1000.0,
        5000.0, 10000.0, 100000.0, 500000.0, 1000000.0,
      ],
      assignedValues: List.filled(10, null),
      gameInProgress: false,
      playerSuitcase: null,
      revealed: List.filled(10, false),
      currentOffer: 0,
      waitingForDealDecision: false,
      gameOver: false,
      finalWinnings: 0,
      finalCaseValue: null,
    ),
  ) {
    on<LoadGame>(_onLoadGame);
    on<StartGame>(_onStartGame);
    on<PickInitialSuitcase>(_onPickInitialSuitcase);
    on<RevealSuitcase>(_onRevealSuitcase);
    on<AcceptDeal>(_onAcceptDeal);
    on<RejectDeal>(_onRejectDeal);
    on<ResetGame>(_onResetGame);

    // Attempt to load from SharedPreferences on creation
    add(LoadGame());
  }

  Future<void> _onLoadGame(LoadGame event, Emitter<DealState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final savedStr = prefs.getString('deal_state');
    if (savedStr != null) {
      try {
        final decoded = jsonDecode(savedStr) as Map<String, dynamic>;
        final loaded = DealState.fromJson(decoded);

        // If the loaded state was already 'gameOver', remove it so we start fresh
        if (loaded.gameOver) {
          await prefs.remove('deal_state');
        } else {
          emit(loaded);
        }
      } catch (_) {
        // If there's an error decoding, we'll ignore and just not load.
      }
    }
  }

  Future<void> _onStartGame(StartGame event, Emitter<DealState> emit) async {
    // Shuffle the 10 amounts among the 10 suitcases
    final values = [...state.allValues];
    values.shuffle(Random());

    final newState = state.copyWith(
      assignedValues: values,
      revealed: List.filled(10, false),
      playerSuitcase: null,
      gameInProgress: true,
      gameOver: false,
      finalWinnings: 0,
      finalCaseValue: null,
      waitingForDealDecision: false,
      currentOffer: 0,
    );

    emit(newState);
    await _saveGameState(newState);
  }

  Future<void> _onPickInitialSuitcase(
      PickInitialSuitcase event,
      Emitter<DealState> emit,
      ) async {
    if (!state.gameInProgress || state.playerSuitcase != null) return;

    final newState = state.copyWith(playerSuitcase: event.suitcaseIndex);
    emit(newState);
    await _saveGameState(newState);
  }

  Future<void> _onRevealSuitcase(
      RevealSuitcase event,
      Emitter<DealState> emit,
      ) async {
    if (!state.gameInProgress || state.gameOver) return;
    if (state.waitingForDealDecision) return;
    if (state.playerSuitcase == null) return;

    final index = event.suitcaseIndex;
    if (index == state.playerSuitcase || state.revealed[index]) return;

    final newRevealed = [...state.revealed];
    newRevealed[index] = true;

    // Compute the dealer's offer = 90% of the average of remaining
    final remainingValues = <double>[];
    for (int i = 0; i < state.assignedValues.length; i++) {
      if (!newRevealed[i]) {
        remainingValues.add(state.assignedValues[i]!);
      }
    }
    final avg = remainingValues.reduce((a, b) => a + b) / remainingValues.length;
    final offer = avg * 0.9;

    final newState = state.copyWith(
      revealed: newRevealed,
      currentOffer: offer,
      waitingForDealDecision: true,
    );

    emit(newState);
    await _saveGameState(newState);
  }

  Future<void> _onAcceptDeal(AcceptDeal event, Emitter<DealState> emit) async {
    if (!state.gameInProgress || !state.waitingForDealDecision) return;

    // Reveal the player's suitcase
    final newRevealed = [...state.revealed];
    if (state.playerSuitcase != null) {
      newRevealed[state.playerSuitcase!] = true;
    }
    final suitcaseValue = (state.playerSuitcase != null)
        ? state.assignedValues[state.playerSuitcase!]!
        : 0;

    // finalWinnings = current offer
    // finalCaseValue = what's actually in the chosen suitcase
    final newState = state.copyWith(
      gameOver: true,
      finalWinnings: state.currentOffer,
      finalCaseValue: suitcaseValue.toDouble(),
      waitingForDealDecision: false,
      revealed: newRevealed,
    );

    emit(newState);
    await _saveGameState(newState);

    // Remove from prefs so next time is fresh
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('deal_state');
  }

  Future<void> _onRejectDeal(RejectDeal event, Emitter<DealState> emit) async {
    if (!state.gameInProgress || !state.waitingForDealDecision) {
      return;
    }

    // No longer waiting for a deal decision
    var newState = state.copyWith(waitingForDealDecision: false);

    // Check if only the player's suitcase remains
    final notRevealed = <int>[];
    for (int i = 0; i < state.assignedValues.length; i++) {
      if (!state.revealed[i]) notRevealed.add(i);
    }

    // If it's only the player's suitcase left, the game ends automatically
    if (notRevealed.length == 1 && notRevealed.contains(state.playerSuitcase)) {
      final suitcaseValue = state.assignedValues[state.playerSuitcase!]!;
      final newRevealed = [...newState.revealed];
      newRevealed[state.playerSuitcase!] = true;

      // finalWinnings = the player's suitcase value
      // finalCaseValue = the same
      newState = newState.copyWith(
        gameOver: true,
        finalWinnings: suitcaseValue,
        finalCaseValue: suitcaseValue,
        revealed: newRevealed,
      );
    }

    emit(newState);
    await _saveGameState(newState);

    // Remove from prefs if the game ended
    if (newState.gameOver) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('deal_state');
    }
  }

  Future<void> _onResetGame(ResetGame event, Emitter<DealState> emit) async {
    // Full reset to initial, no assigned values
    final newState = state.copyWith(
      assignedValues: List.filled(10, null),
      revealed: List.filled(10, false),
      playerSuitcase: null,
      currentOffer: 0,
      waitingForDealDecision: false,
      gameOver: false,
      finalWinnings: 0,
      finalCaseValue: null,
      gameInProgress: false,
    );
    emit(newState);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('deal_state');
  }

  //
  // Save state to SharedPreferences
  //
  Future<void> _saveGameState(DealState newState) async {
    final prefs = await SharedPreferences.getInstance();
    final str = jsonEncode(newState.toJson());
    await prefs.setString('deal_state', str);
  }
}
