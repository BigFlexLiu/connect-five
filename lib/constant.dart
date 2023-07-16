import 'dart:math';

import 'package:flutter/material.dart';

typedef Position = Point<int>;

const WIDTH = 10;
const HEIGHT = 15;
const N = null;

const images = [
  'assets/red.png',
  'assets/green.png',
  'assets/blue.png',
  'assets/orange.png',
  'assets/purple.png',
  'assets/pink.png',
  'assets/yellow.png',
];

const previewImages = [
  'assets/red_preview.png',
  'assets/green_preview.png',
  'assets/blue_preview.png',
  'assets/orange_preview.png',
  'assets/purple_preview.png',
  'assets/pink_preview.png',
  'assets/yellow_preview.png',
];

const pathColors = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.orange,
  Colors.purple,
  Colors.pink,
  Colors.yellow,
];

const sample = [
  [N, 1, N, 2, 2, 2, 2, 2, N, N, N, N, N, N, N],
  [N, 1, N, N, N, N, N, N, N, N, N, N, N, N, N],
  [N, 1, N, N, 3, N, N, N, N, N, N, N, N, N, N],
  [N, 1, N, 3, 3, 3, N, N, 4, N, N, N, N, N, N],
  [N, 1, N, N, 3, N, N, N, 4, N, N, N, N, N, N],
  [N, N, N, N, N, N, N, N, 4, 4, 4, N, N, N, N],
  [N, N, 5, 5, 5, N, N, N, N, N, N, N, N, N, N],
  [N, N, N, 5, N, N, N, N, N, N, N, N, N, N, N],
  [N, N, N, 5, N, N, N, N, N, N, N, N, N, N, N],
  [N, N, N, N, N, N, N, N, N, N, N, N, N, N, N],
  [N, N, N, N, N, N, N, N, N, N, N, N, N, N, N],
];
