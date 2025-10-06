import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:celebcalendarapp/models/celebrity.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('celebrities.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE celebrities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        birthDate TEXT NOT NULL,
        imageUrl TEXT NOT NULL
      )
    ''');
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    try {
      final rawData = await rootBundle.loadString('assets/data/celebrities.csv');
      List<List<dynamic>> listData = const CsvToListConverter().convert(rawData, eol: '\n');

      if (listData.length <= 1) {
        print('Warning: CSV file is empty or contains only headers');
        return;
      }

      // Skip header row
      for (var i = 1; i < listData.length; i++) {
        final row = listData[i];
        if (row.length >= 3) {
          try {
            // Parse the date string and convert to ISO 8601 format
            final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
            final DateTime birthDate = dateFormat.parse(row[1].toString().trim());

            await db.insert('celebrities', {
              'name': row[0].toString().trim(),
              'birthDate': birthDate.toIso8601String(),
              'imageUrl': row[2].toString().trim(),
            });
          } catch (e) {
            print('Error inserting row $i: $e');
          }
        }
      }
    } catch (e) {
      print('Error seeding database: $e');
    }
  }

  Future<List<Celebrity>> getCelebrities() async {
    try {
      final db = await instance.database;
      final result = await db.query('celebrities');
      return result.map((json) => Celebrity.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching celebrities: $e');
      return [];
    }
  }

  // Add method to get celebrities by date
  Future<List<Celebrity>> getCelebritiesByDate(DateTime date) async {
    try {
      final db = await instance.database;
      final result = await db.query(
        'celebrities',
        where: "strftime('%m-%d', birthDate) = strftime('%m-%d', ?)",
        whereArgs: [date.toIso8601String()]
      );
      return result.map((json) => Celebrity.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching celebrities by date: $e');
      return [];
    }
  }
}
