import 'dart:convert';
import 'dart:math';

import 'package:connect_five/bloc/settings_notifier.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef Position = Point<int>;

/// This class represents a notifier for the game board in Connect Five.
class GameBoardNotifier extends ChangeNotifier {
  // Settings
  int _numColors = 0;
  int _minSpotsPerTurn = 0;
  int _maxSpotsPerTurn = 0;
  List<Color> _spotColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];

  // Game states
  int width = 10;
  int height = 15;
  int score = 0;
  Map<Position, Color> circleSpots = {};

  // UI states
  Position initialPosition = const Point(0, 0);
  Position terminalPosition = const Point(0, 0);
  List<Position> movePath = [];
  bool _moving = false;

  GameBoardNotifier() {
    loadData();
    loadGameSettings().then((value) {
      if (_numColors == 0) {
        // There was no saved game
        print('newm');
        newGame(SettingsNotifier());
      }
    });
  }

  // User interaction
  void startTouch(int x, int y) {
    if (_moving) {
      return;
    }
    print(_minSpotsPerTurn);
    initialPosition = Point(x, y);
    terminalPosition = Point(x, y);
    notifyListeners();
  }

  void updateTouch(int x, int y) {
    if (_moving) {
      return;
    }
    terminalPosition = Point(x, y);
    if (!circleSpots.containsKey(initialPosition)) {
      return;
    }
    if (x >= 0 && x < width && y >= 0 && y < height) {
      movePath = generatePath(initialPosition, terminalPosition);
    } else {
      movePath = [];
    }
    notifyListeners();
  }

  void endTouch() async {
    print("end touch");
    if (movePath.isEmpty || _moving || movePath.length <= 1) {
      movePath.clear();
      notifyListeners();
      return;
    }
    final path = movePath;
    movePath = [];
    await _move(path);
    newTurn();
    notifyListeners();
  }

  // Game flow
  void newGame(SettingsNotifier settingsNotifier) {
    // Save the settings at the start of the game
    _numColors = settingsNotifier.numColors;
    _minSpotsPerTurn = settingsNotifier.minSpotsPerTurn;
    _maxSpotsPerTurn = settingsNotifier.maxSpotsPerTurn;
    _spotColors = List<Color>.from(settingsNotifier.spotColors);

    circleSpots.clear();

    saveGameSettings();
    saveData();
    notifyListeners();
  }

  void newTurn() {
    var scoreIncrease = _removeAndScoreSpots(findConnectFive());
    score += scoreIncrease;
    if (scoreIncrease > 0) {
      return;
    }
    generateSpots();
    score += _removeAndScoreSpots(findConnectFive());
    saveData();
  }

  void reset() {
    score = 0;
    circleSpots.clear();
    saveData();
    notifyListeners();
  }

  // Game logic
  void generateSpots() {
    int numSpots =
        _determineNumSpots(_minSpotsPerTurn, _maxSpotsPerTurn, score);

    var rng = Random();
    int x, y;
    // Strategy 1
    // Collect free grids and select them at random
    if (circleSpots.length >= width * height * 0.8) {
      var emptySpots = _getEmptyGrids();
      for (var i = 0; i < numSpots; i++) {
        if (emptySpots.isEmpty) {
          return;
        }
        final randInt = rng.nextInt(emptySpots.length);
        var spot = emptySpots[randInt];
        emptySpots.removeAt(randInt);
        Color color = _spotColors[rng.nextInt(_numColors)];
        circleSpots[spot] = color;
      }
      notifyListeners();
      return;
    }
    // Strategy 2
    // Randomly select grid until a free grid is found
    for (var i = 0; i < numSpots; i++) {
      do {
        x = rng.nextInt(width);
        y = rng.nextInt(height);
      } while (circleSpots.containsKey(Point(x, y)));
      Color color = _spotColors[rng.nextInt(_numColors)];
      circleSpots[Point(x, y)] = color;
    }
    notifyListeners();
  }

  int _determineNumSpots(int base, int max, int score) {
    if (score >= 1000 && base + 3 <= max) {
      return base + 3;
    } else if (score >= 500 && base + 2 <= max) {
      return base + 2;
    } else if (score >= 100 && base + 1 <= max) {
      return base + 1;
    }
    return base;
  }

  List<Position> _getEmptyGrids() {
    List<Position> emptySpots = [];
    for (var xi = 0; xi < width; xi++) {
      for (var yi = 0; yi < height; yi++) {
        var point = Point(xi, yi);
        if (!circleSpots.containsKey(point)) {
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
        path = _tryTwoTurnsPath(x, y);
        if (path.isNotEmpty) return path;
      }
    }

    List xValues = [
      Iterable.generate(minX).toList().reversed,
      List.generate(width - maxX, (i) => i + maxX + 1)
    ].expand((x) => x).toList();

    List yValues = [
      Iterable.generate(minY).toList().reversed,
      List.generate(height - maxY, (i) => i + maxY + 1)
    ].expand((x) => x).toList();

    for (int x in xValues) {
      for (int y in yValues) {
        path = _tryTwoTurnsPath(x, y);
        if (path.isNotEmpty) return path;
      }
    }

    return [];
  }

  List<Position> _tryTwoTurnsPath(int x, int y) {
    Position midPoint1 = Point(x, initialPosition.y);
    Position midPoint2 = Point(x, terminalPosition.y);

    List<Position> path = _linePath(initialPosition, midPoint1) +
        _linePath(midPoint1, midPoint2) +
        _linePath(midPoint2, terminalPosition);
    if (!_pathIntersectsCircle(path)) return path;

    midPoint1 = Point(initialPosition.x, y);
    midPoint2 = Point(terminalPosition.x, y);

    path = _linePath(initialPosition, midPoint1) +
        _linePath(midPoint1, midPoint2) +
        _linePath(midPoint2, terminalPosition);
    if (!_pathIntersectsCircle(path)) return path;

    return [];
  }

  bool _pathIntersectsCircle(List<Point> path) {
    // Exclude the initial position by skipping the first item in path
    return path.skip(1).any((point) => circleSpots.containsKey(point));
  }

  Future<void> _move(List<Position> path) async {
    _moving = true;
    Position current = path.first;
    for (Position position in path) {
      circleSpots[position] = circleSpots.remove(current)!;
      current = Point(position.x, position.y);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 50));
    }
    _moving = false;
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
      return circleSpots.containsKey(point);
    }

    // Checks if the color of the spot at the given point is the same as the color of the last spot in the segment
    bool isSameColorAsLastSpot(Position point, List<Position> segment) {
      return segment.isEmpty || circleSpots[point] == circleSpots[segment.last];
    }

    // Check rows
    for (int y = 0; y < height; y++) {
      List<Position> segment = [];
      for (int x = 0; x < width; x++) {
        Position point = Point(x, y);
        if (isPointOccupied(point) && isSameColorAsLastSpot(point, segment)) {
          segment.add(point);
        } else {
          if (segment.length >= 5) {
            occurrences.add(segment);
          }
          segment = [];
          if (circleSpots.containsKey(point)) {
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
    for (int x = 0; x < width; x++) {
      List<Position> segment = [];
      for (int y = 0; y < height; y++) {
        Position point = Point(x, y);
        if (isPointOccupied(point) && isSameColorAsLastSpot(point, segment)) {
          segment.add(point);
        } else {
          if (segment.length >= 5) {
            occurrences.add(segment);
          }
          segment = [];
          if (circleSpots.containsKey(point)) {
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
    print(spotsGroup);

    for (var group in spotsGroup) {
      int groupLength = group.length;
      if (groupLength >= 5) {
        print(groupLength);
        for (var point in group) {
          circleSpots.remove(point);
        }

        score += 20; // base score for five elements
        if (groupLength > 5) {
          int extraScoreIncrement = 10;
          for (int i = 6; i <= groupLength; i++) {
            extraScoreIncrement *= 2;
          }
          score += extraScoreIncrement;
        }
      }
    }

    return score;
  }

  // Save and load data
  void saveGameSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('game_numColors', _numColors);
    prefs.setInt('game_minSpotsPerTurn', _minSpotsPerTurn);
    prefs.setInt('game_maxSpotsPerTurn', _maxSpotsPerTurn);
    for (int i = 0; i < _spotColors.length; i++) {
      prefs.setInt('game_spotColor$i', _spotColors[i].value);
    }
  }

  Future<void> loadGameSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _numColors = prefs.getInt('game_numColors') ?? _numColors;
    _minSpotsPerTurn = prefs.getInt('game_minSpotsPerTurn') ?? _minSpotsPerTurn;
    _maxSpotsPerTurn = prefs.getInt('game_maxSpotsPerTurn') ?? _maxSpotsPerTurn;
    for (int i = 0; i < _spotColors.length; i++) {
      int? colorValue = prefs.getInt('game_spotColor$i');
      if (colorValue != null) {
        _spotColors[i] = Color(colorValue);
      }
    }
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
      notifyListeners();
    }
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'width': width,
        'height': height,
        'circleSpots': circleSpots
            .map((k, v) => MapEntry('{"x":${k.x},"y":${k.y}}', v.value)),
      };

  void fromJson(Map<String, dynamic> json) {
    score = json['score'];
    width = json['width'];
    height = json['height'];
    circleSpots = (json['circleSpots'] as Map).map((k, v) =>
        MapEntry(Point(jsonDecode(k)['x'], jsonDecode(k)['y']), Color(v)));
  }

  // Getters
  Color get selectedSpotColor {
    return circleSpots[initialPosition]!;
  }

  bool get gameOver {
    return _getEmptyGrids().isEmpty;
  }
}
