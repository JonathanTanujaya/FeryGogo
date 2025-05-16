import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeSelector extends StatelessWidget {
  final DateTime selectedDate;
  final String? selectedTimeString;
  final List<String> availableTimes;
  final Function(DateTime) onDateChanged;
  final Function(String?) onTimeChanged;
  final bool enabled;

  const DateTimeSelector({
    Key? key,
    required this.selectedDate,
    required this.selectedTimeString,
    required this.availableTimes,
    required this.onDateChanged,
    required this.onTimeChanged,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tanggal', style: TextStyle(color: Colors.grey)),
              InkWell(
                onTap: enabled ? () => _selectDate(context) : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white10
                      : (enabled ? const Color(0xFFF7F9FC) : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd MMM yyyy').format(selectedDate),
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : (enabled ? Colors.black87 : Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Waktu', style: TextStyle(color: Colors.grey)),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white10
                    : (enabled ? const Color(0xFFF7F9FC) : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedTimeString,
                    items: availableTimes.map((time) {
                      return DropdownMenuItem(
                        value: time,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : (enabled ? Colors.black87 : Colors.grey.shade600),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: enabled ? onTimeChanged : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      onDateChanged(date);
    }
  }
}