import 'dart:convert';

import 'package:pga/models/player.dart';
import 'package:puppeteer/puppeteer.dart';

class Scraper {
  String link;
  late Page page;
  List<List<Player>> playerDetails = [];
  late Browser browser;

  Scraper({
    required this.link,
  });

  launchPage() async {
    browser = await puppeteer.launch(headless: false);
    page = await browser.newPage();
    await page.goto(link, wait: Until.domContentLoaded);
    var title = await page.title as String;
    print('Successfuly loaded $title');
  }

  closeBrowser() async {
    await browser.close();
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
    // List<ElementHandle> players = await page.$$('tr');
    // print('Checking players');
    // for (var element in players) {
    //   print(element);
    // }
    // print('Found ${players.length} players in the leaderboard');
    var data = await page.$('#__NEXT_DATA__');
    var json =
        await data.evaluate('(element) => element.textContent', args: [data]);
    Map<String, dynamic> decoded = jsonDecode(json);
    List<dynamic> playerJson =
        decoded['props']['pageProps']['leaderboard']['players'];
    List<dynamic> coursesJson =
        decoded['props']['pageProps']['tournament']['courses'];
    for (var item in playerJson) {
      if (item['__typename'] == 'PlayerRowV2') {
        playerDetails.add([
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
        ]);
      }
    }
    print('${playerDetails.length} players found.');
  }

  getData() async {
    await launchPage();
    await getPlayers();

    // End session
    await closeBrowser();
  }
}
