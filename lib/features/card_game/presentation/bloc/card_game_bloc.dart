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
    on<StartNextRoundEvent>(_onStartNextRound);
  }

  @override
  Future<void> close() {
    _gameSubscription?.cancel();
    return super.close();
  }

  void _startListening(String gameId, String currentPlayerId) {
    _gameSubscription?.cancel();
    
    print('🎧 Starting Firebase listener for game: $gameId, player: $currentPlayerId');
    
    if (repository is FirebaseGameRepository) {
      _gameSubscription = (repository as FirebaseGameRepository)
          .watchGameState(gameId)
          .listen(
            (gameState) {
              print('✅ Firebase update received - Phase: ${gameState.currentRound?.phase}, CurrentPlayerIndex: ${gameState.currentRound?.currentPlayerIndex}');
              print('Players: ${gameState.players.map((p) => '${p.name}(bid: ${p.bid})').toList()}');
              add(GameStateUpdatedEvent(gameState: gameState, currentPlayerId: currentPlayerId));
            },
            onError: (error) {
              print('❌ Firebase listener error: $error');
              // Don't emit error state, just log it and try to continue
              // The game will continue with the last known state
            },
            cancelOnError: false,  // Keep listening even if there's an error
          );
    }
  }

  void _onGameStateUpdated(
    GameStateUpdatedEvent event,
    Emitter<CardGameBlocState> emit,
  ) {
    print('Emitting updated game state');
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
      (failure) => emit(CardGameError(message: failure.message ?? 'Failed to join game')),
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
      (failure) => emit(CardGameError(message: failure.message ?? 'Failed to start game')),
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
      (failure) {
        print('PlaceBid failed in BLoC: ${failure.message}');
        emit(CardGameError(message: failure.message ?? 'Invalid bid'));
      },
      (gameState) {
        print('PlaceBid succeeded in BLoC - Firebase listener will update state');
        // Don't emit state here - let the Firebase listener handle it
        // This prevents race conditions and ensures both players get the update
      },
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

  Future<void> _onStartNextRound(
    StartNextRoundEvent event,
    Emitter<CardGameBlocState> emit,
  ) async {
    if (state is! CardGameLoaded) return;

    final result = await repository.startNextRound(event.gameId);

    result.fold(
      (failure) => emit(CardGameError(message: failure.message ?? 'Failed to start next round')),
      (gameState) {
        print('Next round started - Firebase listener will update state');
        // Don't emit state here - let the Firebase listener handle it
      },
    );
  }
}
