import 'package:flutter/material.dart';
import 'package:ferry_ticket_app/models/passenger.dart';

const Color sapphire = Color(0xFF0F52BA);

class PassengerSelector extends StatelessWidget {
  final Map<PassengerType, int> passengerCounts;
  final Function(PassengerType, int) onCountChanged;

  const PassengerSelector({
    Key? key,
    required this.passengerCounts,
    required this.onCountChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jumlah Penumpang', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildPassengerTypeRow(
                'Dewasa (17-60 tahun)',
                PassengerType.adult,
                minValue: 1,
              ),
              const Divider(height: 1),
              _buildPassengerTypeRow(
                'Anak (<17 tahun)',
                PassengerType.child,
              ),
              const Divider(height: 1),
              _buildPassengerTypeRow(
                'Lansia (>60 tahun)',
                PassengerType.elderly,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerTypeRow(String label, PassengerType type, {int minValue = 0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              IconButton(
                onPressed: passengerCounts[type]! > minValue
                    ? () => onCountChanged(type, passengerCounts[type]! - 1)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: passengerCounts[type]! > minValue ? sapphire : Colors.grey,
              ),
              Text(
                passengerCounts[type].toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => onCountChanged(type, passengerCounts[type]! + 1),
                icon: const Icon(Icons.add_circle_outline),
                color: sapphire,
              ),
            ],
          ),
        ],
      ),
    );
  }
}