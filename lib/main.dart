import 'package:connect_five/bloc/game_board_notifier.dart';
import 'package:connect_five/screens/game_screen.dart';
import 'package:connect_five/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameBoardNotifier(),
      child: MaterialApp(
        theme: ThemeData(
            // Define your theme here.
            ),
        home: Home(),
      ),
    );
  }
}
