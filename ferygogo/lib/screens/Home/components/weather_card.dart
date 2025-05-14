import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/weather_provider.dart';
import '../../../models/weather_info.dart';
import 'package:intl/intl.dart';

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
          return const Card(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (weatherProvider.error != null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${weatherProvider.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final weather = weatherProvider.weatherInfo;
        if (weather == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Data cuaca tidak tersedia'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => weatherProvider.loadWeatherInfo(
                      isNearMerak: isNearMerak,
                    ),
                    child: const Text('Muat Ulang'),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather.cityName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weather.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Image.network(
                      'https://openweathermap.org/img/w/${weather.icon}.png',
                      width: 64,
                      height: 64,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn(
                      'Suhu',
                      '${weather.temperature.round()}°C',
                      Icons.thermostat,
                    ),
                    _buildInfoColumn(
                      'Kelembaban',
                      '${weather.humidity.round()}%',
                      Icons.water_drop,
                    ),
                    _buildInfoColumn(
                      'Angin',
                      '${weather.windSpeed.toStringAsFixed(1)} m/s',
                      Icons.air,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kondisi Gelombang',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weather.waveCondition,
                          style: TextStyle(
                            color: _getWaveConditionColor(weather.waveCondition),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => weatherProvider.loadWeatherInfo(
                        isNearMerak: isNearMerak,
                      ),
                      tooltip: 'Muat ulang data cuaca',
                    ),
                  ],
                ),
                if (weather.hourlyForecast.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Prakiraan Per Jam',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: weather.hourlyForecast.length,
                      itemBuilder: (context, index) {
                        final forecast = weather.hourlyForecast[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  DateFormat('HH:mm').format(forecast.time),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Image.network(
                                  'https://openweathermap.org/img/w/${forecast.icon}.png',
                                  width: 32,
                                  height: 32,
                                ),
                                Text(
                                  '${forecast.temperature.round()}°C',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
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
}
