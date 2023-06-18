import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

typedef Position = Point<int>;

class GameBoardNotifier extends ChangeNotifier {
  int score = 0;
  Position initialPosition = Point(0, 0);
  Position terminalPosition = Point(0, 0);
  int width = 10;
  int height = 15;
  List<Position> movePath = [];
  final Map<Position, Color> circleSpots = {};
  final List<Color> spotColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
  ];
  bool _moving = false;

  // User interaction
  void startTouch(int x, int y) {
    print("start touch");
    if (_moving) {
      return;
    }
    initialPosition = Point(x, y);
    terminalPosition = Point(x, y);
    notifyListeners();
  }

  void updateTouch(int x, int y) {
    print("update touch");
    if (_moving) {
      return;
    }
    print((x, y));
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

  void newTurn() {
    var scoreIncrease = removeAndScoreSpots(findConnectFive());
    score += scoreIncrease;
    if (scoreIncrease > 0) {
      return;
    }
    generateSpots();
    score += removeAndScoreSpots(findConnectFive());
  }

  // Game flow
  void reset() {
    score = 0;
    circleSpots.clear();
    notifyListeners();
  }

  void generateSpots({int numSpots = 5}) {
    var rng = Random();
    int x, y;
    // Strategy 1
    // Collect free grids and select them at random
    if (circleSpots.length >= width * height * 0.8) {
      var emptySpots = getEmptyGrids();
      for (var i = 0; i < numSpots; i++) {
        if (emptySpots.length == 0) {
          return;
        }
        final randInt = rng.nextInt(emptySpots.length);
        var spot = emptySpots[randInt];
        emptySpots.removeAt(randInt);
        Color color = spotColors[rng.nextInt(spotColors.length)];
        circleSpots[spot] = color;
        print(circleSpots[spot]);
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
      Color color = spotColors[rng.nextInt(spotColors.length)];
      circleSpots[Point(x, y)] = color;
    }
    notifyListeners();
  }

  List<Position> getEmptyGrids() {
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

  // Path finding
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
      await Future.delayed(Duration(milliseconds: 50));
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

  int removeAndScoreSpots(List<List<Position>> spotsGroup) {
    int score = 0;

    for (var group in spotsGroup) {
      int groupLength = group.length;
      if (groupLength >= 5) {
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

  Color get selectedSpotColor {
    return circleSpots[initialPosition]!;
  }

  bool get gameOver {
    return getEmptyGrids().isEmpty;
  }
}
