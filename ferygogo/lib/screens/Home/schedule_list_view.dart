import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/schedule_provider.dart';
import '../models/schedule.dart';

const Color sapphire = Color(0xFF0F52BA);
const Color regularColor = Color(0xFFD4E4F7);
const Color expressColor = Color(0xFFCBA135);

class ScheduleListView extends StatelessWidget {
  // Fixed item height for optimized scrolling
  static const double _itemExtent = 160.0;
  
  const ScheduleListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.schedules.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.schedules.isEmpty) {
          return const Center(
            child: Text('Tidak ada jadwal yang tersedia'),
          );
        }

        return ListView.builder(
          itemExtent: _itemExtent, // Optimize scroll performance
          itemCount: provider.schedules.length + (provider.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == provider.schedules.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return _ScheduleCard(
              key: ValueKey(provider.schedules[index].id), // Optimize rebuilds
              schedule: provider.schedules[index],
            );
          },
        );
      },
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final Schedule schedule;

  const _ScheduleCard({
    super.key,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    final departureTime = DateFormat('HH:mm').format(schedule.departureTime);
    final arrivalTime = DateFormat('HH:mm').format(schedule.arrivalTime);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  schedule.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _ServiceTypeChip(type: schedule.type),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(departureTime,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: CustomPaint(
                    painter: _DashedLinePainter(),
                    child: Container(height: 2),
                  ),
                ),
                Text(arrivalTime,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.directions_boat, color: sapphire),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: schedule.availability,
              backgroundColor: regularColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                schedule.availability > 0.8 ? Colors.red : sapphire,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rp${schedule.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: sapphire,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(schedule.availability * 100).toInt()}% Available',
                  style: TextStyle(
                    color: schedule.availability > 0.8 ? Colors.red : sapphire,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTypeChip extends StatelessWidget {
  final String type;

  const _ServiceTypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final isRegular = type.toLowerCase() == 'regular';
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isRegular ? regularColor : expressColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: isRegular ? sapphire : Colors.brown,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4E4F7)
      ..strokeWidth = 2;

    const dashWidth = 5;
    const dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}