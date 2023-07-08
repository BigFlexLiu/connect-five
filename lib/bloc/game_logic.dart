import 'dart:math';

import '../constant.dart';
import 'game_board_notifier.dart';
import 'game_data.dart';

class GameLogic {
  GameData gameData;
  Function(List<Position> connectFives) onConnectFiveFound;

  GameLogic(this.gameData, this.onConnectFiveFound);

  // Game flow
  void newGame() {
    gameData.score = 0;
    gameData.circleSpots.clear();
    gameData.nextBatchPreview.clear();
    generatePreview();
    newTurn();

    gameData.saveData();
  }

  void newTurn() async {
    List<List<Position>> connectFives = findConnectFive();
    await onConnectFiveFound(connectFives.expand((i) => i).toList());
    var scoreIncrease = _removeAndScoreSpots(findConnectFive());
    gameData.score += scoreIncrease;
    gameData.turnsSkipped += connectFives.length;
    // Skip spot generation if there is a connectFive
    if (gameData.turnsSkipped > 0) {
      gameData.turnsSkipped -= 1;
      gameData.saveData();
      return;
    }

    // spot generation
    generateOrbs();
    generatePreview();
    connectFives = findConnectFive();
    await onConnectFiveFound(connectFives.expand((i) => i).toList());
    gameData.score += _removeAndScoreSpots(findConnectFive());
    gameData.saveData();
  }

  void generatePreview() {
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
        gameData.nextBatchPreview[spot] = rng.nextInt(numColors);
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
      gameData.nextBatchPreview[Point(x, y)] = rng.nextInt(numColors);
    }
    gameData.nextBatchPreview.forEach((key, value) {
      gameData.circleSpots.remove(key);
    });
  }

  // Game logic
  void generateOrbs() {
    gameData.nextBatchPreview.forEach((key, value) {
      if (!gameData.circleSpots.containsKey(key)) {
        gameData.circleSpots[key] = value;
      }
    });
    gameData.nextBatchPreview.clear();
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

    print(maxX);

    List xValues = [
      Iterable.generate(minX).toList().reversed,
      List.generate(WIDTH - maxX, (i) => i + maxX)
    ].expand((x) => x).toList();

    List yValues = [
      Iterable.generate(minY).toList().reversed,
      List.generate(HEIGHT - maxY, (i) => i + maxY)
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
}
