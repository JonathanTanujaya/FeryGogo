import 'package:ferry_ticket_app/models/schedule.dart';
import 'package:ferry_ticket_app/providers/schedule_provider.dart';
import 'package:ferry_ticket_app/providers/weather_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
  bool _isInitialized = false;
  bool _isSearching = false;

  // Fixed ports
  final String port1 = 'Merak';
  final String port2 = 'Bakauheni';
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  
  // Fixed time slots for 24 hour operation
  final List<String> _regularHours = List.generate(24, (i) => 
    '${i.toString().padLeft(2, '0')}:00'
  );
  final List<String> _oddHours = [
    '01:00', '03:00', '05:00', '07:00', '09:00', '11:00', 
    '13:00', '15:00', '17:00', '19:00', '21:00', '23:00'
  ];
  final List<String> _evenHours = [
    '00:00', '02:00', '04:00', '06:00', '08:00', '10:00', 
    '12:00', '14:00', '16:00', '18:00', '20:00', '22:00'
  ];
  String? _selectedTimeString;
  
  // Service types and passenger types
  final List<String> _serviceTypes = ['Regular', 'Express'];
  String _selectedServiceType = 'Regular';

  final List<String> _passengerTypes = [
    'Penumpang Jalan',
    'Kendaraan Pribadi',
    'Kendaraan Kargo',
    'Bus',
    'Truk',
  ];
  String _selectedPassengerType = 'Penumpang Jalan';

  DateTime _selectedDate = DateTime.now();
  
  // Form validation states
  bool _portsSelected = false;
  bool _dateSelected = false;
  bool _timeSelected = false;
  bool _serviceTypeEnabled = false;
  bool _passengerTypeEnabled = false;

  // Simulated current location - in reality this would come from GPS
  final bool _isNearMerak = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fromController.text = _isNearMerak ? port1 : port2;
    _toController.text = _isNearMerak ? port2 : port1;
    _updateAvailableTime();
    _fromController.addListener(_updateFormState);
    _toController.addListener(_updateFormState);
    
    // Initialize weather data with immediate fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weatherProvider = context.read<WeatherProvider>();
      weatherProvider.fetchWeatherFromApi().then((_) {
        if (mounted && weatherProvider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(weatherProvider.error!),
              action: SnackBarAction(
                label: 'Coba Lagi',
                onPressed: () => weatherProvider.fetchWeatherFromApi(),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _fromController.removeListener(_updateFormState);
    _toController.removeListener(_updateFormState);
    _scrollController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (_isInitialized) return;
    
    final scheduleProvider = context.read<ScheduleProvider>();
    final weatherProvider = context.read<WeatherProvider>();
    
    await Future.wait([
      scheduleProvider.loadSchedules(type: _selectedServiceType),
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

  void _swapPorts() {
    final temp = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = temp;
    _updateFormState();
  }

  void _updateFormState() {
    setState(() {
      _portsSelected = _fromController.text.isNotEmpty && _toController.text.isNotEmpty;
      _dateSelected = _portsSelected;
      _timeSelected = _dateSelected && _selectedTimeString != null;
      _serviceTypeEnabled = _timeSelected;
      _passengerTypeEnabled = _serviceTypeEnabled;
    });
  }

  List<String> _getAvailableTimesForDate(DateTime date) {
    List<String> baseTimeSlots;
    
    if (_selectedServiceType == 'Regular') {
      baseTimeSlots = _regularHours;
    } else {
      final isOddDate = date.day.isOdd;
      baseTimeSlots = isOddDate ? _oddHours : _evenHours;
    }
    
    final now = DateTime.now();
    if (date.year != now.year || date.month != now.month || date.day != now.day) {
      return baseTimeSlots;
    }
    
    final currentTime = TimeOfDay.now();
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    
    return baseTimeSlots.where((timeStr) {
      final parts = timeStr.split(':');
      final timeMinutes = int.parse(parts[0]) * 60;
      return timeMinutes > currentMinutes;
    }).toList();
  }

  String? _findNearestFutureTime(List<String> times) {
    if (times.isEmpty) return null;
    
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;
    
    for (String time in times) {
      final parts = time.split(':');
      final timeMinutes = int.parse(parts[0]) * 60;
      if (timeMinutes > currentMinutes) {
        return time;
      }
    }
    
    return times.first;
  }

  void _updateAvailableTime() {
    final availableTimes = _getAvailableTimesForDate(_selectedDate);
    
    final now = DateTime.now();
    if (_selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day) {
      _selectedTimeString = _findNearestFutureTime(availableTimes);
    } else {
      _selectedTimeString = availableTimes.isNotEmpty ? availableTimes.first : null;
    }
  }

  Future<void> _searchSchedules() async {
    if (!_passengerTypeEnabled || _selectedTimeString == null) return;

    setState(() => _isSearching = true);

    try {
      final scheduleProvider = context.read<ScheduleProvider>();
      await scheduleProvider.searchSchedules(
        fromPort: _fromController.text,
        toPort: _toController.text,
        date: _selectedDate,
        time: _selectedTimeString!,
        type: _selectedServiceType,
      );

      if (!mounted) return;

      if (scheduleProvider.schedules.isNotEmpty) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder: (context, scrollController) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jadwal Tersedia',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: scheduleProvider.schedules.length,
                      itemBuilder: (context, index) => _ScheduleCard(
                        schedule: scheduleProvider.schedules[index],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada jadwal yang tersedia'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.directions_ferry, size: 24, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'FeryGogo', 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [sapphire, skyBlue],
            ),
          ),
        ),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              'AP',
              style: TextStyle(color: sapphire),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Consumer<WeatherProvider>(
          builder: (context, weatherProvider, _) {
            return Consumer<ScheduleProvider>(
              builder: (context, scheduleProvider, _) {
                return RefreshIndicator(
                  onRefresh: () async {
                    _isInitialized = false;
                    return _loadInitialData();
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWeatherCard(weatherProvider),
                        _buildTripTypeSelector(),
                        _buildSearchCard(),
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
    if (weatherProvider.isLoading) {
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

    if (weatherProvider.error != null) {
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
                onPressed: () => weatherProvider.fetchWeatherFromApi(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final weatherInfo = weatherProvider.weatherInfo;
    if (weatherInfo == null) {
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
                onPressed: () => weatherProvider.fetchWeatherFromApi(),
                child: const Text('Muat Ulang'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weatherInfo.cityName,
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: sapphire.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              weatherInfo.description,
                              style: TextStyle(
                                color: sapphire,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (weatherInfo.icon.isNotEmpty) ...[
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: sapphire.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Image.network(
                        'https://www.meteosource.com/static/img/ico/${weatherInfo.icon}.svg',
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.wb_sunny, size: 40, color: Colors.orange),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
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
            ),
          ],
        ),
      ),
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
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTripTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8F0FB),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: sapphire,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Text(
                  'Sekali Jalan',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    final availableTimes = _getAvailableTimesForDate(_selectedDate);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pelabuhan Awal',
                          style: TextStyle(color: Colors.grey)),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9FC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          controller: _fromController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton(
                    onPressed: _swapPorts,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: sapphire,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.swap_horiz,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pelabuhan Tujuan',
                          style: TextStyle(color: Colors.grey)),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9FC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextFormField(
                          controller: _toController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Jenis Layanan', style: TextStyle(color: Colors.grey)),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedServiceType,
                items: _serviceTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedServiceType = value!;
                    _updateAvailableTime();
                    _updateFormState();
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Jenis Penumpang', style: TextStyle(color: Colors.grey)),
            Container(
              decoration: BoxDecoration(
                color: _serviceTypeEnabled
                    ? const Color(0xFFF7F9FC)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedPassengerType,
                items: _passengerTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: _serviceTypeEnabled
                    ? (value) {
                        setState(() {
                          _selectedPassengerType = value!;
                        });
                      }
                    : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                style: TextStyle(
                  color:
                      _serviceTypeEnabled ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tanggal', style: TextStyle(color: Colors.grey)),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 30)),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = date;
                              _updateAvailableTime();
                              _updateFormState();
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F9FC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 20, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('dd MMM yyyy').format(_selectedDate),
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Waktu', style: TextStyle(color: Colors.grey)),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9FC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedTimeString,
                            items: availableTimes.map((time) {
                              return DropdownMenuItem(
                                value: time,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(time),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTimeString = value;
                                _updateFormState();
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _passengerTypeEnabled && _selectedTimeString != null && !_isSearching
                        ? _searchSchedules
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: sapphire,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: _isSearching
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Cari Tiket'),
              ),
            ),
          ],
        ),
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
      margin: const EdgeInsets.only(bottom: 12),
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
                    child: const SizedBox(height: 2),
                  ),
                ),
                Text(arrivalTime,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.directions_boat, color: sapphire),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: schedule.availability,
                backgroundColor: regularColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  schedule.availability > 0.8 ? Colors.red : sapphire,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  NumberFormat.currency(
                    locale: 'id',
                    symbol: 'Rp',
                    decimalDigits: 0,
                  ).format(schedule.price),
                  style: const TextStyle(
                    color: sapphire,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: schedule.availability > 0.8
                        ? Colors.red.withOpacity(0.1)
                        : sapphire.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Tersedia ${(schedule.availability * 100).toInt()}%',
                    style: TextStyle(
                      color: schedule.availability > 0.8 ? Colors.red : sapphire,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
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