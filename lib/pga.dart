import 'dart:io';

import 'package:pga/models/player.dart';
import 'package:pga/models/player_stats.dart';
import 'package:pga/scraper/rev_scraper.dart';

void navigateToPage(link) async {
  var scraper = RevScraper(link: link);
  String completionMessage = '';
  try {
    completionMessage = await scraper.getData();
  } catch (e) {
    print(e);
    print('\nPress ENTER to exit.');
    stdin.readLineSync();
  }

  print(completionMessage);
  var title = scraper.title;

  if (scraper.playerStats.isNotEmpty) {
    createStatsCSV(scraper.playerStats, title);
    print('\n✓ Created stats csv file as "Stats - $title.csv".');
  } else {
    print(
        '\n⊗ Player stats were unable to be generated. Please restart the process and try again.');
  }
  if (scraper.playerDetails.isNotEmpty) {
    createLeaderBoardCSV(scraper.playerDetails, title);
    print('✓ Created leaderboard csv file as "Leaderboard - $title.csv".');
  }

  print('Press ENTER to exit.');
  stdin.readLineSync();
}

void createStatsCSV(List<PlayerStats> stats, String filename) {
  File file = File('Stats - $filename.csv');
  file.writeAsStringSync(
      'Player Name,Position,Total,Round Number,Round Score,Course,Driving Distance,Driving Accuracy,Greens In Regulation,SG: Off The Tee,SG: Approach To Green, SG: Around The Green,SG: Putting,Eagles,Birdies,Pars,Bogeys,Double Bogeys +\n');

  for (var stat in stats) {
    file.writeAsStringSync(
      '${stat.player.playerName},${stat.player.position},${stat.player.total},${stat.roundNumber},${stat.roundScore},${stat.courseName},${stat.drivingDistance.split(' ')[0]},${stat.drivingAccuracy.split(' ')[0]},${stat.greensInRegulation.split(' ')[0]},${stat.sgOffTheTee},${stat.sgApproachTheGreen},${stat.sgAroundTheGreen},${stat.sgPutting},${stat.eagles},${stat.birdies},${stat.pars},${stat.bogeys},${stat.doubleBogeys}\n',
      mode: FileMode.append,
    );
  }
}

void createLeaderBoardCSV(List<Player> players, String filename) {
  File file = File('Leaderboard - $filename.csv');
  file.writeAsStringSync(
      'Player Name,Position,Total,R1,R2,R3,R4,Strokes,Course\n');

  for (var player in players) {
    file.writeAsStringSync(
      '${player.playerName},${player.position},${player.total},${player.roundOne},${player.roundTwo},${player.roundThree},${player.roundFour},${player.strokes},${player.course}\n',
      mode: FileMode.append,
    );
  }
}
