import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/weather_info.dart';

class WeatherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream untuk mendapatkan update real-time
  Stream<WeatherInfo?> streamWeatherData(String location) {
    return _firestore
        .collection('weather')
        .doc(location)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      
      final data = snapshot.data()!;
      final List<dynamic> hourlyData = data['hourlyForecast'] ?? [];
      
      return WeatherInfo(
        cityName: data['cityName'] ?? '',
        temperature: (data['temperature'] ?? 0.0).toDouble(),
        description: data['description'] ?? '',
        humidity: (data['humidity'] ?? 0.0).toDouble(),
        windSpeed: (data['windSpeed'] ?? 0.0).toDouble(),
        icon: data['icon'] ?? '',
        waveCondition: data['waveCondition'] ?? '',
        hourlyForecast: hourlyData.map<HourlyForecast>((hour) {
          return HourlyForecast(
            time: (hour['time'] as Timestamp).toDate(),
            temperature: (hour['temperature'] ?? 0.0).toDouble(),
            icon: hour['icon'] ?? '',
            windSpeed: (hour['windSpeed'] ?? 0.0).toDouble(),
          );
        }).toList(),
      );
    });
  }

  // Menyimpan data cuaca ke Firestore
  Future<void> saveWeatherData(String location, WeatherInfo weatherInfo) async {
    try {
      await _firestore.collection('weather').doc(location).set({
        'cityName': weatherInfo.cityName,
        'temperature': weatherInfo.temperature,
        'description': weatherInfo.description,
        'humidity': weatherInfo.humidity,
        'windSpeed': weatherInfo.windSpeed,
        'waveCondition': weatherInfo.waveCondition,
        'icon': weatherInfo.icon,
        'timestamp': FieldValue.serverTimestamp(),
        'hourlyForecast': weatherInfo.hourlyForecast.map((forecast) => {
          'time': Timestamp.fromDate(forecast.time),
          'temperature': forecast.temperature,
          'icon': forecast.icon,
          'windSpeed': forecast.windSpeed,
        }).toList(),
      });
      print('Weather data saved successfully for $location');
    } catch (e) {
      print('Error saving weather data: $e');
      throw Exception('Failed to save weather data');
    }
  }

  // Mengambil data cuaca dari Firestore
  Future<WeatherInfo?> getWeatherData(String location) async {
    try {
      final doc = await _firestore.collection('weather').doc(location).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      final List<dynamic> hourlyData = data['hourlyForecast'] ?? [];

      return WeatherInfo(
        cityName: data['cityName'] ?? '',
        temperature: (data['temperature'] ?? 0.0).toDouble(),
        description: data['description'] ?? '',
        humidity: (data['humidity'] ?? 0.0).toDouble(),
        windSpeed: (data['windSpeed'] ?? 0.0).toDouble(),
        icon: data['icon'] ?? '',
        waveCondition: data['waveCondition'] ?? '',
        hourlyForecast: hourlyData.map<HourlyForecast>((hour) {
          return HourlyForecast(
            time: (hour['time'] as Timestamp).toDate(),
            temperature: (hour['temperature'] ?? 0.0).toDouble(),
            icon: hour['icon'] ?? '',
            windSpeed: (hour['windSpeed'] ?? 0.0).toDouble(),
          );
        }).toList(),
      );
    } catch (e) {
      print('Error getting weather data: $e');
      return null;
    }
  }
}
