import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bloc/game_board_notifier.dart';

class GameOverScreen extends StatelessWidget {
  final int score;

  GameOverScreen({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7), // semi-transparent background
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Game Over',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Score: $score',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Provider.of<GameBoardNotifier>(context, listen: false).reset();
                // Code to restart the game
                // This could involve routing to the initial screen or resetting the game state
              },
              child: Text('Play Again'),
            ),
          ],
        ),
      ),
    );
  }
}
