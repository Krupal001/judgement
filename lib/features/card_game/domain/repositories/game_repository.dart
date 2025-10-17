import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/game_state.dart';
import '../entities/card.dart';

abstract class GameRepository {
  Future<Either<Failure, CardGameState>> createGame(String hostName, int playerCount);
  Future<Either<Failure, CardGameState>> joinGame(String gameId, String playerName);
  Future<Either<Failure, CardGameState>> startGame(String gameId);
  Future<Either<Failure, CardGameState>> placeBid(String gameId, String playerId, int bid);
  Future<Either<Failure, CardGameState>> playCard(String gameId, String playerId, PlayingCard card);
  Future<Either<Failure, CardGameState>> getGameState(String gameId);
  Future<Either<Failure, CardGameState>> startNextRound(String gameId);
}
