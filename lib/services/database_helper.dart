import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/member.dart';
import '../models/training_note.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static List<Member> get initialMembersSeed {
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

  static final List<TrainingNote> initialNotesSeed = [
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

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('brutewing.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const memberTable = '''
      CREATE TABLE members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        plan TEXT NOT NULL,
        start TEXT NOT NULL,
        end TEXT NOT NULL,
        imagePath TEXT
      )
    ''';

    const noteTable = '''
      CREATE TABLE training_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        memberId INTEGER NOT NULL,
        date TEXT NOT NULL,
        diet TEXT NOT NULL,
        workout TEXT NOT NULL,
        FOREIGN KEY (memberId) REFERENCES members (id) ON DELETE CASCADE
      )
    ''';

    await db.execute(memberTable);
    await db.execute(noteTable);

    // Seed initial demo data
    for (var m in initialMembersSeed) {
      await db.insert('members', m.toMap());
    }

    for (var n in initialNotesSeed) {
      await db.insert('training_notes', n.toMap());
    }
  }

  // Member CRUD
  Future<List<Member>> getMembers() async {
    final db = await instance.database;
    final result = await db.query('members', orderBy: 'id DESC');
    return result.map((json) => Member.fromMap(json)).toList();
  }

  Future<Member> insertMember(Member member) async {
    final db = await instance.database;
    final map = member.toMap();
    map.remove('id'); // let SQLite generate autoincrement ID
    final id = await db.insert('members', map);
    return member.copyWith(id: id);
  }

  Future<int> updateMember(Member member) async {
    final db = await instance.database;
    return await db.update(
      'members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<int> deleteMember(int id) async {
    final db = await instance.database;
    await db.delete('training_notes', where: 'memberId = ?', whereArgs: [id]);
    return await db.delete('members', where: 'id = ?', whereArgs: [id]);
  }

  // TrainingNote CRUD
  Future<List<TrainingNote>> getNotes() async {
    final db = await instance.database;
    final result = await db.query('training_notes', orderBy: 'date DESC');
    return result.map((json) => TrainingNote.fromMap(json)).toList();
  }

  Future<TrainingNote> insertNote(TrainingNote note) async {
    final db = await instance.database;
    final map = note.toMap();
    map.remove('id'); // let SQLite generate autoincrement ID
    final id = await db.insert('training_notes', map);
    return note.copyWith(id: id);
  }

  Future<int> updateNote(TrainingNote note) async {
    final db = await instance.database;
    return await db.update(
      'training_notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete('training_notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
