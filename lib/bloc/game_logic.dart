import 'dart:math';

import '../constant.dart';
import 'game_data.dart';

class GameLogic {
  GameData gameData;
  Function(List<Position>) onClear;

  GameLogic(this.gameData, this.onClear);

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

    // spot generation
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
    List<List<Position>> connectFives = findConnectFive();
    // final palindrome = findPalindromes(gameData.board);
    final pluses = findThreePlusThree(board);
    final cleared = connectFives + pluses;
    if (cleared.isEmpty) {
      return false;
    }

    int scoresEarned = _clearConnectFives(connectFives);
    scoresEarned += clearThreePlusThrees(pluses);
    gameData.score += scoresEarned;

    // Clear all orbs in match and scheduled for clear
    await onClear(gameData.matches);
    for (Position pos in gameData.matches) {
      if (gameData.openGrid == WIDTH * HEIGHT - 1) {
        break;
      }
      gameData.setAt(pos, null);
    }
    gameData.matches.clear();
    await onClear(gameData.removeOnTurnEnd);
    for (Position pos in gameData.removeOnTurnEnd) {
      if (gameData.openGrid == WIDTH * HEIGHT - 1) {
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
    for (var i = 0; i < WIDTH; i++) {
      for (var j = 0; j < HEIGHT; j++) {
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
      List.generate(WIDTH - maxX, (i) => i + maxX)
    ].expand((x) => x).toList();

    List yValues = [
      Iterable.generate(minY).toList().reversed,
      List.generate(HEIGHT - maxY, (i) => i + maxY)
    ].expand((x) => x).toList();

    for (int x in xValues) {
      for (int y in yValues) {
        path = tryTwoTurnsPath(initialPosition, terminalPosition, x, y);
        if (path.isNotEmpty) return path;
      }
    }

    return [];
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

      if (connectFiveLength >= 9) {
        // Color does not generate for the next five rounds of generation
        gameData.colorBan[gameData.at(connectFive[0])!] = 5;
        gameData.nextGenerationPreview
            .removeWhere((key, value) => value == color);
        bonusRemoval += 4;
        generationNerf += 1;
        scoresEarned += 100;
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
        scoresEarned += 80;
      }
      if (connectFiveLength >= 7) {
        bonusRemoval += 2;
        generationNerf += 1;
        scoresEarned += 60;
      }
      if (connectFiveLength >= 6) {
        bonusRemoval += 1;
        scoresEarned += 40;
      }
      if (connectFiveLength >= 5) {
        gameData.turnsSkipped += 1;
        scoresEarned += 20;
      }
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
    for (var xi = 0; xi < WIDTH; xi++) {
      for (var yi = 0; yi < HEIGHT; yi++) {
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

  // NOTE: Unused
  List<List<Point<int>>> findPalindromes(List<List<int?>> board) {
    const int minLength = 7;
    List<List<Point<int>>> palindromes = [];
    int n = board.length;
    int m = board[0].length;

    bool isContained(List<Point<int>> smaller, List<Point<int>> larger) {
      return smaller.first.x >= larger.first.x &&
          smaller.first.y >= larger.first.y &&
          smaller.last.x <= larger.last.x &&
          smaller.last.y <= larger.last.y;
    }

    bool isPalindrome(List<int?> segment) {
      if (segment.contains(null) || segment.length < minLength) {
        return false;
      }

      int i = 0;
      int j = segment.length - 1;
      while (i < j) {
        if (segment[i] != segment[j]) {
          return false;
        }
        i++;
        j--;
      }
      return true;
    }

    List<List<Point<int>>> filterOutContainedPalindromes(
        List<List<Point<int>>> palindromes) {
      List<List<Point<int>>> filtered = [];
      for (var p1 in palindromes) {
        bool isSubset = false;
        for (var p2 in palindromes) {
          if (p1 != p2 && isContained(p1, p2)) {
            isSubset = true;
            break;
          }
        }
        if (!isSubset) {
          filtered.add(p1);
        }
      }
      return filtered;
    }

    // Check all rows
    for (int i = 0; i < n; i++) {
      for (int len = m; len >= minLength; len--) {
        for (int j = 0; j <= m - len; j++) {
          List<int?> segment = board[i].sublist(j, j + len);
          if (isPalindrome(segment)) {
            palindromes
                .add(List<Point<int>>.generate(len, (k) => Point(i, j + k)));
          }
        }
      }
    }

    // Check all columns
    for (int i = 0; i < m; i++) {
      for (int len = n; len >= minLength; len--) {
        for (int j = 0; j <= n - len; j++) {
          List<int?> segment = List<int?>.generate(len, (k) => board[j + k][i]);
          if (isPalindrome(segment)) {
            palindromes
                .add(List<Point<int>>.generate(len, (k) => Point(j + k, i)));
          }
        }
      }
    }

    return filterOutContainedPalindromes(palindromes);
  }

  // Note: Unused
  void clearPalindrome(List<List<Point<int>>> palindrome) {
    if (palindrome.isNotEmpty) {
      gameData.generationNerf += numOrbsToGenerate;
    }

    for (var element in palindrome) {
      gameData.addMatches(element);
    }
  }

  // Note: Unused
  void shuffle(List<List<int?>> board) {
    List<int?> shuffleBoard = board.expand((i) => i).toList();
    shuffleBoard.shuffle();
    for (int i = 0; i < gameData.width; i++) {
      board[i] = shuffleBoard
          .getRange(i * gameData.height, (i + 1) * gameData.height)
          .toList();
    }
  }

  // Three horizontal, three vertical with a single overlap
  List<List<Position>> findThreePlusThree(List<List<int?>> board) {
    List<List<Position>> threePlusThree = [];
    for (int i = 1; i < gameData.width - 1; i++) {
      for (int j = 1; j < gameData.height - 1; j++) {
        final List<List<Position>> verticals = List<List<Position>>.generate(
            3, (x) => List.generate(3, (y) => Position(i + x - 1, j + y - 1)));
        final List<List<Position>> horizontals = List<List<Position>>.generate(
            3, (y) => List.generate(3, (x) => Position(i + x - 1, j + y - 1)));

        for (var threes in [verticals, horizontals]) {
          threes.removeWhere((element) {
            if (element.any((element) => gameData.at(element) == null)) {
              return true;
            }
            if (gameData.at(element[0]) != gameData.at(element[1]) ||
                gameData.at(element[1]) != gameData.at(element[2])) {
              return true;
            }
            return false;
          });
        }

        // Find three by three
        for (final vertical in verticals) {
          for (final horizontal in horizontals) {
            if (gameData.at(vertical[0]) == gameData.at(horizontal[0])) {
              threePlusThree
                  .add(Set<Position>.from((vertical + horizontal)).toList());
            }
          }
        }
      }
    }
    return threePlusThree;
  }

  // Pluses cause its column and row to be cleared
  // Produces the number of score earned
  int clearThreePlusThrees(List<List<Position>> pluses) {
    int scoreEarned = 0;
    for (final plus in pluses) {
      gameData.addMatches(plus);

      // find column (median)
      final x = plus.map((e) => e.x).toList()..sort();
      final col = x[2];
      // find row
      final y = plus.map((e) => e.y).toList()..sort();
      final row = y[2];

      // Clear row and column
      for (int i = 0; i < gameData.height; i++) {
        final pos = Position(col, i);
        if (plus.contains(pos) || gameData.at(pos) == null) {
          continue;
        }
        gameData.scheduleRemoval(pos);
        scoreEarned += 1;
      }
      for (int i = 0; i < gameData.width; i++) {
        final pos = Position(i, row);
        if (plus.contains(pos) || gameData.at(pos) == null) {
          continue;
        }
        gameData.scheduleRemoval(pos);
        scoreEarned += 1;
      }
      scoreEarned += 5;
    }
    return scoreEarned;
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
    } else if (gameData.score > 4000) {
      return 5;
    } else if (gameData.score > 2000) {
      return 4;
    }
    return 3;
  }

  int get numColors {
    if (gameData.score > 10000) {
      return 7;
    } else if (gameData.score > 5000) {
      return 6;
    } else if (gameData.score > 3000) {
      return 5;
    } else if (gameData.score > 1000) {
      return 4;
    }
    return 3;
  }
}
