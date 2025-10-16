import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/card.dart';

class PlayingCardWidget extends StatelessWidget {
  final PlayingCard card;
  final double size;

  const PlayingCardWidget({
    super.key,
    required this.card,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    final color = card.isRed ? Colors.red.shade700 : Colors.black87;

    return Container(
      width: size * 0.7,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top left
          Positioned(
            top: 4,
            left: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.rankString,
                  style: GoogleFonts.orbitron(
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  card.suitSymbol,
                  style: TextStyle(
                    fontSize: size * 0.18,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          // Center
          Center(
            child: Text(
              card.suitSymbol,
              style: TextStyle(
                fontSize: size * 0.4,
                color: color.withValues(alpha: 0.3),
              ),
            ),
          ),
          // Bottom right
          Positioned(
            bottom: 4,
            right: 4,
            child: Transform.rotate(
              angle: 3.14159, // 180 degrees
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.rankString,
                    style: GoogleFonts.orbitron(
                      fontSize: size * 0.2,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    card.suitSymbol,
                    style: TextStyle(
                      fontSize: size * 0.18,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
