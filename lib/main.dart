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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameBoardNotifier()),
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
