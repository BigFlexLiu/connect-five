import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connect_five/bloc/leaderboard.dart';

import '../bloc/game_board_notifier.dart';

class CongratulationScreen extends StatefulWidget {
  final int score;

  const CongratulationScreen({Key? key, required this.score}) : super(key: key);

  @override
  _CongratulationScreenState createState() => _CongratulationScreenState();
}

class _CongratulationScreenState extends State<CongratulationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Congratulations! You made it onto the leaderboard!',
            style: TextStyle(fontSize: 24.0),
          ),
          const SizedBox(height: 24.0),
          Text(
            'Score: ${widget.score}',
            style: const TextStyle(fontSize: 24.0),
          ),
          const SizedBox(height: 24.0),
          TextFormField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Enter your name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          ElevatedButton(
            child: const Text('Submit'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Provider.of<LeaderBoardProvider>(context, listen: false)
                    .addScore(PlayerScore(_controller.text, widget.score));
                Provider.of<GameBoardNotifier>(context, listen: false)
                    .newGame();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
