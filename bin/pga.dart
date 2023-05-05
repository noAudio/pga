import 'dart:io';

import 'package:pga/pga.dart' as pga;

void main(List<String> arguments) {
  String defaultLink = 'https://www.pgatour.com/leaderboard';
  String testLink =
      'https://www.pgatour.com/tournaments/2023/att-pebble-beach-pro-am/R2023005';
  String? link = getUserInput(defaultLink);
  if (link == null) {
    print('User input skipped. Aborting process.');
  } else {
    pga.navigateToPage(link);
  }
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
    if (validateLink(link)) {
      if (link == defaultLink) {
        print('Link matches default link.');
        print('Navigating to default link ($defaultLink).');
        return link;
      }
      print('Navigating to ($link).');
      return link;
    } else {
      print('Please enter a valid link from PGATour!');
      print('You entered "$link".');
      return getUserInput(defaultLink);
    }
  } else {
    print('No link provided. Navigating to default link ($defaultLink).');
    return defaultLink;
  }
}
