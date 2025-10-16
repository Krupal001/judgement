part of 'card_game_bloc.dart';

abstract class CardGameBlocState extends Equatable {
  const CardGameBlocState();

  @override
  List<Object> get props => [];
}

class CardGameInitial extends CardGameBlocState {}

class CardGameLoading extends CardGameBlocState {}

class CardGameLoaded extends CardGameBlocState {
  final CardGameState gameState;
  final String currentPlayerId;

  const CardGameLoaded({
    required this.gameState,
    required this.currentPlayerId,
  });

  @override
  List<Object> get props => [gameState, currentPlayerId];
}

class CardGameError extends CardGameBlocState {
  final String message;

  const CardGameError({required this.message});

  @override
  List<Object> get props => [message];
}
