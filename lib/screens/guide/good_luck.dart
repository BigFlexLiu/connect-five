import 'package:flutter/material.dart';


class GoodLuckGuide extends StatelessWidget {
  const GoodLuckGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Good luck'),
      ),
      body: const Center(
        child: Text(
          "That's all. Good luck and have fun!",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
