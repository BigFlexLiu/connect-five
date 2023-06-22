import 'package:connect_five/bloc/game_board_notifier.dart';
import 'package:connect_five/bloc/settings_notifier.dart';
import 'package:connect_five/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameBoardNotifier()),
        ChangeNotifierProvider(create: (_) => SettingsNotifier()),
      ],
      child: MaterialApp(
        theme: ThemeData(
            // Define your theme here.
            ),
        home: Home(),
      ),
    );
  }
}
