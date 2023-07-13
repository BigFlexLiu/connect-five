import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bloc/leaderboard.dart';

class LeaderBoardScreen extends StatelessWidget {
  const LeaderBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              Provider.of<LeaderBoardProvider>(context, listen: false)
                  .clearScores();
              // Handle back button press
            },
          ),
        ],
      ),
      body: Consumer<LeaderBoardProvider>(
        builder: (context, leaderboardProvider, child) {
          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(color: Colors.grey),
            itemCount: leaderboardProvider.leaderBoard.scores.length,
            itemBuilder: (context, index) {
              final score = leaderboardProvider.leaderBoard.scores[index];
              return Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[
                    Text('#${index + 1}', style: const TextStyle(fontSize: 24.0)),
                    const SizedBox(width: 16.0),
                    Expanded(
                        child: Text(score.playerName,
                            style: const TextStyle(fontSize: 24.0))),
                    Text(score.score.toString(),
                        style: const TextStyle(fontSize: 24.0)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
