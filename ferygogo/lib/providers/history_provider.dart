import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/booking.dart';

class HistoryProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;
  String? _lastKey;
  static const int _pageSize = 10;
  bool _hasMore = true;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHistory() async {
    if (_auth.currentUser == null) return;

    try {
      _setLoading(true);
      _setError(null);
      _hasMore = true;
      _lastKey = null;

      final query = _database
          .child('bookings')
          .child(_auth.currentUser!.uid)
          .orderByChild('status')
          .equalTo('Selesai')  // Hanya ambil tiket yang sudah selesai
          .limitToLast(_pageSize);

      final snapshot = await query.get();
      if (!snapshot.exists) {
        _bookings = [];
        return;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      _bookings = data.entries
          .map((e) => Booking.fromMap(e.key as String, (e.value as Map<dynamic, dynamic>).cast<String, dynamic>()))
          .toList()
          .reversed
          .toList();

      if (_bookings.isNotEmpty) {
        _lastKey = _bookings.first.id;
      }
    } catch (e) {
      _setError('Gagal memuat riwayat: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (_auth.currentUser == null || _isLoading || !_hasMore) return;

    try {
      _setLoading(true);
      _setError(null);

      final query = _database
          .child('bookings')
          .child(_auth.currentUser!.uid)
          .orderByChild('status')
          .equalTo('Selesai')  // Hanya ambil tiket yang sudah selesai
          .endBefore(_lastKey)
          .limitToLast(_pageSize);

      final snapshot = await query.get();
      if (!snapshot.exists) {
        _hasMore = false;
        return;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final newBookings = data.entries
          .map((e) => Booking.fromMap(e.key as String, (e.value as Map<dynamic, dynamic>).cast<String, dynamic>()))
          .toList()
          .reversed
          .toList();

      if (newBookings.isNotEmpty) {
        _bookings.addAll(newBookings);
        _lastKey = newBookings.first.id;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      _setError('Gagal memuat riwayat tambahan: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
}