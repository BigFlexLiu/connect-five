import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import 'animated_state.dart';

typedef Position = Point<int>;

class GameData {
  int score = 0;
  int width = 10;
  int height = 15;
  Map<Position, int> circleSpots = {};

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
    circleSpots = (json['circleSpots'] as Map).map(
        (k, v) => MapEntry(Point(jsonDecode(k)['x'], jsonDecode(k)['y']), v));
  }
}

class GameLogic {
  GameData gameData;
  Function(List<Position> connectFives) onConnectFiveFound;

  GameLogic(this.gameData, this.onConnectFiveFound);

  // Game flow
  void newGame() {
    gameData.score = 0;
    gameData.circleSpots.clear();
    newTurn();

    gameData.saveData();
  }

  void newTurn() async {
    List<List<Position>> connectFives = findConnectFive();
    await onConnectFiveFound(connectFives.expand((i) => i).toList());
    var scoreIncrease = _removeAndScoreSpots(findConnectFive());
    gameData.score += scoreIncrease;
    // Skip spot generation if there is a connectFive
    if (scoreIncrease > 0) {
      return;
    }

    // spot generation
    generateSpots();
    connectFives = findConnectFive();
    await onConnectFiveFound(connectFives.expand((i) => i).toList());
    gameData.score += _removeAndScoreSpots(findConnectFive());
    gameData.saveData();
  }

  // Game logic
  void generateSpots() {
    var rng = Random();
    int x, y;
    // Strategy 1
    // Collect free grids and select them at random
    if (gameData.circleSpots.length >= gameData.width * gameData.height * 0.8) {
      var emptySpots = _getEmptyGrids();
      for (var i = 0; i < numSpots; i++) {
        if (emptySpots.isEmpty) {
          return;
        }
        final randInt = rng.nextInt(emptySpots.length);
        var spot = emptySpots[randInt];
        emptySpots.removeAt(randInt);
        gameData.circleSpots[spot] = rng.nextInt(numColors);
      }
      return;
    }
    // Strategy 2
    // Randomly select grid until a free grid is found
    for (var i = 0; i < numSpots; i++) {
      do {
        x = rng.nextInt(WIDTH);
        y = rng.nextInt(HEIGHT);
      } while (gameData.circleSpots.containsKey(Point(x, y)));
      gameData.circleSpots[Point(x, y)] = rng.nextInt(numColors);
    }
  }

  List<Position> _getEmptyGrids() {
    List<Position> emptySpots = [];
    for (var xi = 0; xi < WIDTH; xi++) {
      for (var yi = 0; yi < HEIGHT; yi++) {
        var point = Point(xi, yi);
        if (!gameData.circleSpots.containsKey(point)) {
          emptySpots.add(point);
        }
      }
    }
    return emptySpots;
  }

  List<Position> generatePath(
      Position initialPosition, Position terminalPosition) {
    List<Position> path;

    // Case 1: Straight line
    if (initialPosition.x == terminalPosition.x ||
        initialPosition.y == terminalPosition.y) {
      path = _linePath(initialPosition, terminalPosition);
      if (!_pathIntersectsCircle(path)) return path;
    }

    // Case 2: One turn
    Position midPoint1 = Point(initialPosition.x, terminalPosition.y);
    Position midPoint2 = Point(terminalPosition.x, initialPosition.y);

    path = _linePath(initialPosition, midPoint1) +
        _linePath(midPoint1, terminalPosition);
    if (!_pathIntersectsCircle(path)) return path;

    path = _linePath(initialPosition, midPoint2) +
        _linePath(midPoint2, terminalPosition);
    if (!_pathIntersectsCircle(path)) return path;

    // Case 3: Two turns
    int minX = min(initialPosition.x, terminalPosition.x).toInt();
    int maxX = max(initialPosition.x, terminalPosition.x).toInt();
    int minY = min(initialPosition.y, terminalPosition.y).toInt();
    int maxY = max(initialPosition.y, terminalPosition.y).toInt();

    for (int x = minX; x <= maxX; x++) {
      for (int y = minY; y <= maxY; y++) {
        path = _tryTwoTurnsPath(initialPosition, terminalPosition, x, y);
        if (path.isNotEmpty) return path;
      }
    }

    List xValues = [
      Iterable.generate(minX).toList().reversed,
      List.generate(WIDTH - maxX, (i) => i + maxX + 1)
    ].expand((x) => x).toList();

    List yValues = [
      Iterable.generate(minY).toList().reversed,
      List.generate(HEIGHT - maxY, (i) => i + maxY + 1)
    ].expand((x) => x).toList();

    for (int x in xValues) {
      for (int y in yValues) {
        path = _tryTwoTurnsPath(initialPosition, terminalPosition, x, y);
        if (path.isNotEmpty) return path;
      }
    }

    return [];
  }

  List<Position> _tryTwoTurnsPath(Position initialPosition,
      Position terminalPosition, int targetX, int targetY) {
    Position midPoint1 = Point(targetX, initialPosition.y);
    Position midPoint2 = Point(targetX, terminalPosition.y);

    List<Position> path = _linePath(initialPosition, midPoint1) +
        _linePath(midPoint1, midPoint2) +
        _linePath(midPoint2, terminalPosition);
    if (!_pathIntersectsCircle(path)) return path;

    midPoint1 = Point(initialPosition.x, targetY);
    midPoint2 = Point(terminalPosition.x, targetY);

    path = _linePath(initialPosition, midPoint1) +
        _linePath(midPoint1, midPoint2) +
        _linePath(midPoint2, terminalPosition);
    if (!_pathIntersectsCircle(path)) return path;

    return [];
  }

