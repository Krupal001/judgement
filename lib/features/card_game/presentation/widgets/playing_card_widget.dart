import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import '../../domain/entities/card.dart' as game_card;

class PlayingCardWidget extends StatelessWidget {
  final game_card.PlayingCard card;
  final double size;

  const PlayingCardWidget({
    super.key,
    required this.card,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    // Use the playing_cards package widget
    return SizedBox(
      width: size * 0.7,
      height: size,
      child: PlayingCardView(
        card: PlayingCard(card.suit, card.value),
        showBack: false,
        elevation: 8.0,
      ),
    );
  }
}
