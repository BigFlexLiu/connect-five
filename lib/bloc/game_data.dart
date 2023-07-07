import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';

class GameData {
  int score = 0;
  int width = 10;
  int height = 15;
  Map<Position, int> circleSpots = {};
  Map<Position, int> nextBatchPreview = {};

  GameData();

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(toJson());
    prefs.setString('gameData', jsonString);
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('gameData');
    if (jsonString != null) {
      Map<String, dynamic> jsonData = jsonDecode(jsonString);
      fromJson(jsonData);
    }
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'circleSpots':
            circleSpots.map((k, v) => MapEntry('{"x":${k.x},"y":${k.y}}', v)),
      };

  void fromJson(Map<String, dynamic> json) {
    score = json['score'];
    circleSpots = json.containsKey('circleSpots')
        ? (json['circleSpots'] as Map).map((k, v) =>
            MapEntry(Point(jsonDecode(k)['x'], jsonDecode(k)['y']), v))
        : {};
  }
}