  bool _pathIntersectsCircle(List<Point> path) {
    // Exclude the initial position by skipping the first item in path
    return path.skip(1).any((point) => gameData.circleSpots.containsKey(point));
  }

  // Generates a path from start to end
  List<Position> _linePath(Position start, Position end) {
    assert(start.x == end.x || start.y == end.y);

    List<Position> path = [];
    Position dir = Point(end.x - start.x, end.y - start.y);
    Position normDir = Point(dir.x.sign, dir.y.sign);
    Position current = start;

    while (current != end) {
      path.add(current);
      current = Point(current.x + normDir.x, current.y + normDir.y);
    }
    path.add(end); // Include the end point
    return path;
  }

  // Finds all occurrences of five or more in a row or column
  List<List<Position>> findConnectFive() {
    List<List<Position>> occurrences = [];

    // Checks if a point on the board is occupied by a spot
    bool isPointOccupied(Position point) {
      return gameData.circleSpots.containsKey(point);
    }

    // Checks if the color of the spot at the given point is the same as the color of the last spot in the segment
    bool isSameColorAsLastSpot(Position point, List<Position> segment) {
      return segment.isEmpty ||
          gameData.circleSpots[point] == gameData.circleSpots[segment.last];
    }

    // Check rows
    for (int y = 0; y < HEIGHT; y++) {
      List<Position> segment = [];
      for (int x = 0; x < WIDTH; x++) {
        Position point = Point(x, y);
        if (isPointOccupied(point) && isSameColorAsLastSpot(point, segment)) {
          segment.add(point);
        } else {
          if (segment.length >= 5) {
            occurrences.add(segment);
          }
          segment = [];
          if (gameData.circleSpots.containsKey(point)) {
            segment.add(point);
          }
        }
      }

      if (segment.length >= 5) {
        occurrences.add(segment);
      }
      segment = [];
    }

    // Check columns
    for (int x = 0; x < WIDTH; x++) {
      List<Position> segment = [];
      for (int y = 0; y < HEIGHT; y++) {
        Position point = Point(x, y);
        if (isPointOccupied(point) && isSameColorAsLastSpot(point, segment)) {
          segment.add(point);
        } else {
          if (segment.length >= 5) {
            occurrences.add(segment);
          }
          segment = [];
          if (gameData.circleSpots.containsKey(point)) {
            segment.add(point);
          }
        }
      }

      if (segment.length >= 5) {
        occurrences.add(segment);
      }
      segment = [];
    }

    return occurrences;
  }

  int _removeAndScoreSpots(List<List<Position>> spotsGroup) {
    int score = 0;
    int bonusRemoval = 0;

    for (var group in spotsGroup) {
      int groupLength = group.length;
      if (groupLength >= 5) {
        for (var point in group) {
          gameData.circleSpots.remove(point);
        }

        // Bonus scores
        score += 20; // base score for five elements
        if (groupLength > 5) {
          int extraScoreIncrement = 10;
          for (int i = 6; i <= groupLength; i++) {
            extraScoreIncrement *= 2;
          }
          score += extraScoreIncrement;
        }
        bonusRemoval += groupLength - 5;
      }
    }
    // Bonus spot removal
    for (int i = 0; i < bonusRemoval; i++) {
      if (gameData.circleSpots.isEmpty) {
        break;
      }
      var randomIndex = Random().nextInt(gameData.circleSpots.length);
      var randomKey = gameData.circleSpots.keys.elementAt(randomIndex);
      gameData.circleSpots.remove(randomKey);
    }

    return score;
  }

  bool get gameOver {
    return _getEmptyGrids().isEmpty;
  }

  int get numSpots {
    if (gameData.score > 10000) {
      return 7;
    } else if (gameData.score > 2000) {
      return 6;
    } else if (gameData.score > 500) {
      return 5;
    } else if (gameData.score > 100) {
      return 4;
    }
    return 3;
  }

  int get numColors {
    if (gameData.score > 20000) {
      return 7;
    } else if (gameData.score > 5000) {
      return 6;
    } else if (gameData.score > 1000) {
      return 5;
    } else if (gameData.score > 200) {
      return 4;
    }
    return 3;
  }

  // ...rest of the Game Logic methods go here...
}

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
    if (!gameData.circleSpots.containsKey(initialPosition)) {
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
      gameData.circleSpots[position] = gameData.circleSpots.remove(current)!;
      current = Point(position.x, position.y);
      await Future.delayed(const Duration(milliseconds: 50));
      notifyListeners();
    }
  }

  Color? getPositionColor(Position pos) {
    if (gameData.circleSpots.containsKey(pos)) {
      return pathColors[gameData.circleSpots[pos]!];
    } else if (movePath.contains(pos)) {
      return pathColors[gameData.circleSpots[initialPosition]!];
    }
    return null;
  }

  String? selectedSpotImage(Position pos) {
    if (gameData.circleSpots.containsKey(pos)) {
      return images[gameData.circleSpots[pos]!];
    }
    return null;
  }

  int get score => gameData.score;
  bool get gameOver => gameLogic.gameOver;
}
