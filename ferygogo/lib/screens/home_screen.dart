import '../models/schedule.dart';
import '../services/error_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../providers/schedule_provider.dart';

const Color sapphire = Color(0xFF0F52BA);
const Color skyBlue = Color(0xFF3B7DE9);
const Color regularColor = Color(0xFFD4E4F7);
const Color expressColor = Color(0xFFCBA135);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedType = 'regular';
  String _selectedTripType = 'one_way';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (_isInitialized) return;
    
    final scheduleProvider = context.read<ScheduleProvider>();
    final weatherProvider = context.read<WeatherProvider>();
    
    await Future.wait([
      scheduleProvider.loadSchedules(type: _selectedType),
      weatherProvider.loadWeatherInfo(),
    ]);

    _isInitialized = true;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<ScheduleProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Consumer<WeatherProvider>(
          builder: (context, weatherProvider, _) {
            return Consumer<ScheduleProvider>(
              builder: (context, scheduleProvider, _) {
                return RefreshIndicator(
                  onRefresh: () async => await _loadInitialData(),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildWeatherCard(weatherProvider),
                        _buildTripTypeSelector(),
                        _buildFerryTypeSelector(),
                        _buildScheduleList(scheduleProvider),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildWeatherCard(WeatherProvider weatherProvider) {
    final theme = Theme.of(context);
    
    if (weatherProvider.isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (weatherProvider.error != null) {
      return ErrorHandler.errorWidget(
        weatherProvider.error!,
        () => weatherProvider.loadWeatherInfo(),
      );
    }

    final weatherInfo = weatherProvider.weatherInfo;
    if (weatherInfo == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weatherInfo.temperature}°C',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  weatherInfo.condition,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  'Kondisi Ombak: ${weatherInfo.waveCondition}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(Icons.air, size: 16),
                    Text(' ${weatherInfo.windSpeed} km/h'),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.water_drop, size: 16),
                    Text(' ${weatherInfo.humidity}%'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SegmentedButton<String>(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              return states.contains(MaterialState.selected)
                  ? skyBlue
                  : Colors.white;
            },
          ),
        ),
        segments: const [
          ButtonSegment(
            value: 'one_way',
            label: Text('One Way'),
          ),
          ButtonSegment(
            value: 'round_trip',
            label: Text('Round Trip'),
          ),
        ],
        selected: <String>{_selectedTripType},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() => _selectedTripType = newSelection.first);
        },
      ),
    );
  }

  Widget _buildFerryTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ChoiceChip(
              label: const Text('Regular Ferry'),
              selected: _selectedType == 'regular',
              selectedColor: regularColor,
              labelStyle: TextStyle(
                color: _selectedType == 'regular' ? sapphire : Colors.grey,
              ),
              onSelected: (selected) => _updateFerryType('regular'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceChip(
              label: const Text('Express Ferry'),
              selected: _selectedType == 'express',
              selectedColor: expressColor,
              labelStyle: TextStyle(
                color: _selectedType == 'express' ? Colors.brown : Colors.grey,
              ),
              onSelected: (selected) => _updateFerryType('express'),
            ),
          ),
        ],
      ),
    );
  }

  void _updateFerryType(String type) {
    if (_selectedType != type) {
      setState(() => _selectedType = type);
      context.read<ScheduleProvider>().loadSchedules(type: type);
    }
  }

  Widget _buildScheduleList(ScheduleProvider scheduleProvider) {
    if (scheduleProvider.isLoading && !_isInitialized) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (scheduleProvider.error != null) {
      return ErrorHandler.errorWidget(
        scheduleProvider.error!,
        () => scheduleProvider.loadSchedules(type: _selectedType),
      );
    }

    if (scheduleProvider.schedules.isEmpty) {
      return ErrorHandler.emptyStateWidget(
        'Tidak ada jadwal tersedia untuk saat ini'
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: scheduleProvider.schedules.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final schedule = scheduleProvider.schedules[index];
              return _ScheduleCard(schedule: schedule);
            },
          ),
          if (scheduleProvider.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final Schedule schedule;

  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final departureTime = DateFormat('HH:mm').format(schedule.departureTime);
    final arrivalTime = DateFormat('HH:mm').format(schedule.arrivalTime);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  schedule.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: schedule.type == 'regular'
                        ? regularColor
                        : expressColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    schedule.type.toUpperCase(),
                    style: TextStyle(
                      color: schedule.type == 'regular'
                          ? sapphire
                          : Colors.brown,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(departureTime,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: CustomPaint(
                    painter: DashedLinePainter(),
                    child: Container(height: 2),
                  ),
                ),
                Text(arrivalTime,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.directions_boat, color: sapphire),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: schedule.availability,
              backgroundColor: regularColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                schedule.availability > 0.8 ? Colors.red : sapphire,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rp${schedule.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: sapphire,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(schedule.availability * 100).toInt()}% Available',
                  style: TextStyle(
                    color: schedule.availability > 0.8 ? Colors.red : sapphire,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4E4F7)
      ..strokeWidth = 2;

    const dashWidth = 5;
    const dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}