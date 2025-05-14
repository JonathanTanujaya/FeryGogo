import 'package:ferry_ticket_app/screens/tiket/ticket_popUp.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

import 'package:ferry_ticket_app/providers/schedule_provider.dart';
import 'package:ferry_ticket_app/providers/weather_provider.dart';
import 'package:ferry_ticket_app/models/ticket.dart';
import 'package:ferry_ticket_app/models/passenger.dart';
import 'package:ferry_ticket_app/models/vehicle_category.dart';
import 'package:ferry_ticket_app/screens/tiket/form_data_screen.dart';

import 'components/weather_card.dart';
import 'components/trip_type_selector.dart';
import 'components/passenger_selector.dart';
import 'components/port_selector.dart';
import 'components/service_selector.dart';
import 'components/date_time_selector.dart';
import 'components/vehicle_category_selector.dart';
import 'utils/time_utils.dart';

const Color sapphire = Color(0xFF0F52BA);
const Color skyBlue = Color(0xFF3B7DE9);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;  bool _isSearching = false;
  VehicleCategory? _selectedCategory;

  // Fixed ports
  final String port1 = 'Merak';
  final String port2 = 'Bakauheni';
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  String _selectedServiceType = 'Regular';
  final List<String> _serviceTypes = ['Regular', 'Express'];

  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeString;

  // Form validation states
  bool _portsSelected = false;
  bool _dateSelected = false;
  bool _timeSelected = false;
  bool _serviceTypeEnabled = false;
  bool _passengerTypeEnabled = false;

  // Koordinat pelabuhan
  static const double merakLat = -6.1141;
  static const double merakLong = 105.8172;
  static const double bakauheniLat = -5.8622;
  static const double bakauheniLong = 105.7517;

  Position? _currentPosition;
  bool _isNearMerak = true; // Default ke Merak

  // Add passenger count state
  final Map<PassengerType, int> _passengerCounts = {
    PassengerType.child: 0,
    PassengerType.adult: 1, // Default 1 adult
    PassengerType.elderly: 0,
  };

  int get _totalPassengers =>
      _passengerCounts.values.fold(0, (sum, count) => sum + count);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializeScreen();
    _fromController.addListener(_updateFormState);
    _toController.addListener(_updateFormState);
  }

  Future<void> _initializeScreen() async {
    await _getCurrentLocation();
    await _initializeWeather();
    await _loadInitialData();
    setState(() {
      _isInitialized = true;
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah layanan lokasi aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Layanan lokasi dinonaktifkan. Silakan aktifkan untuk melanjutkan.')));
      }
      // Buka pengaturan lokasi
      await Geolocator.openLocationSettings();
      return false;
    }

    // Cek izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Minta izin lokasi dengan dialog default
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Izin lokasi ditolak')));
        }
        return false;
      }
    }

    // Jika izin ditolak secara permanen
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Izin Lokasi Diperlukan'),
            content: const Text(
                'Aplikasi membutuhkan akses lokasi untuk memberikan layanan terbaik. Mohon izinkan akses lokasi di pengaturan.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Batal'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Buka Pengaturan'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await Geolocator.openAppSettings();
                },
              ),
            ],
          ),
        );
      }
      return false;
    }

    return true;
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Minta izin lokasi terlebih dahulu
      final hasPermission = await _handleLocationPermission();
      
      if (!hasPermission) {
        // Jika izin ditolak, gunakan Merak sebagai default
        setState(() {
          _isNearMerak = true;
          _fromController.text = port1; // Merak
          _toController.text = port2; // Bakauheni
        });
        return;
      }

      // Dapatkan posisi user
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;

        // Hitung jarak ke masing-masing pelabuhan
        double distanceToMerak = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          merakLat,
          merakLong,
        );

        double distanceToBakauheni = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          bakauheniLat,
          bakauheniLong,
        );

        // Tentukan pelabuhan terdekat
        _isNearMerak = distanceToMerak < distanceToBakauheni;

        // Set pelabuhan awal berdasarkan lokasi terdekat
        if (_isNearMerak) {
          _fromController.text = port1; // Merak
          _toController.text = port2; // Bakauheni
        } else {
          _fromController.text = port2; // Bakauheni
          _toController.text = port1; // Merak
        }
      });

      // Update weather info berdasarkan lokasi
      if (mounted) {
        final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
        await weatherProvider.loadWeatherInfo(isNearMerak: _isNearMerak);
      }
    } catch (e) {
      print('Error getting location: $e');
      // Fallback ke Merak sebagai default
      setState(() {
        _isNearMerak = true;
        _fromController.text = port1;
        _toController.text = port2;
      });
    }
  }

  Future<void> _initializeWeather() async {
    if (mounted) {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      await weatherProvider.loadWeatherInfo(isNearMerak: _isNearMerak);
    }
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
    // Initialize any other data needed for the screen
    setState(() {
      _portsSelected = true;
      _dateSelected = true;
    });
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
      _portsSelected =
          _fromController.text.isNotEmpty && _toController.text.isNotEmpty;
      _dateSelected = _portsSelected;
      _timeSelected = _dateSelected && _selectedTimeString != null;
      _serviceTypeEnabled = _timeSelected;
      _passengerTypeEnabled = _serviceTypeEnabled;
    });
  }

  void _updateAvailableTime() {
    final availableTimes = TimeUtils.getAvailableTimesForDate(
      _selectedDate,
      _selectedServiceType,
    );

    final now = DateTime.now();
    if (_selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day) {
      _selectedTimeString = TimeUtils.findNearestFutureTime(availableTimes);
    } else {
      _selectedTimeString =
          availableTimes.isNotEmpty ? availableTimes.first : null;
    }
  }  Future<void> _searchSchedules() async {
    if (!_passengerTypeEnabled || _selectedTimeString == null) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih golongan'))
      );
      return;
    }

    setState(() => _isSearching = true);

    try {
      // Membuat Map passengerCounts yang benar
      final Map<PassengerType, int> passengerCounts = {
        PassengerType.adult: _passengerCounts[PassengerType.adult] ?? 0,
        PassengerType.child: _passengerCounts[PassengerType.child] ?? 0,
        PassengerType.elderly: _passengerCounts[PassengerType.elderly] ?? 0,
      };

      // Get vehicle info for the selected category
      final vehicleInfo = VehicleInfo.categories[_selectedCategory]!;
      
      // Calculate price based on vehicle category and service type
      double basePrice = _selectedServiceType == 'Regular' ? 
          vehicleInfo.basePrice : 
          vehicleInfo.basePrice * 1.5;
          
      if (_selectedCategory == VehicleCategory.none) {      // For pedestrians, calculate total price based on passenger counts
        basePrice = (passengerCounts[PassengerType.adult] ?? 0) * basePrice +
                   (passengerCounts[PassengerType.child] ?? 0) * (basePrice * 2/3);
      }

      final ticket = Ticket(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        routeName: "${_fromController.text} - ${_toController.text}",
        departurePort: _fromController.text,
        arrivalPort: _toController.text,
        departureTime: DateTime.parse(
          "${DateFormat('yyyy-MM-dd').format(_selectedDate)} ${_selectedTimeString!}:00",
        ),
        price: basePrice,
        shipName: _selectedServiceType == 'Regular' ? "KMP Gajah Mada" : "KMP Jatra III",
        ticketClass: _selectedServiceType,
        status: "Aktif",
        passengerCounts: passengerCounts,
        vehicleCategory: _selectedCategory,
      );

      if (!mounted) return;

      // Tampilkan popup konfirmasi tiket
      showDialog(
        context: context,
        builder: (context) => TicketPopup(
          ticket: ticket,
          onContinue: () {
            Navigator.pop(context); // Tutup dialog
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormDataScreen(ticket: ticket),
              ),
            );
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e'))
      );
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Widget _buildLocationInfo() {
    if (_currentPosition != null) {
      return Text(
        'Lokasi: ${_isNearMerak ? 'Dekat Merak' : 'Dekat Bakauheni'}',
        style: TextStyle(fontSize: 12),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      controller: _scrollController,
      children: [
        if (_currentPosition != null) WeatherCard(isNearMerak: _isNearMerak),
        const SizedBox(height: 16),
        // ...rest of your existing content...
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: sapphire,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FeryGogo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _isNearMerak ? 'Pelabuhan Merak' : 'Pelabuhan Bakauheni',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.white),
            onPressed: _getCurrentLocation,
            tooltip: 'Perbarui Lokasi',
          ),
        ],
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [                      Column(
                        children: [
                          WeatherCard(isNearMerak: _isNearMerak),
                          const SizedBox(height: 8),
                          _buildLocationInfo(), // Menampilkan info lokasi
                        ],
                      ),
                      const TripTypeSelector(),
                      Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PortSelector(
                                fromController: _fromController,
                                toController: _toController,
                                onSwapPorts: _swapPorts,
                              ),
                              const SizedBox(height: 16),                              PassengerSelector(
                                passengerCounts: _passengerCounts,
                                onCountChanged: (type, count) {
                                  setState(() {
                                    _passengerCounts[type] = count;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              ServiceSelector(
                                serviceTypes: _serviceTypes,
                                selectedServiceType: _selectedServiceType,
                                onServiceTypeChanged: (value) {
                                  setState(() {
                                    _selectedServiceType = value!;
                                    _updateAvailableTime();
                                    _updateFormState();
                                  });
                                },
                                enabled: _serviceTypeEnabled,
                              ),
                              const SizedBox(height: 16),
                              VehicleCategorySelector(
                                selectedCategory: _selectedCategory,
                                onCategoryChanged: (category) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                                serviceType: _selectedServiceType,
                              ),
                              const SizedBox(height: 16),
                              DateTimeSelector(
                                selectedDate: _selectedDate,
                                selectedTimeString: _selectedTimeString,
                                availableTimes:
                                    TimeUtils.getAvailableTimesForDate(
                                      _selectedDate,
                                      _selectedServiceType,
                                    ),
                                onDateChanged: (date) {
                                  setState(() {
                                    _selectedDate = date;
                                    _updateAvailableTime();
                                    _updateFormState();
                                  });
                                },
                                onTimeChanged: (value) {
                                  setState(() {
                                    _selectedTimeString = value;
                                    _updateFormState();
                                  });
                                },
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _passengerTypeEnabled &&
                                              _selectedTimeString != null &&
                                              !_isSearching &&
                                              _totalPassengers > 0
                                          ? _searchSchedules
                                          : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: sapphire,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    disabledBackgroundColor:
                                        Colors.grey.shade300,
                                  ),
                                  child:
                                      _isSearching
                                          ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<
                                                    Color
                                                  >(Colors.white),
                                            ),
                                          )
                                          : const Text(
                                            'Lanjutkan Pembayaran',
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
