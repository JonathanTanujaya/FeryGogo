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
      print('DEBUG Stream Weather raw data for $location: $data');
      print('DEBUG Stream Icon from Firestore: ${data['icon']}');
      print('DEBUG Stream Mapped icon: ${WeatherInfo.mapMeteosourceIcon(data['icon']?.toString() ?? '')}');
      print('DEBUG Stream Humidity: ${data['humidity']}');
      print('DEBUG Stream Wave condition: ${data['waveCondition']}');
      
      final List<dynamic> hourlyData = data['hourlyForecast'] ?? [];
      
      return WeatherInfo(
        cityName: data['cityName'] ?? '',
        temperature: (data['temperature'] ?? 0.0).toDouble(),
        description: data['description'] ?? '',
        humidity: (data['humidity'] ?? 0.0).toDouble(),
        windSpeed: (data['windSpeed'] ?? 0.0).toDouble(),
        icon: WeatherInfo.mapMeteosourceIcon(data['icon']?.toString() ?? ''),
        waveCondition: data['waveCondition'] ?? '',
        hourlyForecast: hourlyData.map<HourlyForecast>((hour) {
          // Handle icon field that could be String or int
          final iconValue = hour['icon'] ?? hour['icon_code'] ?? hour['icon_num'] ?? '';
          final iconString = iconValue.toString();
          
          // Handle time field that could be Timestamp or other formats
          DateTime time;
          final timeValue = hour['time'];
          if (timeValue is Timestamp) {
            time = timeValue.toDate();
          } else if (timeValue is String) {
            time = DateTime.parse(timeValue);
          } else if (timeValue is int) {
            time = DateTime.fromMillisecondsSinceEpoch(timeValue);
          } else {
            time = DateTime.now();
          }
          
          return HourlyForecast(
            time: time,
            temperature: (hour['temperature'] ?? 0.0).toDouble(),
            icon: WeatherInfo.mapMeteosourceIcon(iconString),
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
      print('DEBUG Weather raw data for $location: $data');
      print('DEBUG Icon from Firestore: ${data['icon']}');
      print('DEBUG Mapped icon: ${WeatherInfo.mapMeteosourceIcon(data['icon']?.toString() ?? '')}');
      print('DEBUG Humidity: ${data['humidity']}');
      print('DEBUG Wave condition: ${data['waveCondition']}');
      
      final List<dynamic> hourlyData = data['hourlyForecast'] ?? [];

      return WeatherInfo(
        cityName: data['cityName'] ?? '',
        temperature: (data['temperature'] ?? 0.0).toDouble(),
        description: data['description'] ?? '',
        humidity: (data['humidity'] ?? 0.0).toDouble(),
        windSpeed: (data['windSpeed'] ?? 0.0).toDouble(),
        icon: WeatherInfo.mapMeteosourceIcon(data['icon']?.toString() ?? ''),
        waveCondition: data['waveCondition'] ?? '',
        hourlyForecast: hourlyData.map<HourlyForecast>((hour) {
          // Handle icon field that could be String or int
          final iconValue = hour['icon'] ?? hour['icon_code'] ?? hour['icon_num'] ?? '';
          final iconString = iconValue.toString();
          
          // Handle time field that could be Timestamp or other formats
          DateTime time;
          final timeValue = hour['time'];
          if (timeValue is Timestamp) {
            time = timeValue.toDate();
          } else if (timeValue is String) {
            time = DateTime.parse(timeValue);
          } else if (timeValue is int) {
            time = DateTime.fromMillisecondsSinceEpoch(timeValue);
          } else {
            time = DateTime.now();
          }
          
          return HourlyForecast(
            time: time,
            temperature: (hour['temperature'] ?? 0.0).toDouble(),
            icon: WeatherInfo.mapMeteosourceIcon(iconString),
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
