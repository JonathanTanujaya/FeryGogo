import '../models/schedule.dart';
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
  bool _isInitialized = false;

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
  
  // Service types and other fields...
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
  
  // Form validation states - Updated order
  bool _portsSelected = false;
  bool _dateSelected = false;
  bool _timeSelected = false;
  bool _serviceTypeEnabled = false;
  bool _passengerTypeEnabled = false;

  // Simulated current location - in reality this would come from GPS
  final bool _isNearMerak = true; // Simulate being near Merak

  void _updateFormState() {
    setState(() {
      // First check ports
      _portsSelected = _fromController.text.isNotEmpty && _toController.text.isNotEmpty;
      
      // Then check date and time
      _dateSelected = _portsSelected && _selectedDate != null;
      _timeSelected = _dateSelected && _selectedTimeString != null;
      
      // Finally check service and passenger types
      _serviceTypeEnabled = _timeSelected;
      _passengerTypeEnabled = _serviceTypeEnabled && _selectedServiceType != null;
    });
  }

  String _findNearestTime(List<String> times) {
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;
    
    // Convert all times to minutes and find the nearest one
    int nearestDiff = 24 * 60; // Maximum possible difference
    String nearestTime = times[0]; // Default to first time
    
    for (String time in times) {
      final parts = time.split(':');
      final timeMinutes = int.parse(parts[0]) * 60;
      final diff = (timeMinutes - currentMinutes).abs();
      
      if (diff < nearestDiff) {
        nearestDiff = diff;
        nearestTime = time;
      }
    }
    
    return nearestTime;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Set default ports based on location
    _fromController.text = _isNearMerak ? port1 : port2;
    _toController.text = _isNearMerak ? port2 : port1;
    _updateAvailableTime();
    _fromController.addListener(_updateFormState);
    _toController.addListener(_updateFormState);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
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
  }

  List<String> _getAvailableTimesForDate(DateTime date) {
    List<String> baseTimeSlots;
    
    // Get base time slots based on service type
    if (_selectedServiceType == 'Regular') {
      baseTimeSlots = _regularHours;
    } else {
      // For express service, use odd/even hours based on date
      final isOddDate = date.day.isOdd;
      baseTimeSlots = isOddDate ? _oddHours : _evenHours;
    }
    
    // If not today, return all time slots
    final now = DateTime.now();
    if (date.year != now.year || date.month != now.month || date.day != now.day) {
      return baseTimeSlots;
    }
    
    // For today, filter out past times for both regular and express
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
    
    // Find the first time that's after current time
    for (String time in times) {
      final parts = time.split(':');
      final timeMinutes = int.parse(parts[0]) * 60;
      if (timeMinutes > currentMinutes) {
        return time;
      }
    }
    
    return times.first; // Fallback to first time if no future times found
  }

  void _updateAvailableTime() {
    final availableTimes = _getAvailableTimesForDate(_selectedDate);
    
    // If date is today, find nearest future time
    final now = DateTime.now();
    if (_selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day) {
      _selectedTimeString = _findNearestFutureTime(availableTimes);
    } else {
      _selectedTimeString = availableTimes.isNotEmpty ? availableTimes.first : null;
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
                  onRefresh: () async => await _loadInitialData(),
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
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(weatherInfo.condition),
                Text(
                  'Kondisi Ombak: ${weatherInfo.waveCondition}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
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
            // Ports Selection
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pelabuhan Awal', style: TextStyle(color: Colors.grey)),
                      TextFormField(
                        controller: _fromController,
                        readOnly: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF7F9FC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
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
                      const Text('Pelabuhan Tujuan', style: TextStyle(color: Colors.grey)),
                      TextFormField(
                        controller: _toController,
                        readOnly: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF7F9FC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Service Type
            const Text('Jenis Layanan', style: TextStyle(color: Colors.grey)),
            DropdownButtonFormField<String>(
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
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF7F9FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Passenger Type
            const Text('Jenis Penumpang', style: TextStyle(color: Colors.grey)),
            DropdownButtonFormField<String>(
              value: _selectedPassengerType,
              items: _passengerTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: _serviceTypeEnabled ? (value) {
                setState(() {
                  _selectedPassengerType = value!;
                });
              } : null,
              decoration: InputDecoration(
                filled: true,
                fillColor: _serviceTypeEnabled ? const Color(0xFFF7F9FC) : Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                color: _serviceTypeEnabled ? Colors.black87 : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            // Date and Time Selection
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
                            lastDate: DateTime.now().add(const Duration(days: 30)),
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
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9FC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedTimeString,
                            items: availableTimes
                                .map((time) => DropdownMenuItem(
                                      value: time,
                                      child: Text(time),
                                    ))
                                .toList(),
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
            const SizedBox(height: 16),
            // Search Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _passengerTypeEnabled && _selectedTimeString != null ? () {
                  // TODO: Implement search
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: sapphire,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: const Text('Cari Tiket'),
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