import 'package:ferry_ticket_app/screens/tiket/payment_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/ticket.dart';
import '../../models/passenger.dart';
import '../../models/vehicle_category.dart';
import '../../providers/profile_provider.dart';
import 'payment_detail_screen.dart';

class FormDataScreen extends StatefulWidget {
  final Ticket ticket;

  const FormDataScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  State<FormDataScreen> createState() => _FormDataScreenState();
}

class _FormDataScreenState extends State<FormDataScreen> {  final _formKey = GlobalKey<FormState>();
  final List<PassengerFormData> _passengers = [];
  final plateNumberController = TextEditingController();
  VehicleCategory selectedVehicle = VehicleCategory.none;
  bool _useProfileDataForFirstPassenger = false;
  

  @override
  void initState() {
    super.initState();
    _initializePassengerForms();
    _initializeBookerInfo();
  }
  @override
  void dispose() {
    plateNumberController.dispose();
    for (var passenger in _passengers) {
      passenger.dispose();
    }
    super.dispose();
  }

  void _initializePassengerForms() {
    print('Initializing passenger forms...');
    print('Passenger counts: ${widget.ticket.passengerCounts}');
    
    for (var entry in widget.ticket.passengerCounts.entries) {
      var type = entry.key;
      var count = entry.value;
      print('Processing type: $type, count: $count');
      
      for (var i = 0; i < count; i++) {
        _passengers.add(PassengerFormData(type: type));
        print('Added passenger form for type: $type');
      }
    }
  }

  void _initializeBookerInfo() {
    final profile = context.read<ProfileProvider>().userProfile;
    if (profile != null) {
      setState(() {
        if (_passengers.isNotEmpty && _passengers[0].type == PassengerType.adult) {
          _useProfileDataForFirstPassenger = false;
        }
      });
    }
  }

  void _updateFirstPassengerFromProfile(bool useProfile) {
    final profile = context.read<ProfileProvider>().userProfile;
    if (profile != null && _passengers.isNotEmpty && _passengers[0].type == PassengerType.adult) {
      setState(() {
        if (useProfile) {
          _passengers[0].nameController.text = profile.name;
          _passengers[0].idNumberController.text = profile.identityNumber;
        } else {
          _passengers[0].nameController.text = '';
          _passengers[0].idNumberController.text = '';
        }
        _useProfileDataForFirstPassenger = useProfile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Penumpang'),
        backgroundColor: const Color(0xFF0F52BA),
        foregroundColor: Colors.white,
      ),      
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Data Penumpang',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._passengers.asMap().entries.map((entry) {
              return _buildPassengerForm(entry.key);
            }),
            if (widget.ticket.vehicleCategory != VehicleCategory.none) ...[
              const SizedBox(height: 24),
              _buildVehicleInfoSection(),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F52BA),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Lanjutkan ke Pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleInfoSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Kendaraan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: plateNumberController,
              decoration: const InputDecoration(
                labelText: 'Plat Nomor Kendaraan',
                hintText: 'Contoh: B 1234 XYZ',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Plat nomor kendaraan wajib diisi';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerForm(int index) {
    final passenger = _passengers[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Penumpang ${index + 1} - ${_getPassengerTypeLabel(passenger.type)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passenger.nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (passenger.type == PassengerType.child) ...[
              _buildBirthDateField(passenger),
            ] else ...[
              TextFormField(
                controller: passenger.idNumberController,
                decoration: const InputDecoration(
                  labelText: 'Nomor KTP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor KTP tidak boleh kosong';
                  }
                  if (value.length != 16) {
                    return 'Nomor KTP harus 16 digit';
                  }
                  return null;
                },
              ),
            ],
            if (index == 0 && passenger.type == PassengerType.adult) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Gunakan data profil', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Switch(
                    value: _useProfileDataForFirstPassenger,
                    onChanged: _updateFirstPassengerFromProfile,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBirthDateField(PassengerFormData passenger) {
    return TextFormField(
      controller: passenger.idNumberController,
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
          firstDate: DateTime.now().subtract(const Duration(days: 365 * 17)),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() {
            passenger.idNumberController.text = 
                '${date.day.toString().padLeft(2, '0')}${date.month.toString().padLeft(2, '0')}${date.year}';
            passenger.birthDate = date;
          });
        }
      },
      decoration: const InputDecoration(
        labelText: 'Tanggal Lahir',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Tanggal lahir tidak boleh kosong';
        }
        return null;
      },
    );
  }

  String _getPassengerTypeLabel(PassengerType type) {
    return switch (type) {
      PassengerType.child => 'Anak',
      PassengerType.adult => 'Dewasa',
      PassengerType.elderly => 'Lansia',
    };
  }
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final passengers = <Passenger>[];
        final profile = context.read<ProfileProvider>().userProfile;
        
        // Iterate through each passenger form
        for (var form in _passengers) {          
          // Create passenger object based on type
          final passenger = Passenger(
            name: form.nameController.text,
            idNumber: form.idNumberController.text,
            type: form.type,
            birthDate: form.birthDate,
          );
          
          passengers.add(passenger);
        }

        if (passengers.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data penumpang tidak boleh kosong')),
          );
          return;
        }

        // Buat Map passengerCounts yang baru berdasarkan data aktual
        final Map<PassengerType, int> actualCounts = {
          PassengerType.adult: 0,
          PassengerType.child: 0,
          PassengerType.elderly: 0,
        };

        // Hitung jumlah masing-masing tipe penumpang
        for (var passenger in passengers) {
          actualCounts[passenger.type] = (actualCounts[passenger.type] ?? 0) + 1;
        }

        // Calculate total price based on passenger count and vehicle category
        final basePrice = selectedVehicle != VehicleCategory.none
            ? VehicleInfo.categories[selectedVehicle]!.basePrice
            : VehicleInfo.categories[VehicleCategory.none]!.basePrice;

        final totalPassengers = passengers.length;
        final totalPrice = basePrice * totalPassengers;

        final updatedTicket = Ticket(
          id: widget.ticket.id,
          routeName: widget.ticket.routeName,
          departurePort: widget.ticket.departurePort,
          arrivalPort: widget.ticket.arrivalPort,
          departureTime: widget.ticket.departureTime,
          price: totalPrice,
          shipName: widget.ticket.shipName,
          ticketClass: widget.ticket.ticketClass,          status: widget.ticket.status,
          passengerCounts: actualCounts,
          passengers: passengers,
          bookerName: profile?.name ?? '',
          bookerPhone: profile?.phoneNumber ?? '',
          bookerEmail: profile?.email ?? '',
          vehicleCategory: selectedVehicle,
          vehiclePlateNumber: selectedVehicle != VehicleCategory.none ? plateNumberController.text : null,
        );

        // Navigate to payment screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentDetailScreen(ticket: updatedTicket),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }
}

class PassengerFormData {
  final PassengerType type;
  late final TextEditingController nameController;
  late final TextEditingController idNumberController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  DateTime? birthDate;

  PassengerFormData({required this.type}) {
    nameController = TextEditingController();
    idNumberController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
  }

  void dispose() {
    nameController.dispose();
    idNumberController.dispose();
    phoneController.dispose();
    emailController.dispose();
  }
}
