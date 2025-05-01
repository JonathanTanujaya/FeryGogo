import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class WeatherHeader extends StatelessWidget {
  const WeatherHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, _) {
        if (weatherProvider.isLoading) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final weatherInfo = weatherProvider.weatherInfo;
        if (weatherInfo == null) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weatherInfo.temperature}°C',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      weatherInfo.condition,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Kondisi Ombak: ${weatherInfo.waveCondition}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _WeatherMetric(
                      icon: Icons.air,
                      value: '${weatherInfo.windSpeed} km/h',
                    ),
                    _WeatherMetric(
                      icon: Icons.water_drop,
                      value: '${weatherInfo.humidity}%',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WeatherMetric extends StatelessWidget {
  final IconData icon;
  final String value;

  const _WeatherMetric({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(value),
      ],
    );
  }
}