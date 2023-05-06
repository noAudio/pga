import 'dart:convert';
import 'dart:io';

import 'package:pga/models/player.dart';
import 'package:pga/models/player_stats.dart';
import 'package:puppeteer/puppeteer.dart';

class RevScraper {
  String link;
  late String title;
  late Page _page;
  List<Player> playerDetails = [];
  List<PlayerStats> playerStats = [];
  List<String> supplementaryData = [];
  late Browser _browser;
  String _error = '';

  RevScraper({
    required this.link,
  });

  launchPage() async {
    try {
      _browser =
          await puppeteer.launch(headless: false, args: ['--start-maximized']);
      _page = await _browser.newPage();
      await _page.goto(link, wait: Until.domContentLoaded);
      title = await _page.title as String;
      print('\n✔️ Successfuly loaded $title.');

      // Close ad links that the filter fails to recognise
      // while parsing tables.
      _browser.onTargetCreated.listen((target) async {
        if (target.type == "page") {
          var newPage = await target.page;
          await newPage.close();
        }
      });
    } catch (e) {
      _error = '\n$e';
      if (e.toString().contains('ERR_NAME_NOT_RESOLVED')) {
        _error =
            '\n$e\n✖️ Page could not be loaded, potentially an internet connectivity issue.';
      }
      _browser.close();
    }
  }

  closeBrowser() async {
    await _browser.close();
  }

  String checkCourseCode(String courseId, List<dynamic> courses) {
    String courseCode = 'n/a';
    for (var course in courses) {
      if (course['id'] == courseId) {
        courseCode = course['courseCode'];
        break;
      }
    }
    return courseCode;
  }

  getPlayers() async {
    var data = await _page.$('#__NEXT_DATA__');
    var json =
        await data.evaluate('(element) => element.textContent', args: [data]);
    Map<String, dynamic> decoded = jsonDecode(json);
    List<dynamic> playerJson =
        decoded['props']['pageProps']['leaderboard']['players'];
    List<dynamic> coursesJson =
        decoded['props']['pageProps']['tournament']['courses'];
    for (var item in playerJson) {
      if (item['__typename'] == 'PlayerRowV2') {
        playerDetails.add(
          Player(
            playerID: item['player']['id'],
            position: item['position'],
            playerName: item['player']['displayName'].replaceAll(',', ' '),
            total: item['total'],
            roundOne: item['rounds'][0],
            roundTwo: item['rounds'][1],
            roundThree: item['rounds'][2],
            roundFour: item['rounds'][3],
            strokes: item['totalStrokes'],
            course: checkCourseCode(item['courseId'], coursesJson),
          ),
        );
      }
    }
    print('➡️ ${playerDetails.length} players found.');
  }

  Future<List<ElementHandle>> recheckElement(
    String selector,
    ElementHandle rootElement,
    String elementName,
  ) async {
    var elementList = await rootElement.$x(selector);
    int timeElapsed = 0;
    while (elementList.isEmpty) {
      sleep(Duration(seconds: 1));
      elementList = await rootElement.$x(selector);
      if (timeElapsed == 10) {
        print(
            'ℹ️ Trouble finding $elementName element on the page. Please wait a few more seconds for recheck to happen.');
      }
      if (timeElapsed == 75) {
        print(
            '✖️ Could not find $elementName element. The page might not have rendered fully or correctly. Please restart the process.');
      }
      timeElapsed++;
    }

    return elementList;
  }

  void combineData({required String roundsStats}) {
    Map<String, dynamic> allRounds = jsonDecode(roundsStats);
    String id = allRounds['data']['scorecardStats']['id'];
    var rounds = allRounds['data']['scorecardStats']['rounds'];

    id = id.split('-')[1];
    var matchedPlayer = <Player>[];
    for (var item in playerDetails) {
      if (item.playerID == id) {
        matchedPlayer.add(item);
        break;
      }
    }

    for (var round in rounds) {
      String roundNumber = round['round'];
      // Don't pick summarised data
      if (roundNumber != '-1') {
        var performance = round['performance'];
        var scoring = round['scoring'];
        var roundStat = PlayerStats(
          player: matchedPlayer[0],
          roundNumber: roundNumber,
          // roundScore: roundScore,
          sgOffTheTee: performance[0]['total'],
          sgApproachTheGreen: performance[1]['total'],
          sgAroundTheGreen: performance[2]['total'],
          sgPutting: performance[3]['total'],
          drivingAccuracy: performance[6]['total'].split(' ')[0],
          drivingDistance: performance[7]['total'].split(' ')[0],
          greensInRegulation: performance[9]['total'].split(' ')[0],
          eagles: scoring[0]['total'],
          birdies: scoring[1]['total'],
          pars: scoring[2]['total'],
          bogeys: scoring[3]['total'],
          doubleBogeys: scoring[4]['total'],
          // courseName: courseName.replaceAll(',', ' '),
        );
        var isNotRecorded = true;
        if (playerStats.isNotEmpty) {
          // The page returns the json response more
          // than once. Check if the data is already
          // recorded to avoid duplicate data.
          for (var statItem in playerStats) {
            if (statItem == roundStat) {
              isNotRecorded = false;
            }
          }
        }

        if (isNotRecorded) {
          playerStats.add(roundStat);
        }
      }
    }
  }

