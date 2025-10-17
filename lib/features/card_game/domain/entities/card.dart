import 'package:equatable/equatable.dart';
import 'package:playing_cards/playing_cards.dart';

// Re-export the playing_cards types for convenience
export 'package:playing_cards/playing_cards.dart' show Suit, CardValue;

// Wrapper class to maintain compatibility with existing code
class PlayingCard extends Equatable {
  final Suit suit;
  final CardValue value;

  const PlayingCard({required this.suit, required this.value});

  // Convert CardValue to numeric value for game logic
  int get numericValue {
    switch (value) {
      case CardValue.two:
        return 2;
      case CardValue.three:
        return 3;
      case CardValue.four:
        return 4;
      case CardValue.five:
        return 5;
      case CardValue.six:
        return 6;
      case CardValue.seven:
        return 7;
      case CardValue.eight:
        return 8;
      case CardValue.nine:
        return 9;
      case CardValue.ten:
        return 10;
      case CardValue.jack:
        return 11;
      case CardValue.queen:
        return 12;
      case CardValue.king:
        return 13;
      case CardValue.ace:
        return 14;
      default:
        return 0;
    }
  }

  String get rankString {
    switch (value) {
      case CardValue.two:
        return '2';
      case CardValue.three:
        return '3';
      case CardValue.four:
        return '4';
      case CardValue.five:
        return '5';
      case CardValue.six:
        return '6';
      case CardValue.seven:
        return '7';
      case CardValue.eight:
        return '8';
      case CardValue.nine:
        return '9';
      case CardValue.ten:
        return '10';
      case CardValue.jack:
        return 'J';
      case CardValue.queen:
        return 'Q';
      case CardValue.king:
        return 'K';
      case CardValue.ace:
        return 'A';
      default:
        return '';
    }
  }

  String get suitSymbol {
    switch (suit) {
      case Suit.spades:
        return '♠';
      case Suit.diamonds:
        return '♦';
      case Suit.clubs:
        return '♣';
      case Suit.hearts:
        return '♥';
      case Suit.joker:
        return '🃏';
    }
  }

  bool get isRed => suit == Suit.diamonds || suit == Suit.hearts;

  @override
  List<Object> get props => [suit, value];

  @override
  String toString() => '$rankString$suitSymbol';
}
