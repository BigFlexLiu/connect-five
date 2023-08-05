import 'package:connect_five/screens/guide/bonuses_guide.dart';
import 'package:connect_five/screens/guide/good_luck.dart';
import 'package:connect_five/screens/guide/orb_generation_guide.dart';
import 'package:connect_five/screens/guide/top_bar_guide.dart';
import 'package:flutter/material.dart';

import 'guide/connect_five.dart';
import 'guide/move_guide.dart';

// A horizontal scrolling list of tutorial pages
class HowToPage extends StatelessWidget {
  const HowToPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    return PageView(
      /// [PageView.scrollDirection] defaults to [Axis.horizontal].
      /// Use [Axis.vertical] to scroll vertically.
      controller: controller,
      children: const <Widget>[
        Center(child: ConnectFiveGuide()),
        Center(child: MoveGuide()),
        Center(child: TopBarGuide()),
        Center(child: OrbGenerationGuide()),
        Center(child: BonusesGuide()),
        Center(child: GoodLuckGuide()),
      ],
    );
  }
}
