import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/card.dart';
import '../../domain/entities/game_round.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/services/game_logic_service.dart';
import 'package:uuid/uuid.dart';

class GameRepositoryImpl implements GameRepository {
  final GameLogicService gameLogic;
  final Map<String, CardGameState> _games = {};

  GameRepositoryImpl({required this.gameLogic});

  @override
  Future<Either<Failure, CardGameState>> createGame(String hostName, int playerCount) async {
    try {
      final gameId = const Uuid().v4().substring(0, 6).toUpperCase();
      final hostId = const Uuid().v4();

      final host = Player(
        id: hostId,
        name: hostName,
        isHost: true,
      );

      final gameState = CardGameState.initial(
        gameId: gameId,
        playerCount: playerCount,
      ).copyWith(
        players: [host],
      );

      _games[gameId] = gameState;
      return Right(gameState);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, CardGameState>> joinGame(
    String gameId,
    String playerName,
  ) async {
    try {
      final game = _games[gameId];
      if (game == null) return Left(CacheFailure());

      if (game.currentRound != null) {
        return Left(CacheFailure()); // Game already started
      }

      if (game.players.length >= 10) {
        return Left(CacheFailure()); // Max players reached
      }

      final playerId = const Uuid().v4();
      final newPlayer = Player(id: playerId, name: playerName);

      final updatedGame = game.copyWith(
        players: [...game.players, newPlayer],
      );

      _games[gameId] = updatedGame;
      return Right(updatedGame);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, CardGameState>> startGame(String gameId) async {
    try {
      final game = _games[gameId];
      if (game == null) return Left(CacheFailure());

      if (game.players.isEmpty) {
        return Left(CacheFailure()); // Need at least 1 player
      }

      // Calculate starting cards
      final playerCount = game.players.length;
      final startingCards = playerCount <= 6 ? 7 : (52 ~/ playerCount);

      // Deal cards
      final hands = gameLogic.dealCards(
        game.players.map((p) => p.id).toList(),
        startingCards,
      );

      // Update players with their hands
      final updatedPlayers = game.players.map((player) {
        final hand = gameLogic.sortHand(hands[player.id] ?? []);
        return player.copyWith(hand: hand);
      }).toList();

      // Create first round
      final nextPlayerIndex = updatedPlayers.length > 1 ? 1 : 0;
      final firstRound = GameRound(
        roundNumber: 0,
        cardsPerPlayer: startingCards,
        trumpSuit: gameLogic.getTrumpSuit(0),
        dealerIndex: 0,
        currentPlayerIndex: nextPlayerIndex, // Player after dealer starts bidding
        phase: GamePhase.bidding,
      );

      final updatedGame = game.copyWith(
        players: updatedPlayers,
        currentRound: firstRound,
        startingCards: startingCards,
      );

      _games[gameId] = updatedGame;
      return Right(updatedGame);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, CardGameState>> placeBid(
    String gameId,
    String playerId,
    int bid,
  ) async {
    try {
      final game = _games[gameId];
      if (game == null) return Left(CacheFailure());
      if (game.currentRound == null) return Left(CacheFailure());

      // Validate bid
      if (!game.canBid(bid)) {
        return Left(CacheFailure()); // Invalid bid
      }

      // Update player with bid
      final playerIndex = game.players.indexWhere((p) => p.id == playerId);
      if (playerIndex == -1) return Left(CacheFailure());

      final updatedPlayers = List<Player>.from(game.players);
      updatedPlayers[playerIndex] = updatedPlayers[playerIndex].copyWith(bid: bid);

      // Move to next player or start playing phase
      final allBidsPlaced = updatedPlayers.every((p) => p.hasBid);
      final nextPlayerIndex = (game.currentRound!.currentPlayerIndex + 1) % game.players.length;

      final updatedRound = game.currentRound!.copyWith(
        currentPlayerIndex: allBidsPlaced ? (game.currentRound!.dealerIndex + 1) % game.players.length : nextPlayerIndex,
        phase: allBidsPlaced ? GamePhase.playing : GamePhase.bidding,
      );

      final updatedGame = game.copyWith(
        players: updatedPlayers,
        currentRound: updatedRound,
      );

      _games[gameId] = updatedGame;
      return Right(updatedGame);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, CardGameState>> playCard(
    String gameId,
    String playerId,
    PlayingCard card,
  ) async {
    try {
      final game = _games[gameId];
      if (game == null) return Left(CacheFailure());
      if (game.currentRound == null) return Left(CacheFailure());

      final player = game.getPlayerById(playerId);
      if (player == null) return Left(CacheFailure());

      // Validate card play
      if (!gameLogic.isValidPlay(card, player.hand, game.currentRound!.leadSuit)) {
        return Left(CacheFailure());
      }

      // Remove card from player's hand
      final updatedHand = List<PlayingCard>.from(player.hand)..remove(card);
      final playerIndex = game.players.indexWhere((p) => p.id == playerId);
      final updatedPlayers = List<Player>.from(game.players);
      updatedPlayers[playerIndex] = player.copyWith(hand: updatedHand);

      // Add card to current trick
      final updatedTrick = [
        ...game.currentRound!.currentTrick,
        CardPlay(playerId: playerId, card: card),
      ];

      var updatedRound = game.currentRound!.copyWith(currentTrick: updatedTrick);
      var updatedGame = game.copyWith(players: updatedPlayers, currentRound: updatedRound);

      // Check if trick is complete
      if (updatedTrick.length == game.players.length) {
        // Determine winner
        final winnerId = gameLogic.determineTrickWinner(
          updatedTrick,
          game.currentRound!.trumpSuit,
        );

        // Update tricks won
        final winnerIndex = updatedPlayers.indexWhere((p) => p.id == winnerId);
        updatedPlayers[winnerIndex] = updatedPlayers[winnerIndex].copyWith(
          tricksWon: updatedPlayers[winnerIndex].tricksWon + 1,
        );

        // Check if round is complete
        if (updatedPlayers[0].hand.isEmpty) {
          // Calculate scores for completed round
          final scoredPlayers = updatedPlayers.map((player) {
            final roundScore = gameLogic.calculateScore(
              player.bid ?? 0,
              player.tricksWon,
              game.currentRound!.scoringStrategy,
            );
            return player.copyWith(
              totalScore: player.totalScore + roundScore,
              tricksWon: 0, // Reset for next round
              bid: null, // Reset bid for next round
            );
          }).toList();
          
          updatedGame = updatedGame.copyWith(players: scoredPlayers);
          updatedRound = _completeRound(updatedGame, scoredPlayers);
        } else {
          // Start new trick
          updatedRound = updatedRound.copyWith(
            currentTrick: [],
            currentPlayerIndex: winnerIndex,
            trickNumber: updatedRound.trickNumber + 1,
          );
        }

        updatedGame = updatedGame.copyWith(
          players: updatedPlayers,
          currentRound: updatedRound,
        );
      } else {
        // Move to next player
        final nextPlayerIndex = (updatedRound.currentPlayerIndex + 1) % game.players.length;
        updatedRound = updatedRound.copyWith(currentPlayerIndex: nextPlayerIndex);
        updatedGame = updatedGame.copyWith(currentRound: updatedRound);
      }

      _games[gameId] = updatedGame;
      return Right(updatedGame);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  GameRound _completeRound(CardGameState game, List<Player> players) {
    // Determine next round parameters
    final currentCards = game.currentRound!.cardsPerPlayer;
    int nextCards;

    if (currentCards == 1) {
      nextCards = 2;
    } else if (game.isAscending) {
      nextCards = currentCards + 1;
      if (nextCards > game.startingCards) {
        // Game complete
        return game.currentRound!.copyWith(phase: GamePhase.gameComplete);
      }
    } else {
      nextCards = currentCards - 1;
    }

    // Deal new cards for next round
    final hands = gameLogic.dealCards(
      players.map((p) => p.id).toList(),
      nextCards,
    );

    // Update players with new hands
    final playersWithCards = players.map((player) {
      final hand = gameLogic.sortHand(hands[player.id] ?? []);
      return player.copyWith(hand: hand);
    }).toList();

    // Update game state with new players
    final gameId = game.gameId;
    if (_games[gameId] != null) {
      _games[gameId] = game.copyWith(players: playersWithCards);
    }

    // Create next round
    final nextRoundNumber = game.currentRound!.roundNumber + 1;
    final nextDealerIndex = (game.currentRound!.dealerIndex + 1) % players.length;
    final nextPlayerIndex = players.length > 1 ? (nextDealerIndex + 1) % players.length : 0;

    return GameRound(
      roundNumber: nextRoundNumber,
      cardsPerPlayer: nextCards,
      trumpSuit: gameLogic.getTrumpSuit(nextRoundNumber),
      dealerIndex: nextDealerIndex,
      currentPlayerIndex: nextPlayerIndex,
      phase: GamePhase.bidding,
      scoringStrategy: game.currentRound!.scoringStrategy,
    );
  }

  @override
  Future<Either<Failure, CardGameState>> getGameState(String gameId) async {
    try {
      final game = _games[gameId];
      if (game == null) return Left(CacheFailure());
      return Right(game);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, CardGameState>> startNextRound(String gameId) async {
    try {
      final game = _games[gameId];
      if (game == null) return Left(CacheFailure());
      if (game.currentRound == null) return Left(CacheFailure());
      if (game.currentRound!.phase != GamePhase.roundComplete) {
        return Left(CacheFailure());
      }

      // Prepare next round with updated players
      final result = _prepareNextRound(game);
      final nextRound = result['round'] as GameRound;
      final updatedPlayers = result['players'] as List<Player>;
      
      final updatedGame = game.copyWith(
        currentRound: nextRound,
        players: updatedPlayers,
      );
      _games[gameId] = updatedGame;
      
      print('✅ Next round started: Round ${nextRound.roundNumber}, Players bids reset');
      print('Players: ${updatedPlayers.map((p) => '${p.name}:bid=${p.bid}').join(', ')}');
      
      return Right(updatedGame);
    } catch (e) {
      print('❌ Error starting next round: $e');
      return Left(CacheFailure());
    }
  }

  Map<String, dynamic> _prepareNextRound(CardGameState game) {
    // Determine next round parameters
    final currentCards = game.currentRound!.cardsPerPlayer;
    int nextCards;

    if (currentCards == 1) {
      nextCards = 2;
    } else if (game.isAscending) {
      nextCards = currentCards + 1;
      if (nextCards > game.startingCards) {
        // Game complete
        return {
          'round': game.currentRound!.copyWith(phase: GamePhase.gameComplete),
          'players': game.players,
        };
      }
    } else {
      nextCards = currentCards - 1;
    }

    // Deal new cards for next round
    final hands = gameLogic.dealCards(
      game.players.map((p) => p.id).toList(),
      nextCards,
    );

    // Update players with new hands and RESET bids
    final playersWithCards = game.players.map((player) {
      final hand = gameLogic.sortHand(hands[player.id] ?? []);
      return Player(
        id: player.id,
        name: player.name,
        isHost: player.isHost,
        hand: hand,
        bid: null,  // CRITICAL: Reset bid for new round
        tricksWon: 0,  // Reset tricks won
        totalScore: player.totalScore,  // Keep the updated score
      );
    }).toList();

    // Create next round
    final nextRoundNumber = game.currentRound!.roundNumber + 1;
    final nextDealerIndex = (game.currentRound!.dealerIndex + 1) % game.players.length;
    final nextPlayerIndex = game.players.length > 1 ? (nextDealerIndex + 1) % game.players.length : 0;

    final nextRound = GameRound(
      roundNumber: nextRoundNumber,
      cardsPerPlayer: nextCards,
      trumpSuit: gameLogic.getTrumpSuit(nextRoundNumber),
      dealerIndex: nextDealerIndex,
      currentPlayerIndex: nextPlayerIndex,
      phase: GamePhase.bidding,
      scoringStrategy: game.currentRound!.scoringStrategy,
    );

    return {
      'round': nextRound,
      'players': playersWithCards,
    };
  }
}
