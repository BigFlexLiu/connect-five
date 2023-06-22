import 'package:flutter/material.dart';

class SettingsNotifier extends ChangeNotifier {
  final ValueNotifier<int> numColors = ValueNotifier<int>(5);
  final ValueNotifier<int> minSpotsPerTurn = ValueNotifier<int>(3);
  final ValueNotifier<int> maxSpotsPerTurn = ValueNotifier<int>(5);
  final List<ValueNotifier<Color>> spotColors = [
    ValueNotifier<Color>(Colors.red),
    ValueNotifier<Color>(Colors.blue),
    ValueNotifier<Color>(Colors.green),
    ValueNotifier<Color>(Colors.purple),
    ValueNotifier<Color>(Colors.yellow),
    ValueNotifier<Color>(Colors.orange),
  ];

  void resetToDefault() {
    numColors.value = 5;
    minSpotsPerTurn.value = 3;
    maxSpotsPerTurn.value = 5;
    spotColors[0].value = Colors.red;
    spotColors[1].value = Colors.blue;
    spotColors[2].value = Colors.green;
    spotColors[3].value = Colors.purple;
    spotColors[4].value = Colors.yellow;
    spotColors[5].value = Colors.orange;
  }
}
