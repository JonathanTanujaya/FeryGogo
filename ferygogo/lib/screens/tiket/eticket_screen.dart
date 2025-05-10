import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../../models/ticket.dart';
import '../../models/passenger.dart';

class ETicketScreen extends StatelessWidget {
  final Ticket ticket;

  const ETicketScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Tiket'),
        backgroundColor: const Color(0xFF0F52BA),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTicketHeader(),
            _buildQRCode(),
            _buildTicketDetails(),
            _buildPassengerList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketHeader() {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.routeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ticket.shipName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQRCode() {
    final qrData = jsonEncode(ticket.toJson());
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kode Booking: ${ticket.id}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Perjalanan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Pelabuhan Keberangkatan', ticket.departurePort),
          _buildDetailRow('Pelabuhan Tujuan', ticket.arrivalPort),
          _buildDetailRow(
            'Waktu Keberangkatan',
            DateFormat('dd MMMM yyyy, HH:mm').format(ticket.departureTime),
          ),
          _buildDetailRow('Kelas', ticket.ticketClass),
          _buildDetailRow('Status', ticket.status),
        ],
      ),
    );
  }

  Widget _buildPassengerList() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar Penumpang',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ticket.passengers.length,
            itemBuilder: (context, index) {
              final passenger = ticket.passengers[index];
              final isChild = passenger.type == PassengerType.child;
              
              String subtitle;
              if (isChild && passenger.birthDate != null) {
                subtitle = 'Tanggal Lahir: ${DateFormat('dd/MM/yyyy').format(passenger.birthDate!)}';
              } else {
                subtitle = 'ID: ${passenger.idNumber}';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(passenger.name),
                  subtitle: Text(subtitle),
                  trailing: Text(
                    _getPassengerTypeLabel(passenger.type),
                    style: TextStyle(
                      color: isChild ? Colors.blue : Colors.grey[600],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}