import 'package:flutter/material.dart';

class TimeUtils {
  static final List<String> regularHours = List.generate(24, (i) => 
    '${i.toString().padLeft(2, '0')}:00'
  );

  static final List<String> oddHours = [
    '01:00', '03:00', '05:00', '07:00', '09:00', '11:00', 
    '13:00', '15:00', '17:00', '19:00', '21:00', '23:00'
  ];

  static final List<String> evenHours = [
    '00:00', '02:00', '04:00', '06:00', '08:00', '10:00', 
    '12:00', '14:00', '16:00', '18:00', '20:00', '22:00'
  ];

  static List<String> getAvailableTimesForDate(DateTime date, String serviceType) {
    List<String> baseTimeSlots;
    
    if (serviceType == 'Regular') {
      baseTimeSlots = regularHours;
    } else {
      final isOddDate = date.day.isOdd;
      baseTimeSlots = isOddDate ? oddHours : evenHours;
    }
    
    final now = DateTime.now();
    if (date.year != now.year || date.month != now.month || date.day != now.day) {
      return baseTimeSlots;
    }
    
    final currentTime = TimeOfDay.now();
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    
    return baseTimeSlots.where((timeStr) {
      final parts = timeStr.split(':');
      final timeMinutes = int.parse(parts[0]) * 60;
      return timeMinutes > currentMinutes;
    }).toList();
  }

  static String? findNearestFutureTime(List<String> times) {
    if (times.isEmpty) return null;
    
    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;
    
    for (String time in times) {
      final parts = time.split(':');
      final timeMinutes = int.parse(parts[0]) * 60;
      if (timeMinutes > currentMinutes) {
        return time;
      }
    }
    
    return times.first;
  }
}