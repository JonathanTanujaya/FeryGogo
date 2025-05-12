import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../services/error_handler.dart';

class BookingProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  List<Booking> _bookings = [];
  List<Booking> _filteredBookings = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<Booking> get bookings => _searchQuery.isEmpty ? _bookings : _filteredBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<bool> createBooking({
    required String routeName,
    required String date,
    required int quantity,
    required double totalPrice,
    required String departureTime,
    required String arrivalTime,
    required String routeType,
  }) async {
    if (_auth.currentUser == null) {
      _setError('Silakan login terlebih dahulu');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      final newBookingRef = _database
          .child('bookings')
          .child(_auth.currentUser!.uid)
          .push();

      final booking = Booking(
        id: newBookingRef.key!,
        userId: _auth.currentUser!.uid,
        routeName: routeName,
        date: date,
        status: 'Pending',
        quantity: quantity,
        totalPrice: totalPrice,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        routeType: routeType,
      );

      await newBookingRef.set(booking.toMap());
      _bookings.insert(0, booking);
      
      return true;
    } catch (e) {
      _setError(ErrorHandler.getDatabaseErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    if (_auth.currentUser == null) return;

    try {
      _setLoading(true);
      _setError(null);

      await _database
          .child('bookings')
          .child(_auth.currentUser!.uid)
          .child(bookingId)
          .update({'status': 'Dibatalkan'});

      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        final booking = _bookings[index];
        _bookings[index] = Booking(
          id: booking.id,
          userId: booking.userId,
          routeName: booking.routeName,
          date: booking.date,
          status: 'Dibatalkan',
          quantity: booking.quantity,
          totalPrice: booking.totalPrice,
          departureTime: booking.departureTime,
          arrivalTime: booking.arrivalTime,
          routeType: booking.routeType,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError(ErrorHandler.getDatabaseErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeBooking(String bookingId) async {
    if (_auth.currentUser == null) return;

    try {
      _setLoading(true);
      _setError(null);

      await _database
          .child('bookings')
          .child(_auth.currentUser!.uid)
          .child(bookingId)
          .update({'status': 'Selesai'});

      // Update local booking status
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        final booking = _bookings[index];
        _bookings[index] = Booking(
          id: booking.id,
          userId: booking.userId,
          routeName: booking.routeName,
          date: booking.date,
          status: 'Selesai',
          quantity: booking.quantity,
          totalPrice: booking.totalPrice,
          departureTime: booking.departureTime,
          arrivalTime: booking.arrivalTime,
          routeType: booking.routeType,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError(ErrorHandler.getDatabaseErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadBookings() async {
    if (_auth.currentUser == null) return;

    try {
      _setLoading(true);
      _setError(null);

      final snapshot = await _database
          .child('bookings')
          .child(_auth.currentUser!.uid)
          .orderByChild('date')
          .get();

      if (!snapshot.exists) {
        _bookings = [];
        return;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      _bookings = data.entries
          .map((e) => Booking.fromMap(e.key as String, e.value as Map<dynamic, dynamic>))
          .toList();
      
      // Sort bookings by date, most recent first
      _bookings.sort((a, b) => b.date.compareTo(a.date));
      
      if (_searchQuery.isNotEmpty) {
        _filterBookings();
      }
    } catch (e) {
      _setError(ErrorHandler.getDatabaseErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkAndUpdateBookingStatus() async {
    if (_auth.currentUser == null) return;

    try {
      final snapshot = await _database
          .child('bookings')
          .child(_auth.currentUser!.uid)
          .orderByChild('status')
          .equalTo('Pending')
          .get();

      if (!snapshot.exists) return;

      final now = DateTime.now();
      final data = snapshot.value as Map<dynamic, dynamic>;
      
      for (var entry in data.entries) {
        final booking = Booking.fromMap(entry.key as String, entry.value as Map<dynamic, dynamic>);
        final departureTime = DateFormat('dd MMM yyyy, HH:mm')
            .parse('${booking.date}, ${booking.departureTime}');
        
        // Jika sudah 2 jam setelah keberangkatan, tandai selesai
        if (now.isAfter(departureTime.add(const Duration(hours: 2)))) {
          await completeBooking(booking.id);
        }
      }
    } catch (e) {
      _setError(ErrorHandler.getDatabaseErrorMessage(e));
    }
  }

  void searchBookings(String query) {
    _searchQuery = query.toLowerCase();
    _filterBookings();
    notifyListeners();
  }

  void _filterBookings() {
    if (_searchQuery.isEmpty) {
      _filteredBookings = [];
      return;
    }

    _filteredBookings = _bookings.where((booking) {
      return booking.routeName.toLowerCase().contains(_searchQuery) ||
             booking.id.toLowerCase().contains(_searchQuery) ||
             booking.status.toLowerCase().contains(_searchQuery);
    }).toList();
  }
}