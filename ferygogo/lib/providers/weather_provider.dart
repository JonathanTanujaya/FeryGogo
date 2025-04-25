import 'package:flutter/foundation.dart';
import '../services/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  late final CacheService _cacheService;
  WeatherInfo? _weatherInfo;
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;
  Map<String, dynamic>? _weatherData;

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
  Map<String, dynamic>? get weatherData => _weatherData;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> loadWeatherInfo() async {
    try {
      _setLoading(true);
      _setError(null);

      // Example coordinates for Jakarta
      const lat = -6.2088;
      const lon = 106.8456;
      const apiKey = 'fa46cb5b001e426dbb6124635252504';
      final url = 'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$lat,$lon&aqi=no';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        
        _weatherInfo = WeatherInfo(
          condition: current['condition']['text'],
          waveCondition: 'Normal', // This would need a separate marine API
          temperature: current['temp_c'].toDouble(),
          windSpeed: current['wind_kph'].toDouble(),
          humidity: current['humidity'].toDouble(),
          timestamp: DateTime.now(),
        );
        
        await _cacheService.cacheWeatherInfo(_weatherInfo!.toMap());
        notifyListeners();
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      _setError('Gagal memuat informasi cuaca: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshWeatherInfo() async {
    await _cacheService.clearWeatherCache();
    await loadWeatherInfo();
  }
}