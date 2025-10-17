import 'dart:math';
import '../entities/card.dart';
import '../entities/game_round.dart';

class GameLogicService {
  // Generate a standard 52-card deck
  List<PlayingCard> generateDeck() {
    final deck = <PlayingCard>[];
    for (final suit in [Suit.spades, Suit.diamonds, Suit.clubs, Suit.hearts]) {
      for (final cardValue in CardValue.values) {
        if (cardValue != CardValue.joker_1 && cardValue != CardValue.joker_2) {
          deck.add(PlayingCard(suit: suit, value: cardValue));
        }
      }
    }
    return deck;
  }

  // Shuffle and deal cards
  Map<String, List<PlayingCard>> dealCards(
    List<String> playerIds,
    int cardsPerPlayer,
  ) {
    final deck = generateDeck();
    deck.shuffle(Random());

    final hands = <String, List<PlayingCard>>{};
    for (int i = 0; i < playerIds.length; i++) {
      hands[playerIds[i]] = deck
          .skip(i * cardsPerPlayer)
          .take(cardsPerPlayer)
          .toList();
    }

    return hands;
  }

  // Determine trump suit for a round
  Suit? getTrumpSuit(int roundNumber) {
    final trumpPattern = [
      Suit.spades,
      Suit.diamonds,
      Suit.clubs,
      Suit.hearts,
    ];
    return trumpPattern[roundNumber % 4];
  }

  // Check if a card play is valid
  bool isValidPlay(
    PlayingCard card,
    List<PlayingCard> playerHand,
    Suit? leadSuit,
  ) {
    // First card of trick is always valid
    if (leadSuit == null) return true;

    // Must follow suit if possible
    final hasLeadSuit = playerHand.any((c) => c.suit == leadSuit);
    if (hasLeadSuit) {
      return card.suit == leadSuit;
    }

    // Can play any card if don't have lead suit
    return true;
  }

  // Get list of playable cards from player's hand
  List<PlayingCard> getPlayableCards(
    List<PlayingCard> playerHand,
    Suit? leadSuit,
  ) {
    // If no lead suit (first card of trick), all cards are playable
    if (leadSuit == null) return playerHand;

    // Check if player has cards of the lead suit
    final leadSuitCards = playerHand.where((c) => c.suit == leadSuit).toList();
    
    // If player has lead suit cards, they must play one of them
    if (leadSuitCards.isNotEmpty) {
      return leadSuitCards;
    }

    // If player doesn't have lead suit, all cards are playable
    return playerHand;
  }

  // Determine winner of a trick
  String determineTrickWinner(
    List<CardPlay> trick,
    Suit? trumpSuit,
  ) {
    if (trick.isEmpty) throw Exception('Empty trick');

    final leadSuit = trick.first.card.suit;
    CardPlay winner = trick.first;

    for (final play in trick.skip(1)) {
      if (_compareCards(play.card, winner.card, leadSuit, trumpSuit) > 0) {
        winner = play;
      }
    }

    return winner.playerId;
  }

  // Compare two cards (returns positive if card1 wins)
  int _compareCards(
    PlayingCard card1,
    PlayingCard card2,
    Suit leadSuit,
    Suit? trumpSuit,
  ) {
    // Trump beats non-trump
    if (trumpSuit != null) {
      if (card1.suit == trumpSuit && card2.suit != trumpSuit) return 1;
      if (card2.suit == trumpSuit && card1.suit != trumpSuit) return -1;
      
      // Both trump - compare values
      if (card1.suit == trumpSuit && card2.suit == trumpSuit) {
        return card1.numericValue.compareTo(card2.numericValue);
      }
    }

    // Lead suit beats other suits
    if (card1.suit == leadSuit && card2.suit != leadSuit) return 1;
    if (card2.suit == leadSuit && card1.suit != leadSuit) return -1;

    // Same suit - compare values
    if (card1.suit == card2.suit) {
      return card1.numericValue.compareTo(card2.numericValue);
    }

    // Different suits, neither trump nor lead - first card wins
    return 0;
  }

  // Calculate score for a player
  // Simple rule: Exact bid match = 10 points, otherwise 0 points
  int calculateScore(
    int bid,
    int tricksWon,
    ScoringStrategy strategy,
  ) {
    final madeBid = bid == tricksWon;
    
    // Simplified scoring: Match bid = 10 points, fail = 0 points
    return madeBid ? 10 : 0;
  }

  // Sort hand by suit and rank
  List<PlayingCard> sortHand(List<PlayingCard> hand) {
    final sorted = List<PlayingCard>.from(hand);
    sorted.sort((a, b) {
      if (a.suit.index != b.suit.index) {
        return a.suit.index.compareTo(b.suit.index);
      }
      return a.numericValue.compareTo(b.numericValue);
    });
    return sorted;
  }
}
