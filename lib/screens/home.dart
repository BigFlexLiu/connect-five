import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bloc/game_board_notifier.dart';
import 'game_over_screen.dart';
import 'game_screen.dart';
import 'main_screen.dart';

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
        MainScreen(),
        if (Provider.of<GameBoardNotifier>(context).gameOver)
          GameOverScreen(score: Provider.of<GameBoardNotifier>(context).score),
      ],
    );
  }
}
