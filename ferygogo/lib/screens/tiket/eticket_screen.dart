import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../../models/ticket.dart';
import '../../models/passenger.dart';
import '../../models/vehicle_category.dart';

class ETicketScreen extends StatelessWidget {
  final Ticket ticket;

  const ETicketScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to home when back button is pressed
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('E-Tiket'),
          backgroundColor: const Color(0xFF0F52BA),
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false, // Remove back button
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildTicketHeader(),
              _buildQRCode(),
              _buildTicketDetails(),
              if (ticket.vehicleCategory != null && 
                  ticket.vehicleCategory != VehicleCategory.none)
                _buildVehicleInfo(),
              _buildPassengerList(),
              _buildBookerInfo(),
            ],
          ),
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
          _buildDetailRow(
            'Total Harga',
            NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(ticket.price * ticket.passengers.length),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfo() {
    if (ticket.vehicleCategory == null || ticket.vehicleCategory == VehicleCategory.none) {
      return const SizedBox.shrink();
    }

    final vehicleInfo = VehicleInfo.categories[ticket.vehicleCategory]!;
    return Container(
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('Kategori', vehicleInfo.name),
                  _buildDetailRow('Keterangan', vehicleInfo.description),
                  _buildDetailRow('Contoh', vehicleInfo.example),
                  if (ticket.vehiclePlateNumber != null)
                    _buildDetailRow('Nomor Plat', ticket.vehiclePlateNumber!),
                ],
              ),
            ),
          ),
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
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF0F52BA).withOpacity(0.1),
                    child: Text(
                      passenger.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF0F52BA),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(passenger.name),
                  subtitle: Text(_getPassengerTypeLabel(passenger.type)),
                  trailing: Text(
                    isChild && passenger.birthDate != null
                        ? DateFormat('dd/MM/yyyy').format(passenger.birthDate!)
                        : passenger.idNumber,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookerInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Pemesan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('Nama', ticket.bookerName),
                  _buildDetailRow('Telepon', ticket.bookerPhone),
                  _buildDetailRow('Email', ticket.bookerEmail),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPassengerTypeLabel(PassengerType type) {
    return switch (type) {
      PassengerType.child => 'Anak',
      PassengerType.adult => 'Dewasa',
      PassengerType.elderly => 'Lansia',
    };
  }
}