import '../models/scenario_model.dart';
import '../../domain/entities/scenario.dart';

abstract class ScenarioLocalDataSource {
  Future<List<ScenarioModel>> getScenarios();
}

class ScenarioLocalDataSourceImpl implements ScenarioLocalDataSource {
  @override
  Future<List<ScenarioModel>> getScenarios() async {
    // Simulating async data fetch with hardcoded scenarios
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      const ScenarioModel(
        id: '1',
        title: 'The Stolen Bread',
        description: 'You witness a homeless person stealing bread from a local bakery. The baker is chasing them down the street.',
        imageUrl: '🍞',
        category: 'Ethics',
        choices: [
          ChoiceModel(
            id: '1a',
            text: 'Stop the thief and return the bread',
            type: JudgementType.lawful,
            moralScore: 30,
            outcome: 'The baker thanks you, but the homeless person goes hungry. The community sees you as law-abiding.',
          ),
          ChoiceModel(
            id: '1b',
            text: 'Offer to pay for the bread',
            type: JudgementType.neutral,
            moralScore: 50,
            outcome: 'You help both parties. The baker gets paid and the homeless person gets food. Balance is maintained.',
          ),
          ChoiceModel(
            id: '1c',
            text: 'Distract the baker and let them escape',
            type: JudgementType.chaotic,
            moralScore: 20,
            outcome: 'The homeless person escapes with food. The baker is frustrated, but you helped someone in need.',
          ),
        ],
      ),
      const ScenarioModel(
        id: '2',
        title: 'The Secret Keeper',
        description: 'Your best friend confides in you that they cheated on an important exam. The teacher is investigating and asks if you know anything.',
        imageUrl: '📝',
        category: 'Loyalty',
        choices: [
          ChoiceModel(
            id: '2a',
            text: 'Tell the truth to the teacher',
            type: JudgementType.lawful,
            moralScore: 40,
            outcome: 'Your friend faces consequences but learns a lesson. Your honesty is noted, but the friendship is strained.',
          ),
          ChoiceModel(
            id: '2b',
            text: 'Say you don\'t know anything',
            type: JudgementType.neutral,
            moralScore: 30,
            outcome: 'You avoid the conflict entirely. Your friendship remains intact, but you carry the burden of the secret.',
          ),
          ChoiceModel(
            id: '2c',
            text: 'Lie to protect your friend',
            type: JudgementType.chaotic,
            moralScore: 25,
            outcome: 'Your friend is grateful and the friendship strengthens. However, you\'ve compromised your integrity.',
          ),
        ],
      ),
      const ScenarioModel(
        id: '3',
        title: 'The Lost Wallet',
        description: 'You find a wallet on the street containing \$500 cash and an ID. You\'re struggling financially this month.',
        imageUrl: '💰',
        category: 'Integrity',
        choices: [
          ChoiceModel(
            id: '3a',
            text: 'Return it to the owner immediately',
            type: JudgementType.lawful,
            moralScore: 50,
            outcome: 'The owner is extremely grateful and offers a reward. You feel proud of your integrity.',
          ),
          ChoiceModel(
            id: '3b',
            text: 'Take half and return the rest',
            type: JudgementType.neutral,
            moralScore: 25,
            outcome: 'You help yourself a bit while still doing something good. The owner is happy to get most of it back.',
          ),
          ChoiceModel(
            id: '3c',
            text: 'Keep the money',
            type: JudgementType.chaotic,
            moralScore: 10,
            outcome: 'Your financial problems are temporarily solved, but guilt weighs on your conscience.',
          ),
        ],
      ),
      const ScenarioModel(
        id: '4',
        title: 'The Whistleblower',
        description: 'You discover your company is dumping toxic waste illegally. Reporting it could cost you and your colleagues their jobs.',
        imageUrl: '🏭',
        category: 'Justice',
        choices: [
          ChoiceModel(
            id: '4a',
            text: 'Report to authorities immediately',
            type: JudgementType.lawful,
            moralScore: 60,
            outcome: 'The company faces consequences and the environment is protected. You lose your job but gain respect.',
          ),
          ChoiceModel(
            id: '4b',
            text: 'Report anonymously',
            type: JudgementType.neutral,
            moralScore: 45,
            outcome: 'The issue is addressed while you maintain your position. A balanced approach to a difficult situation.',
          ),
          ChoiceModel(
            id: '4c',
            text: 'Stay silent to protect jobs',
            type: JudgementType.chaotic,
            moralScore: 15,
            outcome: 'Jobs are saved but environmental damage continues. You prioritized immediate needs over long-term consequences.',
          ),
        ],
      ),
      const ScenarioModel(
        id: '5',
        title: 'The Final Test',
        description: 'A stranger offers you a briefcase with \$1 million, but you must never speak to your family again. They\'ll think you abandoned them.',
        imageUrl: '💼',
        category: 'Values',
        choices: [
          ChoiceModel(
            id: '5a',
            text: 'Refuse the offer',
            type: JudgementType.lawful,
            moralScore: 55,
            outcome: 'Family bonds prove stronger than money. You maintain your relationships and values.',
          ),
          ChoiceModel(
            id: '5b',
            text: 'Negotiate different terms',
            type: JudgementType.neutral,
            moralScore: 35,
            outcome: 'You try to find a middle ground, but some things can\'t be negotiated. The offer is withdrawn.',
          ),
          ChoiceModel(
            id: '5c',
            text: 'Take the money',
            type: JudgementType.chaotic,
            moralScore: 20,
            outcome: 'You\'re wealthy but alone. Money can\'t replace the warmth of family, and regret sets in.',
          ),
        ],
      ),
    ];
  }
}
