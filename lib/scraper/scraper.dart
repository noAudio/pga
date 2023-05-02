import 'dart:convert';
import 'dart:io';

import 'package:pga/models/player.dart';
import 'package:pga/models/player_stats.dart';
import 'package:puppeteer/puppeteer.dart';

class Scraper {
  String link;
  late String title;
  late Page _page;
  List<Player> playerDetails = [];
  List<PlayerStats> playerStats = [];
  late Browser _browser;
  String _error = '';

  Scraper({
    required this.link,
  });

  launchPage() async {
    try {
      _browser =
          await puppeteer.launch(headless: false, args: ['--start-maximized']);
      _page = await _browser.newPage();
      await _page.goto(link, wait: Until.domContentLoaded);
      title = await _page.title as String;
      print('Successfuly loaded $title.');
    } catch (e) {
      _error = '$e';
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
            position: item['position'],
            playerName: item['player']['displayName'],
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
    print('${playerDetails.length} players found.');
  }

  Future<List<ElementHandle>> recheckElement(
      String selector, String elementName) async {
    var elementList = await _page.$x(selector);
    while (elementList.isEmpty) {
      sleep(Duration(seconds: 1));
      elementList = await _page.$x(selector);
    }

    return elementList;
  }

  Future<String> getStatFromElement(String selector) async {
    var element = await _page.$x(selector);
    String elementText = await _page
        .evaluate('(element) => element.innerHTML', args: [element[0]]);
    return elementText;
  }

  getPlayerStats() async {
    List<ElementHandle> players = await _page.$$('tr');
    for (var i = 1; i <= players.length; i++) {
      var player = await _page.$x(
          '//*[@id="tabs-:R3kqmdf6:--tabpanel-0"]/div[7]/div/div/div/table/tbody/tr[$i]');
      var nameContainer = await _page.$x(
          '//*[@id="tabs-:R3kqmdf6:--tabpanel-0"]/div[7]/div/div/div/table/tbody/tr[$i]/td[3]/div/div/div/span');
      if (nameContainer.isEmpty) {
        // Some table row elements are just decorative.
        // Since they won't have a span element with the player
        // name, we just skip them and continue the loop.
        continue;
      }
      var name = await _page
          .evaluate('(element) => element.innerHTML', args: [nameContainer[0]]);

      // Open stats element
      await player[0].click();

      String statsButtonSelector =
          '/html/body/div[1]/div[2]/div/div/main/div[6]/div[2]/div[1]/div[7]/div/div/div/table/tbody/tr[${i + 1}]/td/div/div/div/div[2]/div[1]/div/button[2]';
      String closeButtonSelector =
          '//*[@id="tabs-:R3kqmdf6:--tabpanel-0"]/div[7]/div/div/div/table/tbody/tr[$i + 1]/td/div/div/button';
      String roundsButtonsSelector =
          '/html/body/div[1]/div[2]/div/div/main/div[6]/div[2]/div[1]/div[7]/div/div/div/table/tbody/tr[${i + 1}]/td/div/div/div/div[2]/div[2]/div[2]/section/div[2]/div[1]/button';

      var statsButton = await recheckElement(statsButtonSelector, 'Stats');
      var closeButton = await recheckElement(closeButtonSelector, 'Close');

      await statsButton[0].click();

      var roundsPlayedButtons =
          await recheckElement(roundsButtonsSelector, 'RoundButtons');
      // Remove 'All' button.
      for (var item in roundsPlayedButtons) {
        String innerHtml = await _page
            .evaluate('(element) => element.innerHTML', args: [item]);

        if (innerHtml.contains('All')) {
          roundsPlayedButtons.remove(item);
          break;
        }
      }

      int round = roundsPlayedButtons.length;
      int divDesignation = 2;

      for (var button in roundsPlayedButtons) {
        var data = <String>[name, '$round'];
        await button.click();
        List<String> dataElementPositions = [
          '1',
          '2',
          '3',
          '4',
          '6',
          '7',
          '8',
          '10',
          '11',
          '12',
          '1',
          '2',
          '3',
          '4',
          '5',
        ];
        int track = 0;
        for (String position in dataElementPositions) {
          String section = track >= 10 ? '2' : '1';
          data.add(await getStatFromElement(
              '/html/body/div[1]/div[2]/div/div/main/div[6]/div[2]/div[1]/div[7]/div/div/div/table/tbody/tr[${i + 1}]/td/div/div/div/div[2]/div[2]/div[2]/section/div[2]/div[2]/div[$divDesignation]/div/div[$section]/div[1]/div[5]/div[$position]/div/div[2]/div/span[2]'));
          track++;
        }
        print(data);

        round--;
        divDesignation++;
        playerStats.add(
          PlayerStats(
            playerName: data[0].replaceAll(',', ' '),
            roundNumber: data[1],
            sgOffTheTee: data[2],
            sgApproachTheGreen: data[3],
            sgAroundTheGreen: data[4],
            sgPutting: data[5],
            sgTotal: data[6],
            drivingAccuracy: data[7].split(' ')[0],
            drivingDistance: data[8].split(' ')[0],
            greensInRegulation: data[9].split(' ')[0],
            sandSaves: data[10].split(' ')[0],
            scrambling: data[11].split(' ')[0],
            eagles: data[12],
            birdies: data[13],
            pars: data[14],
            bogeys: data[15],
            doubleBogeys: data[16],
          ),
        );
      }

      await closeButton[0].click();
    }
  }

  Future<String> getData() async {
    await launchPage();
    if (_error != '') {
      return _error;
    }
    await getPlayers();
    print('Checking player stats...');
    await getPlayerStats();

    // End session
    await closeBrowser();
    return 'Closed browser!';
  }
}
