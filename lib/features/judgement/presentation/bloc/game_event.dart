part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];
}

class LoadScenariosEvent extends GameEvent {}

class MakeChoiceEvent extends GameEvent {
  final Choice choice;

  const MakeChoiceEvent({required this.choice});

  @override
  List<Object> get props => [choice];
}

class RestartGameEvent extends GameEvent {}
