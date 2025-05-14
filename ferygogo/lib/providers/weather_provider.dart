import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/weather_info.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  WeatherInfo? _weatherInfo;
  bool _isLoading = false;
  String? _error;

  WeatherInfo? get weatherInfo => _weatherInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Koordinat pelabuhan
  static const double merakLat = -6.1141;
  static const double merakLong = 105.8172;
  static const double bakauheniLat = -5.8622;
  static const double bakauheniLong = 105.7517;

  Future<void> loadWeatherInfo({bool isNearMerak = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final location = isNearMerak ? 'merak' : 'bakauheni';
      
      // Cek data di Firebase dulu
      final savedWeather = await _weatherService.getWeatherData(location);
      if (savedWeather != null) {
        _weatherInfo = savedWeather;
        notifyListeners();
      }

      // Fetch data baru dari API
      final weatherData = await _fetchWeatherData(
        isNearMerak ? merakLat : bakauheniLat,
        isNearMerak ? merakLong : bakauheniLong,
        location
      );
      
      // Simpan ke Firebase
      await _weatherService.saveWeatherData(location, weatherData);
      
      // Setup real-time listener
      _weatherService.streamWeatherData(location).listen(
        (weather) {
          if (weather != null) {
            _weatherInfo = weather;
            notifyListeners();
          }
        },
        onError: (e) {
          _error = 'Error streaming weather data: $e';
          notifyListeners();
        }
      );

    } catch (e) {
      _error = 'Failed to load weather data: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<WeatherInfo> _fetchWeatherData(
    double lat, 
    double lon, 
    String cityName
  ) async {
    const apiKey = 'YOUR_OPENWEATHER_API_KEY'; // Ganti dengan API key Anda
    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=id';
    final forecastUrl = 'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=id';

    try {
      // Ambil data cuaca saat ini
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to load weather data');
      }
      final weatherData = json.decode(response.body);

      // Ambil data prakiraan cuaca
      final forecastResponse = await http.get(Uri.parse(forecastUrl));
      if (forecastResponse.statusCode != 200) {
        throw Exception('Failed to load forecast data');
      }
      final forecastData = json.decode(forecastResponse.body);

      // Olah data prakiraan per jam
      final List<HourlyForecast> hourlyForecasts = [];
      for (var item in (forecastData['list'] as List).take(8)) {
        hourlyForecasts.add(HourlyForecast(
          time: DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000),
          temperature: item['main']['temp'].toDouble(),
          icon: item['weather'][0]['icon'],
          windSpeed: item['wind']['speed'].toDouble(),
        ));
      }

      // Tentukan kondisi gelombang berdasarkan kecepatan angin
      String waveCondition;
      final windSpeed = weatherData['wind']['speed'].toDouble();
      if (windSpeed < 5.5) {
        waveCondition = 'Tenang';
      } else if (windSpeed < 7.9) {
        waveCondition = 'Ringan';
      } else if (windSpeed < 10.7) {
        waveCondition = 'Sedang';
      } else {
        waveCondition = 'Tinggi';
      }

      return WeatherInfo(
        cityName: cityName,
        temperature: weatherData['main']['temp'].toDouble(),
        description: weatherData['weather'][0]['description'],
        humidity: weatherData['main']['humidity'].toDouble(),
        windSpeed: windSpeed,
        waveCondition: waveCondition,
        icon: weatherData['weather'][0]['icon'],
        hourlyForecast: hourlyForecasts,
      );
    } catch (e) {
      print('Error fetching weather data: $e');
      rethrow;
    }
  }
}