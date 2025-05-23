import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/weather_provider.dart';
import '../../../models/weather_info.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class WeatherCard extends StatelessWidget {
  final bool isNearMerak;

  const WeatherCard({
    Key? key,
    required this.isNearMerak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return _buildLoadingState();
        }

        if (weatherProvider.error != null) {
          return _buildErrorState(weatherProvider);
        }

        final weather = weatherProvider.weatherInfo;

        if (weather == null) {
          return _buildNoDataState(weatherProvider);
        }

        return _buildWeatherDisplay(context, weather, weatherProvider);
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[300]!, Colors.blue[400]!],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Memuat data cuaca...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(WeatherProvider weatherProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cloud_off, color: Colors.red[400], size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data cuaca',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${weatherProvider.error}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => weatherProvider.loadWeatherInfo(
                isNearMerak: isNearMerak,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataState(WeatherProvider weatherProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded, color: Colors.amber[400], size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'Data Tidak Tersedia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data cuaca ${isNearMerak ? "Merak" : "Bakauheni"} tidak tersedia saat ini',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => weatherProvider.loadWeatherInfo(
                isNearMerak: isNearMerak,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Muat Ulang',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDisplay(BuildContext context, WeatherInfo weather, WeatherProvider weatherProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getBackgroundGradient(weather.description.toLowerCase()),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with location and refresh button
                _buildHeader(weather, weatherProvider),
                
                // Main weather info with icon and temperature
                _buildMainWeatherInfo(weather),
                
                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    color: Colors.white.withOpacity(0.3),
                    thickness: 1,
                  ),
                ),
                
                // Weather metrics (humidity, wind)
                _buildWeatherMetrics(weather),
                
                // Wave condition
                _buildWaveCondition(weather),
                
                // Hourly forecast
                if (weather.hourlyForecast.isNotEmpty)
                  _buildHourlyForecast(weather),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(WeatherInfo weather, WeatherProvider weatherProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            weather.cityName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          InkWell(
            onTap: () => weatherProvider.loadWeatherInfo(
              isNearMerak: isNearMerak,
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainWeatherInfo(WeatherInfo weather) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weather.temperature.round()}°',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              Text(
                weather.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          Hero(
            tag: 'weather_icon_${isNearMerak ? "merak" : "bakauheni"}',
            child: _getCustomWeatherIcon(weather.icon, 80),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherMetrics(WeatherInfo weather) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMetricItem(
            Icons.water_drop_outlined,
            '${weather.humidity.round()}%',
            'Kelembaban',
          ),
          _buildVerticalDivider(),
          _buildMetricItem(
            Icons.air_outlined,
            '${weather.windSpeed.toStringAsFixed(1)} m/s',
            'Angin',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildWaveCondition(WeatherInfo weather) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kondisi Gelombang',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getWaveConditionBackgroundColor(weather.waveCondition),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getWaveConditionIcon(weather.waveCondition),
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  weather.waveCondition,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(WeatherInfo weather) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Prakiraan Per Jam',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: weather.hourlyForecast.length,
              itemBuilder: (context, index) {
                final forecast = weather.hourlyForecast[index];
                final isNow = index == 0;
                
                return Container(
                  width: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isNow 
                        ? Colors.white.withOpacity(0.2) 
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: isNow 
                        ? Border.all(color: Colors.white.withOpacity(0.5), width: 1) 
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(forecast.time),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(isNow ? 1.0 : 0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _getCustomWeatherIcon(forecast.icon, 28),
                      const SizedBox(height: 8),
                      Text(
                        '${forecast.temperature.round()}°',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(isNow ? 1.0 : 0.8),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Returns a weather icon based on the mapped meteosource icon code (e.g. '01d', '02d', etc).
  ///
  /// [iconCode] should be the result of WeatherInfo.mapMeteosourceIcon().
  Widget _getCustomWeatherIcon(String iconCode, double size) {
    IconData iconData;
    Color iconColor;
    
    // Based on OpenWeatherMap icon codes
    if (iconCode.contains('01')) {
      // Clear sky
      iconData = Icons.wb_sunny_rounded;
      iconColor = Colors.amber;
    } else if (iconCode.contains('02')) {
      // Few clouds
      iconData = Icons.cloud_rounded;
      iconColor = Colors.amber;
    } else if (iconCode.contains('03') || iconCode.contains('04')) {
      // Scattered clouds, broken clouds
      iconData = Icons.cloud_rounded;
      iconColor = Colors.white;
    } else if (iconCode.contains('09')) {
      // Shower rain
      iconData = Icons.grain_rounded;
      iconColor = Colors.lightBlue;
    } else if (iconCode.contains('10')) {
      // Rain
      iconData = Icons.beach_access_rounded;
      iconColor = Colors.lightBlue;
    } else if (iconCode.contains('11')) {
      // Thunderstorm
      iconData = Icons.flash_on_rounded;
      iconColor = Colors.amber;
    } else if (iconCode.contains('13')) {
      // Snow
      iconData = Icons.ac_unit_rounded;
      iconColor = Colors.white;
    } else if (iconCode.contains('50')) {
      // Mist
      iconData = Icons.cloud_queue_rounded;
      iconColor = Colors.white.withOpacity(0.8);
    } else {
      // Default
      iconData = Icons.cloud_rounded;
      iconColor = Colors.white;
    }
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          iconData,
          color: iconColor,
          size: size * 0.65,
        ),
      ),
    );
  }

  IconData _getWaveConditionIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'tenang':
        return Icons.waves;
      case 'ringan':
        return Icons.waves;
      case 'sedang':
        return Icons.tsunami;
      case 'tinggi':
        return Icons.tsunami;
      default:
        return Icons.waves;
    }
  }

  Color _getWaveConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'tenang':
        return Colors.green;
      case 'ringan':
        return Colors.blue;
      case 'sedang':
        return Colors.orange;
      case 'tinggi':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getWaveConditionBackgroundColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'tenang':
        return Colors.green;
      case 'ringan':
        return Colors.blue;
      case 'sedang':
        return Colors.orange;
      case 'tinggi':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<Color> _getBackgroundGradient(String weatherDescription) {
    // Customize gradient based on weather condition
    if (weatherDescription.contains('hujan') || weatherDescription.contains('rain')) {
      return [Colors.indigo[700]!, Colors.indigo[900]!];
    } else if (weatherDescription.contains('berawan') || weatherDescription.contains('cloud')) {
      return [Colors.blueGrey[400]!, Colors.blueGrey[700]!];
    } else if (weatherDescription.contains('cerah') || weatherDescription.contains('clear') || weatherDescription.contains('sunny')) {
      return [Colors.blue[400]!, Colors.blue[700]!];
    } else if (weatherDescription.contains('kabut') || weatherDescription.contains('fog') || weatherDescription.contains('mist')) {
      return [Colors.blueGrey[300]!, Colors.blueGrey[600]!];
    } else if (weatherDescription.contains('salju') || weatherDescription.contains('snow')) {
      return [Colors.lightBlue[300]!, Colors.lightBlue[700]!];
    } else {
      // Default blue gradient
      return [Colors.blue[400]!, Colors.blue[700]!];
    }
  }
}