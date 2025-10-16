import 'package:equatable/equatable.dart';

class Scenario extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<Choice> choices;
  final String category;

  const Scenario({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.choices,
    required this.category,
  });

  @override
  List<Object> get props => [id, title, description, imageUrl, choices, category];
}

class Choice extends Equatable {
  final String id;
  final String text;
  final JudgementType type;
  final int moralScore;
  final String outcome;

  const Choice({
    required this.id,
    required this.text,
    required this.type,
    required this.moralScore,
    required this.outcome,
  });

  @override
  List<Object> get props => [id, text, type, moralScore, outcome];
}

enum JudgementType {
  lawful,
  neutral,
  chaotic,
}
