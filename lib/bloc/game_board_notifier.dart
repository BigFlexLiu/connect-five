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
  int pause = 0; // semaphore, 0 is false, 1+ is true. For animation
  List<Position> connectiveFivePos = [];
  bool playSound = false;

  GameBoardNotifier() {
    gameData = GameData();
    gameLogic = GameLogic(gameData, onClear);
    _loadData();
  }

  void onClear(List<Position> cleared) async {
    if (cleared.isEmpty) {
      return;
    }
    connectiveFivePos = List.from(cleared);
    notifyListeners();
    pause += 1;
    await Future.delayed(const Duration(milliseconds: 500));
    pause -= 1;
    connectiveFivePos.clear();

    playSound = true;
    notifyListeners();
  }

  Future<void> _loadData() async {
    await gameData.loadData();
    notifyListeners();
  }

  // User interaction
  void startTouch(int x, int y) {
    print(gameData.generationNerf);
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
    if (gameData.at(initialPosition) == null) {
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
    gameLogic.nextTurn();
    notifyListeners();
  }

  void shuffle() {
    gameLogic.shuffle(gameData.board);
    notifyListeners();
  }

  void clearBoard() {
    gameData.newBoard();
    newTurn();
    notifyListeners();
  }

  Future<void> _move(List<Position> path) async {
    Position current = path.first;
    for (Position position in path.skip(1)) {
      gameData.setAt(position, gameData.at(current));
      gameData.setAt(current, null);
      current = position;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Color? getPositionColor(Position pos) {
    if (gameData.at(pos) != null) {
      return pathColors[gameData.at(pos)!];
    } else if (movePath.contains(pos)) {
      return pathColors[gameData.at(initialPosition)!];
    }
    return null;
  }

  String? selectedSpotImage(Position pos) {
    if (gameData.at(pos) != null) {
      return images[gameData.at(pos)!];
    }
    return null;
  }

  String? previewImage(Position pos) {
    if (gameData.nextGenerationPreview.containsKey(pos)) {
      return previewImages[gameData.nextGenerationPreview[pos]!];
    }
    return null;
  }

  int get score => gameData.score;
  bool get gameOver => gameData.isGameOver;
  int get orbNum => gameLogic.numOrbsToGenerate + generationNerf;
  int get generationNerf => gameData.generationNerf;
  int get newestColor => gameLogic.numColors - 1;
  int get turnsPaused => gameData.turnsSkipped;
}
