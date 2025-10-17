import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/card.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/game_round.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/services/game_logic_service.dart';
import 'package:uuid/uuid.dart';

class FirebaseGameRepository implements GameRepository {
  final GameLogicService gameLogic;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  FirebaseGameRepository({required this.gameLogic});

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

      // Save to Firebase
      await _database.child('games').child(gameId).set(_gameStateToJson(gameState));

      return Right(gameState);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, CardGameState>> joinGame(
    String gameId,
    String playerName,
  ) async {
    try {
      print('Attempting to join game: $gameId with player: $playerName');
      
      final snapshot = await _database.child('games').child(gameId).get();
      
      if (!snapshot.exists) {
        print('Join failed: Game not found');
        return const Left(ServerFailure(message: 'Game not found'));
      }

      final gameState = _gameStateFromJson(snapshot.value as Map, gameId);
      
      print('Current game state - Players: ${gameState.players.length}, Required: ${gameState.requiredPlayers}');
      print('Current round: ${gameState.currentRound?.phase}');
      print('Player names: ${gameState.players.map((p) => p.name).toList()}');
      
      // Check if game has already started
      if (gameState.currentRound != null && gameState.currentRound!.phase != GamePhase.waiting) {
        print('Join failed: Game already started');
        return const Left(GameAlreadyStartedFailure());
      }
      
      // Check if player with same name already exists
      final existingPlayer = gameState.players.where((p) => p.name.toLowerCase() == playerName.toLowerCase());
      if (existingPlayer.isNotEmpty) {
        print('Join failed: Duplicate player name');
        return const Left(DuplicatePlayerFailure());
      }
      
      // Check if room is full
      if (gameState.players.length >= gameState.requiredPlayers) {
        print('Join failed: Room is full (${gameState.players.length}/${gameState.requiredPlayers})');
        return const Left(GameFullFailure());
      }

      final playerId = const Uuid().v4();

      final newPlayer = Player(
        id: playerId,
        name: playerName,
        isHost: false,
      );

      final updatedPlayers = [...gameState.players, newPlayer];
      final updatedGame = gameState.copyWith(players: updatedPlayers);

      print('Updating Firebase with new player: $playerName');
      // Update Firebase
      await _database.child('games').child(gameId).set(_gameStateToJson(updatedGame));

      print('Join successful: ${playerName} joined game ${gameId}');
      return Right(updatedGame);
    } catch (e, stackTrace) {
      print('Join exception: $e');
      print('Stack trace: $stackTrace');
      return Left(ServerFailure(message: 'Failed to join game: $e'));
    }
  }

