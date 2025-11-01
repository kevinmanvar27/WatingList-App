import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/restaurant.dart';
import 'models/waiting_person.dart';

class AppDatabase {
  final Database db;

  AppDatabase._(this.db);

  static Future<AppDatabase> open() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'waiting_list.db');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE restaurants (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            state TEXT NOT NULL
          );
        ''');

        await db.execute('''
          CREATE TABLE waiting (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            restaurantId INTEGER NOT NULL,
            name TEXT NOT NULL,
            partySize INTEGER NOT NULL,
            FOREIGN KEY(restaurantId) REFERENCES restaurants(id)
          );
        ''');
      },
    );

    return AppDatabase._(db);
  }

  // ---------- Restaurant Methods ----------
  Future<int> insertRestaurant(Restaurant restaurant) =>
      db.insert('restaurants', restaurant.toMap());

  Future<List<Restaurant>> getRestaurants({String? state}) async {
    final where = state != null ? 'WHERE state = ?' : '';
    final args = state != null ? [state] : null;

    final rows = await db.rawQuery('SELECT * FROM restaurants $where', args);
    return rows.map((row) => Restaurant.fromMap(row)).toList();
  }

  // ---------- Waiting List Methods ----------
  Future<int> insertWaiting(WaitingPerson person) =>
      db.insert('waiting', person.toMap());

  Future<List<WaitingPerson>> getWaitingForRestaurant(int restaurantId) async {
    final rows = await db.query(
      'waiting',
      where: 'restaurantId = ?',
      whereArgs: [restaurantId],
    );
    return rows.map((row) => WaitingPerson.fromMap(row)).toList();
  }
}
