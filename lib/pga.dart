import 'dart:io';

import 'package:pga/models/player.dart';
import 'package:pga/models/player_stats.dart';
import 'package:pga/scraper/scraper.dart';

void navigateToPage(link) async {
  var scraper = Scraper(link: link);
  String completionMessage = await scraper.getData();
  print(completionMessage);
  if (scraper.playerStats.isNotEmpty) {
    var title = scraper.title.replaceAll(' ', '');
    createStatsCSV(scraper.playerStats, title);
    print('Created stats csv file as (stats)$title.csv');
  }
  if (scraper.playerDetails.isNotEmpty) {
    var title = scraper.title.replaceAll(' ', '');
    createLeaderBoardCSV(scraper.playerDetails, title);
    print('Created leaderboard csv file as "(leaderboard)$title.csv".');
  }
}

void createStatsCSV(List<PlayerStats> stats, String filename) {
  File file = File('(stats)$filename.csv');
  file.writeAsStringSync(
      'Player Name,Round #,SG: Off The Tee,SG: Approach the Green,SG: Around The Green,SG: Putting,SG: Total,Driving Accuracy,Driving Distance,Greens in Regulation,Sand Saves,Scrambling,Eagles,Birdies,Pars,Bogeys,Double Bogeys +\n');

  for (var stat in stats) {
    file.writeAsStringSync(
      '${stat.playerName},${stat.roundNumber},${stat.sgOffTheTee},${stat.sgApproachTheGreen},${stat.sgAroundTheGreen},${stat.sgPutting},${stat.sgTotal},${stat.drivingAccuracy},${stat.drivingDistance},${stat.greensInRegulation},${stat.sandSaves},${stat.scrambling},${stat.eagles},${stat.birdies},${stat.pars},${stat.bogeys},${stat.doubleBogeys}\n',
      mode: FileMode.append,
    );
  }
}

void createLeaderBoardCSV(List<Player> players, String filename) {
  File file = File('(leaderboard)$filename.csv');
  file.writeAsStringSync(
      'Position,PlayerName,Total,R1,R2,R3,R4,Strokes,Course\n');

  for (var player in players) {
    file.writeAsStringSync(
      '${player.position},${player.playerName},${player.total},${player.roundOne},${player.roundTwo},${player.roundThree},${player.roundFour},${player.strokes},${player.course}\n',
      mode: FileMode.append,
    );
  }
}
