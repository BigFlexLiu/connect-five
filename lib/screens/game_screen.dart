import 'dart:math';

import 'package:connect_five/util/circle_painter.dart';
import 'package:connect_five/util/line_painter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bloc/game_board_notifier.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            // Handle back button press
          },
        ),
        title: Text('Game Mode Name'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Provider.of<GameBoardNotifier>(context, listen: false).newTurn();
              // Handle settings button press
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(height: viewportConstraints.maxHeight * 0.05),
                  Text(
                      'Score: ${Provider.of<GameBoardNotifier>(context).score}'),
                  SizedBox(height: viewportConstraints.maxHeight * 0.05),
                  Container(
                      height: viewportConstraints.maxHeight * 0.8,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final squareSize = constraints.maxWidth / 10;
                          return GestureDetector(
                            onPanDown: (details) {
                              final RenderBox renderBox =
                                  context.findRenderObject() as RenderBox;
                              final localPosition = renderBox
                                  .globalToLocal(details.globalPosition);
                              final x = (localPosition.dx / squareSize).floor();
                              final y = (localPosition.dy / squareSize).floor();
                              Provider.of<GameBoardNotifier>(context,
                                      listen: false)
                                  .startTouch(x, y);
                            },
                            onPanUpdate: (details) {
                              final RenderBox renderBox =
                                  context.findRenderObject() as RenderBox;
                              final localPosition = renderBox
                                  .globalToLocal(details.globalPosition);
                              final x = (localPosition.dx / squareSize).floor();
                              final y = (localPosition.dy / squareSize).floor();
                              Provider.of<GameBoardNotifier>(context,
                                      listen: false)
                                  .updateTouch(x, y);
                            },
                            onPanEnd: (_) => Provider.of<GameBoardNotifier>(
                                    context,
                                    listen: false)
                                .endTouch(),
                            child: GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: 150,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 10,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                final int x = index % 10;
                                final int y = index ~/ 10;
                                final isTaken =
                                    Provider.of<GameBoardNotifier>(context)
                                        .movePath
                                        .contains(Point(x, y));
                                final spotColor =
                                    Provider.of<GameBoardNotifier>(context)
                                        .circleSpots[Point(x, y)];

                                return CustomPaint(
                                  painter: spotColor != null
                                      ? CirclePainter(color: spotColor)
                                      : null,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      color: isTaken
                                          ? Provider.of<GameBoardNotifier>(
                                                  context)
                                              .selectedSpotColor
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      )),
                  SizedBox(height: viewportConstraints.maxHeight * 0.05),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
