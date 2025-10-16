import '../../domain/entities/scenario.dart';

class ScenarioModel extends Scenario {
  const ScenarioModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.choices,
    required super.category,
  });

  factory ScenarioModel.fromJson(Map<String, dynamic> json) {
    return ScenarioModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      choices: (json['choices'] as List)
          .map((choice) => ChoiceModel.fromJson(choice))
          .toList(),
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'choices': choices.map((choice) => (choice as ChoiceModel).toJson()).toList(),
      'category': category,
    };
  }
}

class ChoiceModel extends Choice {
  const ChoiceModel({
    required super.id,
    required super.text,
    required super.type,
    required super.moralScore,
    required super.outcome,
  });

  factory ChoiceModel.fromJson(Map<String, dynamic> json) {
    return ChoiceModel(
      id: json['id'],
      text: json['text'],
      type: JudgementType.values.firstWhere(
        (e) => e.toString() == 'JudgementType.${json['type']}',
      ),
      moralScore: json['moralScore'],
      outcome: json['outcome'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.toString().split('.').last,
      'moralScore': moralScore,
      'outcome': outcome,
    };
  }
}
