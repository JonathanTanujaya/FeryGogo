import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/weather_info.dart';

class WeatherProvider with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  WeatherInfo? _weatherInfo;
  bool _isLoading = false;
  String? _error;

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
      }
      return MapEntry(key.toString(), value);
    });
  }

  Future<void> loadWeatherInfo() async {
    try {
      _setLoading(true);
      _setError(null);

      final snapshot = await _database.child('weather').get();
      if (!snapshot.exists) {
        _weatherInfo = null;
        return;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      _weatherInfo = WeatherInfo.fromMap(_convertMap(data));
      notifyListeners();
    } catch (e) {
      _setError('Failed to load weather info: $e');
    } finally {
      _setLoading(false);
    }
  }

  void startWeatherUpdates() {
    _database.child('weather').onValue.listen(
      (event) {
        if (!event.snapshot.exists) {
          _weatherInfo = null;
          notifyListeners();
          return;
        }

        final data = event.snapshot.value as Map<dynamic, dynamic>;
        _weatherInfo = WeatherInfo.fromMap(_convertMap(data));
        notifyListeners();
      },
      onError: (error) {
        _setError('Error monitoring weather updates: $error');
      },
    );
  }
}