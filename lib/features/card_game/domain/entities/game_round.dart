import 'package:equatable/equatable.dart';
import 'card.dart';

enum GamePhase {
  waiting,
  bidding,
  playing,
  roundComplete,
  gameComplete,
}

enum ScoringStrategy {
  highIncentive,
  mediumIncentive,
  lowIncentive,
}

class GameRound extends Equatable {
  final int roundNumber;
  final int cardsPerPlayer;
  final Suit? trumpSuit; // null for no trump round
  final int dealerIndex;
  final int currentPlayerIndex;
  final GamePhase phase;
  final List<CardPlay> currentTrick;
  final int trickNumber;
  final ScoringStrategy scoringStrategy;

  const GameRound({
    required this.roundNumber,
    required this.cardsPerPlayer,
    this.trumpSuit,
    required this.dealerIndex,
    required this.currentPlayerIndex,
    required this.phase,
    this.currentTrick = const [],
    this.trickNumber = 0,
    this.scoringStrategy = ScoringStrategy.highIncentive,
  });

  bool get isNoTrump => trumpSuit == null;

  Suit? get leadSuit {
    if (currentTrick.isEmpty) return null;
    return currentTrick.first.card.suit;
  }

  GameRound copyWith({
    int? roundNumber,
    int? cardsPerPlayer,
    Suit? trumpSuit,
    bool clearTrump = false,
    int? dealerIndex,
    int? currentPlayerIndex,
    GamePhase? phase,
    List<CardPlay>? currentTrick,
    int? trickNumber,
    ScoringStrategy? scoringStrategy,
  }) {
    return GameRound(
      roundNumber: roundNumber ?? this.roundNumber,
      cardsPerPlayer: cardsPerPlayer ?? this.cardsPerPlayer,
      trumpSuit: clearTrump ? null : (trumpSuit ?? this.trumpSuit),
      dealerIndex: dealerIndex ?? this.dealerIndex,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      phase: phase ?? this.phase,
      currentTrick: currentTrick ?? this.currentTrick,
      trickNumber: trickNumber ?? this.trickNumber,
      scoringStrategy: scoringStrategy ?? this.scoringStrategy,
    );
  }

  @override
  List<Object?> get props => [
        roundNumber,
        cardsPerPlayer,
        trumpSuit,
        dealerIndex,
        currentPlayerIndex,
        phase,
        currentTrick,
        trickNumber,
        scoringStrategy,
      ];
}

class CardPlay extends Equatable {
  final String playerId;
  final PlayingCard card;

  const CardPlay({
    required this.playerId,
    required this.card,
  });

  @override
  List<Object> get props => [playerId, card];
}
