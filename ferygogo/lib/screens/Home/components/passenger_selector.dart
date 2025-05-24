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
            color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white10 
                    : const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildPassengerTypeRow(
                context,
                'Dewasa (17-60 tahun)',
                PassengerType.adult,
                minValue: 1,
              ),
              const Divider(height: 1),
              _buildPassengerTypeRow(
                context,
                'Anak (<17 tahun)',
                PassengerType.child,
              ),
              const Divider(height: 1),
              _buildPassengerTypeRow(
                context,
                'Lansia (>60 tahun)',
                PassengerType.elderly,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerTypeRow(BuildContext context, String label, PassengerType type, {int minValue = 0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: passengerCounts[type]! > minValue
                    ? () => onCountChanged(type, passengerCounts[type]! - 1)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: passengerCounts[type]! > minValue ? sapphire : Colors.grey,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                padding: EdgeInsets.zero,
              ),
              Container(
                width: 30,
                alignment: Alignment.center,
                child: Text(
                  passengerCounts[type].toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onCountChanged(type, passengerCounts[type]! + 1),
                icon: const Icon(Icons.add_circle_outline),
                color: sapphire,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }
}