import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/error_handler.dart';
import '../services/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherInfo {
  final String condition;
  final String waveCondition;
  final double temperature;
  final double windSpeed;
  final double humidity;
  final DateTime timestamp;

  WeatherInfo({
    required this.condition,
    required this.waveCondition,
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
    required this.timestamp,
  });

  factory WeatherInfo.fromMap(Map<String, dynamic> map) {
    return WeatherInfo(
      condition: map['condition'] ?? 'Unknown',
      waveCondition: map['wave_condition'] ?? 'Unknown',
      temperature: (map['temperature'] ?? 0.0).toDouble(),
      windSpeed: (map['wind_speed'] ?? 0.0).toDouble(),
      humidity: (map['humidity'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'condition': condition,
      'wave_condition': waveCondition,
      'temperature': temperature,
      'wind_speed': windSpeed,
      'humidity': humidity,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool isOutdated() {
    final now = DateTime.now();
    return now.difference(timestamp).inHours > 1;
  }
}

class WeatherProvider with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  late final CacheService _cacheService;
  WeatherInfo? _weatherInfo;
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  WeatherProvider() {
    _initCache();
  }

  Future<void> _initCache() async {
    if (_initialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    _cacheService = CacheService(prefs);
    _initialized = true;

    // Load cached data immediately if available
    final cachedData = _cacheService.getWeatherInfo();
    if (cachedData != null) {
      final weatherInfo = WeatherInfo.fromMap(cachedData);
      if (!weatherInfo.isOutdated()) {
        _weatherInfo = weatherInfo;
        notifyListeners();
      }
    }
  }

  WeatherInfo? get weatherInfo => _weatherInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWeatherInfo() async {
    if (_isLoading) return;

    bool shouldNotify = false;
    try {
      _isLoading = true;
      _error = null;
      shouldNotify = true;

      final snapshot = await _database.child('weather').get();
      
      if (snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _weatherInfo = WeatherInfo.fromMap(data);
        
        // Cache the weather info
        await _cacheService.cacheWeatherInfo(_weatherInfo!.toMap());
      }
    } catch (e) {
      _error = ErrorHandler.getDatabaseErrorMessage(e);
    } finally {
      _isLoading = false;
      if (shouldNotify) {
        notifyListeners();
      }
    }
  }

  Future<void> refreshWeatherInfo() async {
    await _cacheService.clearWeatherCache();
    await loadWeatherInfo();
  }
}