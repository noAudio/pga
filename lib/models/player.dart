import 'dart:convert';

class Player {
  String position;
  String playerName;
  String total;
  String roundOne;
  String roundTwo;
  String roundThree;
  String roundFour;
  String strokes;
  String course;
  Player({
    required this.position,
    required this.playerName,
    required this.total,
    required this.roundOne,
    required this.roundTwo,
    required this.roundThree,
    required this.roundFour,
    required this.strokes,
    required this.course,
  });

  Player copyWith({
    String? position,
    String? playerName,
    String? total,
    String? roundOne,
    String? roundTwo,
    String? roundThree,
    String? roundFour,
    String? strokes,
    String? course,
  }) {
    return Player(
      position: position ?? this.position,
      playerName: playerName ?? this.playerName,
      total: total ?? this.total,
      roundOne: roundOne ?? this.roundOne,
      roundTwo: roundTwo ?? this.roundTwo,
      roundThree: roundThree ?? this.roundThree,
      roundFour: roundFour ?? this.roundFour,
      strokes: strokes ?? this.strokes,
      course: course ?? this.course,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'position': position,
      'playerName': playerName,
      'total': total,
      'roundOne': roundOne,
      'roundTwo': roundTwo,
      'roundThree': roundThree,
      'roundFour': roundFour,
      'strokes': strokes,
      'course': course,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      position: map['position'] ?? '',
      playerName: map['playerName'] ?? '',
      total: map['total'] ?? '',
      roundOne: map['roundOne'] ?? '',
      roundTwo: map['roundTwo'] ?? '',
      roundThree: map['roundThree'] ?? '',
      roundFour: map['roundFour'] ?? '',
      strokes: map['strokes'] ?? '',
      course: map['course'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Player.fromJson(String source) => Player.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Player(position: $position, playerName: $playerName, total: $total, roundOne: $roundOne, roundTwo: $roundTwo, roundThree: $roundThree, roundFour: $roundFour, strokes: $strokes, course: $course)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Player &&
        other.position == position &&
        other.playerName == playerName &&
        other.total == total &&
        other.roundOne == roundOne &&
        other.roundTwo == roundTwo &&
        other.roundThree == roundThree &&
        other.roundFour == roundFour &&
        other.strokes == strokes &&
        other.course == course;
  }

  @override
  int get hashCode {
    return position.hashCode ^
        playerName.hashCode ^
        total.hashCode ^
        roundOne.hashCode ^
        roundTwo.hashCode ^
        roundThree.hashCode ^
        roundFour.hashCode ^
        strokes.hashCode ^
        course.hashCode;
  }
}