  getPlayerStats() async {
    // Get all `tr` elements that are children of a
    // `td` element. This should only target `tr` elements
    // that have player info.
    var players = await _page.$x('//tbody/tr[count(*)>5]');
    print('➡️ Found ${players.length} matching elements.');

    for (var i = 0; i < players.length; i++) {
      var player = await _page.$x('(//tbody/tr[count(*)>5])[${i + 1}]');
      // The site displays ads in iframes.
      // Check the innerHTML of each player container and
      // if it contains the text "iframe" in any of the
      // children then skip evalutaion otherwise the app will
      // be stuck in a loop waiting for the stats button to
      // render.
      String innerHtml = await _page
          .evaluate('(element) => element.innerHTML', args: [player[0]]);
      if (innerHtml.contains('iframe')) {
        continue;
      }

      // Click player container to expand and find the stats button.
      await player[0].click();

      Future<List<ElementHandle>> loopUntilElementFound(
          {required ElementHandle rootElement,
          required String selector,
          required String name}) async {
        var element = await rootElement.$$(selector);
        int timeElapsed = 0;

        while (element.isEmpty) {
          sleep(Duration(seconds: 1));
          element = await rootElement.$$(selector);
          if (timeElapsed == 10) {
            print(
                '➡️ Trouble finding $name element on the page. Stuck on player number $i. Please wait a few more seconds for recheck to happen...');
          }
          if (timeElapsed == 20) {
            print(
                '➡️ Could not find $name element for player number $i. The page might not have rendered fully or correctly. Please restart the process.');
          }
          timeElapsed++;
        }

        return element;
      }

      var statsContainer = await _page.$$('.expanded-content');

      while (statsContainer.isEmpty) {
        statsContainer = await _page.$$('.expanded-content');
        sleep(Duration(seconds: 1));
      }

      var closeButton = await loopUntilElementFound(
        rootElement: statsContainer[0],
        selector: 'button',
        name: 'Close button',
      );

      var statsButton = await recheckElement(
          '//button[text()="Stats"]', statsContainer[0], 'Stats button');

      String roundsStats = '';
      String roundsTotal = '';

      // This is a listener that tries to capture the
      // json response of api calls made by the page.
      //
      // Since the elements holding the data keep changing
      // every new tournament, capturing the json response
      // makes sure the data is obtained since it looks like
      // the json structure remains the same throughout all
      // tournaments.
      _page.onResponse.listen((response) async {
        // Check if the response URL matches the graphql endpoint
        if (response.url == 'https://orchestrator.pgatour.com/graphql') {
          // Get the payload from the graphql response as a string
          var payload = await response.text;
          // The relevant data we need will always have 'scorecardStats'
          // within it. This api call is only triggered after the 'Stats'
          // button is clicked.
          if (payload.contains('scorecardStats')) {
            roundsStats = payload;
          }
          // This json response will contain the round totals and is
          // also required.
          // For some reason unknown to mankind, this data does not
          // load with the corresponding player (jk its probably to
          // combat scraping). So we just have to collect everything
          // and then extract what we need later.
          if (payload.contains('scorecardV2')) {
            roundsTotal = payload;
            bool isNotPresent = true;
            for (var item in supplementaryData) {
              if (roundsTotal == item) {
                isNotPresent = false;
                break;
              }
            }
            if (isNotPresent) {
              supplementaryData.add(roundsTotal);
              print('ps: ${playerStats.length}');
              print('sd: ${supplementaryData.length}');
            }
          }
        }
      });

      await statsButton[0].click();
      // bool foundStats = true;

      // Sometimes a pop up ad opens in a new page. This
      // breaks the program flow and the data that was
      // being captured at that point gets skipped.
      // Tracking the json payload from an external
      // variable allows us to click the Stats button
      // again after the pesky ad tab gets yeeted.
      while (roundsStats == '') {
        print('Waiting for all stats');
        sleep(Duration(seconds: 2));
        await statsButton[0].click();
      }

      combineData(roundsStats: roundsStats);

      sleep(Duration(seconds: 1));

      await closeButton[0].click();
    }
  }

  Future<String> getData() async {
    try {
      await launchPage();
    } catch (e) {
      print('\n✖️ An unexpected error occurred. This was the message:');
      print(e);
      await closeBrowser();
    }
    if (_error != '') {
      return _error;
    }
    await getPlayers();
    print('➡️ Checking player stats...');
    try {
      await getPlayerStats();
    } on TargetClosedException {
      print(
          '\n⚠️ Browser terminated. Please restart the process to get the full data.');
    } on Exception catch (e) {
      print('\n✖️ An unexpected error occurred:');
      print(e);
      await closeBrowser();
    }

    // End session
    await closeBrowser();
    return '➡️ Closed browser!';
  }
}
