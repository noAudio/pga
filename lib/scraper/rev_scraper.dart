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
      print('\n✓ Successfuly loaded $title.');

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
            '\n⊗ Page could not be loaded, potentially an internet connectivity issue. ($e)';
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
    print('⇾ ${playerDetails.length} players found.');
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
            '⇢ Trouble finding $elementName element on the page. Please wait a few more seconds for recheck to happen.');
      }
      if (timeElapsed == 75) {
        print(
            '⊗ Could not find $elementName element. The page might not have rendered fully or correctly. Please restart the process.');
      }
      timeElapsed++;
    }

    return elementList;
  }

  getByIndex(
      {required List<dynamic> list,
      required String key,
      required dynamic value,
      required String finalKey}) {
    int index = list.indexWhere((element) => element[key] == value);
    if (index == -1) {
      return null;
    }
    return list[index][finalKey];
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
          roundScore: roundNumber == '1'
              ? matchedPlayer[0].roundOne
              : roundNumber == '2'
                  ? matchedPlayer[0].roundTwo
                  : roundNumber == '3'
                      ? matchedPlayer[0].roundThree
                      : matchedPlayer[0].roundFour,
          sgOffTheTee: getByIndex(
                list: performance,
                key: 'label',
                value: 'SG: Off The Tee',
                finalKey: 'total',
              ) ??
              'n/a',
          sgApproachTheGreen: getByIndex(
                list: performance,
                key: 'label',
                value: 'SG: Approach to Green',
                finalKey: 'total',
              ) ??
              'n/a',
          sgAroundTheGreen: getByIndex(
                list: performance,
                key: 'label',
                value: 'SG: Around The Green',
                finalKey: 'total',
              ) ??
              'n/a',
          sgPutting: getByIndex(
                list: performance,
                key: 'label',
                value: 'SG: Putting',
                finalKey: 'total',
              ) ??
              'n/a',
          drivingAccuracy: getByIndex(
                list: performance,
                key: 'label',
                value: 'Driving Accuracy',
                finalKey: 'total',
              ) ??
              'n/a',
          drivingDistance: getByIndex(
                list: performance,
                key: 'label',
                value: 'Driving Distance',
                finalKey: 'total',
              ) ??
              'n/a',
          greensInRegulation: getByIndex(
                list: performance,
                key: 'label',
                value: 'Greens in Regulation',
                finalKey: 'total',
              ) ??
              'n/a',
          eagles: getByIndex(
                list: scoring,
                key: 'label',
                value: 'Eagles -',
                finalKey: 'total',
              ) ??
              'n/a',
          birdies: getByIndex(
                list: scoring,
                key: 'label',
                value: 'Birdies',
                finalKey: 'total',
              ) ??
              'n/a',
          pars: getByIndex(
                list: scoring,
                key: 'label',
                value: 'Pars',
                finalKey: 'total',
              ) ??
              'n/a',
          bogeys: getByIndex(
                list: scoring,
                key: 'label',
                value: 'Bogeys',
                finalKey: 'total',
              ) ??
              'n/a',
          doubleBogeys: getByIndex(
                list: scoring,
                key: 'label',
                value: 'Double Bogeys +',
                finalKey: 'total',
              ) ??
              'n/a',
          courseName: matchedPlayer[0].course,
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
    // Elements that have less than 5 children are not
    // relevant for our use case so they will be ignored.
    // TODO: Switch the number to 9
    var players = await _page.$x('//tbody/tr[count(*)>5]');
    print('⇾ Found ${players.length} matching elements.');

    for (var i = 0; i < players.length; i++) {
      // Info to show user so that app doesn't appear to be
      // hanging.
      if (i == (players.length / 4).round() + 1) {
        print(
            '⇢ Evaluated 1/4 (${(players.length / 4).round()}) of the players.');
      } else if (i == (players.length / 2).round() + 1) {
        print(
            '⇢ Evaluated 1/2 (${(players.length / 2).round()}) of the players.');
      } else if (i == ((players.length * 3) / 4).round() + 1) {
        print(
            '⇢ Evaluated 3/4 (${((players.length * 3) / 4).round()}) of the players.');
      } else if (i == players.length - 1) {
        print('⇢ Evaluating last player...');
      }
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
                '⇢ Trouble finding $name element on the page. Stuck on player number ${i + 1}. Please wait a few more seconds for recheck to happen...');
          }
          if (timeElapsed == 20) {
            print(
                '⊗ Could not find $name element for player number ${i + 1}. The page might not have rendered fully or correctly. Please restart the process.');
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

      // This is a listener that tries to capture the
      // json response of api calls made by the page.
      //
      // Since the elements holding the data keep changing
      // every new tournament, capturing the json response
      // makes sure the data is obtained since it looks like
      // the json structure remains the same throughout all
      // tournaments.
      _page.onResponse.listen((response) async {
        String payload = '';
        // Check if the response URL matches the graphql endpoint
        if (response.url == 'https://orchestrator.pgatour.com/graphql') {
          // Get the payload from the graphql response as a string
          try {
            payload = await response.text;
          } on ServerException {
            // Sometimes a Server Exception is encountered
            // when the response is mishandled.
            // We can ignore this since the data is sent multiple
            // times so one way or another the data is always
            // available.
          }
          // The relevant data we need will always have 'scorecardStats'
          // within it. This api call is only triggered after the 'Stats'
          // button is clicked.
          if (payload.contains('scorecardStats')) {
            combineData(roundsStats: payload);
          }
        }
      });

      await statsButton[0].click();

      sleep(Duration(seconds: 3));

      await closeButton[0].click();
    }
  }

  Future<String> getData() async {
    try {
      await launchPage();
    } catch (e) {
      print('\n⊗ An unexpected error occurred. This was the message:');
      print(e);
      await closeBrowser();
    }
    if (_error != '') {
      return _error;
    }
    await getPlayers();
    print('⇾ Checking player stats...');
    try {
      await getPlayerStats();
    } on TargetClosedException {
      print(
          '\n⊙ Browser terminated. Please restart the process to get the full data.');
    } on Exception catch (e) {
      print('\n⊗ An unexpected error occurred:');
      print(e);
      await closeBrowser();
    }

    // End session
    await closeBrowser();
    return '⇾ Closed browser!';
  }
}
