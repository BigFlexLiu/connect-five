import 'package:connect_five/bloc/game_logic.dart';
import 'package:connect_five/constant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void checkEqual(List<List<Position>> result, List<List<Position>> expected) {
    // sort function for Position<int>
    int sortPosition(Position a, Position b) {
      if (a.x == b.x) {
        return a.y.compareTo(b.y);
      } else {
        return a.y.compareTo(b.y);
      }
    }

    // sort each list of positions and then the outer list
    for (var list in [result, expected]) {
      for (var positions in list) {
        positions.sort(sortPosition);
      }
      list.sort((a, b) => sortPosition(a[0], b[0]));
    }

    expect(result, expected);
  }

  test('Empty board', () {
    // An empty board should result in an empty list of sequences
    checkEqual(findSequences([[]]), []);
  });

  test('Board with no sequences', () {
    // A board with no sequences should also result in an empty list of sequences
    checkEqual(
        findSequences([
          [1, 2, 3, 4, 5],
          [2, 3, 4, 5, 1],
          [3, 4, 5, 1, 2],
          [4, 5, 1, 2, 3],
          [5, 1, 2, 3, 4],
        ]),
        []);
  });

  test('Board with one sequence', () {
    // A board with one sequence of five 1s
    checkEqual(
        findSequences([
          [1, 1, 1, 1, 1],
          [2, 3, 4, 5, 2],
          [3, 4, 5, 1, 3],
          [4, 5, 1, 2, 4],
          [5, 1, 2, 3, 5],
        ]),
        [
          [
            const Position(0, 0),
            const Position(0, 1),
            const Position(0, 2),
            const Position(0, 3),
            const Position(0, 4)
          ]
        ]);
  });

  test('Board with multiple sequences', () {
    // A board with multiple sequences (1s and 2s)
    checkEqual(
        findSequences([
          [1, 1, 1, 1, 1],
          [2, 2, 2, 2, 2],
          [3, 4, 5, 1, 3],
          [4, 5, 1, 2, 4],
          [5, 1, 2, 3, 5],
        ]),
        [
          [
            const Position(0, 0),
            const Position(0, 1),
            const Position(0, 2),
            const Position(0, 3),
            const Position(0, 4)
          ],
          [
            const Position(1, 0),
            const Position(1, 1),
            const Position(1, 2),
            const Position(1, 3),
            const Position(1, 4)
          ]
        ]);
  });

  test('Board with null values', () {
    // A board with null values. A sequence of 1s and 2s.
    // Notice that null values are not considered in a sequence.
    checkEqual(
        findSequences([
          [1, 1, 1, 1, 1],
          [null, 2, 2, 2, 2],
          [3, 4, 5, null, 2],
          [4, 5, 1, 2, 4],
          [5, 1, 2, 3, 5],
        ]),
        [
          [
            const Position(0, 0),
            const Position(0, 1),
            const Position(0, 2),
            const Position(0, 3),
            const Position(0, 4)
          ],
          [
            const Position(1, 1),
            const Position(1, 2),
            const Position(1, 3),
            const Position(1, 4),
            const Position(2, 4)
          ]
        ]);
  });
  test('Board with oversized sequence', () {
    checkEqual(
        findSequences([
          [1, 1, 1, 1, 1],
          [2, 1, 2, 1, 2],
          [3, 1, 4, 1, 3],
          [4, 1, 5, 1, 4],
          [5, 1, 2, 1, 5],
        ]),
        [
          [
            const Position(0, 0),
            const Position(0, 1),
            const Position(0, 2),
            const Position(0, 3),
            const Position(0, 4),
            const Position(1, 1),
            const Position(2, 1),
            const Position(3, 1),
            const Position(4, 1),
            const Position(1, 3),
            const Position(2, 3),
            const Position(3, 3),
            const Position(4, 3)
          ]
        ]);
  });
  test('Board with oversized sequence', () {
    // A board with a T shape sequence of 1s
    checkEqual(
        findSequences([
          [1, 1, 1, 3, 1],
          [2, 1, 2, 2, 2],
          [3, 1, 4, 4, 3],
          [4, 4, 5, 5, 4],
          [5, 1, 2, 1, 5],
        ]),
        [
          [
            const Position(0, 0),
            const Position(0, 1),
            const Position(0, 2),
            const Position(1, 1),
            const Position(2, 1),
          ]
        ]);
  });
  test('Board with T shape', () {
    // A board with a T shape sequence of 1s
    checkEqual(
        findSequences([
          [1, 1, 1, 3, 1],
          [2, 1, 2, 2, 2],
          [3, 1, 4, 4, 3],
          [4, 4, 5, 5, 4],
          [5, 1, 2, 1, 5],
        ]),
        [
          [
            const Position(0, 0),
            const Position(0, 1),
            const Position(0, 2),
            const Position(1, 1),
            const Position(2, 1),
          ]
        ]);
  });
  test('Board with L shape', () {
    // A board with a T shape sequence of 1s
    checkEqual(
        findSequences([
          [1, 4, 1, 1, 1],
          [2, 1, 2, 2, 1],
          [3, 1, 4, 2, 3],
          [4, 4, 5, 2, 4],
          [5, 1, 3, 2, 5],
        ]),
        [
          [
            const Position(1, 2),
            const Position(1, 3),
            const Position(2, 3),
            const Position(3, 3),
            const Position(4, 3),
          ]
        ]);
  });
  test('Board with odd shape', () {
    // A board with a T shape sequence of 1s
    checkEqual(
        findSequences([
          [1, 1, 1, 3, 1],
          [2, 1, 1, 2, 2],
          [3, 3, 4, 4, 3],
          [4, 4, 5, 5, 4],
          [5, 1, 2, 1, 5],
        ]),
        [
          [
            const Position(0, 0),
            const Position(0, 1),
            const Position(0, 2),
            const Position(1, 1),
            const Position(1, 2),
          ]
        ]);
  });
  test('Board with multiple sequences', () {
    checkEqual(
        findSequences([
          [1, 1, 1, 3, 1],
          [2, 1, 1, 2, 2],
          [3, 3, 4, 4, 3],
          [4, 4, 4, 5, 4],
          [5, 1, 2, 1, 5],
        ]),
        [
          [
            const Position(0, 0),
            const Position(0, 1),
            const Position(0, 2),
            const Position(1, 1),
            const Position(1, 2),
          ],
          [
            const Position(2, 2),
            const Position(2, 3),
            const Position(3, 0),
            const Position(3, 1),
            const Position(3, 2),
          ]
        ]);
  });
}
