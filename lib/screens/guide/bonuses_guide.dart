import 'package:flutter/material.dart';


class BonusesGuide extends StatelessWidget {
  const BonusesGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bonuses'),
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BonusDescription(
            "Connect five in a straight line",
            ["Multiply points earned by 5 times."],
          ),
          BonusDescription(
            "Connect five with five orbs",
            ["20 points", "Pause orb generation for two turns"],
          ),
          BonusDescription(
            "Connect five with six orbs",
            ["40 Bonus points", "Remove a random orb from the board"],
          ),
          BonusDescription(
            "Connect five with seven orbs",
            [
              "60 Bonus points",
              "Remove two random orb from the board",
              "Reduce the number of orbs generated by 1"
            ],
          ),
          BonusDescription(
            "Connect five with eight orbs",
            [
              "80 Bonus points",
              "Remove three random orb from the board",
              "Reduce the number of orbs generated by 1",
              "Remove all orbs of the same color as the connect five"
            ],
          ),
          BonusDescription(
            "Connect five with nine orbs",
            [
              "100 Bonus points",
              "Remove four random orb from the board",
              "Reduce the number of orbs generated by 1",
              "Ban the color of the connect five for five turns"
            ],
          ),
          BonusDescription(
            "Connect five with ten or more orbs",
            ["One hundred bonus point for each orb above nine"],
          ),
        ],
      ),
    );
  }
}

// Description for a bonus
class BonusDescription extends StatelessWidget {
  final String title;
  final List<String> bonuses;
  const BonusDescription(
    this.title,
    this.bonuses, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: bonuses.length,
            itemBuilder: (context, index) {
              return Text(
                " - ${bonuses[index]}",
                style: const TextStyle(fontSize: 14),
              );
            },
          ),
        ],
      ),
    );
  }
}