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
  };  static const Map<String, String> meteosourceIconMapping = {
    // Standard meteosource icons
    'clear-day': '01d',
    'clear-night': '01n',
    'partly-cloudy-day': '02d',
    'partly-cloudy-night': '02n',
    'cloudy': '04d',
    'overcast': '04d',
    'rain': '10d',
    'rain-light': '09d',
    'rain-heavy': '10d',
    'snow': '13d',
    'snow-light': '13d',
    'snow-heavy': '13d',
    'thunderstorm': '11d',
    'fog': '50d',
    'mist': '50d',
    // Alternative formats
    'clear_day': '01d',
    'clear_night': '01n',
    'partly_cloudy_day': '02d',
    'partly_cloudy_night': '02n',
    'rain_light': '09d',
    'rain_heavy': '10d',
    'snow_light': '13d',
    'snow_heavy': '13d',
    // Numeric codes if any
    '1': '01d',
    '2': '02d',
    '3': '04d',
    '4': '04d',
    '5': '09d',
    '6': '10d',
    '7': '11d',
    '8': '13d',
    '9': '50d',
  };
  static String mapMeteosourceIcon(String meteosourceIcon) {
    // First try direct mapping
    final directMapping = meteosourceIconMapping[meteosourceIcon.toLowerCase()];
    if (directMapping != null) return directMapping;
    
    // If no direct mapping, try to infer from icon name
    final iconLower = meteosourceIcon.toLowerCase();
    
    if (iconLower.contains('clear') || iconLower.contains('sun')) {
      return iconLower.contains('night') ? '01n' : '01d';
    } else if (iconLower.contains('partly') || iconLower.contains('few')) {
      return iconLower.contains('night') ? '02n' : '02d';
    } else if (iconLower.contains('cloud') || iconLower.contains('overcast')) {
      return '04d';
    } else if (iconLower.contains('rain') || iconLower.contains('shower')) {
      return iconLower.contains('light') ? '09d' : '10d';
    } else if (iconLower.contains('thunder') || iconLower.contains('storm')) {
      return '11d';
    } else if (iconLower.contains('snow')) {
      return '13d';
    } else if (iconLower.contains('fog') || iconLower.contains('mist')) {
      return '50d';
    }
    
    // Default fallback based on time of day
    final hour = DateTime.now().hour;
    return (hour >= 6 && hour < 18) ? '01d' : '01n';
  }factory WeatherInfo.fromMap(Map<String, dynamic> data) {
    final current = data['current'] as Map<String, dynamic>;
    
    // Calculate wave condition based on wind speed with more variation
    final windSpeed = (current['wind']['speed'] as num).toDouble();
    String waveCondition;
    if (windSpeed < 3.0) {
      waveCondition = 'Tenang';
    } else if (windSpeed < 6.0) {
      waveCondition = 'Ringan';
    } else if (windSpeed < 10.0) {
      waveCondition = 'Sedang';
    } else {
      waveCondition = 'Tinggi';
    }

    // Handle humidity with fallback and variation based on weather conditions
    double humidity = (current['humidity'] as num?)?.toDouble() ?? 65.0;
    
    // If humidity is not provided, estimate based on weather conditions
    if (current['humidity'] == null) {
      final summary = (current['summary'] as String? ?? '').toLowerCase();
      if (summary.contains('rain') || summary.contains('hujan')) {
        humidity = 85.0 + (windSpeed * 2); // Higher humidity during rain
      } else if (summary.contains('cloud') || summary.contains('overcast') || summary.contains('berawan')) {
        humidity = 70.0 + (windSpeed * 1.5);
      } else if (summary.contains('clear') || summary.contains('cerah')) {
        humidity = 50.0 + (windSpeed * 1.2);
      } else {
        humidity = 60.0 + (windSpeed * 1.5);
      }
      
      // Add some variation based on temperature
      final temp = (current['temperature'] as num?)?.toDouble() ?? 25.0;
      if (temp > 30) humidity -= 5;
      if (temp < 20) humidity += 5;
      
      // Ensure humidity is within valid range
      humidity = humidity.clamp(30.0, 95.0);
    }    return WeatherInfo(
      cityName: data['cityName'] ?? '',
      temperature: (current['temperature'] as num?)?.toDouble() ?? 0.0,
      description: current['summary'] as String? ?? 'Tidak ada data',
      humidity: humidity,
      windSpeed: windSpeed,
      waveCondition: waveCondition,
      icon: _getIconFromData(current),
      hourlyForecast: _parseHourlyForecast(data['hourly'] as List<dynamic>? ?? []),
    );
  }
  static String _getIconFromData(Map<String, dynamic> current) {
    // Try multiple icon fields with type safety
    dynamic iconField = current['icon'] ?? current['icon_code'] ?? current['icon_num'];
    
    if (iconField != null) {
      final iconString = iconField.toString(); // Convert to string regardless of type
      if (iconString.isNotEmpty && iconString != 'null') {
        return WeatherInfo.mapMeteosourceIcon(iconString);
      }
    }
    
    // If no icon field, try to infer from summary
    final summary = (current['summary'] as String? ?? '').toLowerCase();
    
    if (summary.contains('overcast') || summary.contains('cloudy')) {
      return '04d';
    } else if (summary.contains('partly')) {
      final hour = DateTime.now().hour;
      return (hour >= 6 && hour < 18) ? '02d' : '02n';
    } else if (summary.contains('clear') || summary.contains('sunny')) {
      final hour = DateTime.now().hour;
      return (hour >= 6 && hour < 18) ? '01d' : '01n';
    } else if (summary.contains('rain')) {
      return '10d';
    } else if (summary.contains('thunderstorm') || summary.contains('thunder')) {
      return '11d';
    } else if (summary.contains('snow')) {
      return '13d';
    } else if (summary.contains('fog') || summary.contains('mist')) {
      return '50d';
    }
    
    // Default fallback
    final hour = DateTime.now().hour;
    return (hour >= 6 && hour < 18) ? '01d' : '01n';
  }static List<HourlyForecast> _parseHourlyForecast(List<dynamic> hourlyData) {
    return hourlyData.map((hour) {
      final Map<String, dynamic> hourMap = hour as Map<String, dynamic>;
      
      // Handle icon code with multiple possible field names and types
      dynamic iconRaw = hourMap['icon_code'] ?? hourMap['icon'] ?? 'clear-day';
      final iconCode = iconRaw.toString(); // Convert to string regardless of type
      
      // Handle date parsing - could be int (timestamp) or string
      DateTime time;
      final dateValue = hourMap['date'];
      if (dateValue is int) {
        time = DateTime.fromMillisecondsSinceEpoch(dateValue * 1000);
      } else if (dateValue is String) {
        time = DateTime.parse(dateValue);
      } else {
        time = DateTime.now();
      }
      
      return HourlyForecast(
        time: time,
        temperature: (hourMap['temperature'] as num).toDouble(),
        icon: WeatherInfo.mapMeteosourceIcon(iconCode),
        windSpeed: ((hourMap['wind'] as Map<String, dynamic>)['speed'] as num).toDouble(),
      );
    }).toList();
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
    // Handle time field that could be String or int
    DateTime time;
    final timeValue = json['time'];
    if (timeValue is String) {
      time = DateTime.parse(timeValue);
    } else if (timeValue is int) {
      time = DateTime.fromMillisecondsSinceEpoch(timeValue);
    } else {
      time = DateTime.now();
    }
    
    // Handle icon field that could be String or int
    final iconValue = json['icon'] ?? json['icon_code'] ?? json['icon_num'] ?? '';
    final iconString = iconValue.toString();
    
    return HourlyForecast(
      time: time,
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      icon: WeatherInfo.mapMeteosourceIcon(iconString),
      windSpeed: (json['windSpeed'] ?? 0.0).toDouble(),
    );
  }
}