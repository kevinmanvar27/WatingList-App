import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


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


}
