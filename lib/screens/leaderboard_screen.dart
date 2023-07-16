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
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text(
                      'Are you sure you want to delete the leaderboard?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<LeaderBoardProvider>(context, listen: false)
                            .clearScores();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<LeaderBoardProvider>(
        builder: (context, leaderboardProvider, child) {
          if (leaderboardProvider.isLeaderBoardEmpty) {
            return const Center(
                child: Text(
              "Nothing to see here.",
              style: TextStyle(fontSize: 24),
            ));
          }
          return ListView.separated(
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.grey),
            itemCount: leaderboardProvider.leaderBoard.scores.length,
            itemBuilder: (context, index) {
              final score = leaderboardProvider.leaderBoard.scores[index];
              return Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[
                    Text('#${index + 1}',
                        style: const TextStyle(fontSize: 24.0)),
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
