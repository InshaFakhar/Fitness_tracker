import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/workout_model.dart';

class DatabaseService {
  static final DatabaseService _i = DatabaseService._();
  factory DatabaseService() => _i;
  DatabaseService._();
  Database? _db;

  Future<Database> get db async => _db ??= await _init();

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'fit_pro_v2.db');
    return openDatabase(path, version: 1, onCreate: (db, _) async {
      await db.execute('''CREATE TABLE workouts(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        name TEXT,
        type TEXT NOT NULL,
        duration INTEGER,
        calories INTEGER,
        steps INTEGER DEFAULT 0,
        distance REAL,
        heartRate INTEGER,
        difficulty TEXT DEFAULT 'Medium',
        date TEXT NOT NULL,
        notes TEXT DEFAULT '',
        synced INTEGER DEFAULT 0)''');

      await db.execute('''CREATE TABLE water_log(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        glasses INTEGER,
        date TEXT)''');

      await db.execute('''CREATE TABLE user_profile(
        uid TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        photoUrl TEXT,
        height REAL DEFAULT 165,
        weight REAL DEFAULT 55,
        age INTEGER DEFAULT 21,
        gender TEXT DEFAULT 'Female',
        dailyCalorieGoal INTEGER DEFAULT 500,
        dailyStepGoal INTEGER DEFAULT 8000)''');
    });
  }

  // ── WORKOUTS — userId se filter ────────────────────────────
  Future<void> upsertWorkout(WorkoutModel w) async =>
      (await db).insert('workouts', w.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

  Future<List<WorkoutModel>> getAll(String userId) async {
    final rows = await (await db).query('workouts',
        where: 'userId = ?', whereArgs: [userId], orderBy: 'date DESC');
    return rows.map(WorkoutModel.fromMap).toList();
  }

  Future<List<WorkoutModel>> getToday(String userId) async {
    final t = DateTime.now();
    final s = DateTime(t.year, t.month, t.day).toIso8601String();
    final e = DateTime(t.year, t.month, t.day, 23, 59, 59).toIso8601String();
    final rows = await (await db).query('workouts',
        where: 'userId = ? AND date BETWEEN ? AND ?',
        whereArgs: [userId, s, e], orderBy: 'date DESC');
    return rows.map(WorkoutModel.fromMap).toList();
  }

  Future<List<WorkoutModel>> getThisWeek(String userId) async {
    final n = DateTime.now();
    final s = DateTime(n.year, n.month, n.day - n.weekday + 1).toIso8601String();
    final rows = await (await db).query('workouts',
        where: 'userId = ? AND date >= ?',
        whereArgs: [userId, s], orderBy: 'date DESC');
    return rows.map(WorkoutModel.fromMap).toList();
  }

  Future<List<WorkoutModel>> getUnsynced(String userId) async {
    final rows = await (await db).query('workouts',
        where: 'userId = ? AND synced = 0', whereArgs: [userId]);
    return rows.map(WorkoutModel.fromMap).toList();
  }

  Future<void> markSynced(String id) async =>
      (await db).update('workouts', {'synced': 1},
          where: 'id = ?', whereArgs: [id]);

  Future<void> deleteWorkout(String id) async =>
      (await db).delete('workouts', where: 'id = ?', whereArgs: [id]);

  Future<List<double>> weeklyCalories(String userId) async {
    final n = DateTime.now();
    return Future.wait(List.generate(7, (i) async {
      final d = n.subtract(Duration(days: n.weekday - 1 - i));
      final s = DateTime(d.year, d.month, d.day).toIso8601String();
      final e = DateTime(d.year, d.month, d.day, 23, 59, 59).toIso8601String();
      final rows = await (await db).query('workouts',
          where: 'userId = ? AND date BETWEEN ? AND ?',
          whereArgs: [userId, s, e]);
      return rows.fold<double>(0.0, (sum, m) => sum + (m['calories'] as int));    }));
  }

  // ── WATER — userId se filter ───────────────────────────────
  Future<void> setWater(String userId, int glasses) async {
    final d = DateTime.now();
    final date = DateTime(d.year, d.month, d.day).toIso8601String();
    final existing = await (await db).query('water_log',
        where: 'userId = ? AND date = ?', whereArgs: [userId, date]);
    if (existing.isEmpty) {
      await (await db).insert('water_log',
          {'userId': userId, 'glasses': glasses, 'date': date});
    } else {
      await (await db).update('water_log', {'glasses': glasses},
          where: 'userId = ? AND date = ?', whereArgs: [userId, date]);
    }
  }

  Future<int> getWaterToday(String userId) async {
    final d = DateTime.now();
    final date = DateTime(d.year, d.month, d.day).toIso8601String();
    final rows = await (await db).query('water_log',
        where: 'userId = ? AND date = ?', whereArgs: [userId, date]);
    return rows.isEmpty ? 0 : rows.first['glasses'] as int;
  }

  // ── PROFILE ───────────────────────────────────────────────
  Future<void> saveProfile(UserProfile p) async =>
      (await db).insert('user_profile', p.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

  Future<UserProfile?> getProfile(String uid) async {
    final rows = await (await db).query('user_profile',
        where: 'uid = ?', whereArgs: [uid]);
    return rows.isEmpty ? null : UserProfile.fromMap(rows.first);
  }
}