import 'package:intl/intl.dart';

enum PaymentStatus { paid, pending, overdue }

class Payment {
  final int id;
  final int memberId;
  final String memberName;
  final double amount;
  final String plan;
  final DateTime date;
  final String paymentMethod; // Cash, UPI, Card, NetBanking
  final PaymentStatus status;
  final String? transactionRef;

  Payment({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.plan,
    required this.date,
    required this.paymentMethod,
    required this.status,
    this.transactionRef,
  });

  static const Map<String, double> defaultPlanPrices = {
    'Monthly': 1500.0,
    'Quarterly': 4000.0,
    'Annual': 14000.0,
  };

  String get formattedAmount => '₹${amount.toStringAsFixed(0)}';
  String get formattedDate => DateFormat('dd MMM yyyy').format(date);
  String get formattedDateShort => DateFormat('dd MMM').format(date);

  String get statusKey {
    switch (status) {
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.overdue:
        return 'overdue';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'amount': amount,
      'plan': plan,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'status': statusKey,
      'transactionRef': transactionRef,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    PaymentStatus statusEnum;
    final statusStr = map['status'] as String? ?? 'paid';
    if (statusStr == 'pending') {
      statusEnum = PaymentStatus.pending;
    } else if (statusStr == 'overdue') {
      statusEnum = PaymentStatus.overdue;
    } else {
      statusEnum = PaymentStatus.paid;
    }

    return Payment(
      id: map['id'] as int,
      memberId: map['memberId'] as int,
      memberName: map['memberName'] as String,
      amount: (map['amount'] as num).toDouble(),
      plan: map['plan'] as String,
      date: DateTime.parse(map['date'] as String),
      paymentMethod: map['paymentMethod'] as String? ?? 'UPI',
      status: statusEnum,
      transactionRef: map['transactionRef'] as String?,
    );
  }

  Payment copyWith({
    int? id,
    int? memberId,
    String? memberName,
    double? amount,
    String? plan,
    DateTime? date,
    String? paymentMethod,
    PaymentStatus? status,
    String? transactionRef,
  }) {
    return Payment(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      amount: amount ?? this.amount,
      plan: plan ?? this.plan,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      transactionRef: transactionRef ?? this.transactionRef,
    );
  }
}
