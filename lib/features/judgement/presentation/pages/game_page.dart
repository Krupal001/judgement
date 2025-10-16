import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../injection_container.dart';
import '../bloc/game_bloc.dart';
import '../widgets/scenario_card.dart';
import '../widgets/choice_button.dart';
import '../widgets/outcome_dialog.dart';
import 'result_page.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GameBloc>()..add(LoadScenariosEvent()),
      child: const GameView(),
    );
  }
}

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade900,
              Colors.purple.shade800,
              Colors.deepPurple.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<GameBloc, GameBlocState>(
            listener: (context, state) {
              if (state is ChoiceMade) {
                _showOutcomeDialog(context, state);
              }
            },
            builder: (context, state) {
              if (state is GameLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              }

              if (state is GameError) {
                return Center(
                  child: Text(
                    state.message,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                );
              }

              if (state is GameLoaded || state is ChoiceMade) {
                final scenarios = state is GameLoaded
                    ? state.scenarios
                    : (state as ChoiceMade).scenarios;
                final gameState = state is GameLoaded
                    ? state.gameState
                    : (state as ChoiceMade).gameState;

                if (gameState.currentScenarioIndex >= scenarios.length) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultPage(
                          gameState: gameState,
                          totalScenarios: scenarios.length,
                        ),
                      ),
                    );
                  });
                  return const SizedBox();
                }

                final currentScenario = scenarios[gameState.currentScenarioIndex];

                return Column(
                  children: [
                    _buildHeader(context, gameState, scenarios.length),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            FadeInDown(
                              duration: const Duration(milliseconds: 600),
                              child: ScenarioCard(scenario: currentScenario),
                            ),
                            const SizedBox(height: 24),
                            FadeInUp(
                              duration: const Duration(milliseconds: 600),
                              child: Column(
                                children: currentScenario.choices
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final choice = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: SlideInLeft(
                                      delay: Duration(milliseconds: 200 * index),
                                      duration: const Duration(milliseconds: 600),
                                      child: ChoiceButton(
                                        choice: choice,
                                        onPressed: () {
                                          context.read<GameBloc>().add(
                                                MakeChoiceEvent(choice: choice),
                                              );
                                        },
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, gameState, int totalScenarios) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                'Scenario ${gameState.currentScenarioIndex + 1}/$totalScenarios',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '⭐ ${gameState.totalScore}',
                style: GoogleFonts.orbitron(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (gameState.currentScenarioIndex + 1) / totalScenarios,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade400),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  void _showOutcomeDialog(BuildContext context, ChoiceMade state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => OutcomeDialog(
        choice: state.selectedChoice,
        onContinue: () {
          Navigator.pop(dialogContext);
          final newGameState = state.gameState.copyWith(
            currentScenarioIndex: state.gameState.currentScenarioIndex + 1,
          );
          
          if (newGameState.currentScenarioIndex >= state.scenarios.length) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResultPage(
                  gameState: newGameState,
                  totalScenarios: state.scenarios.length,
                ),
              ),
            );
          } else {
            context.read<GameBloc>().add(LoadScenariosEvent());
          }
        },
      ),
    );
  }
}
