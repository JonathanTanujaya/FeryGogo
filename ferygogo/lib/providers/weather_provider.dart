import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_info.dart';

class WeatherProvider with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  WeatherInfo? _weatherInfo;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<DatabaseEvent>? _weatherSubscription;

  WeatherInfo? get weatherInfo => _weatherInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Map<String, dynamic> _convertMap(Map<dynamic, dynamic> map) {
    return map.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), _convertMap(value));
      } else if (value is List) {
        return MapEntry(key.toString(), 
          List.from(value.map((item) => item is Map ? _convertMap(item) : item)));
      }
      return MapEntry(key.toString(), value);
    });
  }

  Future<void> fetchWeatherFromApi() async {
    try {
      _setLoading(true);
      _setError(null);

      final mockWeatherData = {
        'current': {
          'temperature': 30.2,
          'humidity': 82.0,
          'wind': {
            'speed': 5.8
          },
          'summary': 'Berawan Sedang',
          'icon': 'cloudy',
          'weather_description': 'Kondisi cuaca berawan dengan kelembaban tinggi',
          'wind_description': 'Angin sedang bertiup ke arah timur'
        }
      };

      // Save to Firebase first to ensure data persistence
      await _database.child('weather').set({
        'timestamp': DateTime.now().toIso8601String(),
        'location': 'Bakauheni',
        'data': mockWeatherData
      });

      _weatherInfo = WeatherInfo.fromMap(mockWeatherData);
      
      // Cache the weather data locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('weather_cache', json.encode(mockWeatherData));
      await prefs.setInt('weather_cache_time', DateTime.now().millisecondsSinceEpoch);
      
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error with weather data: $e');
      debugPrint('Stack trace: $stackTrace');
      _setError('Gagal memuat informasi cuaca: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadWeatherInfo() async {
    try {
      _setLoading(true);
      _setError(null);

      // Try to load from cache first
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('weather_cache');
      final cacheTime = prefs.getInt('weather_cache_time');
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheValid = cacheTime != null && 
          now - cacheTime < const Duration(minutes: 30).inMilliseconds;

      if (cachedData != null && cacheValid) {
        final data = json.decode(cachedData);
        _weatherInfo = WeatherInfo.fromMap(data);
        notifyListeners();
        return;
      }

      // If no valid cache, fetch new data
      await fetchWeatherFromApi();
    } catch (e) {
      debugPrint('Error loading weather info: $e');
      _setError('Gagal memuat informasi cuaca: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void startWeatherUpdates() {
    _weatherSubscription?.cancel();

    // Start periodic updates
    Timer.periodic(const Duration(minutes: 30), (_) {
      fetchWeatherFromApi();
    });

    // Listen to Firebase updates
    _weatherSubscription = _database.child('weather').onValue.listen(
      (event) {
        if (!event.snapshot.exists || event.snapshot.value == null) {
          return;
        }

        try {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          final convertedData = _convertMap(data);
          _weatherInfo = WeatherInfo.fromMap(convertedData);
          _setError(null);
          notifyListeners();
        } catch (e) {
          debugPrint('Error processing weather update: $e');
          _setError('Gagal memproses pembaruan cuaca: ${e.toString()}');
        }
      },
      onError: (error) {
        debugPrint('Error monitoring weather updates: $error');
        _setError('Gagal memonitor pembaruan cuaca: $error');
      },
    );
  }

  @override
  void dispose() {
    _weatherSubscription?.cancel();
    super.dispose();
  }
}