// lib/core/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:language_learning_app/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'lexicon.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Words progress table
        await db.execute('''
          CREATE TABLE word_progress (
            id TEXT PRIMARY KEY,
            languageId TEXT NOT NULL,
            isFavorite INTEGER DEFAULT 0,
            isLearned INTEGER DEFAULT 0,
            reviewCount INTEGER DEFAULT 0,
            nextReviewDate TEXT
          )
        ''');

        // User progress table
        await db.execute('''
          CREATE TABLE user_progress (
            languageId TEXT PRIMARY KEY,
            wordsLearned INTEGER DEFAULT 0,
            quizzesTaken INTEGER DEFAULT 0,
            currentStreak INTEGER DEFAULT 0,
            longestStreak INTEGER DEFAULT 0,
            totalXP INTEGER DEFAULT 0,
            lastActiveDate TEXT
          )
        ''');

        // Quiz results table
        await db.execute('''
          CREATE TABLE quiz_results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            languageId TEXT NOT NULL,
            category TEXT NOT NULL,
            totalQuestions INTEGER NOT NULL,
            correctAnswers INTEGER NOT NULL,
            timeTaken INTEGER NOT NULL,
            completedAt TEXT NOT NULL
          )
        ''');

        // Achievements table
        await db.execute('''
          CREATE TABLE achievements (
            id TEXT PRIMARY KEY,
            isUnlocked INTEGER DEFAULT 0,
            unlockedAt TEXT
          )
        ''');
      },
    );
  }

  // ─── Word Progress ───────────────────────────────────────────────

  Future<void> saveWordProgress(WordModel word) async {
    final db = await database;
    await db.insert(
      'word_progress',
      {
        'id': word.id,
        'languageId': word.languageId,
        'isFavorite': word.isFavorite ? 1 : 0,
        'isLearned': word.isLearned ? 1 : 0,
        'reviewCount': word.reviewCount,
        'nextReviewDate': word.nextReviewDate?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, Map<String, dynamic>>> getWordProgressForLanguage(String languageId) async {
    final db = await database;
    final rows = await db.query(
      'word_progress',
      where: 'languageId = ?',
      whereArgs: [languageId],
    );
    final map = <String, Map<String, dynamic>>{};
    for (final row in rows) {
      map[row['id'] as String] = row;
    }
    return map;
  }

  // ─── User Progress ───────────────────────────────────────────────

  Future<UserProgress?> getUserProgress(String languageId) async {
    final db = await database;
    final rows = await db.query(
      'user_progress',
      where: 'languageId = ?',
      whereArgs: [languageId],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return UserProgress(
      languageId: languageId,
      wordsLearned: row['wordsLearned'] as int,
      quizzesTaken: row['quizzesTaken'] as int,
      currentStreak: row['currentStreak'] as int,
      longestStreak: row['longestStreak'] as int,
      totalXP: row['totalXP'] as int,
      lastActiveDate: row['lastActiveDate'] != null
          ? DateTime.parse(row['lastActiveDate'] as String)
          : null,
    );
  }

  Future<void> saveUserProgress(UserProgress progress) async {
    final db = await database;
    await db.insert(
      'user_progress',
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─── Quiz Results ────────────────────────────────────────────────

  Future<void> saveQuizResult(QuizResult result) async {
    final db = await database;
    await db.insert('quiz_results', result.toMap());
  }

  Future<List<Map<String, dynamic>>> getQuizResults(String languageId) async {
    final db = await database;
    return db.query(
      'quiz_results',
      where: 'languageId = ?',
      whereArgs: [languageId],
      orderBy: 'completedAt DESC',
      limit: 20,
    );
  }

  // ─── Achievements ────────────────────────────────────────────────

  Future<void> unlockAchievement(String id) async {
    final db = await database;
    await db.insert(
      'achievements',
      {'id': id, 'isUnlocked': 1, 'unlockedAt': DateTime.now().toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<Set<String>> getUnlockedAchievements() async {
    final db = await database;
    final rows = await db.query('achievements', where: 'isUnlocked = 1');
    return rows.map((r) => r['id'] as String).toSet();
  }
}