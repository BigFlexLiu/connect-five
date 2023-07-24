import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:connect_five/constant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bloc/game_board_notifier.dart';

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
  void playSound() async {
    final player = AudioPlayer();

    await player.play(
      AssetSource('pop_short.mp3'),
      mode: PlayerMode.lowLatency,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    Size screenSize = MediaQuery.of(context).size;

    // Calculate total grid area (80% of screen area)
    final double totalGridArea = screenSize.width * screenSize.height * 0.7;

    // Calculate area, width, and height of each grid item
    final double gridItemArea = totalGridArea / 150;
    final double gridItemSize = sqrt(gridItemArea);

    final int cols = (screenSize.width / gridItemSize).floor();

    final double actualGridWidth = screenSize.width / cols;

    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
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
                    Provider.of<GameBoardNotifier>(context, listen: false)
                        .newGame();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    Provider.of<GameBoardNotifier>(context, listen: false)
                        .newTurn();
                  },
                ),
              ]),
          body: LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
              final gameBoard = Provider.of<GameBoardNotifier>(context);
              return ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(height: viewportConstraints.maxHeight * 0.02),
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle,
                            size: 24,
                            color: pathColors[gameBoard.newestColor],
                          ),
                          Text(
                              "${gameBoard.orbNum}${gameBoard.generationNerf > 0 ? " (- ${gameBoard.generationNerf})" : ""}"),
                          const Spacer(),
                          Text(
                            'Score: ${Provider.of<GameBoardNotifier>(context).score}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.hourglass_disabled,
                            size: 24,
                          ),
                          Text("${gameBoard.turnsPaused}"),
                        ],
                      ),
                    ),
                    SizedBox(height: viewportConstraints.maxHeight * 0.02),
                    SizedBox(
                        height: viewportConstraints.maxHeight * 0.8,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return GestureDetector(
                              onPanDown: (details) {
                                final RenderBox renderBox =
                                    context.findRenderObject() as RenderBox;
                                final localPosition = renderBox
                                    .globalToLocal(details.globalPosition);
                                final x = (localPosition.dx / actualGridWidth)
                                    .floor();
                                final y = (localPosition.dy / actualGridWidth)
                                    .floor();
                                Provider.of<GameBoardNotifier>(context,
                                        listen: false)
                                    .startTouch(x, y);
                              },
                              onPanUpdate: (details) {
                                final RenderBox renderBox =
                                    context.findRenderObject() as RenderBox;
                                final localPosition = renderBox
                                    .globalToLocal(details.globalPosition);
                                final x = (localPosition.dx / actualGridWidth)
                                    .floor();
                                final y = (localPosition.dy / actualGridWidth)
                                    .floor();
                                Provider.of<GameBoardNotifier>(context,
                                        listen: false)
                                    .updateTouch(x, y);
                              },
                              onPanEnd: (_) => Provider.of<GameBoardNotifier>(
                                      context,
                                      listen: false)
                                  .endTouch(),
                              child: AspectRatio(
                                aspectRatio: gameBoard.width / gameBoard.height,
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: gameBoard.width * gameBoard.height,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: gameBoard.width,
                                  ),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final int x = index % gameBoard.width;
                                    final int y = index ~/ gameBoard.width;

                                    final position = Point(x, y);
                                    final isTaken =
                                        Provider.of<GameBoardNotifier>(context)
                                            .movePath
                                            .contains(position);
                                    final isInConnectFive =
                                        Provider.of<GameBoardNotifier>(context)
                                            .connectiveFivePos
                                            .contains(position);
                                    final color =
                                        Provider.of<GameBoardNotifier>(context)
                                            .getPositionColor(position);
                                    final previewImage =
                                        Provider.of<GameBoardNotifier>(context)
                                            .previewImage(position);
                                    final image =
                                        Provider.of<GameBoardNotifier>(context)
                                            .selectedSpotImage(position);

                                    // Define the color for the Container decoration based on certain conditions
                                    final boxColor =
                                        (isTaken || isInConnectFive)
                                            ? color
                                            : null;
                                    // Define the image for the Container child based on certain conditions
                                    final containerImage = (image != null)
                                        ? AssetImage(image)
                                        : (previewImage != null)
                                            ? AssetImage(previewImage)
                                            : null;
                                    // Define the child for the Container based on whether there's an image or not
                                    final containerChild =
                                        (containerImage != null)
                                            ? Image(
                                                image: containerImage,
                                                fit: BoxFit.contain)
                                            : null;
                                    // Return the Container
                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(),
                                        color: boxColor,
                                      ),
                                      child: containerChild,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        )),
                    SizedBox(height: viewportConstraints.maxHeight * 0.05),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
