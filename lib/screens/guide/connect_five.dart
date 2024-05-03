import 'package:flutter/material.dart';

import '../../constant.dart';

class ConnectFiveGuide extends StatelessWidget {
  const ConnectFiveGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Five'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 32.0),
          const Center(
            child: Text(
              "Form Connect fives to earn points and eliminate orbs.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32.0),
          Flexible(
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
                }),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("slide"),
                Icon(Icons.arrow_right),
              ],
            ),
          )
        ],
      ),
    );
  }
}
