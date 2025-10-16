import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/scenario.dart';
import '../../domain/usecases/get_scenarios.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameBlocState> {
  final GetScenarios getScenarios;

  GameBloc({required this.getScenarios}) : super(GameInitial()) {
    on<LoadScenariosEvent>(_onLoadScenarios);
    on<MakeChoiceEvent>(_onMakeChoice);
    on<RestartGameEvent>(_onRestartGame);
  }

  Future<void> _onLoadScenarios(
    LoadScenariosEvent event,
    Emitter<GameBlocState> emit,
  ) async {
    emit(GameLoading());
    
    final failureOrScenarios = await getScenarios(NoParams());
    
    failureOrScenarios.fold(
      (failure) => emit(const GameError(message: 'Failed to load scenarios')),
      (scenarios) => emit(GameLoaded(
        scenarios: scenarios,
        gameState: GameState.initial(),
      )),
    );
  }

  void _onMakeChoice(
    MakeChoiceEvent event,
    Emitter<GameBlocState> emit,
  ) {
    if (state is GameLoaded) {
      final currentState = state as GameLoaded;
      final currentScenario = currentState.scenarios[currentState.gameState.currentScenarioIndex];
      
      final newJudgementCounts = Map<JudgementType, int>.from(currentState.gameState.judgementCounts);
      newJudgementCounts[event.choice.type] = (newJudgementCounts[event.choice.type] ?? 0) + 1;
      
      final newCompletedScenarios = List<String>.from(currentState.gameState.completedScenarios)
        ..add(currentScenario.id);
      
      final newGameState = currentState.gameState.copyWith(
        totalScore: currentState.gameState.totalScore + event.choice.moralScore,
        judgementCounts: newJudgementCounts,
        completedScenarios: newCompletedScenarios,
      );

      emit(ChoiceMade(
        scenarios: currentState.scenarios,
        gameState: newGameState,
        selectedChoice: event.choice,
      ));
    }
  }

  void _onRestartGame(
    RestartGameEvent event,
    Emitter<GameBlocState> emit,
  ) {
    if (state is GameLoaded || state is GameCompleted) {
      final scenarios = state is GameLoaded 
          ? (state as GameLoaded).scenarios 
          : (state as GameCompleted).scenarios;
      
      emit(GameLoaded(
        scenarios: scenarios,
        gameState: GameState.initial(),
      ));
    }
  }
}
