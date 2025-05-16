import 'package:flutter/material.dart';

const Color sapphire = Color(0xFF0F52BA);
const Color blackInDarkMode = Colors.white;

class PortSelector extends StatelessWidget {
  final TextEditingController fromController;
  final TextEditingController toController;
  final VoidCallback onSwapPorts;
  final bool enabled;

  const PortSelector({
    Key? key,
    required this.fromController,
    required this.toController,
    required this.onSwapPorts,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [              Text('Pelabuhan Awal',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[600],
                  )),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white10
                    : const Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: fromController,
                  readOnly: true,
                  enabled: enabled,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: IconButton(
            onPressed: enabled ? onSwapPorts : null,
            icon: Container(
              padding: const EdgeInsets.all(8),              decoration: BoxDecoration(
                color: enabled 
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? sapphire.withOpacity(0.8)
                      : sapphire)
                  : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.swap_horiz,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [              Text('Pelabuhan Tujuan',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                  )),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white10
                    : const Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: toController,
                  readOnly: true,
                  enabled: enabled,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}