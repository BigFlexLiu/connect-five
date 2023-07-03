import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bloc/game_board_notifier.dart';
import '../constant.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            // Handle back button press
          },
        ),
        title: const Text('Connect Five'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<GameBoardNotifier>(context, listen: false).newGame();
              // Handle back button press
            },
          ),
          IconButton(
            icon: const Icon(Icons.trending_flat),
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
                  SizedBox(
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
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 150,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 10,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                final int x = index % 10;
                                final int y = index ~/ 10;

                                final position = Point(x, y);
                                final isTaken =
                                    Provider.of<GameBoardNotifier>(context)
                                        .movePath
                                        .contains(position);
                                final isInConnectFive =
                                    Provider.of<GameBoardNotifier>(context)
                                        .positionsToAnimate
                                        .containsKey(position);
                                final image = isInConnectFive
                                    ? Provider.of<GameBoardNotifier>(context)
                                        .positionsToAnimate[position]
                                    : Provider.of<GameBoardNotifier>(context)
                                        .selectedSpotImage(position);

                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    color: isTaken
                                        ? Provider.of<GameBoardNotifier>(
                                                context)
                                            .selectedSpotColor
                                        : null,
                                  ),
                                  child: image != null
                                      ? Image(
                                          image: AssetImage(image),
                                          fit: BoxFit.contain,
                                        )
                                      : null,
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
