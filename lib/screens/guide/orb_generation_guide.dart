import 'package:flutter/material.dart';


class OrbGenerationGuide extends StatelessWidget {
  const OrbGenerationGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orb Generation'),
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 32.0),
          Center(
            child: Text(
              "'X' on the board shows where the next group of orbs will be generated and their colors.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32.0),
          Padding(
              padding: EdgeInsets.all(8.0),
              child: Image(
                  image: AssetImage("assets/howto/generation.png"),
                  fit: BoxFit.contain)),
        ],
      ),
    );
  }
}
