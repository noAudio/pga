import 'dart:convert';

import 'package:pga/models/player.dart';

class PlayerStats {
  Player player;
  String roundNumber;
  String? roundScore;
  String sgOffTheTee;
  String sgApproachTheGreen;
  String sgAroundTheGreen;
  String sgPutting;
  String drivingAccuracy;
  String drivingDistance;
  String greensInRegulation;
  String eagles;
  String birdies;
  String pars;
  String bogeys;
  String doubleBogeys;
  String? courseName;
  PlayerStats({
    required this.player,
    required this.roundNumber,
    this.roundScore,
    required this.sgOffTheTee,
    required this.sgApproachTheGreen,
    required this.sgAroundTheGreen,
    required this.sgPutting,
    required this.drivingAccuracy,
    required this.drivingDistance,
    required this.greensInRegulation,
    required this.eagles,
    required this.birdies,
    required this.pars,
    required this.bogeys,
    required this.doubleBogeys,
    this.courseName,
  });

  PlayerStats copyWith({
    Player? player,
    String? roundNumber,
    String? roundScore,
    String? sgOffTheTee,
    String? sgApproachTheGreen,
    String? sgAroundTheGreen,
    String? sgPutting,
    String? drivingAccuracy,
    String? drivingDistance,
    String? greensInRegulation,
    String? eagles,
    String? birdies,
    String? pars,
    String? bogeys,
    String? doubleBogeys,
    String? courseName,
  }) {
    return PlayerStats(
      player: player ?? this.player,
      roundNumber: roundNumber ?? this.roundNumber,
      roundScore: roundScore ?? this.roundScore,
      sgOffTheTee: sgOffTheTee ?? this.sgOffTheTee,
      sgApproachTheGreen: sgApproachTheGreen ?? this.sgApproachTheGreen,
      sgAroundTheGreen: sgAroundTheGreen ?? this.sgAroundTheGreen,
      sgPutting: sgPutting ?? this.sgPutting,
      drivingAccuracy: drivingAccuracy ?? this.drivingAccuracy,
      drivingDistance: drivingDistance ?? this.drivingDistance,
      greensInRegulation: greensInRegulation ?? this.greensInRegulation,
      eagles: eagles ?? this.eagles,
      birdies: birdies ?? this.birdies,
      pars: pars ?? this.pars,
      bogeys: bogeys ?? this.bogeys,
      doubleBogeys: doubleBogeys ?? this.doubleBogeys,
      courseName: courseName ?? this.courseName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'player': player.toMap(),
      'roundNumber': roundNumber,
      'roundScore': roundScore,
      'sgOffTheTee': sgOffTheTee,
      'sgApproachTheGreen': sgApproachTheGreen,
      'sgAroundTheGreen': sgAroundTheGreen,
      'sgPutting': sgPutting,
      'drivingAccuracy': drivingAccuracy,
      'drivingDistance': drivingDistance,
      'greensInRegulation': greensInRegulation,
      'eagles': eagles,
      'birdies': birdies,
      'pars': pars,
      'bogeys': bogeys,
      'doubleBogeys': doubleBogeys,
      'courseName': courseName,
    };
  }

  factory PlayerStats.fromMap(Map<String, dynamic> map) {
    return PlayerStats(
      player: Player.fromMap(map['player']),
      roundNumber: map['roundNumber'] ?? '',
      roundScore: map['roundScore'],
      sgOffTheTee: map['sgOffTheTee'] ?? '',
      sgApproachTheGreen: map['sgApproachTheGreen'] ?? '',
      sgAroundTheGreen: map['sgAroundTheGreen'] ?? '',
      sgPutting: map['sgPutting'] ?? '',
      drivingAccuracy: map['drivingAccuracy'] ?? '',
      drivingDistance: map['drivingDistance'] ?? '',
      greensInRegulation: map['greensInRegulation'] ?? '',
      eagles: map['eagles'] ?? '',
      birdies: map['birdies'] ?? '',
      pars: map['pars'] ?? '',
      bogeys: map['bogeys'] ?? '',
      doubleBogeys: map['doubleBogeys'] ?? '',
      courseName: map['courseName'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PlayerStats.fromJson(String source) =>
      PlayerStats.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PlayerStats(player: $player, roundNumber: $roundNumber, roundScore: $roundScore, sgOffTheTee: $sgOffTheTee, sgApproachTheGreen: $sgApproachTheGreen, sgAroundTheGreen: $sgAroundTheGreen, sgPutting: $sgPutting, drivingAccuracy: $drivingAccuracy, drivingDistance: $drivingDistance, greensInRegulation: $greensInRegulation, eagles: $eagles, birdies: $birdies, pars: $pars, bogeys: $bogeys, doubleBogeys: $doubleBogeys, courseName: $courseName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PlayerStats &&
        other.player == player &&
        other.roundNumber == roundNumber &&
        other.roundScore == roundScore &&
        other.sgOffTheTee == sgOffTheTee &&
        other.sgApproachTheGreen == sgApproachTheGreen &&
        other.sgAroundTheGreen == sgAroundTheGreen &&
        other.sgPutting == sgPutting &&
        other.drivingAccuracy == drivingAccuracy &&
        other.drivingDistance == drivingDistance &&
        other.greensInRegulation == greensInRegulation &&
        other.eagles == eagles &&
        other.birdies == birdies &&
        other.pars == pars &&
        other.bogeys == bogeys &&
        other.doubleBogeys == doubleBogeys &&
        other.courseName == courseName;
  }

  @override
  int get hashCode {
    return player.hashCode ^
        roundNumber.hashCode ^
        roundScore.hashCode ^
        sgOffTheTee.hashCode ^
        sgApproachTheGreen.hashCode ^
        sgAroundTheGreen.hashCode ^
        sgPutting.hashCode ^
        drivingAccuracy.hashCode ^
        drivingDistance.hashCode ^
        greensInRegulation.hashCode ^
        eagles.hashCode ^
        birdies.hashCode ^
        pars.hashCode ^
        bogeys.hashCode ^
        doubleBogeys.hashCode ^
        courseName.hashCode;
  }
}
