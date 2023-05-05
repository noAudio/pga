import 'dart:io';

import 'package:pga/models/player.dart';
import 'package:pga/models/player_stats.dart';
import 'package:pga/scraper/rev_scraper.dart';
import 'package:pga/scraper/scraper.dart';

void navigateToPage(link) async {
  var scraper = RevScraper(link: link);
  String completionMessage = await scraper.getData();
  print(completionMessage);
  if (scraper.playerStats.isNotEmpty) {
    var title = scraper.title.replaceAll(' ', '');
    createStatsCSV(scraper.playerStats, title);
    print('Created stats csv file as (stats)$title.csv');
  } else {
    print(
        'Player stats were unable to be scraped. The page elements might have been modified or there are no stats to scrape.');
  }
  // if (scraper.playerDetails.isNotEmpty) {
  //   var title = scraper.title.replaceAll(' ', '');
  //   createLeaderBoardCSV(scraper.playerDetails, title);
  //   print('Created leaderboard csv file as "(leaderboard)$title.csv".');
  // }
}

void createStatsCSV(List<PlayerStats> stats, String filename) {
  File file = File('(stats)$filename.csv');
  file.writeAsStringSync(
      'Player Name,Round #,SG: Off The Tee,SG: Approach the Green,SG: Around The Green,SG: Putting,Driving Distance,Driving Accuracy,Greens in Regulation,Eagles,Birdies,Pars,Bogeys,Double Bogeys +\n');

  for (var stat in stats) {
    file.writeAsStringSync(
      '${stat.player.playerName},${stat.roundNumber},${stat.sgOffTheTee},${stat.sgApproachTheGreen},${stat.sgAroundTheGreen},${stat.sgPutting},${stat.drivingDistance},${stat.drivingAccuracy},${stat.greensInRegulation},${stat.eagles},${stat.birdies},${stat.pars},${stat.bogeys},${stat.doubleBogeys}\n',
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
