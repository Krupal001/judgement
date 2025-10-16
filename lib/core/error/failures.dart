import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String? message;
  
  const Failure({this.message});
  
  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message});
}

class GameFullFailure extends Failure {
  const GameFullFailure() : super(message: 'Game room is full');
}

class DuplicatePlayerFailure extends Failure {
  const DuplicatePlayerFailure() : super(message: 'A player with this name already exists');
}

class GameAlreadyStartedFailure extends Failure {
  const GameAlreadyStartedFailure() : super(message: 'Game has already started');
}

class NotEnoughPlayersFailure extends Failure {
  const NotEnoughPlayersFailure() : super(message: 'Not enough players to start the game');
}

class InvalidBidFailure extends Failure {
  const InvalidBidFailure() : super(message: 'Invalid bid');
}

class NotYourTurnFailure extends Failure {
  const NotYourTurnFailure() : super(message: 'It\'s not your turn');
}
