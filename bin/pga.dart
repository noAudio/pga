import 'dart:io';

import 'package:pga/pga.dart' as pga;

void main(List<String> arguments) {
  const String defaultLink = 'https://www.pgatour.com/leaderboard';
  String testLink =
      'https://www.pgatour.com/tournaments/2023/rbc-canadian-open/R2023032';
  pga.navigateToPage(testLink);
  // String? link = getUserInput(defaultLink);
  // if (link == null) {
  //   print('⊙ User input skipped. Aborting process.');
  //   print('Press ENTER to exit.');
  //   stdin.readLineSync();
  // } else {
  //   pga.navigateToPage(link);
  // }
}

bool validateLink(String userInput) {
  RegExp pattern = RegExp(
      r'^(https?://)?(www\.)?pgatour\.com/tournaments/\d{4}/[\w-]+/[\w\d]+$');

  return pattern.hasMatch(userInput);
}

String? getUserInput(String defaultLink) {
  print('Please type / paste in a link or hit ENTER to load "$defaultLink":');
  String? link = stdin.readLineSync();

  if (link == null) {
    return null;
  }

  if (link != '') {
    if (link == defaultLink) {
      print('⇾ Link matches default link.');
      print('Navigating to default link ($defaultLink).\n');
      return link;
    } else if (validateLink(link)) {
      print('Navigating to ($link).\n');
      return link;
    } else {
      print('⊙ Please enter a valid link from PGATour! You entered "$link".\n');
      return getUserInput(defaultLink);
    }
  } else {
    print('⇾ No link provided. Navigating to default link ($defaultLink).');
    return defaultLink;
  }
}
