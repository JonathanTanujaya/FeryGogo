import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ticket.dart';
import '../models/passenger.dart';
import '../models/vehicle_category.dart';

class HistoryDetailScreen extends StatefulWidget {
  final String ticketId;

  const HistoryDetailScreen({Key? key, required this.ticketId}) : super(key: key);

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  bool _isLoading = true;
  String? _error;
  Ticket? _ticket;

  @override
  void initState() {
    super.initState();
    _loadTicketDetails();
  }

  Future<void> _loadTicketDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final docRef = FirebaseFirestore.instance.collection('tiket').doc(widget.ticketId);
      final doc = await docRef.get();

      if (!doc.exists) {
        setState(() {
          _error = 'Tiket tidak ditemukan';
          _isLoading = false;
        });
        return;
      }

      final data = doc.data()!;
      
      // Parse passenger data
      List<Passenger> passengers = [];
      if (data['passengers'] != null) {
        final passengerList = data['passengers'] as List;
        passengers = passengerList.map((p) {
          return Passenger(
            name: p['name'] ?? '',
            idNumber: p['idNumber'] ?? '',
            type: _parsePassengerType(p['type']),
            birthDate: p['birthDate'] != null ? DateTime.parse(p['birthDate']) : null,
          );
        }).toList();
      }
      
      // Parse passenger counts
      Map<PassengerType, int> passengerCounts = {};
      if (data['passengerCounts'] != null) {
        final countsMap = data['passengerCounts'] as Map<String, dynamic>;
        countsMap.forEach((key, value) {
          passengerCounts[_parsePassengerType(key)] = value as int;
        });
      }
      
      // Parse vehicle category
      VehicleCategory? vehicleCategory;
      if (data['vehicleCategory'] != null) {
        final categoryStr = data['vehicleCategory'] as String;
        vehicleCategory = VehicleCategory.values.firstWhere(
          (e) => e.toString() == categoryStr,
          orElse: () => VehicleCategory.none,
        );
      }

      // Create ticket object
      _ticket = Ticket(
        id: data['id'],
        routeName: data['routeName'],
        departurePort: data['departurePort'],
        arrivalPort: data['arrivalPort'],
        departureTime: DateTime.parse(data['departureTime']),
        price: (data['price'] as num).toDouble(),
        shipName: data['shipName'],
        ticketClass: data['ticketClass'],
        status: data['status'],
        passengerCounts: passengerCounts,
        passengers: passengers,
        bookerName: data['bookerName'] ?? '',
        bookerPhone: data['bookerPhone'] ?? '',
        bookerEmail: data['bookerEmail'] ?? '',
        vehicleCategory: vehicleCategory,
        vehiclePlateNumber: data['vehiclePlateNumber'],
      );
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  PassengerType _parsePassengerType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'adult':
        return PassengerType.adult;
      case 'child':
        return PassengerType.child;
      case 'elderly':
        return PassengerType.elderly;
      default:
        return PassengerType.adult;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Riwayat'),
        backgroundColor: const Color(0xFF0F52BA),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTicketDetails,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_ticket == null) {
      return const Center(child: Text('Data tidak ditemukan'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTicketSummary(),
          _buildTicketDetails(),
          _buildPassengerList(),
          if (_ticket!.vehicleCategory != null && _ticket!.vehicleCategory != VehicleCategory.none)
            _buildVehicleInfo(),
          _buildBookerInfo(),
        ],
      ),
    );
  }

  Widget _buildTicketSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F52BA),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_boat, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _ticket!.routeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _ticket!.shipName ?? 'Tidak ada kapal aktif',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Waktu Keberangkatan',
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(_ticket!.departureTime),
                style: const TextStyle(color: Colors.white),
              ),
            ],
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('Pelabuhan Keberangkatan', _ticket!.departurePort),
                  _buildDetailRow('Pelabuhan Tujuan', _ticket!.arrivalPort),
                  _buildDetailRow('Nama Kapal', (_ticket!.shipName == null || _ticket!.shipName!.trim().isEmpty) ? 'Tidak ada kapal aktif' : _ticket!.shipName!),
                  _buildDetailRow(
                    'Waktu Keberangkatan',
                    DateFormat('dd MMMM yyyy, HH:mm').format(_ticket!.departureTime),
                  ),
                  _buildDetailRow('Kelas', _ticket!.ticketClass),
                  _buildDetailRow('Status', _ticket!.status),
                  const Divider(height: 24),
                  _buildDetailRow(
                    'Total Harga',
                    NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(_ticket!.price),
                  ),
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
            itemCount: _ticket!.passengers.length,
            itemBuilder: (context, index) {
              final passenger = _ticket!.passengers[index];
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
  
  Widget _buildVehicleInfo() {
    if (_ticket!.vehicleCategory == null || _ticket!.vehicleCategory == VehicleCategory.none) {
      return const SizedBox.shrink();
    }

    final vehicleInfo = VehicleInfo.categories[_ticket!.vehicleCategory]!;
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
                  if (_ticket!.vehiclePlateNumber != null)
                    _buildDetailRow('Nomor Plat', _ticket!.vehiclePlateNumber!),
                ],
              ),
            ),
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
                  _buildDetailRow('Nama', _ticket!.bookerName),
                  _buildDetailRow('Telepon', _ticket!.bookerPhone),
                  _buildDetailRow('Email', _ticket!.bookerEmail),
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
