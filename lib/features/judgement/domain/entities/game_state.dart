import 'package:equatable/equatable.dart';
import 'scenario.dart';

class GameState extends Equatable {
  final int currentScenarioIndex;
  final int totalScore;
  final Map<JudgementType, int> judgementCounts;
  final List<String> completedScenarios;

  const GameState({
    required this.currentScenarioIndex,
    required this.totalScore,
    required this.judgementCounts,
    required this.completedScenarios,
  });

  factory GameState.initial() {
    return const GameState(
      currentScenarioIndex: 0,
      totalScore: 0,
      judgementCounts: {
        JudgementType.lawful: 0,
        JudgementType.neutral: 0,
        JudgementType.chaotic: 0,
      },
      completedScenarios: [],
    );
  }

  GameState copyWith({
    int? currentScenarioIndex,
    int? totalScore,
    Map<JudgementType, int>? judgementCounts,
    List<String>? completedScenarios,
  }) {
    return GameState(
      currentScenarioIndex: currentScenarioIndex ?? this.currentScenarioIndex,
      totalScore: totalScore ?? this.totalScore,
      judgementCounts: judgementCounts ?? this.judgementCounts,
      completedScenarios: completedScenarios ?? this.completedScenarios,
    );
  }

  String get alignment {
    final lawful = judgementCounts[JudgementType.lawful] ?? 0;
    final neutral = judgementCounts[JudgementType.neutral] ?? 0;
    final chaotic = judgementCounts[JudgementType.chaotic] ?? 0;

    if (lawful > neutral && lawful > chaotic) return 'Lawful Good';
    if (chaotic > neutral && chaotic > lawful) return 'Chaotic Rebel';
    return 'True Neutral';
  }

  @override
  List<Object> get props => [currentScenarioIndex, totalScore, judgementCounts, completedScenarios];
}
