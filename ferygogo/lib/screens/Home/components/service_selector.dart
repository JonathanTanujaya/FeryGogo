import 'package:flutter/material.dart';

const Color sapphire = Color(0xFF0F52BA);
const Color blackInDarkMode = Colors.white;

class ServiceSelector extends StatelessWidget {
  final List<String> serviceTypes;
  final String selectedServiceType;
  final Function(String?) onServiceTypeChanged;
  final bool enabled;

  const ServiceSelector({
    Key? key,
    required this.serviceTypes,
    required this.selectedServiceType,
    required this.onServiceTypeChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jenis Layanan', style: TextStyle(color: Colors.grey)),
        Container(          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : (enabled ? const Color(0xFFF7F9FC) : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedServiceType,
            items: serviceTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: enabled ? onServiceTypeChanged : null,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : (enabled ? Colors.black87 : Colors.grey.shade600),
            ),
          ),
        ),
      ],
    );
  }
}