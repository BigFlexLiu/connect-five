import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../bloc/settings_notifier.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsNotifier>(
      builder: (context, settingsNotifier, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Settings'),
          ),
          body: ListView(
            padding: EdgeInsets.all(20.0),
            children: <Widget>[
              ValueListenableBuilder<int>(
                valueListenable: settingsNotifier.numColors,
                builder: (context, value, child) {
                  return Text('Number of colors: $value',
                      style: TextStyle(fontSize: 20.0));
                },
              ),
              ValueListenableBuilder<int>(
                valueListenable: settingsNotifier.numColors,
                builder: (context, value, child) {
                  return Slider(
                    value: value.toDouble(),
                    min: 4,
                    max: 6,
                    divisions: 2,
                    label: value.toString(),
                    onChanged: (double newValue) {
                      settingsNotifier.numColors.value = newValue.round();
                    },
                  );
                },
              ),
              ValueListenableBuilder<int>(
                valueListenable: settingsNotifier.minSpotsPerTurn,
                builder: (context, value, child) {
                  return Text('Min spots generated per turn: $value',
                      style: TextStyle(fontSize: 20.0));
                },
              ),
              ValueListenableBuilder<int>(
                valueListenable: settingsNotifier.minSpotsPerTurn,
                builder: (context, value, child) {
                  return Slider(
                    value: value.toDouble(),
                    min: 3,
                    max: 5,
                    divisions: 2,
                    label: value.toString(),
                    onChanged: (double newValue) {
                      settingsNotifier.minSpotsPerTurn.value = newValue.round();
                      settingsNotifier.maxSpotsPerTurn.value = max(
                          newValue.round(),
                          settingsNotifier.maxSpotsPerTurn.value);
                    },
                  );
                },
              ),
              ValueListenableBuilder<int>(
                valueListenable: settingsNotifier.maxSpotsPerTurn,
                builder: (context, value, child) {
                  return Text('Max spots generated per turn: $value',
                      style: TextStyle(fontSize: 20.0));
                },
              ),
              ValueListenableBuilder<int>(
                valueListenable: settingsNotifier.maxSpotsPerTurn,
                builder: (context, value, child) {
                  return Slider(
                    value: value.toDouble(),
                    min: 4,
                    max: 6,
                    divisions: 3,
                    label: value.toString(),
                    onChanged: (double newValue) {
                      settingsNotifier.maxSpotsPerTurn.value = newValue.round();
                      settingsNotifier.minSpotsPerTurn.value = min(
                          newValue.round(),
                          settingsNotifier.minSpotsPerTurn.value);
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
                    valueListenable: settingsNotifier.spotColors[index],
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
                                      settingsNotifier.spotColors[index].value =
                                          color;
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
                onPressed: settingsNotifier.resetToDefault,
                child: Text('Reset to Default'),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  onPrimary: Colors.white,
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
