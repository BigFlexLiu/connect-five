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
    gameData.clear();
    generatePreview();
    newTurn();
    print(gameData.board);

    gameData.saveData();
  }

  void newTurn() async {
    List<List<Position>> connectFives = findConnectFive();
    await onConnectFiveFound(connectFives.expand((i) => i).toList());
    _clearConnectFives(findConnectFive());
    // Skip spot generation if there is a connectFive
    if (gameData.turnsSkipped > 0) {
      gameData.turnsSkipped -= 1;
      gameData.saveData();
      return;
    }

    // spot generation
    generateOrbs();
    generatePreview();
    if (gameData.generationNerf > 0) {
      gameData.generationNerf -= 1;
    }

    connectFives = findConnectFive();
    await onConnectFiveFound(connectFives.expand((i) => i).toList());
    _clearConnectFives(findConnectFive());

    gameData.saveData();
  }

  void generatePreview() {
    var rng = Random();
    int x, y;
    // Strategy 1
    // Collect free grids and select them at random
    if (gameData.board.length >= gameData.width * gameData.height * 0.8) {
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
      } while (gameData.at(Point(x, y)) != null);
      gameData.setAt(Point(x, y), rng.nextInt(numColors));
      gameData.nextBatchPreview[Point(x, y)] = rng.nextInt(numColors);
    }
    gameData.nextBatchPreview.forEach((key, value) {
      gameData.setAt(key, null);
    });
  }

  // Game logic
  void generateOrbs() {
    gameData.nextBatchPreview.forEach((pos, value) {
      if (gameData.at(pos) == null) {
        gameData.setAt(pos, value);
      }
    });
    gameData.nextBatchPreview.clear();
  }

  List<Position> _getEmptyGrids() {
    List<Position> emptySpots = [];
    for (var xi = 0; xi < WIDTH; xi++) {
      for (var yi = 0; yi < HEIGHT; yi++) {
        var point = Point(xi, yi);
        if (gameData.at(point) == null) {
          emptySpots.add(point);
        }
      }
    }
    return emptySpots;
  }

  // Orb moves are restricted to a path composed of no more than 3 horizontal or vertical translations
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
        _linePath(midPoint1, terminalPosition).skip(1).toList();
    if (!_pathIntersectsCircle(path)) return path;

    path = _linePath(initialPosition, midPoint2) +
        _linePath(midPoint2, terminalPosition).skip(1).toList();
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
        _linePath(midPoint1, midPoint2).skip(1).toList() +
        _linePath(midPoint2, terminalPosition).skip(1).toList();
    if (!_pathIntersectsCircle(path)) return path;

    midPoint1 = Point(initialPosition.x, targetY);
    midPoint2 = Point(terminalPosition.x, targetY);

    path = _linePath(initialPosition, midPoint1) +
        _linePath(midPoint1, midPoint2).skip(1).toList() +
        _linePath(midPoint2, terminalPosition).skip(1).toList();
    if (!_pathIntersectsCircle(path)) return path;

    return [];
  }

  bool _pathIntersectsCircle(List<Position> path) {
    // Exclude the initial position by skipping the first item in path
    return path.skip(1).any((point) => gameData.at(point) != null);
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
      return gameData.at(point) != null;
    }

    // Checks if the color of the spot at the given point is the same as the color of the last spot in the segment
    bool isSameColorAsLastSpot(Position point, List<Position> segment) {
      return segment.isEmpty || gameData.at(point) == gameData.at(segment.last);
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
          if (gameData.at(point) != null) {
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
          if (gameData.at(point) != null) {
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

  void _clearConnectFives(List<List<Position>> connectFives) {
    // Calculate bonuses
    int bonusRemoval = 0;
    int generationNerf = 0;
    for (final connectFive in connectFives) {
      int? score;
      int connectFiveLength = connectFive.length;

      if (connectFiveLength >= 9) {
        gameData.turnsSkipped += 1;
        bonusRemoval += 4;
        generationNerf += 1;
        score ??= 320;
      }
      if (connectFiveLength >= 8) {
        for (var element in gameData.board) {
          element
              .removeWhere((value) => value == gameData.at(connectFive.first));
        }
        bonusRemoval += 2;
        generationNerf += 1;
        score ??= 160;
      }
      if (connectFiveLength >= 7) {
        generationNerf += 1;
        score ??= 40;
      }
      if (connectFiveLength >= 6) {
        bonusRemoval += 1;
        score ??= 80;
      }
      if (connectFiveLength >= 5) {
        gameData.turnsSkipped += 1;
        score ??= 20;
      }

      gameData.score += score ?? 0;
    }

    // Remove connect fives
    for (var group in connectFives) {
      int groupLength = group.length;
      if (groupLength >= 5) {
        for (var point in group) {
          gameData.board.remove(point);
        }
      }
    }

    // apply generation nerf
    for (int i = 0; i < generationNerf; i++) {
      final randomKey = (gameData.nextBatchPreview.keys.toList()..shuffle())[0];
      gameData.nextBatchPreview.remove(randomKey);
    }
    gameData.generationNerf += generationNerf;

    // Bonus spot removal
    List<Position> taken = [];
    for (var xi = 0; xi < WIDTH; xi++) {
      for (var yi = 0; yi < HEIGHT; yi++) {
        var point = Point(xi, yi);
        if (gameData.at(point) != null) {
          taken.add(point);
        }
      }
    }
    for (int i = 0; i < bonusRemoval; i++) {
      if (gameData.board.isEmpty) {
        break;
      }
      var randomIndex = Random().nextInt(taken.length);
      var randomPos = taken.elementAt(randomIndex);
      gameData.setAt(randomPos, null);
    }
  }

  bool get gameOver {
    return _getEmptyGrids().isEmpty;
  }

  int get numSpots {
    int spots = 3;
    if (gameData.score > 10000) {
      spots = 7;
    } else if (gameData.score > 2000) {
      spots = 6;
    } else if (gameData.score > 500) {
      spots = 5;
    } else if (gameData.score > 100) {
      spots = 4;
    }
    return max(0, spots - gameData.generationNerf);
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
