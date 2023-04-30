import 'package:pga/pga.dart' as pga;

void main(List<String> arguments) {
  String defaultLink = 'https://www.pgatour.com/leaderboard';
  // String defaultLink =
  // 'https://tourcast.pgatour.com/tourcast.html?id=R2023005&webview=true#/hole-view?round=4&hole=1';
  print('Navigating to default link ($defaultLink).');
  pga.navigateToPage(defaultLink);
}
