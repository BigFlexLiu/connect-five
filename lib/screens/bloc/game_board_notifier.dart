import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

class GameBoardNotifier extends ChangeNotifier {
  Point<int> initialPosition = Point(0, 0);
  Point<int> terminalPosition = Point(0, 0);
  int width = 10;
  int height = 15;
  List<Point<int>> movePath = [];
  final Map<Point<int>, Color> circleSpots = {};
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

  void endTouch() {
    print("end touch");
    if (movePath.isEmpty || _moving) {
      return;
    }
    final path = movePath;
    movePath = [];
    notifyListeners();
    _move(path);
  }

  void generateSpots({int numSpots = 5}) {
    var rng = Random();
    int x, y;
    // Strategy 1
    // Collect free grids and select them at random
    if (circleSpots.length >= width * height * 0.8) {
      var emptySpots = [];
      for (var xi = 0; xi < width; xi++) {
        for (var yi = 0; yi < height; yi++) {
          var point = Point(xi, yi);
          if (!circleSpots.containsKey(point)) {
            emptySpots.add(point);
          }
        }
      }
      for (var i = 0; i < numSpots; i++) {
        final randInt = rng.nextInt(emptySpots.length);
        var spot = emptySpots[randInt];
        emptySpots.removeAt(spot);
        x = spot.x;
        y = spot.y;
        Color color = spotColors[rng.nextInt(spotColors.length)];
        circleSpots[Point(x, y)] = color;
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

  // Path finding
  List<Point<int>> generatePath(
      Point<int> initialPosition, Point<int> terminalPosition) {
    List<Point<int>> path;

    // Case 1: Straight line
    if (initialPosition.x == terminalPosition.x ||
        initialPosition.y == terminalPosition.y) {
      path = _linePath(initialPosition, terminalPosition);
      if (!_pathIntersectsCircle(path)) return path;
    }

    // Case 2: One turn
    Point<int> midPoint1 = Point(initialPosition.x, terminalPosition.y);
    Point<int> midPoint2 = Point(terminalPosition.x, initialPosition.y);

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

  List<Point<int>> _tryTwoTurnsPath(int x, int y) {
    Point<int> midPoint1 = Point(x, initialPosition.y);
    Point<int> midPoint2 = Point(x, terminalPosition.y);

    List<Point<int>> path = _linePath(initialPosition, midPoint1) +
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

  void _move(List<Point<int>> path) async {
    _moving = true;
    Point<int> current = path.first;
    for (Point<int> position in path) {
      circleSpots[position] = circleSpots.remove(current)!;
      current = Point(position.x, position.y);
      notifyListeners();
      await Future.delayed(Duration(milliseconds: 50));
    }
    _moving = false;
  }

  // Generates a path from start to end
  List<Point<int>> _linePath(Point<int> start, Point<int> end) {
    assert(start.x == end.x || start.y == end.y);

    List<Point<int>> path = [];
    Point<int> dir = Point(end.x - start.x, end.y - start.y);
    Point<int> normDir = Point(dir.x.sign, dir.y.sign);
    Point<int> current = start;

    while (current != end) {
      path.add(current);
      current = Point(current.x + normDir.x, current.y + normDir.y);
    }
    path.add(end); // Include the end point
    return path;
  }

  Color get selectedSpotColor {
    return circleSpots[initialPosition]!;
  }
}
