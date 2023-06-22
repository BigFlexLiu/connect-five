import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsScreen extends StatelessWidget {
  final ValueNotifier<int> numColors = ValueNotifier<int>(5);
  final ValueNotifier<int> minSpotsPerTurn = ValueNotifier<int>(3);
  final ValueNotifier<int> maxSpotsPerTurn = ValueNotifier<int>(5);
  final List<ValueNotifier<Color>> spotColors =
      List.generate(6, (_) => ValueNotifier<Color>(Colors.red));

  void resetToDefault() {
    numColors.value = 5;
    minSpotsPerTurn.value = 3;
    maxSpotsPerTurn.value = 5;
    spotColors.forEach((color) => color.value = Colors.red);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.0),
        children: <Widget>[
          Text('Number of colors:', style: TextStyle(fontSize: 20.0)),
          ValueListenableBuilder<int>(
            valueListenable: numColors,
            builder: (context, value, child) {
              return Slider(
                value: value.toDouble(),
                min: 4,
                max: 6,
                divisions: 2,
                label: value.toString(),
                onChanged: (double newValue) {
                  numColors.value = newValue.round();
                },
              );
            },
          ),
          Text('Min spots generated per turn:',
              style: TextStyle(fontSize: 20.0)),
          ValueListenableBuilder<int>(
            valueListenable: minSpotsPerTurn,
            builder: (context, value, child) {
              return Slider(
                value: value.toDouble(),
                min: 3,
                max: 5,
                divisions: 2,
                label: value.toString(),
                onChanged: (double newValue) {
                  minSpotsPerTurn.value = newValue.round();
                },
              );
            },
          ),
          Text('Max spots generated per turn:',
              style: TextStyle(fontSize: 20.0)),
          ValueListenableBuilder<int>(
            valueListenable: maxSpotsPerTurn,
            builder: (context, value, child) {
              return Slider(
                value: value.toDouble(),
                min: 4,
                max: 7,
                divisions: 3,
                label: value.toString(),
                onChanged: (double newValue) {
                  maxSpotsPerTurn.value = newValue.round();
                },
              );
            },
          ),
          Text('Spot colors:', style: TextStyle(fontSize: 20.0)),
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: List<Widget>.generate(6, (index) {
              return ValueListenableBuilder<Color>(
                valueListenable: spotColors[index],
                builder: (context, color, child) {
                  return GestureDetector(
                    onTap: () {
                      showDialog<Color>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Pick a color!'),
                            content: SingleChildScrollView(
                              child: MaterialPicker(
                                pickerColor: color,
                                onColorChanged: (Color color) {
                                  spotColors[index].value = color;
                                },
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Close'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: resetToDefault,
            child: Text('Reset to Default'),
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            ),
          ),
        ],
      ),
    );
  }
}
