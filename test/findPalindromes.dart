import 'dart:math';

import 'package:connect_five/bloc/game_data.dart';
import 'package:connect_five/bloc/game_logic.dart';
import 'package:connect_five/constant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final gameLogic = GameLogic(GameData(), (List<Position> i) {});

  bool _comparePointSets(Set<Point<int>> set1, Set<Point<int>> set2) {
    if (set1.length != set2.length) {
      return false;
    }

    for (var point in set1) {
      if (!set2.contains(point)) {
        return false;
      }
    }

    return true;
  }

  test('Test Case 1: No Palindrome', () {
    List<List<int?>> board = [
      [1, 2, 3, 4, 5],
      [6, 7, 8, 9, 0],
      [0, 9, 8, 7, 6],
      [5, 4, 3, 2, 1],
      [1, 2, 3, 4, 5],
    ];
    List<List<Point<int>>> result = gameLogic.findPalindromes(board);
    assert(result.isEmpty);
  });

  test('Test Case 2: Palindrome in Row', () {
    List<List<int?>> board = [
      [1, 2, 3, 4, 5],
      [6, 7, 8, 7, 6],
      [0, 9, 8, 7, 6],
      [5, 4, 3, 2, 1],
      [1, 2, 3, 4, 5],
    ];
    List<List<Point<int>>> result = gameLogic.findPalindromes(board);
    assert(result.length == 1);
    assert(result[0].toSet().difference({
      const Point(1, 0),
      const Point(1, 1),
      const Point(1, 2),
      const Point(1, 3),
      const Point(1, 4)
    }).isEmpty);
  });

  test('Test Case 3: Palindrome in Column and Rows', () {
    List<List<int?>> board = [
      [1, 6, 0, 5, 1],
      [2, 7, 9, 4, 2],
      [3, 8, 8, 3, 3],
      [2, 7, 9, 4, 2],
      [1, 6, 0, 5, 1],
    ];
    List<List<Point<int>>> result = gameLogic.findPalindromes(board);

    assert(result.length == 5);

    // Expected palindromes
    List<Set<Point<int>>> expected = [
      {const Point(0, 2), const Point(1, 2), const Point(2, 2), const Point(3, 2), const Point(4, 2)},
      {const Point(0, 0), const Point(1, 0), const Point(2, 0), const Point(3, 0), const Point(4, 0)},
      {const Point(0, 1), const Point(1, 1), const Point(2, 1), const Point(3, 1), const Point(4, 1)},
      {const Point(0, 3), const Point(1, 3), const Point(2, 3), const Point(3, 3), const Point(4, 3)},
      {const Point(0, 4), const Point(1, 4), const Point(2, 4), const Point(3, 4), const Point(4, 4)},
    ];

    // Every palindrome in result should be in expected
    for (var resultSet in result.map((r) => r.toSet())) {
      bool found = false;
      for (var expSet in expected) {
        if (_comparePointSets(resultSet, expSet)) {
          found = true;
          expected.remove(expSet);
          break;
        }
      }
      assert(found);
    }
    // No palindromes should be left in expected
    assert(expected.isEmpty);
  });

  test('Test Case 4: Multiple Palindromes', () {
    List<List<int?>> board = [
      [1, 2, 3, 4, 5],
      [6, 7, 8, 7, 6],
      [6, 7, 8, 7, 6],
      [1, 2, 3, 4, 5],
      [5, 4, 3, 2, 1],
    ];
    List<List<Point<int>>> result = gameLogic.findPalindromes(board);
    assert(result.length == 2);
  });

  test('Test Case 5: Palindrome of Length 9 in Row', () {
    List<List<int?>> board = [
      [1, 2, 3, 4, 5, 4, 3, 2, 1, null],
      [null, null, null, null, null, null, null, null, null, null],
    ];
    List<List<Point<int>>> result = gameLogic.findPalindromes(board);

    assert(result.length == 1);

    // Expected palindromes
    List<Set<Point<int>>> expected = [
      {
        const Point(0, 0),
        const Point(0, 1),
        const Point(0, 2),
        const Point(0, 3),
        const Point(0, 4),
        const Point(0, 5),
        const Point(0, 6),
        const Point(0, 7),
        const Point(0, 8)
      }
    ];

    for (var resultSet in result.map((r) => r.toSet())) {
      bool found = false;
      for (var expSet in expected) {
        if (_comparePointSets(resultSet, expSet)) {
          found = true;
          expected.remove(expSet);
          break;
        }
      }
      assert(found);
    }

    // No palindromes should be left in expected
    assert(expected.isEmpty);
  });
}
