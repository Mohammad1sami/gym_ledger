import 'package:intl/intl.dart';

class TrainingNote {
  final int id;
  final int memberId;
  final DateTime date;
  final String diet;
  final String workout;

  TrainingNote({
    required this.id,
    required this.memberId,
    required this.date,
    required this.diet,
    required this.workout,
  });

  String get formattedDate => DateFormat('dd MMM yyyy').format(date);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'date': date.toIso8601String(),
      'diet': diet,
      'workout': workout,
    };
  }

  factory TrainingNote.fromMap(Map<String, dynamic> map) {
    return TrainingNote(
      id: map['id'] as int,
      memberId: map['memberId'] as int,
      date: DateTime.parse(map['date'] as String),
      diet: map['diet'] as String,
      workout: map['workout'] as String,
    );
  }

  TrainingNote copyWith({
    int? id,
    int? memberId,
    DateTime? date,
    String? diet,
    String? workout,
  }) {
    return TrainingNote(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      date: date ?? this.date,
      diet: diet ?? this.diet,
      workout: workout ?? this.workout,
    );
  }
}
