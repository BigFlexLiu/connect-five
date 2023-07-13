import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bloc/game_board_notifier.dart';

class GameOverScreen extends StatelessWidget {
  final int score;

  const GameOverScreen({Key? key, required this.score}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Over'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Text(
              'Score: $score',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Provider.of<GameBoardNotifier>(context, listen: false)
                    .newGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        ),
      ),
    );
  }
}
