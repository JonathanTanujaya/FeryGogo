import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  final SharedPreferences _prefs;
  static const String _timestampPrefix = 'timestamp_';
  static const String _weatherKey = 'weather_cache';

  CacheService(this._prefs);

  // Weather caching
  Map<String, dynamic>? getWeatherInfo() {
    final String? cachedData = _prefs.getString(_weatherKey);
    if (cachedData != null) {
      return json.decode(cachedData) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> cacheWeatherInfo(Map<String, dynamic> weatherInfo) async {
    await _prefs.setString(_weatherKey, json.encode(weatherInfo));
  }

  Future<void> clearWeatherCache() async {
    await _prefs.remove(_weatherKey);
  }

  // Schedule caching
  List<dynamic>? getSchedules(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    return json.decode(jsonString) as List<dynamic>;
  }

  Future<void> cacheSchedules(String key, List<Map<String, dynamic>> schedules) async {
    await _prefs.setString(key, json.encode(schedules));
  }

  Future<void> clearScheduleCache() async {
    final keys = _prefs.getKeys();
    final scheduleKeys = keys.where((key) => 
        key.startsWith('schedules_') || key.startsWith('${_timestampPrefix}schedules_'));
    
    for (final key in scheduleKeys) {
      await _prefs.remove(key);
    }
  }

  // Cache timestamp management
  Future<void> setCacheTimestamp(String key) async {
    await _prefs.setString(
      '$_timestampPrefix$key',
      DateTime.now().toIso8601String(),
    );
  }

  DateTime? getCacheTimestamp(String key) {
    final timestamp = _prefs.getString('$_timestampPrefix$key');
    if (timestamp == null) return null;
    return DateTime.parse(timestamp);
  }

  // General cache management
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}