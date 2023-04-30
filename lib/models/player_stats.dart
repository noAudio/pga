import 'dart:convert';

class PlayerStats {
  String playerName;
  String roundNumber;
  String roundTotal;
  String sgOffTheTee;
  String sgApproachTheGreen;
  String sgAroundTheGreen;
  String sgPutting;
  String sgTotal;
  String drivingAccuracy;
  String drivingDistance;
  String greensInRegulation;
  String sandSaves;
  String scrambling;
  String eagles;
  String birdies;
  String pars;
  String bogeys;
  String doubleBogeys;
  PlayerStats({
    required this.playerName,
    required this.roundNumber,
    required this.roundTotal,
    required this.sgOffTheTee,
    required this.sgApproachTheGreen,
    required this.sgAroundTheGreen,
    required this.sgPutting,
    required this.sgTotal,
    required this.drivingAccuracy,
    required this.drivingDistance,
    required this.greensInRegulation,
    required this.sandSaves,
    required this.scrambling,
    required this.eagles,
    required this.birdies,
    required this.pars,
    required this.bogeys,
    required this.doubleBogeys,
  });

  PlayerStats copyWith({
    String? playerName,
    String? roundNumber,
    String? roundTotal,
    String? sgOffTheTee,
    String? sgApproachTheGreen,
    String? sgAroundTheGreen,
    String? sgPutting,
    String? sgTotal,
    String? drivingAccuracy,
    String? drivingDistance,
    String? greensInRegulation,
    String? sandSaves,
    String? scrambling,
    String? eagles,
    String? birdies,
    String? pars,
    String? bogeys,
    String? doubleBogeys,
  }) {
    return PlayerStats(
      playerName: playerName ?? this.playerName,
      roundNumber: roundNumber ?? this.roundNumber,
      roundTotal: roundTotal ?? this.roundTotal,
      sgOffTheTee: sgOffTheTee ?? this.sgOffTheTee,
      sgApproachTheGreen: sgApproachTheGreen ?? this.sgApproachTheGreen,
      sgAroundTheGreen: sgAroundTheGreen ?? this.sgAroundTheGreen,
      sgPutting: sgPutting ?? this.sgPutting,
      sgTotal: sgTotal ?? this.sgTotal,
      drivingAccuracy: drivingAccuracy ?? this.drivingAccuracy,
      drivingDistance: drivingDistance ?? this.drivingDistance,
      greensInRegulation: greensInRegulation ?? this.greensInRegulation,
      sandSaves: sandSaves ?? this.sandSaves,
      scrambling: scrambling ?? this.scrambling,
      eagles: eagles ?? this.eagles,
      birdies: birdies ?? this.birdies,
      pars: pars ?? this.pars,
      bogeys: bogeys ?? this.bogeys,
      doubleBogeys: doubleBogeys ?? this.doubleBogeys,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'playerName': playerName,
      'roundNumber': roundNumber,
      'roundTotal': roundTotal,
      'sgOffTheTee': sgOffTheTee,
      'sgApproachTheGreen': sgApproachTheGreen,
      'sgAroundTheGreen': sgAroundTheGreen,
      'sgPutting': sgPutting,
      'sgTotal': sgTotal,
      'drivingAccuracy': drivingAccuracy,
      'drivingDistance': drivingDistance,
      'greensInRegulation': greensInRegulation,
      'sandSaves': sandSaves,
      'scrambling': scrambling,
      'eagles': eagles,
      'birdies': birdies,
      'pars': pars,
      'bogeys': bogeys,
      'doubleBogeys': doubleBogeys,
    };
  }

  factory PlayerStats.fromMap(Map<String, dynamic> map) {
    return PlayerStats(
      playerName: map['playerName'] ?? '',
      roundNumber: map['roundNumber'] ?? '',
      roundTotal: map['roundTotal'] ?? '',
      sgOffTheTee: map['sgOffTheTee'] ?? '',
      sgApproachTheGreen: map['sgApproachTheGreen'] ?? '',
      sgAroundTheGreen: map['sgAroundTheGreen'] ?? '',
      sgPutting: map['sgPutting'] ?? '',
      sgTotal: map['sgTotal'] ?? '',
      drivingAccuracy: map['drivingAccuracy'] ?? '',
      drivingDistance: map['drivingDistance'] ?? '',
      greensInRegulation: map['greensInRegulation'] ?? '',
      sandSaves: map['sandSaves'] ?? '',
      scrambling: map['scrambling'] ?? '',
      eagles: map['eagles'] ?? '',
      birdies: map['birdies'] ?? '',
      pars: map['pars'] ?? '',
      bogeys: map['bogeys'] ?? '',
      doubleBogeys: map['doubleBogeys'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PlayerStats.fromJson(String source) =>
      PlayerStats.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PlayerStats(playerName: $playerName, roundNumber: $roundNumber, roundTotal: $roundTotal, sgOffTheTee: $sgOffTheTee, sgApproachTheGreen: $sgApproachTheGreen, sgAroundTheGreen: $sgAroundTheGreen, sgPutting: $sgPutting, sgTotal: $sgTotal, drivingAccuracy: $drivingAccuracy, drivingDistance: $drivingDistance, greensInRegulation: $greensInRegulation, sandSaves: $sandSaves, scrambling: $scrambling, eagles: $eagles, birdies: $birdies, pars: $pars, bogeys: $bogeys, doubleBogeys: $doubleBogeys)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PlayerStats &&
        other.playerName == playerName &&
        other.roundNumber == roundNumber &&
        other.roundTotal == roundTotal &&
        other.sgOffTheTee == sgOffTheTee &&
        other.sgApproachTheGreen == sgApproachTheGreen &&
        other.sgAroundTheGreen == sgAroundTheGreen &&
        other.sgPutting == sgPutting &&
        other.sgTotal == sgTotal &&
        other.drivingAccuracy == drivingAccuracy &&
        other.drivingDistance == drivingDistance &&
        other.greensInRegulation == greensInRegulation &&
        other.sandSaves == sandSaves &&
        other.scrambling == scrambling &&
        other.eagles == eagles &&
        other.birdies == birdies &&
        other.pars == pars &&
        other.bogeys == bogeys &&
        other.doubleBogeys == doubleBogeys;
  }

  @override
  int get hashCode {
    return playerName.hashCode ^
        roundNumber.hashCode ^
        roundTotal.hashCode ^
        sgOffTheTee.hashCode ^
        sgApproachTheGreen.hashCode ^
        sgAroundTheGreen.hashCode ^
        sgPutting.hashCode ^
        sgTotal.hashCode ^
        drivingAccuracy.hashCode ^
        drivingDistance.hashCode ^
        greensInRegulation.hashCode ^
        sandSaves.hashCode ^
        scrambling.hashCode ^
        eagles.hashCode ^
        birdies.hashCode ^
        pars.hashCode ^
        bogeys.hashCode ^
        doubleBogeys.hashCode;
  }
}
