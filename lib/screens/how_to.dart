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
          Flexible(
            flex: 1,
            child: Container(), // Spacer equivalent.
          ),
          const Flexible(
            flex: 1,
            child: Center(
              child: Text(
                "Move orb to form a group of five to score points.",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Flexible(
            flex: 1,
            child: Center(
              child: Text(
                "Form a larger group for bonuses.",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(), // Spacer equivalent.
          ),
          Flexible(
              flex: 16,
              child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sample.length * sample[0].length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: sample.length,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final int x = index % sample.length;
                    final int y = index ~/ sample.length;

                    final image =
                        sample[x][y] != null ? images[sample[x][y]] : null;

                    // Define the child for the Container based on whether there's an image or not
                    final containerChild = (image != null)
                        ? Image(image: AssetImage(image), fit: BoxFit.contain)
                        : null;
                    // Return the Container
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                      ),
                      child: containerChild,
                    );
                  })),
        ],
      ),
    );
  }
}
