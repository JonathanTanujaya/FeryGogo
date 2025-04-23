import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';

class TripHistory {
  final String id;
  final String departure;
  final String arrival;
  final DateTime date;
  final String status;
  final double price;

  TripHistory({
    required this.id,
    required this.departure,
    required this.arrival,
    required this.date,
    required this.status,
    required this.price,
  });
}

class HistoryProvider with ChangeNotifier {
  final List<TripHistory> _history = [];
  bool _isLoading = false;
  String? _lastKey;
  static const int _pageSize = 15;

  List<TripHistory> get history => [..._history];
  bool get isLoading => _isLoading;

  Future<void> loadHistory({bool refresh = false}) async {
    if (_isLoading) return;
    
    if (refresh) {
      _history.clear();
      _lastKey = null;
      notifyListeners();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final ref = FirebaseDatabase.instance.ref().child('trip_history');
      Query query = ref.orderByChild('date');
      
      if (_lastKey != null) {
        query = query.endBefore(_lastKey).limitToLast(_pageSize);
      } else {
        query = query.limitToLast(_pageSize);
      }

      final snapshot = await query.get();
      if (snapshot.value != null) {
        final Map<dynamic, dynamic> values = 
            snapshot.value as Map<dynamic, dynamic>;
        
        final sortedKeys = values.keys.toList()
          ..sort((a, b) => values[b]['date'].compareTo(values[a]['date']));

        for (var key in sortedKeys) {
          final value = values[key];
          _lastKey = key.toString();
          final trip = TripHistory(
            id: key.toString(),
            departure: value['departure'] ?? '',
            arrival: value['arrival'] ?? '',
            date: DateTime.parse(value['date'] ?? ''),
            status: value['status'] ?? 'completed',
            price: (value['price'] ?? 0.0).toDouble(),
          );
          _history.add(trip);
        }
      }
    } catch (error) {
      debugPrint('Error loading history: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByDateRange(DateTime start, DateTime end) async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final ref = FirebaseDatabase.instance.ref().child('trip_history');
      final snapshot = await ref
          .orderByChild('date')
          .startAt(start.toIso8601String())
          .endAt(end.toIso8601String())
          .get();

      _history.clear();
      
      if (snapshot.value != null) {
        final Map<dynamic, dynamic> values = 
            snapshot.value as Map<dynamic, dynamic>;
        
        final sortedKeys = values.keys.toList()
          ..sort((a, b) => values[b]['date'].compareTo(values[a]['date']));

        for (var key in sortedKeys) {
          final value = values[key];
          final trip = TripHistory(
            id: key.toString(),
            departure: value['departure'] ?? '',
            arrival: value['arrival'] ?? '',
            date: DateTime.parse(value['date'] ?? ''),
            status: value['status'] ?? 'completed',
            price: (value['price'] ?? 0.0).toDouble(),
          );
          _history.add(trip);
        }
      }
    } catch (error) {
      debugPrint('Error filtering history: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}