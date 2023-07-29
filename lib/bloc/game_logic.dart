import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

import '../constant.dart';
import 'game_data.dart';

class GameLogic {
  GameData gameData;
  Function(List<Position>) onClear;

  GameLogic(this.gameData, this.onClear) {
    newGame();
  }

  // Game flow
  void newGame() {
    gameData.clear();
    generatePreview(numOrbsToGenerate);
    nextTurn();

    gameData.saveData();
  }

  void nextTurn() async {
    bool cleared = false;
    while (await clear(gameData.board)) {
      cleared = true;
    }
    // Skip orb generation
    if (gameData.turnsSkipped > 0) {
      // Extend turn skip if removed orb while turn is being skipped
      if (cleared) {
        gameData.saveData();
        return;
      }
      gameData.turnsSkipped -= 1;
      gameData.saveData();
      return;
    }

    // end game if not enough free grids left for generation
    if (checkGameOver()) {
      return;
    }

    // reduce color ban turn count
    for (int i = 0; i < gameData.colorBan.length; i++) {
      gameData.colorBan[i] = max(gameData.colorBan[i] - 1, 0);
    }

    // Orb generation
    generateOrbs();
    generatePreview(numOrbsToGenerate);
    if (gameData.generationNerf > 0) {
      gameData.generationNerf -= 1;
    }

    while (await clear(gameData.board)) {}

    // Ensure board has at least one orb as a safenet
    // WARNING: should not be true, ever
    if (gameData.openGrid == gameData.width * gameData.height) {
      gameData.setAt(const Position(0, 0), 0);
    }

    gameData.saveData();
  }

  // Clear all orbs in match or as bonus
  // Leave at least one orb
  Future<bool> clear(List<List<int?>> board) async {
    List<List<Position>> connectFives = findSequences(gameData.board);
    if (connectFives.isEmpty) {
      return false;
    }

    gameData.score += _clearConnectFives(connectFives);

    // Clear all orbs in match and scheduled for clear
    await onClear(gameData.matches);
    for (var connectFive in connectFives) {
      for (Position pos in connectFive) {
        if (gameData.openGrid == gameData.width * gameData.height - 1) {
          break;
        }
        gameData.setAt(pos, null);
      }
    }
    gameData.matches.clear();
    await onClear(gameData.removeOnTurnEnd);
    for (Position pos in gameData.removeOnTurnEnd) {
      if (gameData.openGrid == gameData.width * gameData.height - 1) {
        break;
      }
      gameData.setAt(pos, null);
    }
    gameData.removeOnTurnEnd.clear();

    return true;
  }

  void generatePreview(int numOrbs) {
    List<int> colors = [];
    // Collect all available colors
    for (int i = 0; i < numColors; i++) {
      if (gameData.colorBan[i] == 0) {
        colors.add(i);
      }
    }
    if (colors.isEmpty) {
      return;
    }

    // Generate orbs preview
    var rng = Random();
    var emptyGrids = _getEmptyGrids();
    for (var i = 0; i < numOrbs; i++) {
      if (emptyGrids.isEmpty) {
        gameData.isGameOver = true;
        return;
      }
      final randInt = rng.nextInt(emptyGrids.length);
      var spot = emptyGrids[randInt];
      emptyGrids.removeAt(randInt);

      gameData.nextGenerationPreview[spot] = colors[rng.nextInt(colors.length)];
    }
    return;
  }

  // Game logic
  void generateOrbs() {
    gameData.nextGenerationPreview.forEach((pos, value) {
      if (gameData.at(pos) == null) {
        gameData.setAt(pos, value);
      }
    });
    gameData.nextGenerationPreview.clear();
  }

  List<Position> _getEmptyGrids() {
    List<Position> emptyGrids = [];
    for (var i = 0; i < gameData.width; i++) {
      for (var j = 0; j < gameData.height; j++) {
        var point = Point(i, j);
        if (gameData.at(point) == null) {
          emptyGrids.add(point);
        }
      }
    }
    return emptyGrids;
  }

  bool checkGameOver() {
    if (numOrbsToGenerate > gameData.openGrid) {
      gameData.isGameOver = true;
    }
    return gameData.isGameOver;
  }

