import 'package:pga/scraper/scraper.dart';

void navigateToPage(link) {
  var scraper = Scraper(link: link);
  scraper.getData();
}
