import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  // =========================
  // DATABASE INSTANCE
  // =========================
  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  // =========================
  // INIT DATABASE
  // =========================
  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'quiz_app.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE results ADD COLUMN created_at TEXT');
        }
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE questions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT,
        a TEXT,
        b TEXT,
        c TEXT,
        d TEXT,
        answer TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE results(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        score INTEGER,
        total INTEGER,
        created_at TEXT
      )
    ''');

    await db.insert('users', {
      'username': 'admin',
      'password': 'admin',
      'role': 'admin',
    });

    await _insertSampleQuestions(db);
  }

  static Future<void> _insertSampleQuestions(Database db) async {
    final samples = [
      {
        'question': 'What is Flutter mainly used for?',
        'a': 'Building mobile, web, and desktop apps',
        'b': 'Editing videos',
        'c': 'Designing databases only',
        'd': 'Creating spreadsheets',
        'answer': 'Building mobile, web, and desktop apps',
      },
      {
        'question': 'Which language is used with Flutter?',
        'a': 'Python',
        'b': 'Dart',
        'c': 'PHP',
        'd': 'Ruby',
        'answer': 'Dart',
      },
      {
        'question': 'Which widget is used for vertical layout?',
        'a': 'Row',
        'b': 'Column',
        'c': 'Stack',
        'd': 'Container',
        'answer': 'Column',
      },
    ];

    for (final question in samples) {
      await db.insert('questions', question);
    }
  }

  static Future<Map<String, Object?>?> login(
    String username,
    String password,
  ) async {
    final dbClient = await db;

    final res = await dbClient.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    return res.isNotEmpty ? res.first : null;
  }

  static Future<bool> addStudent(String username, String password) async {
    final dbClient = await db;

    try {
      await dbClient.insert('users', {
        'username': username,
        'password': password,
        'role': 'student',
      });
      return true;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        return false;
      }
      rethrow;
    }
  }

  static Future<void> addQuestion(Map<String, Object?> q) async {
    final dbClient = await db;
    await dbClient.insert('questions', q);
  }

  static Future<List<Map<String, Object?>>> getQuestions() async {
    final dbClient = await db;
    return await dbClient.query('questions', orderBy: 'id DESC');
  }

  static Future<void> deleteQuestion(int id) async {
    final dbClient = await db;
    await dbClient.delete('questions', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> saveResult(String username, int score, int total) async {
    final dbClient = await db;

    await dbClient.insert('results', {
      'username': username,
      'score': score,
      'total': total,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, Object?>>> getResults(String username) async {
    final dbClient = await db;

    return await dbClient.query(
      'results',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'id DESC',
    );
  }

  static Future<List<Map<String, Object?>>> getAllResults() async {
    final dbClient = await db;
    return await dbClient.query('results', orderBy: 'id DESC');
  }
}
