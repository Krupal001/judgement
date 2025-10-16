import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/scenario.dart';

class ChoiceButton extends StatelessWidget {
  final Choice choice;
  final VoidCallback onPressed;

  const ChoiceButton({
    super.key,
    required this.choice,
    required this.onPressed,
  });

  Color _getColorForType(JudgementType type) {
    switch (type) {
      case JudgementType.lawful:
        return Colors.blue.shade400;
      case JudgementType.neutral:
        return Colors.green.shade400;
      case JudgementType.chaotic:
        return Colors.red.shade400;
    }
  }

  IconData _getIconForType(JudgementType type) {
    switch (type) {
      case JudgementType.lawful:
        return Icons.balance;
      case JudgementType.neutral:
        return Icons.handshake;
      case JudgementType.chaotic:
        return Icons.whatshot;
    }
  }

  String _getLabelForType(JudgementType type) {
    switch (type) {
      case JudgementType.lawful:
        return 'LAWFUL';
      case JudgementType.neutral:
        return 'NEUTRAL';
      case JudgementType.chaotic:
        return 'CHAOTIC';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType(choice.type);
    final icon = _getIconForType(choice.type);
    final label = _getLabelForType(choice.type);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        choice.text,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
