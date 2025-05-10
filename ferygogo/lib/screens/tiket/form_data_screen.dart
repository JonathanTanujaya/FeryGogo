import 'package:flutter/material.dart';
import '../../models/ticket.dart';
import '../../models/passenger.dart';
import 'payment_detail_screen.dart';

class FormDataScreen extends StatefulWidget {
  final Ticket ticket;

  const FormDataScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  State<FormDataScreen> createState() => _FormDataScreenState();
}

class _FormDataScreenState extends State<FormDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<PassengerFormData> _passengers = [];

  @override
  void initState() {
    super.initState();
    _initializePassengerForms();
  }  void _initializePassengerForms() {
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
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _passengers.length,
          itemBuilder: (context, index) {
            return _buildPassengerForm(index);
          },
        ),
      ),      bottomNavigationBar: Padding(
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
            if (index == 0) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: passenger.phoneController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passenger.emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!value.contains('@')) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
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
  }  String _getPassengerTypeLabel(PassengerType type) {
    return switch (type) {
      PassengerType.child => 'Anak',
      PassengerType.adult => 'Dewasa',
      PassengerType.elderly => 'Lansia',
    };
  }

  void _submitForm() {
    // Debug print untuk membantu troubleshooting
    print('Starting form submission...');
    print('Number of passengers: ${_passengers.length}');

    if (_formKey.currentState?.validate() ?? false) {
      try {
        final passengers = <Passenger>[];
        
        // Iterate through each passenger form
        for (var form in _passengers) {
          print('Processing passenger type: ${form.type}');
          
          // Create passenger object based on type
          final passenger = Passenger(
            name: form.nameController.text,
            idNumber: form.idNumberController.text,
            phoneNumber: form.type == PassengerType.adult ? form.phoneController.text : '',
            email: form.type == PassengerType.adult ? form.emailController.text : '',
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

        print('Created ${passengers.length} passenger objects successfully');

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

        final updatedTicket = Ticket(
          id: widget.ticket.id,
          routeName: widget.ticket.routeName,
          departurePort: widget.ticket.departurePort,
          arrivalPort: widget.ticket.arrivalPort,
          departureTime: widget.ticket.departureTime,
          price: widget.ticket.price,
          shipName: widget.ticket.shipName,
          ticketClass: widget.ticket.ticketClass,
          status: widget.ticket.status,
          passengerCounts: actualCounts,
          passengers: passengers,
        );

        // Navigasi ke halaman pembayaran
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
