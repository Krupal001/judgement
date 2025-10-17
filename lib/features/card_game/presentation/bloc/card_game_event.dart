part of 'card_game_bloc.dart';

abstract class CardGameEvent extends Equatable {
  const CardGameEvent();

  @override
  List<Object> get props => [];
}

class CreateGameEvent extends CardGameEvent {
  final String hostName;
  final int playerCount;

  const CreateGameEvent({required this.hostName, required this.playerCount});

  @override
  List<Object> get props => [hostName, playerCount];
}

class JoinGameEvent extends CardGameEvent {
  final String gameId;
  final String playerName;

  const JoinGameEvent({
    required this.gameId,
    required this.playerName,
  });

  @override
  List<Object> get props => [gameId, playerName];
}

class StartGameEvent extends CardGameEvent {}

class PlaceBidEvent extends CardGameEvent {
  final String playerId;
  final int bid;

  const PlaceBidEvent({
    required this.playerId,
    required this.bid,
  });

  @override
  List<Object> get props => [playerId, bid];
}

class PlayCardEvent extends CardGameEvent {
  final String playerId;
  final PlayingCard card;

  const PlayCardEvent({
    required this.playerId,
    required this.card,
  });

  @override
  List<Object> get props => [playerId, card];
}

class RefreshGameEvent extends CardGameEvent {}

class GameStateUpdatedEvent extends CardGameEvent {
  final CardGameState gameState;
  final String currentPlayerId;

  const GameStateUpdatedEvent({
    required this.gameState,
    required this.currentPlayerId,
  });

  @override
  List<Object> get props => [gameState, currentPlayerId];
}

class StartNextRoundEvent extends CardGameEvent {
  final String gameId;

  const StartNextRoundEvent({required this.gameId});

  @override
  List<Object> get props => [gameId];
}
