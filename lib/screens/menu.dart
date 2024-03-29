import 'package:connect_five/screens/home.dart';
import 'package:flutter/material.dart';

import 'how_to.dart';
import 'leaderboard_screen.dart';

class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(),
              const Text(
                "Connect Five",
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: 300, // Set your desired width here
                height: 80, // Set your desired height here
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return const Home();
                      }), // replace with your actual game screen widget
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      textStyle: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(16.0)))),
                  child: const Text('Play'),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: 300, // Make this the same as the first button
                height: 80, // Make this the same as the first button
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const HowToPage()), // replace with your actual settings screen widget
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      textStyle: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(16.0)))),
                  child: const Text('How to play'),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: 300, // Make this the same as the first button
                height: 80, // Make this the same as the first button
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const LeaderBoardScreen()), // replace with your actual settings screen widget
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      textStyle: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(16.0)))),
                  child: const Text('Leaderboard'),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
