import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';

class GameData {
  int width = 10;
  int height = 15;

  int score = 0;
  int openGrid = 150; // Number of grids without an orb on it
  bool isGameOver = false;

  List<List<int?>> board = [];
  Map<Position, int> nextGenerationPreview = {};
  List<int> colorBan = List.filled(7, 0); // Key: color, value: num turn banned

  // Midturn information
  List<Position> removeOnTurnEnd = [];
  List<Position> matches = [];

  // Bonuses
  int turnsSkipped = 0;
  int generationNerf = 0;

  GameData(this.width, this.height) {
    newBoard();
  }

  void newBoard() {
    board.clear();
    for (int i = 0; i < width; i++) {
      board.add([]);
      for (int j = 0; j < height; j++) {
        board[i].add(null);
      }
    }
  }

  void clear() {
    score = 0;
    newBoard();
    nextGenerationPreview.clear();
    turnsSkipped = 0;
    generationNerf = 0;
    isGameOver = false;
    openGrid = width * height;
    removeOnTurnEnd.clear();
    colorBan = List.filled(7, 0);
  }

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
        'board': json.encode(board),
        'nextBatchPreview': nextGenerationPreview
            .map((k, v) => MapEntry('{"x":${k.x},"y":${k.y}}', v)),
        'turnsSkipped': turnsSkipped,
        'generationNerf': generationNerf,
        'freeSpots': openGrid,
        'colorBan': colorBan,
      };

  void fromJson(Map<String, dynamic> json) {
    score = json['score'];
    List<dynamic> listDynamic = jsonDecode(json['board']);
    board = listDynamic.map((listItem) {
      List<int?> listItemInt = List<int?>.from(listItem);
      return listItemInt;
    }).toList();
    nextGenerationPreview = json.containsKey('nextBatchPreview')
        ? (json['nextBatchPreview'] as Map).map((k, v) =>
            MapEntry(Point(jsonDecode(k)['x'], jsonDecode(k)['y']), v))
        : {};
    turnsSkipped = json['turnsSkipped'];
    generationNerf = json['generationNerf'];
    openGrid = json['freeSpots'];
    colorBan = List<int>.from(json['colorBan']);
  }

  int? at(Position pos) {
    return board[pos.x][pos.y];
  }

  void setAt(Position pos, int? value) {
    if (at(pos) == null && value != null) {
      openGrid -= 1;
    } else if (at(pos) != null && value == null) {
      openGrid += 1;
    }
    board[pos.x][pos.y] = value;
  }

  void scheduleRemoval(Position pos) {
    removeOnTurnEnd.add(pos);
  }

  void addMatches(Iterable<Position> newMatch) {
    matches.addAll(newMatch);
  }
}
