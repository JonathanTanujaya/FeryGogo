import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';

class Booking {
  final String id;
  final String departure;
  final String arrival;
  final DateTime date;
  final String status;

  Booking({
    required this.id,
    required this.departure,
    required this.arrival,
    required this.date,
    required this.status,
  });
}

class BookingProvider with ChangeNotifier {
  final List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _lastKey;
  static const int _pageSize = 10;

  List<Booking> get bookings => [..._bookings];
  bool get isLoading => _isLoading;

  Future<void> loadBookings({bool refresh = false}) async {
    if (_isLoading) return;
    
    if (refresh) {
      _bookings.clear();
      _lastKey = null;
      notifyListeners();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final ref = FirebaseDatabase.instance.ref().child('bookings');
      Query query = ref.orderByKey();
      
      if (_lastKey != null) {
        query = query.startAfter(_lastKey).limitToFirst(_pageSize);
      } else {
        query = query.limitToFirst(_pageSize);
      }

      final snapshot = await query.get();
      if (snapshot.value != null) {
        final Map<dynamic, dynamic> values = 
            snapshot.value as Map<dynamic, dynamic>;
        
        values.forEach((key, value) {
          _lastKey = key.toString();
          final booking = Booking(
            id: key.toString(),
            departure: value['departure'] ?? '',
            arrival: value['arrival'] ?? '',
            date: DateTime.parse(value['date'] ?? ''),
            status: value['status'] ?? 'pending',
          );
          _bookings.add(booking);
        });
      }
    } catch (error) {
      debugPrint('Error loading bookings: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchBookings(String query) async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final ref = FirebaseDatabase.instance.ref().child('bookings');
      final snapshot = await ref
          .orderByChild('departure')
          .startAt(query)
          .endAt('$query\uf8ff')
          .limitToFirst(_pageSize)
          .get();

      _bookings.clear();
      
      if (snapshot.value != null) {
        final Map<dynamic, dynamic> values = 
            snapshot.value as Map<dynamic, dynamic>;
        
        values.forEach((key, value) {
          final booking = Booking(
            id: key.toString(),
            departure: value['departure'] ?? '',
            arrival: value['arrival'] ?? '',
            date: DateTime.parse(value['date'] ?? ''),
            status: value['status'] ?? 'pending',
          );
          _bookings.add(booking);
        });
      }
    } catch (error) {
      debugPrint('Error searching bookings: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}