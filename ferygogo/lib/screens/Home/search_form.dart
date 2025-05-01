import 'package:flutter/material.dart';

const Color sapphire = Color(0xFF0F52BA);

class SearchForm extends StatefulWidget {
  const SearchForm({super.key});

  @override
  State<SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<SearchForm> with AutomaticKeepAliveClientMixin {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final String port1 = 'Merak';
  final String port2 = 'Bakauheni';
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeString;
  String _selectedServiceType = 'Regular';
  String _selectedPassengerType = 'Penumpang Jalan';
  bool _formValid = false;

  // Lists for dropdowns
  final List<String> _serviceTypes = ['Regular', 'Express'];
  final List<String> _passengerTypes = [
    'Penumpang Jalan',
    'Kendaraan Pribadi',
    'Kendaraan Kargo',
    'Bus',
    'Truk',
  ];

  // Time slots
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

  @override
  void initState() {
    super.initState();
    // Set default ports based on location (simulated)
    _fromController.text = port1;
    _toController.text = port2;
    _updateAvailableTime();
    _validateForm();

    // Add listeners
    _fromController.addListener(_validateForm);
    _toController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _fromController.removeListener(_validateForm);
    _toController.removeListener(_validateForm);
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _formValid = _fromController.text.isNotEmpty &&
          _toController.text.isNotEmpty &&
          _selectedTimeString != null;
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

  void _updateAvailableTime() {
    final availableTimes = _getAvailableTimesForDate(_selectedDate);
    if (availableTimes.isNotEmpty) {
      setState(() {
        _selectedTimeString = availableTimes.first;
        _validateForm();
      });
    }
  }

  void _swapPorts() {
    final temp = _fromController.text;
    setState(() {
      _fromController.text = _toController.text;
      _toController.text = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final availableTimes = _getAvailableTimesForDate(_selectedDate);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPortSelection(),
            const SizedBox(height: 16),
            _buildServiceTypeDropdown(),
            const SizedBox(height: 16),
            _buildPassengerTypeDropdown(),
            const SizedBox(height: 16),
            _buildDateTimeSelection(availableTimes),
            const SizedBox(height: 16),
            _buildSearchButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPortSelection() {
    return Row(
      children: [
        Expanded(
          child: _buildPortField(
            label: 'Pelabuhan Awal',
            controller: _fromController,
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
          child: _buildPortField(
            label: 'Pelabuhan Tujuan',
            controller: _toController,
          ),
        ),
      ],
    );
  }

  Widget _buildPortField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        TextFormField(
          controller: controller,
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
    );
  }

  Widget _buildServiceTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildPassengerTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jenis Penumpang', style: TextStyle(color: Colors.grey)),
        DropdownButtonFormField<String>(
          value: _selectedPassengerType,
          items: _passengerTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: _formValid ? (value) {
            setState(() {
              _selectedPassengerType = value!;
            });
          } : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: _formValid ? const Color(0xFFF7F9FC) : Colors.grey.shade200,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelection(List<String> availableTimes) {
    return Row(
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
                      Text(_selectedDate.toString().split(' ')[0]),
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
                    items: availableTimes.map((time) => DropdownMenuItem(
                      value: time,
                      child: Text(time),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTimeString = value;
                        _validateForm();
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _formValid ? () {
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}