  @override
  Future<Either<Failure, CardGameState>> startGame(String gameId) async {
    try {
      final snapshot = await _database.child('games').child(gameId).get();
      
      if (!snapshot.exists) {
        return Left(ServerFailure());
      }

      final game = _gameStateFromJson(snapshot.value as Map, gameId);

      if (game.players.isEmpty) {
        return Left(ServerFailure());
      }
      
      // Check if game has already started
      if (game.currentRound != null && game.currentRound!.phase != GamePhase.waiting) {
        return const Left(GameAlreadyStartedFailure());
      }
      
      // Check if we have enough players
      if (game.players.length < game.requiredPlayers) {
        return const Left(NotEnoughPlayersFailure());
      }

      // Use the starting cards from game state (which is 1 for 10-round game)
      final playerCount = game.players.length;
      final startingCards = game.startingCards; // This is 1 for our 10-round game

      print('Starting game with $startingCards cards per player');

      // Deal cards
      final hands = gameLogic.dealCards(
        game.players.map((p) => p.id).toList(),
        startingCards,
      );

      // Update players with hands
      final updatedPlayers = game.players.map((player) {
        final hand = gameLogic.sortHand(hands[player.id] ?? []);
        return player.copyWith(hand: hand);
      }).toList();

      // Create first round
      final firstRound = GameRound(
        roundNumber: 0,
        cardsPerPlayer: startingCards,
        trumpSuit: gameLogic.getTrumpSuit(0),
        dealerIndex: 0,
        currentPlayerIndex: playerCount > 1 ? 1 : 0,
        phase: GamePhase.bidding,
        scoringStrategy: ScoringStrategy.highIncentive,
      );

      final updatedGame = game.copyWith(
        players: updatedPlayers,
        currentRound: firstRound,
      );

      // Update Firebase
      await _database.child('games').child(gameId).set(_gameStateToJson(updatedGame));

      return Right(updatedGame);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, CardGameState>> placeBid(
    String gameId,
    String playerId,
    int bid,
  ) async {
    try {
      print('PlaceBid called - GameId: $gameId, PlayerId: $playerId, Bid: $bid');
      
      final snapshot = await _database.child('games').child(gameId).get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⏱️ PlaceBid: Firebase read timeout after 10 seconds');
              throw TimeoutException('Firebase read timeout');
            },
          );
      
      if (!snapshot.exists) {
        print('PlaceBid failed: Game not found');
        return Left(ServerFailure());
      }

      final game = _gameStateFromJson(snapshot.value as Map, gameId);

      if (game.currentRound == null) {
        print('PlaceBid failed: No current round');
        return Left(ServerFailure());
      }
      
      print('Current player index: ${game.currentRound!.currentPlayerIndex}');
      print('Players: ${game.players.map((p) => '${p.name}(${p.id.substring(0, 8)}, bid: ${p.bid})').toList()}');
      
      // Check if game is in bidding phase
      if (game.currentRound!.phase != GamePhase.bidding) {
        print('PlaceBid failed: Not in bidding phase');
        return const Left(InvalidBidFailure());
      }
      
      // Check if it's the player's turn
      final currentPlayer = game.players[game.currentRound!.currentPlayerIndex];
      print('Current player: ${currentPlayer.name} (${currentPlayer.id.substring(0, 8)})');
      
      if (currentPlayer.id != playerId) {
        print('PlaceBid failed: Not player\'s turn');
        return const Left(NotYourTurnFailure());
      }
      
      // Check if player has already bid
      if (currentPlayer.hasBid) {
        print('PlaceBid failed: Player already bid');
        return const Left(InvalidBidFailure());
      }
      
      // Validate bid
      if (!game.canBid(bid)) {
        print('PlaceBid failed: Invalid bid value');
        return const Left(InvalidBidFailure());
      }

      // Update player's bid
      final updatedPlayers = game.players.map((player) {
        if (player.id == playerId) {
          return player.copyWith(bid: bid);
        }
        return player;
      }).toList();

      var updatedGame = game.copyWith(players: updatedPlayers);

      // Check if all players have bid
      final allBid = updatedPlayers.every((p) => p.bid != null);
      print('All players bid: $allBid');
      
      if (allBid) {
        // Move to playing phase
        print('Moving to playing phase');
        final updatedRound = game.currentRound!.copyWith(
          phase: GamePhase.playing,
        );
        updatedGame = updatedGame.copyWith(currentRound: updatedRound);
      } else {
        // Move to next player
        final nextPlayerIndex = (game.currentRound!.currentPlayerIndex + 1) % game.players.length;
        print('Moving to next player: index $nextPlayerIndex');
        final updatedRound = game.currentRound!.copyWith(
          currentPlayerIndex: nextPlayerIndex,
        );
        updatedGame = updatedGame.copyWith(currentRound: updatedRound);
      }

      // Update Firebase with timeout
      try {
        await _database.child('games').child(gameId).set(_gameStateToJson(updatedGame))
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                print('⏱️ PlaceBid: Firebase write timeout after 10 seconds');
                throw TimeoutException('Firebase write timeout');
              },
            );
        print('✅ Bid placed and Firebase updated');
      } catch (firebaseError) {
        print('❌ Firebase update failed: $firebaseError');
        // Continue anyway - local state is updated
      }

