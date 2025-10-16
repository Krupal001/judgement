part of 'game_bloc.dart';

abstract class GameBlocState extends Equatable {
  const GameBlocState();

  @override
  List<Object> get props => [];
}

class GameInitial extends GameBlocState {}

class GameLoading extends GameBlocState {}

class GameLoaded extends GameBlocState {
  final List<Scenario> scenarios;
  final GameState gameState;

  const GameLoaded({
    required this.scenarios,
    required this.gameState,
  });

  @override
  List<Object> get props => [scenarios, gameState];
}

class ChoiceMade extends GameBlocState {
  final List<Scenario> scenarios;
  final GameState gameState;
  final Choice selectedChoice;

  const ChoiceMade({
    required this.scenarios,
    required this.gameState,
    required this.selectedChoice,
  });

  @override
  List<Object> get props => [scenarios, gameState, selectedChoice];
}

class GameCompleted extends GameBlocState {
  final List<Scenario> scenarios;
  final GameState gameState;

  const GameCompleted({
    required this.scenarios,
    required this.gameState,
  });

  @override
  List<Object> get props => [scenarios, gameState];
}

class GameError extends GameBlocState {
  final String message;

  const GameError({required this.message});

  @override
  List<Object> get props => [message];
}
