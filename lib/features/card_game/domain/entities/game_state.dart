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
    // Calculate starting cards based on player count
    // For demo purposes, allow 1 player with 7 cards
    final startingCards = playerCount == 1 ? 7 : (playerCount <= 6 ? 7 : (52 ~/ playerCount));
    
    return CardGameState(
      gameId: gameId,
      players: [],
      currentRound: null,
      startingCards: startingCards,
      isAscending: false,
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
