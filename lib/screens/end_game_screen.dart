import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bloc/game_board_notifier.dart';
import '../bloc/leaderboard.dart';
import 'congratulation_screen.dart';
import 'new_high_score_screen.dart';

class EndGameScreen extends StatelessWidget {
  final int score;

  const EndGameScreen({Key? key, required this.score}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final leaderBoardProvider =
        Provider.of<LeaderBoardProvider>(context, listen: false);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              child: (score > leaderBoardProvider.leaderBoard.min_highscore)
                  ? CongratulationScreen(
                      score:
                          score) // If the score is higher than the lowest score on the leaderboard, display CongratulationScreen
                  : Column(
                      // Else, display GameOverScreen
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
                            Provider.of<GameBoardNotifier>(context,
                                    listen: false)
                                .newGame();
                          },
                          child: const Text('Play Again'),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
