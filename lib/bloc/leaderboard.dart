import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerScore {
  final String playerName;
  final int score;

  PlayerScore(this.playerName, this.score);
}

class LeaderBoard {
  final length = 10;
  List<PlayerScore> _scores = [];

  LeaderBoard();

  LeaderBoard.fromScores(this._scores);

  List<PlayerScore> get scores => _scores;
  int get minHighscore =>
      scores.length < length ? 0 : scores[scores.length - 1].score;

  void addScore(PlayerScore playerScore) {
    _scores.add(playerScore);
    _scores.sort((a, b) => b.score.compareTo(a.score));
    if (scores.length == 10) {
      _scores.removeLast();
    }
  }

  void clear() {
    _scores.clear();
  }
}

class LeaderBoardProvider with ChangeNotifier {
  LeaderBoard _leaderBoard = LeaderBoard();

  LeaderBoardProvider() {
    loadScores();
  }

  LeaderBoard get leaderBoard => _leaderBoard;

  void addScore(PlayerScore playerScore) {
    _leaderBoard.addScore(playerScore);
    saveScores();
    notifyListeners();
  }

  void clearScores() {
    _leaderBoard.clear();
    saveScores();
    notifyListeners();
  }

  void saveScores() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_leaderBoard.scores
        .map((score) => {'playerName': score.playerName, 'score': score.score})
        .toList());
    await prefs.setString('leaderBoard', data);
  }

  void loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('leaderBoard');
    if (data != null) {
      final scores = (jsonDecode(data) as List)
          .map((item) => PlayerScore(item['playerName'], item['score']))
          .toList();
      _leaderBoard = LeaderBoard.fromScores(scores);
    }
  }

  get isLeaderBoardEmpty => leaderBoard._scores.isEmpty;
}
