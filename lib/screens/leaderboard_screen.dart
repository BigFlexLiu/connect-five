import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bloc/leaderboard.dart';

class LeaderBoardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
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
            separatorBuilder: (context, index) => Divider(color: Colors.grey),
            itemCount: leaderboardProvider.leaderBoard.scores.length,
            itemBuilder: (context, index) {
              final score = leaderboardProvider.leaderBoard.scores[index];
              return Container(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[
                    Text('#${index + 1}', style: TextStyle(fontSize: 24.0)),
                    SizedBox(width: 16.0),
                    Expanded(
                        child: Text(score.playerName,
                            style: TextStyle(fontSize: 24.0))),
                    Text(score.score.toString(),
                        style: TextStyle(fontSize: 24.0)),
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
