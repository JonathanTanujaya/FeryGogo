import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ticket.dart';
import '../models/passenger.dart';
import 'eticket_screen.dart';

class PaymentDetailScreen extends StatefulWidget {
  final Ticket ticket;

  const PaymentDetailScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<PassengerForm> _passengerForms = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeForms();
  }

  void _initializeForms() {
    widget.ticket.passengerCounts.forEach((key, count) {
      final type = PassengerType.values.firstWhere((t) => t.toString() == 'PassengerType.$key');
      for (int i = 0; i < count; i++) {
        _passengerForms.add(PassengerForm(type: type));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pembayaran'),
        backgroundColor: const Color(0xFF0F52BA),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTicketSummary(),
              _buildPassengerForms(),
              _buildPaymentSummary(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildTicketSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF0F52BA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_boat, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                widget.ticket.routeName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Waktu Keberangkatan',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(widget.ticket.departureTime),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerForms() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Penumpang',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _passengerForms.length,
            separatorBuilder: (context, index) => const Divider(height: 32),
            itemBuilder: (context, index) {
              return _buildPassengerFormFields(
                index + 1,
                _passengerForms[index],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerFormFields(int number, PassengerForm form) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Penumpang $number - ${_getPassengerTypeLabel(form.type)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: form.nameController,
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
        if (form.type == PassengerType.child) ...[
          _buildDateField(
            label: 'Tanggal Lahir',
            controller: form.idNumberController,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
                firstDate: DateTime.now().subtract(const Duration(days: 365 * 17)),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                form.idNumberController.text = DateFormat('ddMMyyyy').format(date);
                form.birthDate = date;
              }
            },
          ),
        ] else ...[
          TextFormField(
            controller: form.idNumberController,
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
        if (number == 1) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: form.phoneController,
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
            controller: form.emailController,
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
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Tanggal lahir tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildPaymentSummary() {
    final serviceFee = 2500.0 * _passengerForms.length;
    final totalAmount = (widget.ticket.price * _passengerForms.length) + serviceFee;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pembayaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Harga Tiket (${_passengerForms.length}x)'),
              Text(
                NumberFormat.currency(
                  locale: 'id',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(widget.ticket.price * _passengerForms.length),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Biaya Layanan (${_passengerForms.length}x)'),
              Text(
                NumberFormat.currency(
                  locale: 'id',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(serviceFee),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                NumberFormat.currency(
                  locale: 'id',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(totalAmount),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F52BA),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Bayar Sekarang'),
      ),
    );
  }

  String _getPassengerTypeLabel(PassengerType type) {
    switch (type) {
      case PassengerType.child:
        return 'Anak';
      case PassengerType.adult:
        return 'Dewasa';
      case PassengerType.elderly:
        return 'Lansia';
    }
  }

  Future<void> _processPayment() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isProcessing = true);

      try {
        // Simulate payment processing
        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;

        // Create passenger list from forms
        final passengers = _passengerForms.map((form) => Passenger(
          name: form.nameController.text,
          idNumber: form.idNumberController.text,
          phoneNumber: form.phoneController.text,
          email: form.emailController.text,
          type: form.type,
          birthDate: form.birthDate,
        )).toList();

        // Create updated ticket with passengers
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
          passengerCounts: widget.ticket.passengerCounts,
          passengers: passengers,
        );

        // Navigate to e-ticket screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ETicketScreen(ticket: updatedTicket),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isProcessing = false);
      }
    }
  }
}

class PassengerForm {
  final PassengerType type;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  DateTime? birthDate;

  PassengerForm({required this.type});

  void dispose() {
    nameController.dispose();
    idNumberController.dispose();
    phoneController.dispose();
    emailController.dispose();
  }
}