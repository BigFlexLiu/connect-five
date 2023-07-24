import 'dart:math';

import 'package:connect_five/bloc/game_board_notifier.dart';
import 'package:connect_five/screens/menu.dart';
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
    Size screenSize = MediaQuery.of(context).size;

    // Calculate total grid area (80% of screen area)
    final double totalGridArea = screenSize.width * screenSize.height * 0.7;

    // Calculate area, width, and height of each grid item
    final double gridItemArea = totalGridArea / 150;
    final double gridItemSize = sqrt(gridItemArea);

    // Estimate number of rows and columns
    final int cols = (screenSize.width / gridItemSize).floor();
    final int rows = (screenSize.height * 0.7 / gridItemSize).floor();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameBoardNotifier(cols, rows)),
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
