import 'package:celebcalendarapp/services/database_service.dart';
import '../models/celebrity.dart';

class CelebrityService {
  static List<Celebrity> _celebrities = [];

  static Future<void> loadCelebrities() async {
    _celebrities = await DatabaseService.instance.getCelebrities();
  }

  static Future<List<Celebrity>> getTodaysBirthdays() async {
    return await DatabaseService.instance.getCelebritiesByDate(DateTime.now());
  }

  static Future<List<Celebrity>> getAllCelebrities() async {
    if (_celebrities.isEmpty) {
      await loadCelebrities();
    }
    return _celebrities;
  }
}
