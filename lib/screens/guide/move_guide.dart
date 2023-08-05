import 'package:flutter/material.dart';


class MoveGuide extends StatelessWidget {
  const MoveGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Move an orb'),
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 24.0),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Drag an orb to move it.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Colored trails show the move path.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "A move is only valid if there is a colored trail.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32.0),
          Padding(
              padding: EdgeInsets.all(8.0),
              child: Image(
                  image: AssetImage("assets/howto/move.png"),
                  fit: BoxFit.contain)),
          Spacer(),
        ],
      ),
    );
  }
}
