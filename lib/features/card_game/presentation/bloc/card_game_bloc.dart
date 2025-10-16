import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/card.dart';
import '../../domain/repositories/game_repository.dart';
import '../../data/repositories/firebase_game_repository.dart';

part 'card_game_event.dart';
part 'card_game_state.dart';

class CardGameBloc extends Bloc<CardGameEvent, CardGameBlocState> {
  final GameRepository repository;
  StreamSubscription? _gameSubscription;

  CardGameBloc({required this.repository}) : super(CardGameInitial()) {
    on<CreateGameEvent>(_onCreateGame);
    on<JoinGameEvent>(_onJoinGame);
    on<StartGameEvent>(_onStartGame);
    on<PlaceBidEvent>(_onPlaceBid);
    on<PlayCardEvent>(_onPlayCard);
    on<RefreshGameEvent>(_onRefreshGame);
    on<GameStateUpdatedEvent>(_onGameStateUpdated);
  }

  @override
  Future<void> close() {
    _gameSubscription?.cancel();
    return super.close();
  }

  void _startListening(String gameId, String currentPlayerId) {
    _gameSubscription?.cancel();
    
    if (repository is FirebaseGameRepository) {
      _gameSubscription = (repository as FirebaseGameRepository)
          .watchGameState(gameId)
          .listen((gameState) {
        add(GameStateUpdatedEvent(gameState: gameState, currentPlayerId: currentPlayerId));
      });
    }
  }

  void _onGameStateUpdated(
    GameStateUpdatedEvent event,
    Emitter<CardGameBlocState> emit,
  ) {
    emit(CardGameLoaded(
      gameState: event.gameState,
      currentPlayerId: event.currentPlayerId,
    ));
  }

  Future<void> _onCreateGame(
    CreateGameEvent event,
    Emitter<CardGameBlocState> emit,
  ) async {
    emit(CardGameLoading());

    final result = await repository.createGame(event.hostName, event.playerCount);

    result.fold(
      (failure) => emit(const CardGameError(message: 'Failed to create game')),
      (gameState) {
        final playerId = gameState.players.first.id;
        _startListening(gameState.gameId, playerId);
        emit(CardGameLoaded(
          gameState: gameState,
          currentPlayerId: playerId,
        ));
      },
    );
  }

  Future<void> _onJoinGame(
    JoinGameEvent event,
    Emitter<CardGameBlocState> emit,
  ) async {
    emit(CardGameLoading());

    final result = await repository.joinGame(event.gameId, event.playerName);

    result.fold(
      (failure) => emit(const CardGameError(message: 'Failed to join game')),
      (gameState) {
        final player = gameState.players.lastWhere((p) => p.name == event.playerName);
        _startListening(gameState.gameId, player.id);
        emit(CardGameLoaded(
          gameState: gameState,
          currentPlayerId: player.id,
        ));
      },
    );
  }

  Future<void> _onStartGame(
    StartGameEvent event,
    Emitter<CardGameBlocState> emit,
  ) async {
    if (state is! CardGameLoaded) return;

    final currentState = state as CardGameLoaded;
    emit(CardGameLoading());

    final result = await repository.startGame(currentState.gameState.gameId);

    result.fold(
      (failure) => emit(const CardGameError(message: 'Failed to start game')),
      (gameState) => emit(CardGameLoaded(
        gameState: gameState,
        currentPlayerId: currentState.currentPlayerId,
      )),
    );
  }

  Future<void> _onPlaceBid(
    PlaceBidEvent event,
    Emitter<CardGameBlocState> emit,
  ) async {
    if (state is! CardGameLoaded) return;

    final currentState = state as CardGameLoaded;
    
    final result = await repository.placeBid(
      currentState.gameState.gameId,
      event.playerId,
      event.bid,
    );

    result.fold(
      (failure) => emit(const CardGameError(message: 'Invalid bid')),
      (gameState) => emit(CardGameLoaded(
        gameState: gameState,
        currentPlayerId: currentState.currentPlayerId,
      )),
    );
  }

  Future<void> _onPlayCard(
    PlayCardEvent event,
    Emitter<CardGameBlocState> emit,
  ) async {
    if (state is! CardGameLoaded) return;

    final currentState = state as CardGameLoaded;

    final result = await repository.playCard(
      currentState.gameState.gameId,
      event.playerId,
      event.card,
    );

    result.fold(
      (failure) => emit(const CardGameError(message: 'Invalid card play')),
      (gameState) => emit(CardGameLoaded(
        gameState: gameState,
        currentPlayerId: currentState.currentPlayerId,
      )),
    );
  }

  Future<void> _onRefreshGame(
    RefreshGameEvent event,
    Emitter<CardGameBlocState> emit,
  ) async {
    if (state is! CardGameLoaded) return;

    final currentState = state as CardGameLoaded;

    final result = await repository.getGameState(currentState.gameState.gameId);

    result.fold(
      (failure) => emit(const CardGameError(message: 'Failed to refresh game')),
      (gameState) => emit(CardGameLoaded(
        gameState: gameState,
        currentPlayerId: currentState.currentPlayerId,
      )),
    );
  }
}
