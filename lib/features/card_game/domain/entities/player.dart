import 'package:equatable/equatable.dart';
import 'card.dart';

class Player extends Equatable {
  final String id;
  final String name;
  final List<PlayingCard> hand;
  final int? bid;
  final int tricksWon;
  final int totalScore;
  final bool isHost;

  const Player({
    required this.id,
    required this.name,
    this.hand = const [],
    this.bid,
    this.tricksWon = 0,
    this.totalScore = 0,
    this.isHost = false,
  });

  Player copyWith({
    String? id,
    String? name,
    List<PlayingCard>? hand,
    int? bid,
    bool resetBid = false,  // Add flag to explicitly reset bid
    int? tricksWon,
    int? totalScore,
    bool? isHost,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      hand: hand ?? this.hand,
      bid: resetBid ? null : (bid ?? this.bid),  // Reset if flag is true
      tricksWon: tricksWon ?? this.tricksWon,
      totalScore: totalScore ?? this.totalScore,
      isHost: isHost ?? this.isHost,
    );
  }

  bool get hasBid => bid != null;

  bool get madeContract => bid != null && tricksWon == bid;

  @override
  List<Object?> get props => [id, name, hand, bid, tricksWon, totalScore, isHost];
}
