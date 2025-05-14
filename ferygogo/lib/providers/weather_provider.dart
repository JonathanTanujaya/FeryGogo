import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import '../models/weather_info.dart';

class WeatherProvider with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  WeatherInfo? _weatherInfo;
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;
  StreamSubscription<DatabaseEvent>? _weatherSubscription;

  // API Configuration
  static const String _baseUrl = 'https://www.meteosource.com/api/v1/free/point';
  static const String _apiKey = 'rzx8nw1h83ij7mrz3e35vqjb2w4zj7wv9nx2qqjq';

  // Koordinat Pelabuhan
  static const Map<String, Map<String, double>> _portCoordinates = {
    'merak': {
      'lat': -5.8933,
      'lon': 106.0056,
    },
    'bakauheni': {
      'lat': -5.8727,
      'lon': 105.7526,
    },
  };

  WeatherInfo? get weatherInfo => _weatherInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WeatherProvider() {
    _startAutoRefresh();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Map<String, dynamic> _convertToMap(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return Map<String, dynamic>.from(data.map((key, value) {
        if (value is Map) {
          return MapEntry(key.toString(), _convertToMap(value));
        } else if (value is List) {
          return MapEntry(
            key.toString(),
            value.map((e) => e is Map ? _convertToMap(e) : e).toList(),
          );
        }
        return MapEntry(key.toString(), value);
      }));
    }
    return {};
  }

  Future<Map<String, dynamic>> _fetchWeatherData(bool isNearMerak) async {
    final coordinates = isNearMerak ? _portCoordinates['merak']! : _portCoordinates['bakauheni']!;

    try {
      final queryParams = {
        'lat': coordinates['lat'].toString(),
        'lon': coordinates['lon'].toString(),
        'sections': 'current,hourly',
        'units': 'metric',
        'key': _apiKey,
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final List<Map<String, dynamic>> processedHourly = [];
        if (data['hourly']?['data'] != null) {
          for (var hour in data['hourly']['data']) {
            final Map<String, dynamic> processedHour = Map.from(hour);
            if (hour['date'] is String) {
              final DateTime dateTime = DateTime.parse(hour['date']);
              processedHour['date'] = dateTime.millisecondsSinceEpoch ~/ 1000;
            }
            processedHourly.add(processedHour);
          }
        }

        return {
          'cityName': isNearMerak ? 'Merak' : 'Bakauheni',
          'current': {
            'temperature': data['current']['temperature'],
            'humidity': data['current']['humidity'],
            'wind': {
              'speed': data['current']['wind']['speed'],
            },
            'summary': data['current']['summary'],
            'icon': data['current']['icon_code'],
          },
          'hourly': processedHourly,
        };
      } else {
        print('API Response: ${response.body}');
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      throw Exception('Error fetching weather data: $e');
    }
  }

  Future<void> loadWeatherInfo({bool isNearMerak = true}) async {
    try {
      _setLoading(true);
      _setError(null);

      final weatherData = await _fetchWeatherData(isNearMerak);

      // Simpan ke Firebase
      await _database.child('weather').set({
        'data': weatherData,
        'timestamp': ServerValue.timestamp,
        'location': isNearMerak ? 'Merak' : 'Bakauheni',
      });

      _weatherInfo = WeatherInfo.fromMap(weatherData);
      notifyListeners();
    } catch (e) {
      _setError('Gagal memuat informasi cuaca: ${e.toString()}');

      // Ambil dari cache Firebase
      try {
        final snapshot = await _database.child('weather').get();
        if (snapshot.exists && snapshot.value != null) {
          final rawData = snapshot.value as Map;
          final cachedData = _convertToMap(rawData);
          if (cachedData['data'] != null) {
            _weatherInfo = WeatherInfo.fromMap(_convertToMap(cachedData['data']));
            notifyListeners();
          }
        }
      } catch (e) {
        print('Failed to load cached weather data: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      loadWeatherInfo();
    });

    _weatherSubscription = _database.child('weather').onValue.listen(
      (event) {
        if (event.snapshot.exists && event.snapshot.value != null) {
          try {
            final rawData = event.snapshot.value as Map;
            final data = _convertToMap(rawData);
            if (data['data'] != null) {
              _weatherInfo = WeatherInfo.fromMap(_convertToMap(data['data']));
              notifyListeners();
            }
          } catch (e) {
            print('Error parsing Firebase weather data: $e');
          }
        }
      },
      onError: (error) {
        print('Error in Firebase weather subscription: $error');
      },
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _weatherSubscription?.cancel();
    super.dispose();
  }
}
