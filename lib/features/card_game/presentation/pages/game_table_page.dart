import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/card_game_bloc.dart';
import '../../domain/entities/game_round.dart';
import '../widgets/playing_card_widget.dart';
import '../widgets/bid_dialog.dart';

class GameTablePage extends StatefulWidget {
  const GameTablePage({super.key});

  @override
  State<GameTablePage> createState() => _GameTablePageState();
}

class _GameTablePageState extends State<GameTablePage> {
  String? _lastBidDialogPlayerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade900,
              Colors.teal.shade800,
              Colors.blue.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<CardGameBloc, CardGameBlocState>(
            builder: (context, state) {
              if (state is! CardGameLoaded) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final game = state.gameState;
              final round = game.currentRound;
              if (round == null) return const SizedBox();

              final currentPlayer = game.getPlayerById(state.currentPlayerId);
              if (currentPlayer == null) return const SizedBox();

              print('GameTablePage - Round: ${round.roundNumber}, Phase: ${round.phase}, CurrentPlayer: ${game.currentPlayer?.name}, MyPlayer: ${currentPlayer.name}, MyBid: ${currentPlayer.bid}, LastDialogKey: $_lastBidDialogPlayerId');
              
              // Create a unique key for this bid opportunity (round + player + turn)
              final bidKey = '${round.roundNumber}_${currentPlayer.id}_${game.currentPlayer?.id}';
              print('Current bidKey: $bidKey');
              
              // Show bid dialog if it's player's turn to bid and we haven't shown it yet
              final isMyTurn = game.currentPlayer?.id == currentPlayer.id;
              final hasNotBid = !currentPlayer.hasBid;
              final isNewKey = _lastBidDialogPlayerId != bidKey;
              
              print('Dialog check - Phase: ${round.phase}, MyTurn: $isMyTurn, HasNotBid: $hasNotBid, IsNewKey: $isNewKey');
              
              final shouldShowDialog = round.phase == GamePhase.bidding &&
                  isMyTurn &&
                  hasNotBid &&
                  isNewKey;
              
              if (shouldShowDialog) {
                print('✅ Should show bid dialog for ${currentPlayer.name} with key: $bidKey');
                // Set the key immediately to prevent multiple shows
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _lastBidDialogPlayerId != bidKey) {
                    setState(() {
                      _lastBidDialogPlayerId = bidKey;
                    });
                    print('✅ Showing bid dialog for ${currentPlayer.name}');
                    _showBidDialog(context, game, currentPlayer.id);
                  }
                });
              } else {
                print('❌ Not showing dialog');
              }

              // Check if round just completed and show winner
              if (round.phase == GamePhase.bidding && 
                  currentPlayer.hand.isNotEmpty && 
                  game.players.every((p) => p.bid == null)) {
                // Round just started, check if we should show previous round winner
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && round.roundNumber > 0) {
                    _showRoundWinner(context, game);
                  }
                });
              }

              return Column(
                children: [
                  _buildGameInfo(round, game),
                  Expanded(
                    child: _buildGameTable(game, round, currentPlayer.id),
                  ),
                  _buildPlayerHand(currentPlayer.hand, context, game, currentPlayer.id),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGameInfo(GameRound round, game) {
    String phaseText = '';
    Color phaseColor = Colors.white;
    
    switch (round.phase) {
      case GamePhase.bidding:
        phaseText = 'BIDDING PHASE';
        phaseColor = Colors.orange.shade400;
        break;
      case GamePhase.playing:
        phaseText = 'PLAYING PHASE';
        phaseColor = Colors.green.shade400;
        break;
      case GamePhase.roundComplete:
        phaseText = 'ROUND COMPLETE';
        phaseColor = Colors.blue.shade400;
        break;
      case GamePhase.gameComplete:
        phaseText = 'GAME COMPLETE';
        phaseColor = Colors.purple.shade400;
        break;
      default:
        phaseText = 'WAITING';
        phaseColor = Colors.grey.shade400;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: phaseColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: phaseColor, width: 2),
            ),
            child: Text(
              phaseText,
              style: GoogleFonts.orbitron(
                color: phaseColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoChip('Round ${round.roundNumber + 1}', Icons.casino),
              _buildInfoChip(
                round.trumpSuit != null ? 'Trump: ${_getTrumpSymbol(round.trumpSuit!)}' : 'No Trump',
                Icons.star,
              ),
              _buildInfoChip('${round.cardsPerPlayer} Cards', Icons.style),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.amber.shade400, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameTable(game, GameRound round, String currentPlayerId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Players info
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: game.players.map<Widget>((player) {
              final isCurrentPlayer = player.id == currentPlayerId;
              final isActive = game.currentPlayer?.id == player.id;
              
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.amber.shade400.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive ? Colors.amber.shade400 : Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      isCurrentPlayer ? '${player.name} (You)' : player.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (player.hasBid)
                      Text(
                        'Bid: ${player.bid} | Won: ${player.tricksWon}',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    Text(
                      'Score: ${player.totalScore}',
                      style: GoogleFonts.poppins(
                        color: Colors.amber.shade400,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          // Current trick
          if (round.currentTrick.isNotEmpty) ...[
            Text(
              'Current Trick',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: round.currentTrick.map((play) {
                final player = game.getPlayerById(play.playerId);
                return Column(
                  children: [
                    PlayingCardWidget(card: play.card, size: 80),
                    const SizedBox(height: 8),
                    Text(
                      player?.name ?? '',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerHand(List hand, BuildContext context, game, String playerId) {
    if (hand.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Waiting for next round...',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }

    final isMyTurn = game.currentPlayer?.id == playerId;
    final isPlaying = game.currentRound?.phase == GamePhase.playing;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your Hand',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isMyTurn && isPlaying) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'YOUR TURN',
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: hand.map<Widget>((card) {
                final canPlay = isMyTurn && isPlaying;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: canPlay
                        ? () {
                            context.read<CardGameBloc>().add(
                                  PlayCardEvent(playerId: playerId, card: card),
                                );
                          }
                        : null,
                    child: Opacity(
                      opacity: canPlay ? 1.0 : 0.6,
                      child: PlayingCardWidget(card: card, size: 100),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (!isPlaying) ...[
            const SizedBox(height: 8),
            Text(
              'Waiting for all bids...',
              style: GoogleFonts.poppins(
                color: Colors.orange.shade300,
                fontSize: 12,
              ),
            ),
          ] else if (!isMyTurn) ...[
            const SizedBox(height: 8),
            Text(
              'Waiting for other players...',
              style: GoogleFonts.poppins(
                color: Colors.blue.shade300,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showRoundWinner(BuildContext context, game) {
    // Find the player with highest score
    final sortedPlayers = List.from(game.players)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
    final leader = sortedPlayers.first;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade700, Colors.orange.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'Round ${game.currentRound!.roundNumber} Complete!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Current Leader',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                leader.name,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${leader.totalScore} points',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBidDialog(BuildContext context, game, String playerId) {
    // Capture the BLoC reference BEFORE showing the dialog
    final bloc = context.read<CardGameBloc>();
    
    print('Showing dialog - BLoC closed: ${bloc.isClosed}');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BidDialog(
        maxBid: game.currentRound!.cardsPerPlayer,
        onBidPlaced: (bid) {
          print('Bid placed: $bid - BLoC closed: ${bloc.isClosed}');
          Navigator.pop(dialogContext);
          
          if (!bloc.isClosed) {
            print('Adding PlaceBidEvent for player $playerId with bid $bid');
            bloc.add(
              PlaceBidEvent(playerId: playerId, bid: bid),
            );
          } else {
            print('ERROR: BLoC is closed, cannot add event');
          }
        },
        canBid: (bid) => game.canBid(bid),
      ),
    );
  }

  String _getTrumpSymbol(suit) {
    switch (suit.toString()) {
      case 'Suit.spades':
        return '♠';
      case 'Suit.diamonds':
        return '♦';
      case 'Suit.clubs':
        return '♣';
      case 'Suit.hearts':
        return '♥';
      default:
        return '';
    }
  }
}
