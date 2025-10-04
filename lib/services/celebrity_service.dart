import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../models/celebrity.dart';

class CelebrityService {
  static List<Celebrity> _celebrities = [];

  static Future<void> loadCelebrities() async {
    if (_celebrities.isNotEmpty) return;

    try {
      final rawData = await rootBundle.loadString('assets/data/celebrities.csv');
      if (rawData.trim().isEmpty) {
        print('Error: CSV file is empty');
        return;
      }

      // Use `eol: '\n'` to handle line endings consistently
      final List<List<dynamic>> csvTable = const CsvToListConverter(eol: '\n').convert(rawData);
      print('Parsed ${csvTable.length} rows from CSV');

      if (csvTable.length < 2) { // At least header + one row
        print('Error: CSV file has insufficient data');
        return;
      }

      // Process rows after header
      _celebrities = [];
      for (var i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        if (row.length >= 3) {
          try {
            final celebrity = Celebrity(
              name: row[0].toString().trim(),
              birthDate: DateTime.parse(row[1].toString().trim()),
              imageUrl: row[2].toString().trim(),
            );
            _celebrities.add(celebrity);
          } catch (e) {
            print('Error parsing row $i: ${row.join(',')} - $e');
          }
        } else {
          print('Skipping malformed row $i: ${row.join(',')}');
        }
      }

      print('Successfully loaded ${_celebrities.length} celebrities');
    } catch (e) {
      print('Error loading celebrities: $e');
      _celebrities = [];
    }
  }

  static List<Celebrity> getTodaysBirthdays() {
    final now = DateTime.now();
    return _celebrities.where((celebrity) =>
        celebrity.birthDate.month == now.month &&
        celebrity.birthDate.day == now.day).toList();
  }

  static List<Celebrity> getAllCelebrities() {
    return List.from(_celebrities);
  }
}
