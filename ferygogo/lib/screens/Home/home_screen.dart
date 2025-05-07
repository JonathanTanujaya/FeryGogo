import 'package:ferry_ticket_app/screens/tiket/ticket_popUp.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:ferry_ticket_app/providers/schedule_provider.dart';
import 'package:ferry_ticket_app/providers/weather_provider.dart';
import 'package:ferry_ticket_app/providers/profile_provider.dart';
import 'package:ferry_ticket_app/screens/payment_detail_screen.dart';
import 'package:ferry_ticket_app/screens/profile_screen.dart';
import 'package:ferry_ticket_app/models/ticket.dart';
import 'package:ferry_ticket_app/models/passenger.dart';

import 'components/weather_card.dart';
import 'components/trip_type_selector.dart';
import 'components/passenger_selector.dart';
import 'components/port_selector.dart';
import 'components/service_selector.dart';
import 'components/date_time_selector.dart';
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
  bool _isInitialized = false;
  bool _isSearching = false;

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

  // Simulated current location - in reality this would come from GPS
  final bool _isNearMerak = true;

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
    _fromController.text = _isNearMerak ? port1 : port2;
    _toController.text = _isNearMerak ? port2 : port1;
    _updateAvailableTime();
    _fromController.addListener(_updateFormState);
    _toController.addListener(_updateFormState);

    // Initialize weather data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWeather();
    });
  }

  Future<void> _initializeWeather() async {
    final weatherProvider = context.read<WeatherProvider>();
    await weatherProvider.fetchWeatherFromApi();
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
  }

  Future<void> _searchSchedules() async {
    if (!_passengerTypeEnabled || _selectedTimeString == null) return;

    setState(() => _isSearching = true);

    try {
      final ticket = Ticket(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        routeName: "${_fromController.text} - ${_toController.text}",
        departurePort: _fromController.text,
        arrivalPort: _toController.text,
        departureTime: DateTime.parse(
          "${DateFormat('yyyy-MM-dd').format(_selectedDate)} ${_selectedTimeString!}:00",
        ),
        price: _selectedServiceType == 'Regular' ? 150000 : 200000,
        shipName:
            _selectedServiceType == 'Regular'
                ? "KMP Gajah Mada"
                : "KMP Jatra III",
        ticketClass: _selectedServiceType,
        status: "Aktif",
        passengerCounts: Map.from(_passengerCounts),
      );

      if (!mounted) return;

      // Tampilkan popup terlebih dahulu
      showDialog(
        context: context,
        builder: (context) => TicketPopup(
          ticket: ticket,
          onContinue: () {
            Navigator.pop(context); // Tutup dialog
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentDetailScreen(ticket: ticket),
              ),
            );
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Widget _buildProfileAvatar(ProfileProvider profileProvider) {
    final profile = profileProvider.userProfile;

    if (profile?.profilePicture != null && profile!.profilePicture.isNotEmpty) {
      // Jika ada foto profil, tampilkan foto
      return CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(profile.profilePicture),
      );
    } else if (profile?.imageBase64 != null &&
        profile!.imageBase64!.isNotEmpty) {
      // Jika ada foto dalam format base64, gunakan itu
      return CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: MemoryImage(
          Base64Decoder().convert(profile.imageBase64!),
        ),
      );
    } else if (profile?.name != null && profile!.name.isNotEmpty) {
      // Jika tidak ada foto tapi ada nama, tampilkan inisial
      final initials =
          profile.name
              .split(' ')
              .take(2)
              .map((e) => e[0])
              .join('')
              .toUpperCase();
      return CircleAvatar(
        backgroundColor: Colors.white,
        child: Text(
          initials,
          style: const TextStyle(color: sapphire, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      // Default avatar jika tidak ada foto dan nama
      return const CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.person, color: sapphire),
      );
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
            gradient: LinearGradient(colors: [sapphire, skyBlue]),
          ),
        ),
        actions: [
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: _buildProfileAvatar(profileProvider),
                ),
              );
            },
          ),
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
                        WeatherCard(weatherProvider: weatherProvider),
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
                                const SizedBox(height: 16),
                                PassengerSelector(
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}
