import 'dart:math';

import 'package:connect_five/bloc/game_board_notifier.dart';
import 'package:connect_five/screens/menu.dart';
import 'package:connect_five/util/util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bloc/leaderboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final Size screenSize = MediaQuery.of(context).size;

    final Point<int> boardSize = getNumRowAndCol(screenSize);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => GameBoardNotifier(boardSize.x, boardSize.y)),
        ChangeNotifierProvider(
          create: (context) => LeaderBoardProvider(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
            // Define your theme here.
            ),
        home: const Menu(),
      ),
    );
  }
}
