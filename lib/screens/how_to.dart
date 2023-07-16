import 'package:flutter/material.dart';

import '../constant.dart';

class HowToPage extends StatelessWidget {
  const HowToPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Play'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 50,
          ),
          const Center(
            child: Text(
              "Move orb to form a group of five to score points.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          Expanded(
            child: GridView.builder(
                itemCount: 150, // 10 rows * 15 columns
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10, // defines number of columns
                ),
                itemBuilder: (BuildContext context, int index) {
                  final int x = index % 10;
                  final int y = index ~/ 10;
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: sample[x][y] != null
                        ? Image(image: AssetImage(images[sample[x][y]!]))
                        : null,
                  );
                }),
          ),
        ],
      ),
    );
  }
}
