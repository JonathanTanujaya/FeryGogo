import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/passenger.dart';
import '../models/ticket.dart';
import '../providers/booking_provider.dart';
import 'tiket/eticket_screen.dart';

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

  Future<void> _processPayment() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isProcessing = true);

      try {
        // Simulate payment processing
        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;
        
        // Create new booking
        final bookingProvider = context.read<BookingProvider>();
        final success = await bookingProvider.createBooking(
          routeName: widget.ticket.routeName,
          date: DateFormat('dd MMM yyyy').format(widget.ticket.departureTime),
          quantity: widget.ticket.passengerCounts.values.fold(0, (sum, count) => sum + count),
          totalPrice: widget.ticket.price * widget.ticket.passengerCounts.values.fold(0, (sum, count) => sum + count),
          departureTime: DateFormat('HH:mm').format(widget.ticket.departureTime),
          arrivalTime: DateFormat('HH:mm').format(widget.ticket.departureTime.add(const Duration(hours: 2))),
          routeType: widget.ticket.ticketClass.toLowerCase(),
        );

        if (success) {
          // Mark booking as complete immediately since payment was successful
          final bookingId = bookingProvider.bookings.first.id; // Get the ID of the booking we just created
          await bookingProvider.completeBooking(bookingId);

          // Create passenger list from forms
          final passengers = _passengerForms.map((form) => Passenger(
            name: form.nameController.text,
            idNumber: form.idNumberController.text,
            phoneNumber: form.phoneController.text,
            email: form.emailController.text,
            type: form.type,
            birthDate: form.birthDate,
          )).toList();

          final updatedTicket = Ticket(
            id: widget.ticket.id,
            routeName: widget.ticket.routeName,
            departurePort: widget.ticket.departurePort,
            arrivalPort: widget.ticket.arrivalPort,
            departureTime: widget.ticket.departureTime,
            price: widget.ticket.price,
            shipName: widget.ticket.shipName,
            ticketClass: widget.ticket.ticketClass,
            status: "Selesai",
            passengerCounts: widget.ticket.passengerCounts,
            passengers: passengers,
          );

          // Navigate to e-ticket screen
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ETicketScreen(ticket: updatedTicket),
            ),
          );
        }
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