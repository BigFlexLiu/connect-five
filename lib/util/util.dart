import 'dart:math';
import 'dart:ui';

import '../constant.dart';

/// Determine the number of rows and columns the game board should have
/// based on the screen size.
/// Produces (cols, rows)
Point<int> getNumRowAndCol(Size screenSize) {
  // Calculate total grid area (80% of horizontal screen with 70% of vertical screen)
  final double width = screenSize.width * horitzontalScreenUsageRatio;
  final double height = screenSize.height * verticalScreenUsageRatio;
  // final double totalGridArea = width * height;

  // Use aspect ratio to determine the ratio of rows and columns
  final double aspectRatio = width / height;

  // Using the aspect ratio, calculate the number of rows and columns to fill the screen with
  // Calculation as follows:
  // Row / Col = aspectRatio
  // Row * Col = MAXNUMGRIDS
  // Row^2 = MAXNUMGRIDS * aspectRatio
  // Row = sqrt(MAXNUMGRIDS * aspectRatio)
  final int rows = sqrt(maxNumberGrids * aspectRatio).floor();
  final int cols = (maxNumberGrids / rows).floor();

  return Point<int>(rows, cols);
}
