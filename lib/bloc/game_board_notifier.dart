import 'dart:math';

import 'package:flutter/material.dart';

import '../constant.dart';
import 'game_data.dart';
import 'game_logic.dart';

class GameBoardNotifier extends ChangeNotifier {
  late GameData gameData;
  late GameLogic gameLogic;

  // UI states
  Position initialPosition = const Point(0, 0);
  Position terminalPosition = const Point(0, 0);
  List<Position> movePath = [];
  int pause = 0; // semaphore, 0 is false, 1+ is true
  List<Position> connectiveFivePos = [];

  GameBoardNotifier() {
    gameData = GameData();
    gameLogic = GameLogic(gameData, onConnectFive);
    _loadData();
  }

  void onConnectFive(List<Position> connectFives) async {
    if (connectFives.isEmpty) {
      return;
    }
    connectiveFivePos = connectFives;
    notifyListeners();

    pause += 1;
    await Future.delayed(Duration(milliseconds: 500));
    connectiveFivePos.clear();
    pause -= 1;
    notifyListeners();
  }

  Future<void> _loadData() async {
    await gameData.loadData();
    notifyListeners();
  }

  // User interaction
  void startTouch(int x, int y) {
    if (pause != 0) {
      return;
    }
    initialPosition = Point(x, y);
    terminalPosition = Point(x, y);
    notifyListeners();
  }

  void updateTouch(int x, int y) {
    if (pause != 0) {
      return;
    }
    terminalPosition = Point(x, y);
    if (!gameData.orbs.containsKey(initialPosition)) {
      return;
    }
    if (x >= 0 && x < WIDTH && y >= 0 && y < HEIGHT) {
      movePath = gameLogic.generatePath(initialPosition, terminalPosition);
    } else {
      movePath = [];
    }
    notifyListeners();
  }

  void endTouch() async {
    if (movePath.isEmpty || pause != 0 || movePath.length <= 1) {
      movePath.clear();
      notifyListeners();
      return;
    }
    final path = movePath;
    movePath = [];

    pause += 1;
    await _move(path);
    pause -= 1;

    newTurn();
    notifyListeners();
  }

  void newGame() {
    gameLogic.newGame();
    notifyListeners();
  }

  void newTurn() async {
    gameLogic.newTurn();
    notifyListeners();
  }

  Future<void> _move(List<Position> path) async {
    Position current = path.first;
    for (Position position in path) {
      gameData.orbs[position] = gameData.orbs.remove(current)!;
      current = Point(position.x, position.y);
      await Future.delayed(const Duration(milliseconds: 50));
      notifyListeners();
    }
  }

  Color? getPositionColor(Position pos) {
    if (gameData.orbs.containsKey(pos)) {
      return pathColors[gameData.orbs[pos]!];
    } else if (movePath.contains(pos)) {
      return pathColors[gameData.orbs[initialPosition]!];
    }
    return null;
  }

  String? selectedSpotImage(Position pos) {
    if (gameData.orbs.containsKey(pos)) {
      return images[gameData.orbs[pos]!];
    }
    return null;
  }

  String? previewImage(Position pos) {
    if (gameData.nextBatchPreview.containsKey(pos)) {
      return previewImages[gameData.nextBatchPreview[pos]!];
    }
    return null;
  }

  int get score => gameData.score;
  bool get gameOver => gameLogic.gameOver;
}
