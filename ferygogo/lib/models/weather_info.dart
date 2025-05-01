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