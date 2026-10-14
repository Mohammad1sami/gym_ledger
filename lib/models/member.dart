import 'package:intl/intl.dart';

enum MemberStatus { active, expiring, expired }

class Member {
  final int id;
  final String name;
  final String phone;
  final String plan; // Monthly, Quarterly, Annual
  final DateTime start;
  final DateTime end;

  final String? imagePath;

  Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.plan,
    required this.start,
    required this.end,
    this.imagePath,
  });

  static const Map<String, int> planDays = {
    'Monthly': 30,
    'Quarterly': 90,
    'Annual': 365,
  };

  int get daysLeft {
    final now = DateTime.now();
    final endDate = DateTime(end.year, end.month, end.day);
    final today = DateTime(now.year, now.month, now.day);
    return endDate.difference(today).inDays;
  }

  MemberStatus get status {
    final d = daysLeft;
    if (d < 0) return MemberStatus.expired;
    if (d <= 5) return MemberStatus.expiring;
    return MemberStatus.active;
  }

  String get statusKey {
    switch (status) {
      case MemberStatus.expired:
        return 'expired';
      case MemberStatus.expiring:
        return 'expiring';
      case MemberStatus.active:
        return 'active';
    }
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String get formattedStart => DateFormat('dd MMM yyyy').format(start);
  String get formattedEnd => DateFormat('dd MMM yyyy').format(end);
  String get formattedEndShort => DateFormat('dd MMM').format(end);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'plan': plan,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] as int,
      name: map['name'] as String,
      phone: map['phone'] as String,
      plan: map['plan'] as String,
      start: DateTime.parse(map['start'] as String),
      end: DateTime.parse(map['end'] as String),
      imagePath: map['imagePath'] as String?,
    );
  }

  Member copyWith({
    int? id,
    String? name,
    String? phone,
    String? plan,
    DateTime? start,
    DateTime? end,
    String? imagePath,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      plan: plan ?? this.plan,
      start: start ?? this.start,
      end: end ?? this.end,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
