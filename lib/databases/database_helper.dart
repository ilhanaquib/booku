import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:booku/models/books_model.dart';
import 'package:booku/themes/themes.dart';

class DatabaseHelper {
  static const tablePurchasedThemes = 'purchased_themes';
  static const colThemeId = 'theme_id';
  static const tableSelectedTheme = 'selected_theme';

  //-------------------themes only---------------------
Future<List<ThemeData>> getPurchasedThemes() async {
  final db = await instance.database;

  final results = await db.query(tablePurchasedThemes);
  final themeList = results.map((row) => _themeFromRow(row)).toList();

  // Filter out any null themes
  final purchasedThemes = themeList.whereType<ThemeData>().toList();

  return purchasedThemes;
}

  Future<void> savePurchasedThemes(List<ThemeData> themes) async {
    final db = await instance.database;

    // Delete existing purchased themes
    await db.delete(tablePurchasedThemes);

    // Insert new purchased themes
    for (var theme in themes) {
      final themeMap = _themeToRow(theme);
      await db.insert(tablePurchasedThemes, themeMap);
    }
  }

  ThemeData? _themeFromRow(Map<String, dynamic> row) {
    final themeId = row[colThemeId] as int?;
    return themeId != null ? allThemes[themeId] : null;
  }

  Map<String, dynamic> _themeToRow(ThemeData theme) {
    final themeId = allThemes.indexOf(theme);
    return {colThemeId: themeId};
  }

Future<int> getSelectedThemeId() async {
  final db = await instance.database;

  final results = await db.query(tableSelectedTheme);
  if (results.isNotEmpty) {
    final themeId = results.first[colThemeId];
    return themeId != null ? themeId as int : 0;
  }
  return 0;
}

  Future<void> saveSelectedThemeId(int themeId) async {
    final db = await instance.database;

    await db.delete(tableSelectedTheme);

    await db.insert(tableSelectedTheme, {colThemeId: themeId});
  }
  //---------------------------------------------------

  static final DatabaseHelper instance = DatabaseHelper._init();

  //this is variable to store database
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('books.db');
    return _database!;
  }

  //initialize database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  //create table
  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
    CREATE TABLE $tableBook (
      ${BookFields.id} $idType,
      ${BookFields.title} $textType,
      ${BookFields.author} $textType,
      ${BookFields.image} $textType,
      ${BookFields.date} $textType,
      ${BookFields.category} $textType
    )
  ''');

    await db.execute('''
    CREATE TABLE $tablePurchasedThemes (
      $colThemeId INTEGER PRIMARY KEY
    )
  ''');

    await db.execute('''
    CREATE TABLE $tableSelectedTheme (
      $colThemeId INTEGER PRIMARY KEY
    )
  ''');
  }

  Future<Book> create(Book book) async {
    final db = await instance.database;

    final bookMap = book.toJson();
    final updatedBookMap = Map<String, dynamic>.from(bookMap);
    updatedBookMap['_category'] = book.category.index;

    final id = await db.insert(tableBook, updatedBookMap);
    return book.copy(id: id.toString());
  }

  Future<Book> readBook(String id) async {
    final db = await instance.database;

    final maps = await db.query(tableBook,
        columns: BookFields.values,
        where: '${BookFields.id} = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Book.fromJson(maps.first);
    } else {
      throw Exception('ID $id is not found');
    }
  }

  Future<List<Book>> readAllBook() async {
    final db = await instance.database;

    final result = await db.query(tableBook);

    return result.map((json) => Book.fromJson(json)).toList();
  }

  Future<int> update(Book book) async {
    final db = await instance.database;

    return db.update(
      tableBook,
      book.toJson(),
      where: '${BookFields.id} = ?',
      whereArgs: [book.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await instance.database;

    return await db.delete(
      tableBook,
      where: '${BookFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
