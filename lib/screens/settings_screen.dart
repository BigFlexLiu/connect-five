import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../bloc/settings_notifier.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var settingsNotifier = Provider.of<SettingsNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: <Widget>[
          Text('Number of colors: ${settingsNotifier.numColors}',
              style: const TextStyle(fontSize: 20.0)),
          Slider(
            value: settingsNotifier.numColors.toDouble(),
            min: 4,
            max: 6,
            divisions: 2,
            label: settingsNotifier.numColors.toString(),
            onChanged: (double newValue) {
              settingsNotifier.numColors = newValue.round();
            },
          ),
          Text(
              'Min spots generated per turn: ${settingsNotifier.minSpotsPerTurn}',
              style: const TextStyle(fontSize: 20.0)),
          Slider(
            value: settingsNotifier.minSpotsPerTurn.toDouble(),
            min: 3,
            max: 5,
            divisions: 2,
            label: settingsNotifier.minSpotsPerTurn.toString(),
            onChanged: (double newValue) {
              settingsNotifier.minSpotsPerTurn = newValue.round();
            },
          ),
          Text(
              'Max spots generated per turn: ${settingsNotifier.maxSpotsPerTurn}',
              style: const TextStyle(fontSize: 20.0)),
          Slider(
            value: settingsNotifier.maxSpotsPerTurn.toDouble(),
            min: 4,
            max: 6,
            divisions: 2,
            label: settingsNotifier.maxSpotsPerTurn.toString(),
            onChanged: (double newValue) {
              settingsNotifier.maxSpotsPerTurn = newValue.round();
            },
          ),
          const Text('Spot colors:', style: TextStyle(fontSize: 20.0)),
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: List<Widget>.generate(6, (index) {
              return GestureDetector(
                onTap: () {
                  showDialog<Color>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Pick a color!'),
                        content: SingleChildScrollView(
                          child: MaterialPicker(
                            pickerColor: settingsNotifier.spotColors[index],
                            onColorChanged: (Color color) {
                              settingsNotifier.setSpotColor(index, color);
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
                    color: settingsNotifier.spotColors[index],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: settingsNotifier.resetToDefault,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            ),
            child: const Text('Reset to Default'),
          ),
        ],
      ),
    );
  }
}