  // Orb moves are restricted to a path composed of no more than 3 horizontal or vertical translations
  List<Position> generatePath(
      Position initialPosition, Position terminalPosition) {
    List<Position> path;

    bool pathIntersectsCircle(List<Position> path) {
      // Exclude the initial position by skipping the first item in path
      return path.skip(1).any((point) => gameData.at(point) != null);
    }

    // Generates a path from start to end
    List<Position> linePath(Position start, Position end) {
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

    List<Position> tryTwoTurnsPath(Position initialPosition,
        Position terminalPosition, int targetX, int targetY) {
      Position midPoint1 = Point(targetX, initialPosition.y);
      Position midPoint2 = Point(targetX, terminalPosition.y);

      List<Position> path = linePath(initialPosition, midPoint1) +
          linePath(midPoint1, midPoint2).skip(1).toList() +
          linePath(midPoint2, terminalPosition).skip(1).toList();
      if (!pathIntersectsCircle(path)) return path;

      midPoint1 = Point(initialPosition.x, targetY);
      midPoint2 = Point(terminalPosition.x, targetY);

      path = linePath(initialPosition, midPoint1) +
          linePath(midPoint1, midPoint2).skip(1).toList() +
          linePath(midPoint2, terminalPosition).skip(1).toList();
      if (!pathIntersectsCircle(path)) return path;

      return [];
    }

    // Case 1: Straight line
    if (initialPosition.x == terminalPosition.x ||
        initialPosition.y == terminalPosition.y) {
      path = linePath(initialPosition, terminalPosition);
      if (!pathIntersectsCircle(path)) return path;
    }

    // Case 2: One turn
    Position midPoint1 = Point(initialPosition.x, terminalPosition.y);
    Position midPoint2 = Point(terminalPosition.x, initialPosition.y);

    path = linePath(initialPosition, midPoint1) +
        linePath(midPoint1, terminalPosition).skip(1).toList();
    if (!pathIntersectsCircle(path)) return path;

    path = linePath(initialPosition, midPoint2) +
        linePath(midPoint2, terminalPosition).skip(1).toList();
    if (!pathIntersectsCircle(path)) return path;

    // Case 3: Two turns
    int minX = min(initialPosition.x, terminalPosition.x).toInt();
    int maxX = max(initialPosition.x, terminalPosition.x).toInt();
    int minY = min(initialPosition.y, terminalPosition.y).toInt();
    int maxY = max(initialPosition.y, terminalPosition.y).toInt();

    for (int x = minX; x <= maxX; x++) {
      for (int y = minY; y <= maxY; y++) {
        path = tryTwoTurnsPath(initialPosition, terminalPosition, x, y);
        if (path.isNotEmpty) return path;
      }
    }

    List xValues = [
      Iterable.generate(minX).toList().reversed,
      List.generate(gameData.width - maxX, (i) => i + maxX)
    ].expand((x) => x).toList();

    List yValues = [
      Iterable.generate(minY).toList().reversed,
      List.generate(gameData.height - maxY, (i) => i + maxY)
    ].expand((x) => x).toList();

    for (int x in xValues) {
      for (int y in yValues) {
        path = tryTwoTurnsPath(initialPosition, terminalPosition, x, y);
        if (path.isNotEmpty) return path;
      }
    }

    return [];
  }

  int _clearConnectFives(List<List<Position>> connectFives) {
    gameData.addMatches(connectFives.expand((i) => i).toList());
    // Calculate bonuses
    int bonusRemoval = 0;
    int generationNerf = 0;
    int scoresEarned = 0;
    for (final connectFive in connectFives) {
      assert(connectFive.length >= 5);
      int connectFiveLength = connectFive.length;
      int color = gameData.at(connectFive.first)!;
      int scores = 0;
      bool isStraightLine =
          connectFive.every((element) => element.x == connectFive[0].x) ||
              connectFive.every((element) => element.y == connectFive[0].y);

      scores += 100 * max(0, connectFiveLength - 9);

      if (connectFiveLength >= 9) {
        // Color does not generate for the next five rounds of generation
        gameData.colorBan[gameData.at(connectFive[0])!] = 5;
        gameData.nextGenerationPreview
            .removeWhere((key, value) => value == color);
        bonusRemoval += 4;
        generationNerf += 1;
        scores += 100;
      }
      if (connectFiveLength >= 8) {
        // Remove all orbs with the same color as the connect five
        for (int i = 0; i < gameData.width; i++) {
          for (int j = 0; j < gameData.height; j++) {
            final pos = Position(i, j);
            if (gameData.at(pos) == color) {
              gameData.scheduleRemoval(pos);
            }
          }
        }
        bonusRemoval += 3;
        generationNerf += 1;
        scores += 80;
      }
      if (connectFiveLength >= 7) {
        bonusRemoval += 2;
        generationNerf += 1;
        scores += 60;
      }
      if (connectFiveLength >= 6) {
        bonusRemoval += 1;
        scores += 40;
      }
      if (connectFiveLength >= 5) {
        gameData.turnsSkipped += 1;
        scores += 20;
      }
      scoresEarned += scores * (isStraightLine ? 5 : 1);
    }

    // Remove connect fives
    for (var group in connectFives) {
      gameData.addMatches(group);
    }

    // apply generation nerf
    for (int i = 0; i < generationNerf; i++) {
      if (gameData.nextGenerationPreview.isEmpty) {
        break;
      }
      final randomKey =
          (gameData.nextGenerationPreview.keys.toList()..shuffle())[0];
      gameData.nextGenerationPreview.remove(randomKey);
    }
    gameData.generationNerf += generationNerf;

    // Bonus spot removal
    List<Position> taken = [];
    for (var xi = 0; xi < gameData.width; xi++) {
      for (var yi = 0; yi < gameData.height; yi++) {
        var point = Point(xi, yi);
        if (gameData.at(point) != null &&
            !gameData.matches.contains(point) &&
            !gameData.removeOnTurnEnd.contains(point)) {
          taken.add(point);
        }
      }
    }
    for (int i = 0; i < bonusRemoval; i++) {
      if (taken.isEmpty) {
        break;
      }
      var randomIndex = Random().nextInt(taken.length);
      var randomPos = taken.elementAt(randomIndex);
      taken.removeAt(randomIndex);
      gameData.scheduleRemoval(randomPos);
    }
    return scoresEarned;
  }

  void playSound() async {
    final player = AudioPlayer();

    await player.play(
      AssetSource('pop_short.mp3'),
      mode: PlayerMode.lowLatency,
    );
  }

  bool get gameOver {
    return _getEmptyGrids().isEmpty;
  }

  int get numOrbsToGenerate =>
      max(0, numOrbsToGenerateBeforeNerf - gameData.generationNerf);

  int get numOrbsToGenerateBeforeNerf {
    if (gameData.score > 8000) {
      return 7;
    } else if (gameData.score > 6000) {
      return 6;
    } else if (gameData.score > 2000) {
      return 5;
    } else if (gameData.score > 200) {
      return 4;
    }
    return 3;
  }

  int get numColors {
    if (gameData.score > 10000) {
      return 7;
    } else if (gameData.score > 4000) {
      return 6;
    } else if (gameData.score > 1000) {
      return 5;
    } else if (gameData.score > 500) {
      return 4;
    }
    return 3;
  }
}

List<List<Position>> findSequences(List<List<int?>> board) {
  List<List<Position>> sequences = [];
  Set<Position> visited = {};
  int n = board.length;
  int m = board[0].length;

  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {
      List<Position> temp = [];
      dfs(board, i, j, visited, temp);
      if (temp.length >= 5) {
        sequences.add(temp);
      }
    }
  }

  return sequences;
}

void dfs(List<List<int?>> board, int x, int y, Set<Position> visited,
    List<Position> temp) {
  int n = board.length;
  int m = board[0].length;

  if (x < 0 || x >= n || y < 0 || y >= m || board[x][y] == null) {
    return;
  }

  Position pos = Position(x, y);
  if (visited.contains(pos)) {
    return;
  }

  visited.add(pos);
  temp.add(pos);

  List<int> dx = [-1, 0, 1, 0];
  List<int> dy = [0, 1, 0, -1];

  for (int i = 0; i < 4; i++) {
    int newX = x + dx[i];
    int newY = y + dy[i];

    if (newX >= 0 &&
        newX < n &&
        newY >= 0 &&
        newY < m &&
        board[newX][newY] == board[x][y]) {
      dfs(board, newX, newY, visited, temp);
    }
  }
}
