import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member.dart';
import '../models/payment.dart';
import '../models/training_note.dart';

class StorageService {
  static const String _membersKey = 'brutewing_members_v2';
  static const String _notesKey = 'brutewing_notes_v2';
  static const String _paymentsKey = 'brutewing_payments_v2';

  static List<Member> get _initialMembersSeed {
    final now = DateTime.now();
    return [
      Member(
        id: 1,
        name: 'Rohan Patil',
        phone: '9876543210',
        plan: 'Quarterly',
        start: now.subtract(const Duration(days: 30)),
        end: now.add(const Duration(days: 60)),
      ),
      Member(
        id: 2,
        name: 'Ayesha Khan',
        phone: '9823456710',
        plan: 'Monthly',
        start: now.subtract(const Duration(days: 26)),
        end: now.add(const Duration(days: 4)),
      ),
      Member(
        id: 3,
        name: 'Vikram Deshmukh',
        phone: '9765432198',
        plan: 'Annual',
        start: now.subtract(const Duration(days: 355)),
        end: now.add(const Duration(days: 10)),
      ),
      Member(
        id: 4,
        name: 'Sneha Joshi',
        phone: '9988776655',
        plan: 'Monthly',
        start: now.subtract(const Duration(days: 28)),
        end: now.add(const Duration(days: 2)),
      ),
      Member(
        id: 5,
        name: 'Imran Sheikh',
        phone: '9112233445',
        plan: 'Quarterly',
        start: now.subtract(const Duration(days: 100)),
        end: now.subtract(const Duration(days: 10)),
      ),
      Member(
        id: 6,
        name: 'Pooja Nair',
        phone: '9001122334',
        plan: 'Monthly',
        start: now.subtract(const Duration(days: 10)),
        end: now.add(const Duration(days: 20)),
      ),
    ];
  }

  static final List<TrainingNote> _initialNotesSeed = [
    TrainingNote(
      id: 101,
      memberId: 1,
      date: DateTime(2026, 6, 10),
      diet: 'High protein, 2400 kcal. Eggs, paneer, rice, dal, chicken twice a week.',
      workout: 'Push/Pull/Legs split, 5 days a week. Progressive overload on compounds.',
    ),
    TrainingNote(
      id: 102,
      memberId: 3,
      date: DateTime(2026, 6, 14),
      diet: 'Cutting phase, 1900 kcal, 170g protein. Cut rice portions, added more salad.',
      workout: 'Upper/Lower split, 4 days. Added 20 min incline walk post-session.',
    ),
    TrainingNote(
      id: 103,
      memberId: 1,
      date: DateTime(2026, 5, 28),
      diet: 'Maintenance, 2200 kcal. Increased water intake, added ashwagandha at night.',
      workout: 'Switched to 5-day split from 3-day full body, added deload week.',
    ),
  ];

  static List<Payment> get _initialPaymentsSeed {
    final now = DateTime.now();
    return [
      Payment(
        id: 201,
        memberId: 1,
        memberName: 'Rohan Patil',
        amount: 4000.0,
        plan: 'Quarterly',
        date: now.subtract(const Duration(days: 30)),
        paymentMethod: 'UPI',
        status: PaymentStatus.paid,
        transactionRef: 'UPI/987123849201',
      ),
      Payment(
        id: 202,
        memberId: 6,
        memberName: 'Pooja Nair',
        amount: 1500.0,
        plan: 'Monthly',
        date: now.subtract(const Duration(days: 10)),
        paymentMethod: 'Cash',
        status: PaymentStatus.paid,
        transactionRef: 'Rec# 402',
      ),
      Payment(
        id: 203,
        memberId: 2,
        memberName: 'Ayesha Khan',
        amount: 1500.0,
        plan: 'Monthly',
        date: now.subtract(const Duration(days: 26)),
        paymentMethod: 'UPI',
        status: PaymentStatus.pending,
        transactionRef: 'Invoice #092',
      ),
      Payment(
        id: 204,
        memberId: 4,
        memberName: 'Sneha Joshi',
        amount: 1500.0,
        plan: 'Monthly',
        date: now.subtract(const Duration(days: 28)),
        paymentMethod: 'Cash',
        status: PaymentStatus.pending,
        transactionRef: 'Due on renewal',
      ),
      Payment(
        id: 205,
        memberId: 5,
        memberName: 'Imran Sheikh',
        amount: 4000.0,
        plan: 'Quarterly',
        date: now.subtract(const Duration(days: 10)),
        paymentMethod: 'UPI',
        status: PaymentStatus.overdue,
        transactionRef: 'Overdue 10d',
      ),
      Payment(
        id: 206,
        memberId: 3,
        memberName: 'Vikram Deshmukh',
        amount: 14000.0,
        plan: 'Annual',
        date: now.subtract(const Duration(days: 355)),
        paymentMethod: 'Card',
        status: PaymentStatus.pending,
        transactionRef: 'Renewal due soon',
      ),
    ];
  }

  static Future<List<Member>> getMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_membersKey);

    if (jsonString == null) {
      // First time launching app - save initial seed and return
      await saveMembers(_initialMembersSeed);
      return List.from(_initialMembersSeed);
    }

    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((item) => Member.fromMap(item as Map<String, dynamic>)).toList();
  }

  static Future<void> saveMembers(List<Member> members) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(members.map((m) => m.toMap()).toList());
    await prefs.setString(_membersKey, jsonString);
  }

  static Future<List<TrainingNote>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_notesKey);

    if (jsonString == null) {
      // First time launching app - save initial seed and return
      await saveNotes(_initialNotesSeed);
      return List.from(_initialNotesSeed);
    }

    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((item) => TrainingNote.fromMap(item as Map<String, dynamic>)).toList();
  }

  static Future<void> saveNotes(List<TrainingNote> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(notes.map((n) => n.toMap()).toList());
    await prefs.setString(_notesKey, jsonString);
  }

  static Future<List<Payment>> getPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_paymentsKey);

    if (jsonString == null) {
      // First time launching app - save initial seed and return
      await savePayments(_initialPaymentsSeed);
      return List.from(_initialPaymentsSeed);
    }

    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((item) => Payment.fromMap(item as Map<String, dynamic>)).toList();
  }

  static Future<void> savePayments(List<Payment> payments) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(payments.map((p) => p.toMap()).toList());
    await prefs.setString(_paymentsKey, jsonString);
  }
}
