import 'package:flutter/material.dart';


class TopBarGuide extends StatelessWidget {
  const TopBarGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orb Generation'),
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 24.0),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Top bar displays information of the game.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "The circle contains the newest orb color.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "The number in the circle is the number of orb colors.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "The value next to it is the number of orbs to generate.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Hourglass shows the pause in orb generation.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          SizedBox(height: 32.0),
          Padding(
              padding: EdgeInsets.all(8.0),
              child: Image(
                  image: AssetImage("assets/howto/topbar.png"),
                  fit: BoxFit.contain)),
        ],
      ),
    );
  }
}
