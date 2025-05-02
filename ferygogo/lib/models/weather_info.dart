import 'package:flutter/foundation.dart';

class WeatherInfo {
  final String cityName;
  final double temperature;
  final String description;
  final double humidity;
  final double windSpeed;
  final String icon;
  final String waveCondition;

  WeatherInfo({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
    required this.waveCondition,
  });

  factory WeatherInfo.fromMap(Map<String, dynamic> map) {
    String getWaveCondition(double windSpeed) {
      if (windSpeed < 5.5) return 'Tenang';
      if (windSpeed < 11.0) return 'Ringan';
      if (windSpeed < 16.5) return 'Sedang';
      return 'Tinggi';
    }

    try {
      Map<String, dynamic> current;
      
      // Handle both possible data structures (direct or nested)
      if (map['data'] != null && map['data']['current'] != null) {
        current = map['data']['current'];
      } else if (map['current'] != null) {
        current = map['current'];
      } else {
        throw Exception('Invalid weather data format');
      }
      
      // Extract wind speed
      double windSpeed = 0.0;
      if (current['wind'] != null && current['wind'] is Map) {
        windSpeed = (current['wind']['speed'] as num).toDouble();
      }

      final weatherInfo = WeatherInfo(
        cityName: 'Bakauheni',
        temperature: (current['temperature'] as num).toDouble(),
        description: current['summary'] ?? current['weather_description'] ?? 'Tidak tersedia',
        humidity: (current['humidity'] as num).toDouble(),
        windSpeed: windSpeed,
        icon: current['icon'] ?? 'cloudy',
        waveCondition: getWaveCondition(windSpeed),
      );

      debugPrint('Created weather info: ${weatherInfo.toMap()}');
      return weatherInfo;
    } catch (e, stackTrace) {
      debugPrint('Error parsing weather data: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'cityName': cityName,
      'current': {
        'temperature': temperature,
        'humidity': humidity,
        'wind': {
          'speed': windSpeed
        },
        'summary': description,
        'icon': icon,
      },
      'waveCondition': waveCondition,
    };
  }
}