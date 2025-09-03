import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'HistoryProvider.dart';
import 'FavouritesProvider.dart';

class DataBase {
  late Database _database;

  Future<void> openDataBase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'database.db');

    _database = await openDatabase(path, version: 1, onCreate: (db, version) {
      // Crear tabla para HistoryConversion
      db.execute('''
        CREATE TABLE history_conversions (
          id INTEGER PRIMARY KEY,
          fromCurrency TEXT,
          toCurrency TEXT,
          amount REAL
        )
      ''');

      // Crear tabla para FavoriteConversion
      db.execute('''
        CREATE TABLE favorite_conversions (
          fromCurrency TEXT,
          toCurrency TEXT,
          PRIMARY KEY (fromCurrency, toCurrency)
        )
      ''');
    });
  }

  Future<void> insertHistoryConversion(HistoryConversion history) async {
    await _database.insert('history_conversions', history.toMap());
  }

  Future<List<HistoryConversion>> getHistoryConversions() async {
    final List<Map<String, dynamic>> maps =
    await _database.query('history_conversions');
    return List.generate(maps.length, (i) {
      return HistoryConversion(
        fromCurrency: maps[i]['fromCurrency'],
        toCurrency: maps[i]['toCurrency'],
        amount: maps[i]['amount'],
      );
    });
  }

  Future<int> updateHistoryConversion(HistoryConversion history) async {
    return await _database.update(
      'history_conversions',
      history.toMap(),
      where: 'fromCurrency = ? AND toCurrency = ?',
      whereArgs: [history.fromCurrency, history.toCurrency],
    );
  }

  Future<void> insertFavoriteConversion(
      FavoriteConversion favorite) async {
    await _database.insert('favorite_conversions', favorite.toMap());
  }

  Future<List<FavoriteConversion>> getFavoriteConversions() async {
    final List<Map<String, dynamic>> maps =
    await _database.query('favorite_conversions');
    return List.generate(maps.length, (i) {
      return FavoriteConversion(
        fromCurrency: maps[i]['fromCurrency'],
        toCurrency: maps[i]['toCurrency'],
      );
    });
  }

  Future<int> removeFavoriteConversion(
      String fromCurrency, String toCurrency) async {
    return await _database.delete('favorite_conversions',
        where: 'fromCurrency = ? AND toCurrency = ?',
        whereArgs: [fromCurrency, toCurrency]);
  }


  Future<int> updateFavoriteConversion(FavoriteConversion favorite) async {
    return await _database.update(
      'favorite_conversions',
      favorite.toMap(),
      where: 'fromCurrency = ? AND toCurrency = ?',
      whereArgs: [favorite.fromCurrency, favorite.toCurrency],
    );
  }


}