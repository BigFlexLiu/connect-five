import 'package:connect_five/screens/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bloc/game_board_notifier.dart';
import 'end_game_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const GameScreen(),
        if (Provider.of<GameBoardNotifier>(context).gameOver)
          EndGameScreen(score: Provider.of<GameBoardNotifier>(context).score),
      ],
    );
  }
}
