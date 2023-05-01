import 'package:pga/scraper/scraper.dart';

void navigateToPage(link) async {
  var scraper = Scraper(link: link);
  String completionMessage = await scraper.getData();
  print(completionMessage);
}
