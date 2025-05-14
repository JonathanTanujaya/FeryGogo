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

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      cityName: json['cityName'] ?? '',
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      humidity: (json['humidity'] ?? 0.0).toDouble(),
      windSpeed: (json['windSpeed'] ?? 0.0).toDouble(),
      waveCondition: json['waveCondition'] ?? '',
      icon: json['icon'] ?? '',
      hourlyForecast: (json['hourlyForecast'] as List?)
          ?.map((h) => HourlyForecast.fromJson(h as Map<String, dynamic>))
          .toList() ?? [],
    );
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