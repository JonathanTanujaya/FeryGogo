import 'package:ferry_ticket_app/models/weather_info.dart';
import 'package:flutter/material.dart';
import 'package:ferry_ticket_app/providers/weather_provider.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:intl/intl.dart';

const Color sapphire = Color(0xFF0F52BA);

class WeatherCard extends StatelessWidget {
  final WeatherProvider weatherProvider;

  const WeatherCard({Key? key, required this.weatherProvider})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (weatherProvider.isLoading) {
      return _buildLoadingCard();
    }

    if (weatherProvider.error != null) {
      return _buildErrorCard();
    }

    final weatherInfo = weatherProvider.weatherInfo;
    if (weatherInfo == null) {
      return _buildNoDataCard();
    }

    return _buildWeatherInfoCard(weatherInfo);
  }

  Widget _buildLoadingCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Memuat informasi cuaca...'),
          ],
        ),
      ),
    );
  }

  IconData _mapIconToWeatherIcon(String iconCode) {
    switch (iconCode.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return WeatherIcons.day_sunny;
      case 'clear-night':
        return WeatherIcons.night_clear;
      case 'partly-cloudy':
        return WeatherIcons.day_cloudy;
      case 'partly-cloudy-night':
        return WeatherIcons.night_alt_cloudy;
      case 'cloudy':
        return WeatherIcons.cloud;
      case 'overcast':
        return WeatherIcons.cloudy;
      case 'rain':
        return WeatherIcons.rain;
      case 'rain-light':
        return WeatherIcons.showers;
      case 'rain-heavy':
        return WeatherIcons.rain_wind;
      case 'thunderstorm':
        return WeatherIcons.thunderstorm;
      case 'fog':
        return WeatherIcons.fog;
      case 'snow':
        return WeatherIcons.snow;
      default:
        return WeatherIcons.na;
    }
  }

  Widget _buildErrorCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text(weatherProvider.error ?? 'Terjadi kesalahan'),
            TextButton(
              onPressed: () => weatherProvider.loadWeatherInfo(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            const Text('Informasi cuaca tidak tersedia'),
            TextButton(
              onPressed: () => weatherProvider.loadWeatherInfo(),
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfoCard(WeatherInfo weatherInfo) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeatherHeader(weatherInfo),
            if (weatherInfo.hourlyForecast.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildHourlyForecast(weatherInfo),
              const SizedBox(height: 16),
              const Divider(),
            ],
            const SizedBox(height: 16),
            _buildWeatherDetails(weatherInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherHeader(WeatherInfo weatherInfo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pelabuhan ${weatherInfo.cityName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${weatherInfo.temperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: sapphire.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      weatherInfo.description,
                      style: TextStyle(color: sapphire, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: sapphire.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: BoxedIcon(
              _mapIconToWeatherIcon(weatherInfo.icon),
              size: 40,
              color: Colors.orange[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyForecast(WeatherInfo weatherInfo) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weatherInfo.hourlyForecast.length,
        itemBuilder: (context, index) {
          final forecast = weatherInfo.hourlyForecast[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('HH:mm').format(forecast.time),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                BoxedIcon(
                  _mapIconToWeatherIcon(forecast.icon),
                  size: 24,
                  color: Colors.orange[700],
                ),
                const SizedBox(height: 4),
                Text(
                  '${forecast.temperature.toStringAsFixed(1)}°',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${forecast.windSpeed.toStringAsFixed(1)} m/s',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherDetails(WeatherInfo weatherInfo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildWeatherDetail(
          icon: Icons.waves,
          label: 'Kondisi Ombak',
          value: weatherInfo.waveCondition,
        ),
        _buildWeatherDetail(
          icon: Icons.air,
          label: 'Kec. Angin',
          value: '${weatherInfo.windSpeed.toStringAsFixed(1)} m/s',
        ),
        _buildWeatherDetail(
          icon: Icons.water_drop,
          label: 'Kelembaban',
          value: '${weatherInfo.humidity.toStringAsFixed(0)}%',
        ),
      ],
    );
  }

  Widget _buildWeatherDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: sapphire),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
