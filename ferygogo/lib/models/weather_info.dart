import 'package:flutter/foundation.dart';

class WeatherInfo {
  final String cityName;
  final double temperature;
  final String description;
  final double humidity;
  final double windSpeed;
  final String icon;
  final String waveCondition;
  final List<HourlyForecast> hourlyForecast;

  WeatherInfo({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
    required this.waveCondition,
    required this.hourlyForecast,
  });

  factory WeatherInfo.fromMap(Map<String, dynamic> map) {
    String getWaveCondition(double windSpeed) {
      if (windSpeed < 5.5) return 'Tenang';
      if (windSpeed < 11.0) return 'Ringan';
      if (windSpeed < 16.5) return 'Sedang';
      return 'Tinggi';
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    try {
      debugPrint('Parsing weather data: $map');
      final current = map['current'];
      
      // Extract wind speed and calculate wave condition
      final windSpeed = parseDouble(current['wind']?['speed']);
      final waveCondition = getWaveCondition(windSpeed);

      // Parse hourly forecast if available
      List<HourlyForecast> hourlyForecasts = [];
      if (map['hourly'] != null && map['hourly'] is List) {
        hourlyForecasts = (map['hourly'] as List)
            .take(24) // Take next 24 hours
            .map((hour) {
              try {
                return HourlyForecast.fromMap(hour);
              } catch (e) {
                debugPrint('Error parsing hourly forecast: $e');
                return null;
              }
            })
            .where((element) => element != null)
            .cast<HourlyForecast>()
            .toList();
      }

      return WeatherInfo(
        cityName: map['cityName'] ?? 'Unknown',
        temperature: parseDouble(current['temperature']),
        description: current['summary'] ?? 'Tidak tersedia',
        humidity: parseDouble(current['humidity']),
        windSpeed: windSpeed,
        icon: current['icon_code'] ?? 'sunny',
        waveCondition: waveCondition,
        hourlyForecast: hourlyForecasts,
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing weather data: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Raw data: $map');
      rethrow;
    }
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String icon;
  final double windSpeed;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.icon,
    required this.windSpeed,
  });

  factory HourlyForecast.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue * 1000);
      } else if (dateValue is String) {
        // Try parsing as Unix timestamp string first
        try {
          return DateTime.fromMillisecondsSinceEpoch(int.parse(dateValue) * 1000);
        } catch (e) {
          // If that fails, try parsing as ISO 8601 date string
          try {
            return DateTime.parse(dateValue);
          } catch (e) {
            debugPrint('Error parsing date: $dateValue');
            return DateTime.now(); // Fallback to current time
          }
        }
      }
      debugPrint('Invalid date format received: $dateValue');
      return DateTime.now(); // Fallback to current time
    }

    return HourlyForecast(
      time: parseDate(map['date']),
      temperature: map['temperature']?.toDouble() ?? 0.0,
      icon: map['icon_code'] ?? 'sunny',
      windSpeed: map['wind']?['speed']?.toDouble() ?? 0.0,
    );
  }
}