      print('PlaceBid successful');
      return Right(updatedGame);
    } catch (e, stackTrace) {
      print('❌ PlaceBid exception: $e');
      print('Stack trace: $stackTrace');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, CardGameState>> playCard(
    String gameId,
    String playerId,
    PlayingCard card,
  ) async {
    try {
      final snapshot = await _database.child('games').child(gameId).get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⏱️ PlayCard: Firebase read timeout after 10 seconds');
              throw TimeoutException('Firebase read timeout');
            },
          );
      
      if (!snapshot.exists) {
        return Left(ServerFailure());
      }

      final game = _gameStateFromJson(snapshot.value as Map, gameId);

      if (game.currentRound == null) {
        return Left(ServerFailure());
      }

      // Get the player
      final player = game.players.firstWhere((p) => p.id == playerId);
      
      // Validate must-follow-suit rule
      if (game.currentRound!.currentTrick.isNotEmpty) {
        // Get the suit of the first card played in this trick
        final leadSuit = game.currentRound!.currentTrick.first.card.suit;
        
        // Check if player has cards of the lead suit
        final hasLeadSuit = player.hand.any((c) => c.suit == leadSuit);
        
        // If player has lead suit cards but played a different suit, reject
        if (hasLeadSuit && card.suit != leadSuit) {
          print('Invalid play: Must follow suit $leadSuit');
          return const Left(ServerFailure(message: 'You must follow suit!'));
        }
      }

      // Remove card from player's hand
      final updatedPlayers = game.players.map((player) {
        if (player.id == playerId) {
          final newHand = player.hand.where((c) => c != card).toList();
          return player.copyWith(hand: newHand);
        }
        return player;
      }).toList();

      // Add card to current trick
      final cardPlay = CardPlay(playerId: playerId, card: card);
      final updatedTrick = [...game.currentRound!.currentTrick, cardPlay];
      var updatedRound = game.currentRound!.copyWith(currentTrick: updatedTrick);
      var updatedGame = game.copyWith(players: updatedPlayers, currentRound: updatedRound);

      // Check if trick is complete
      if (updatedTrick.length == game.players.length) {
        print('Trick complete! ${updatedTrick.length} cards played');
        
        // Determine winner
        final winnerId = gameLogic.determineTrickWinner(
          updatedTrick,
          game.currentRound!.trumpSuit,
        );

        // Update tricks won
        final winnerIndex = updatedPlayers.indexWhere((p) => p.id == winnerId);
        print('Trick winner: ${updatedPlayers[winnerIndex].name}');
        
        updatedPlayers[winnerIndex] = updatedPlayers[winnerIndex].copyWith(
          tricksWon: updatedPlayers[winnerIndex].tricksWon + 1,
        );

        // Check if round is complete
        final roundComplete = updatedPlayers[0].hand.isEmpty;
        print('Round complete: $roundComplete (hand size: ${updatedPlayers[0].hand.length})');
        
        if (roundComplete) {
          print('🎯 Calculating scores for round ${game.currentRound!.roundNumber}');
          
          // Calculate scores for completed round
          final scoredPlayers = updatedPlayers.map((player) {
            final roundScore = gameLogic.calculateScore(
              player.bid ?? 0,
              player.tricksWon,
              game.currentRound!.scoringStrategy,
            );
            final newTotal = player.totalScore + roundScore;
            print('${player.name}: Bid=${player.bid}, Won=${player.tricksWon}, RoundScore=$roundScore, OldTotal=${player.totalScore}, NewTotal=$newTotal');
            
            return player.copyWith(
              totalScore: newTotal,
              tricksWon: 0,
              resetBid: true,  // Use flag to reset bid to null
            );
          }).toList();
          
          updatedRound = _completeRound(updatedGame.copyWith(players: scoredPlayers), scoredPlayers);
          
          // CRITICAL: Use scoredPlayers, not updatedPlayers!
          updatedGame = updatedGame.copyWith(
            players: scoredPlayers,
            currentRound: updatedRound,
          );
        } else {
          // Start new trick
          print('Starting new trick ${updatedRound.trickNumber + 1}');
          updatedRound = updatedRound.copyWith(
            currentTrick: [],
            currentPlayerIndex: winnerIndex,
            trickNumber: updatedRound.trickNumber + 1,
          );
          
          updatedGame = updatedGame.copyWith(
            players: updatedPlayers,
            currentRound: updatedRound,
          );
        }
      } else {
        // Move to next player
        final nextPlayerIndex = (updatedRound.currentPlayerIndex + 1) % game.players.length;
        updatedRound = updatedRound.copyWith(currentPlayerIndex: nextPlayerIndex);
        updatedGame = updatedGame.copyWith(currentRound: updatedRound);
      }

      // Update Firebase with timeout
      try {
        await _database.child('games').child(gameId).set(_gameStateToJson(updatedGame))
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                print('⏱️ PlayCard: Firebase write timeout after 10 seconds');
                throw TimeoutException('Firebase write timeout');
              },
            );
        print('✅ Card played and Firebase updated');
      } catch (firebaseError) {
        print('❌ Firebase update failed: $firebaseError');
        // Continue anyway - local state is updated
      }

      return Right(updatedGame);
    } catch (e) {
      print('❌ PlayCard error: $e');
      return Left(ServerFailure());
    }
  }

  GameRound _completeRound(CardGameState game, List<Player> players) {
    final currentCards = game.currentRound!.cardsPerPlayer;
    
    // Game goes from 1 to 4 cards over 4 rounds, then repeats
    final nextCards = currentCards + 1;
    
    // Check if game is complete (after 4 rounds)
    if (nextCards > 4) {
      print('🎉 Game complete after 4 rounds!');
      return game.currentRound!.copyWith(phase: GamePhase.gameComplete);
    }

    print('Round ${game.currentRound!.roundNumber} complete! Showing scoreboard...');

    // Return roundComplete phase to show scoreboard
    // The next round will be started when user clicks "Next Round" button
    return game.currentRound!.copyWith(phase: GamePhase.roundComplete);
  }

  Map<String, dynamic> _prepareNextRoundWithPlayers(CardGameState game) {
    final currentCards = game.currentRound!.cardsPerPlayer;
    final nextCards = currentCards + 1;

    print('Starting round ${game.currentRound!.roundNumber + 1} with $nextCards cards');

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
      currentTrick: const [],  // CRITICAL: Reset trick
      trickNumber: 0,  // CRITICAL: Reset trick number
      scoringStrategy: game.currentRound!.scoringStrategy,
    );
    
    print('✅ New round created: Round $nextRoundNumber, Cards: $nextCards, Tricks: 0');

    return {
      'round': nextRound,
      'players': playersWithCards,
    };
  }

  @override
  Future<Either<Failure, CardGameState>> getGameState(String gameId) async {
    try {
      final snapshot = await _database.child('games').child(gameId).get();
      
      if (!snapshot.exists) {
        return Left(ServerFailure());
      }

      final game = _gameStateFromJson(snapshot.value as Map, gameId);
      return Right(game);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, CardGameState>> startNextRound(String gameId) async {
    try {
      final snapshot = await _database.child('games').child(gameId).get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⏱️ StartNextRound: Firebase read timeout after 10 seconds');
              throw TimeoutException('Firebase read timeout');
            },
          );
      
      if (!snapshot.exists) {
        return Left(ServerFailure());
      }

      final game = _gameStateFromJson(snapshot.value as Map, gameId);
      
      if (game.currentRound == null) return Left(ServerFailure());
      if (game.currentRound!.phase != GamePhase.roundComplete) {
        return Left(ServerFailure());
      }

      // Prepare next round with updated players
      final result = _prepareNextRoundWithPlayers(game);
      final nextRound = result['round'] as GameRound;
      final updatedPlayers = result['players'] as List<Player>;
      
      final updatedGame = game.copyWith(
        currentRound: nextRound,
        players: updatedPlayers,
      );
      
      // Update Firebase with complete game state and timeout
      try {
        await _database.child('games').child(gameId).set(_gameStateToJson(updatedGame))
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                print('⏱️ StartNextRound: Firebase write timeout after 10 seconds');
                throw TimeoutException('Firebase write timeout');
              },
            );
        print('✅ Firebase updated for next round');
      } catch (firebaseError) {
        print('❌ Firebase update failed: $firebaseError');
        // Continue anyway - local state is updated
      }
      
      print('✅ Next round started: Round ${nextRound.roundNumber}, Players bids reset');
      print('Players: ${updatedPlayers.map((p) => '${p.name}:bid=${p.bid}').join(', ')}');
      
      return Right(updatedGame);
    } catch (e) {
      print('❌ Error starting next round: $e');
      return Left(ServerFailure());
    }
  }

  // Stream for real-time updates with error handling
  Stream<CardGameState> watchGameState(String gameId) {
    return _database.child('games').child(gameId).onValue
        .map((event) {
          if (event.snapshot.value == null) {
            print('⚠️ Game state is null for gameId: $gameId');
            throw Exception('Game not found');
          }
          print('📡 Firebase update received for game: $gameId');
          return _gameStateFromJson(event.snapshot.value as Map, gameId);
        })
        .handleError((error) {
          print('❌ Firebase stream error: $error');
          // Don't throw - let the listener handle it
        });
  }

  // JSON Serialization
  Map<String, dynamic> _gameStateToJson(CardGameState game) {
    return {
      'gameId': game.gameId,
      'players': game.players.map((p) => _playerToJson(p)).toList(),
      'currentRound': game.currentRound != null ? _roundToJson(game.currentRound!) : null,
      'startingCards': game.startingCards,
      'isAscending': game.isAscending,
      'requiredPlayers': game.requiredPlayers,
    };
  }

  CardGameState _gameStateFromJson(Map data, String gameId) {
    return CardGameState(
      gameId: gameId,
      players: (data['players'] as List?)?.map((p) => _playerFromJson(p as Map)).toList() ?? [],
      currentRound: data['currentRound'] != null ? _roundFromJson(data['currentRound'] as Map) : null,
      startingCards: data['startingCards'] as int? ?? 7,
      isAscending: data['isAscending'] as bool? ?? false,
      requiredPlayers: data['requiredPlayers'] as int? ?? 4,
    );
  }

  Map<String, dynamic> _playerToJson(Player player) {
    return {
      'id': player.id,
      'name': player.name,
      'isHost': player.isHost,
      'hand': player.hand.map((c) => _cardToJson(c)).toList(),
      'bid': player.bid,
      'tricksWon': player.tricksWon,
      'totalScore': player.totalScore,
    };
  }

  Player _playerFromJson(Map data) {
    return Player(
      id: data['id'] as String,
      name: data['name'] as String,
      isHost: data['isHost'] as bool? ?? false,
      hand: (data['hand'] as List?)?.map((c) => _cardFromJson(c as Map)).toList() ?? [],
      bid: data['bid'] as int?,
      tricksWon: data['tricksWon'] as int? ?? 0,
      totalScore: data['totalScore'] as int? ?? 0,
    );
  }

  Map<String, dynamic> _roundToJson(GameRound round) {
    return {
      'roundNumber': round.roundNumber,
      'cardsPerPlayer': round.cardsPerPlayer,
      'trumpSuit': round.trumpSuit?.toString(),
      'dealerIndex': round.dealerIndex,
      'currentPlayerIndex': round.currentPlayerIndex,
      'phase': round.phase.toString(),
      'currentTrick': round.currentTrick.map((cp) => _cardPlayToJson(cp)).toList(),
      'trickNumber': round.trickNumber,
      'scoringStrategy': round.scoringStrategy.toString(),
    };
  }

  GameRound _roundFromJson(Map data) {
    return GameRound(
      roundNumber: data['roundNumber'] as int,
      cardsPerPlayer: data['cardsPerPlayer'] as int,
      trumpSuit: data['trumpSuit'] != null ? _suitFromString(data['trumpSuit'] as String) : null,
      dealerIndex: data['dealerIndex'] as int,
      currentPlayerIndex: data['currentPlayerIndex'] as int,
      phase: _phaseFromString(data['phase'] as String),
      currentTrick: (data['currentTrick'] as List?)?.map((c) => _cardPlayFromJson(c as Map)).toList() ?? [],
      trickNumber: data['trickNumber'] as int? ?? 0,
      scoringStrategy: _strategyFromString(data['scoringStrategy'] as String),
    );
  }

  Map<String, dynamic> _cardToJson(PlayingCard card) {
    return {
      'suit': card.suit.toString(),
      'value': card.value.toString(),
    };
  }

  PlayingCard _cardFromJson(Map data) {
    return PlayingCard(
      suit: _suitFromString(data['suit'] as String),
      value: _cardValueFromString(data['value'] as String? ?? data['rank'] as String),
    );
  }

  Map<String, dynamic> _cardPlayToJson(CardPlay cardPlay) {
    return {
      'playerId': cardPlay.playerId,
      'card': _cardToJson(cardPlay.card),
    };
  }

  CardPlay _cardPlayFromJson(Map data) {
    return CardPlay(
      playerId: data['playerId'] as String,
      card: _cardFromJson(data['card'] as Map),
    );
  }

  Suit _suitFromString(String str) {
    switch (str) {
      case 'Suit.spades': return Suit.spades;
      case 'Suit.hearts': return Suit.hearts;
      case 'Suit.diamonds': return Suit.diamonds;
      case 'Suit.clubs': return Suit.clubs;
      default: return Suit.spades;
    }
  }

  CardValue _cardValueFromString(String str) {
    switch (str) {
      case 'CardValue.two':
      case 'Rank.two': return CardValue.two;
      case 'CardValue.three':
      case 'Rank.three': return CardValue.three;
      case 'CardValue.four':
      case 'Rank.four': return CardValue.four;
      case 'CardValue.five':
      case 'Rank.five': return CardValue.five;
      case 'CardValue.six':
      case 'Rank.six': return CardValue.six;
      case 'CardValue.seven':
      case 'Rank.seven': return CardValue.seven;
      case 'CardValue.eight':
      case 'Rank.eight': return CardValue.eight;
      case 'CardValue.nine':
      case 'Rank.nine': return CardValue.nine;
      case 'CardValue.ten':
      case 'Rank.ten': return CardValue.ten;
      case 'CardValue.jack':
      case 'Rank.jack': return CardValue.jack;
      case 'CardValue.queen':
      case 'Rank.queen': return CardValue.queen;
      case 'CardValue.king':
      case 'Rank.king': return CardValue.king;
      case 'CardValue.ace':
      case 'Rank.ace': return CardValue.ace;
      default: return CardValue.two;
    }
  }

  GamePhase _phaseFromString(String str) {
    switch (str) {
      case 'GamePhase.waiting': return GamePhase.waiting;
      case 'GamePhase.bidding': return GamePhase.bidding;
      case 'GamePhase.playing': return GamePhase.playing;
      case 'GamePhase.roundComplete': return GamePhase.roundComplete;
      case 'GamePhase.gameComplete': return GamePhase.gameComplete;
      default: return GamePhase.waiting;
    }
  }

  ScoringStrategy _strategyFromString(String str) {
    switch (str) {
      case 'ScoringStrategy.highIncentive': return ScoringStrategy.highIncentive;
      case 'ScoringStrategy.mediumIncentive': return ScoringStrategy.mediumIncentive;
      case 'ScoringStrategy.lowIncentive': return ScoringStrategy.lowIncentive;
      default: return ScoringStrategy.highIncentive;
    }
  }
}
