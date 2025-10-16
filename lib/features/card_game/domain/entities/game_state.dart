import 'package:equatable/equatable.dart';
import 'player.dart';
import 'game_round.dart';

class CardGameState extends Equatable {
  final String gameId;
  final List<Player> players;
  final GameRound? currentRound;
  final int startingCards;
  final bool isAscending; // true when going up, false when going down
  final int requiredPlayers; // Required number of players to start

  const CardGameState({
    required this.gameId,
    required this.players,
    this.currentRound,
    required this.startingCards,
    this.isAscending = false,
    this.requiredPlayers = 4,
  });

  factory CardGameState.initial({
    required String gameId,
    required int playerCount,
  }) {
    // Start with 1 card and go up to 10 cards over 10 rounds
    final startingCards = 1;
    
    return CardGameState(
      gameId: gameId,
      players: [],
      currentRound: null,
      startingCards: startingCards,
      isAscending: true, // Always ascending from 1 to 10
      requiredPlayers: playerCount,
    );
  }

  Player? get currentPlayer {
    if (currentRound == null || players.isEmpty) return null;
    return players[currentRound!.currentPlayerIndex];
  }

  Player? getPlayerById(String id) {
    try {
      return players.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  int getTotalBids() {
    return players.fold(0, (sum, player) => sum + (player.bid ?? 0));
  }

  bool canBid(int bid) {
    if (currentRound == null) return false;
    
    // Check if this is the last player to bid
    final biddingPlayers = players.where((p) => p.hasBid).length;
    final isLastBidder = biddingPlayers == players.length - 1;
    
    if (!isLastBidder) return true;
    
    // Last player cannot bid a number that makes total equal to cards per player
    final currentTotal = getTotalBids();
    return (currentTotal + bid) != currentRound!.cardsPerPlayer;
  }

  CardGameState copyWith({
    String? gameId,
    List<Player>? players,
    GameRound? currentRound,
    int? startingCards,
    bool? isAscending,
    int? requiredPlayers,
  }) {
    return CardGameState(
      gameId: gameId ?? this.gameId,
      players: players ?? this.players,
      currentRound: currentRound ?? this.currentRound,
      startingCards: startingCards ?? this.startingCards,
      isAscending: isAscending ?? this.isAscending,
      requiredPlayers: requiredPlayers ?? this.requiredPlayers,
    );
  }

  @override
  List<Object?> get props => [gameId, players, currentRound, startingCards, isAscending, requiredPlayers];
}
