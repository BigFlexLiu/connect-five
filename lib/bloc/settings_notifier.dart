import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotifier extends ChangeNotifier {
  // Private fields
  int _numColors = 5;
  int _minSpotsPerTurn = 3;
  int _maxSpotsPerTurn = 5;
  List<Color> spotColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.yellow,
    Colors.orange,
  ];

  SettingsNotifier() {
    loadSettings();
  }

  // getters
  int get numColors => _numColors;
  int get minSpotsPerTurn => _minSpotsPerTurn;
  int get maxSpotsPerTurn => _maxSpotsPerTurn;

  // setters
  set numColors(int value) {
    _numColors = value;
    saveSettings();
    notifyListeners();
  }

  set minSpotsPerTurn(int value) {
    _minSpotsPerTurn = value;
    saveSettings();
    notifyListeners();
  }

  set maxSpotsPerTurn(int value) {
    _maxSpotsPerTurn = value;
    saveSettings();
    notifyListeners();
  }

  setSpotColor(int index, Color value) {
    spotColors[index] = value;
    saveSettings();
    notifyListeners();
  }

  void resetToDefault() {
    _numColors = 5;
    _minSpotsPerTurn = 3;
    _maxSpotsPerTurn = 5;
    spotColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.yellow,
      Colors.orange,
    ];
    saveSettings();
    notifyListeners();
  }

  void saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('numColors', _numColors);
    prefs.setInt('minSpotsPerTurn', _minSpotsPerTurn);
    prefs.setInt('maxSpotsPerTurn', _maxSpotsPerTurn);
    for (int i = 0; i < spotColors.length; i++) {
      prefs.setInt('spotColor$i', spotColors[i].value);
    }
  }

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _numColors = prefs.getInt('numColors') ?? 5;
    _minSpotsPerTurn = prefs.getInt('minSpotsPerTurn') ?? 3;
    _maxSpotsPerTurn = prefs.getInt('maxSpotsPerTurn') ?? 5;
    for (int i = 0; i < spotColors.length; i++) {
      int colorValue = prefs.getInt('spotColor$i') ?? Colors.red.value;
      spotColors[i] = Color(colorValue);
    }
    notifyListeners(); // notify listeners after loading settings
  }
}
