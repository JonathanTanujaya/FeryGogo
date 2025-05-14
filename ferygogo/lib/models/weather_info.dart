import 'package:flutter/foundation.dart';

class WeatherInfo {
  final String cityName;
  final double temperature;
  final String description;
  final double humidity;
  final double windSpeed;
  final String waveCondition;
  final String icon;
  final List<HourlyForecast> hourlyForecast;

  WeatherInfo({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.waveCondition,
    required this.icon,
    required this.hourlyForecast,
  });

  Map<String, dynamic> toJson() => {
    'cityName': cityName,
    'temperature': temperature,
    'description': description,
    'humidity': humidity,
    'windSpeed': windSpeed,
    'waveCondition': waveCondition,
    'icon': icon,
    'hourlyForecast': hourlyForecast.map((h) => h.toJson()).toList(),
  };
  factory WeatherInfo.fromMap(Map<String, dynamic> data) {
    final current = data['current'] as Map<String, dynamic>;
    
    // Calculate wave condition based on wind speed
    final windSpeed = (current['wind']['speed'] as num).toDouble();
    String waveCondition;
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
      cityName: data['cityName'] ?? '',
      temperature: (current['temperature'] as num?)?.toDouble() ?? 0.0,
      description: current['summary'] as String? ?? 'Tidak ada data',
      humidity: (current['humidity'] as num?)?.toDouble() ?? 0.0,
      windSpeed: windSpeed,
      waveCondition: waveCondition,
      icon: _mapMeteosourceIcon(current['icon'] as String? ?? ''),
      hourlyForecast: _parseHourlyForecast(data['hourly'] as List<dynamic>? ?? []),
    );
  }

  static List<HourlyForecast> _parseHourlyForecast(List<dynamic> hourlyData) {
    return hourlyData.map((hour) {
      final Map<String, dynamic> hourMap = hour as Map<String, dynamic>;
      return HourlyForecast(
        time: DateTime.fromMillisecondsSinceEpoch(hourMap['date'] * 1000),
        temperature: (hourMap['temperature'] as num).toDouble(),
        icon: _mapMeteosourceIcon(hourMap['icon_code'] as String? ?? ''),
        windSpeed: ((hourMap['wind'] as Map<String, dynamic>)['speed'] as num).toDouble(),
      );
    }).toList();
  }

  static String _mapMeteosourceIcon(String meteosourceIcon) {
    final Map<String, String> iconMapping = {
      'clear-day': '01d',
      'clear-night': '01n',
      'cloudy': '04d',
      'partly-cloudy-day': '02d',
      'partly-cloudy-night': '02n',
      'rain': '10d',
      'snow': '13d',
      'thunderstorm': '11d',
      'fog': '50d',
    };

    return iconMapping[meteosourceIcon] ?? '01d';
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

  Map<String, dynamic> toJson() => {
    'time': time.toIso8601String(),
    'temperature': temperature,
    'icon': icon,
    'windSpeed': windSpeed,
  };

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.parse(json['time'] as String),
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      icon: json['icon'] ?? '',
      windSpeed: (json['windSpeed'] ?? 0.0).toDouble(),
    );
  }
}