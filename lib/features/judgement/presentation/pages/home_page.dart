import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../card_game/presentation/bloc/card_game_bloc.dart';
import '../../../card_game/presentation/pages/lobby_page.dart';
import '../../../../injection_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _nameController = TextEditingController();
  final _gameIdController = TextEditingController();
  int _selectedPlayerCount = 4; // Default 4 players

  @override
  void dispose() {
    _nameController.dispose();
    _gameIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
              Color(0xFF533483),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: const Text(
                      '🃏',
                      style: TextStyle(fontSize: 100),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      'JUDGEMENT',
                      style: GoogleFonts.orbitron(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInDown(
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 800),
                    child: Text(
                      'The Ultimate Card Game',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: _buildNameInput(),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    delay: const Duration(milliseconds: 650),
                    child: _buildPlayerCountSelector(),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    delay: const Duration(milliseconds: 700),
                    child: _buildHostButton(),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: Text(
                      'OR',
                      style: GoogleFonts.orbitron(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    delay: const Duration(milliseconds: 900),
                    child: _buildGameIdInput(),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    delay: const Duration(milliseconds: 1000),
                    child: _buildJoinButton(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          hintText: 'Enter your name',
          border: InputBorder.none,
          icon: Icon(Icons.person, color: Color(0xFF00d9ff)),
          hintStyle: GoogleFonts.poppins(color: Colors.grey),
        ),
        style: GoogleFonts.poppins(fontSize: 16),
      ),
    );
  }

  Widget _buildGameIdInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _gameIdController,
        decoration: InputDecoration(
          hintText: 'Enter Game ID',
          border: InputBorder.none,
          icon: Icon(Icons.tag, color: Color(0xFF00d9ff)),
          hintStyle: GoogleFonts.poppins(color: Colors.grey),
        ),
        style: GoogleFonts.poppins(fontSize: 16),
        textCapitalization: TextCapitalization.characters,
      ),
    );
  }

  Widget _buildPlayerCountSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: Color(0xFF00d9ff)),
              const SizedBox(width: 12),
              Text(
                'Number of Players',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(9, (index) {
              final playerCount = index + 2; // 2 to 10 players
              final isSelected = _selectedPlayerCount == playerCount;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPlayerCount = playerCount;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              Color(0xFF00d9ff),
                              Color(0xFF0abde3),
                            ],
                          )
                        : null,
                    color: isSelected ? null : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Color(0xFF00d9ff) : Colors.grey.shade400,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Color(0xFF00d9ff).withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$playerCount',
                      style: GoogleFonts.orbitron(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            'Game will wait for $_selectedPlayerCount players to join',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Color(0xFFf39c12),
            Color(0xFFe94560),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFf39c12).withValues(alpha: 0.6),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _hostGame,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              'HOST GAME',
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJoinButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Color(0xFF9b59b6),
            Color(0xFF533483),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF9b59b6).withValues(alpha: 0.6),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _joinGame,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              'JOIN GAME',
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _hostGame() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your name');
      return;
    }

    // Create BLoC instance that won't be auto-disposed
    final gameBloc = sl<CardGameBloc>()
      ..add(CreateGameEvent(
        hostName: _nameController.text.trim(),
        playerCount: _selectedPlayerCount,
      ));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: gameBloc,
          child: const LobbyPage(),
        ),
      ),
    );
  }

  void _joinGame() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your name');
      return;
    }

    if (_gameIdController.text.trim().isEmpty) {
      _showError('Please enter Game ID');
      return;
    }

    // Create BLoC instance that won't be auto-disposed
    final gameBloc = sl<CardGameBloc>()
      ..add(JoinGameEvent(
        gameId: _gameIdController.text.trim().toUpperCase(),
        playerName: _nameController.text.trim(),
      ));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: gameBloc,
          child: const LobbyPage(),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
