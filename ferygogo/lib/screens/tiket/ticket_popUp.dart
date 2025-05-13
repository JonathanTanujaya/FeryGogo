import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/ticket.dart';
import '../../models/passenger.dart';
import '../../models/vehicle_category.dart';

class TicketPopup extends StatelessWidget {
  final VoidCallback onContinue;
  final Ticket ticket;

  const TicketPopup({
    Key? key, 
    required this.onContinue,
    required this.ticket,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vehicleInfo = ticket.vehicleCategory != null ? 
        VehicleInfo.categories[ticket.vehicleCategory] : null;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Informasi Tiket",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ticketRow("Pelabuhan Keberangkatan", ticket.departurePort),
                  const SizedBox(height: 12),
                  _ticketRow("Pelabuhan Tujuan", ticket.arrivalPort),
                  const SizedBox(height: 12),
                  _ticketRow(
                    "Jadwal Masuk Pelabuhan",
                    DateFormat('dd MMM yyyy, HH:mm').format(ticket.departureTime),
                  ),
                  const SizedBox(height: 12),                  _ticketRow("Layanan", ticket.ticketClass),
                  const SizedBox(height: 12),
                  _ticketRow("Jenis Tiket", vehicleInfo?.name ?? 'Tidak diketahui'),
                  const SizedBox(height: 12),
                  _ticketRow(
                    "Harga Tiket",
                    NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(ticket.price),
                  ),
                  const SizedBox(height: 8),
                  if ((ticket.passengerCounts[PassengerType.adult] ?? 0) > 0)
                    _ticketRow(
                      "Dewasa x${ticket.passengerCounts[PassengerType.adult]}",
                      "Termasuk",
                    ),
                  if ((ticket.passengerCounts[PassengerType.child] ?? 0) > 0)
                    _ticketRow(
                      "Anak x${ticket.passengerCounts[PassengerType.child]}",
                      "Termasuk",
                    ),
                  if ((ticket.passengerCounts[PassengerType.elderly] ?? 0) > 0)
                    _ticketRow(
                      "Lansia x${ticket.passengerCounts[PassengerType.elderly]}",
                      "Termasuk",
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("KEMBALI"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F52BA),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("LANJUTKAN"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _ticketRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: const TextStyle(fontSize: 14))),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
