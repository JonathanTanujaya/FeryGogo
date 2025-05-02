import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule.dart';

class ScheduleProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Schedule> _schedules = [];
  bool _isLoading = false;
  String? _error;
  DocumentSnapshot? _lastDocument;
  static const int _limit = 10;

  List<Schedule> get schedules => _schedules;
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

  Map<String, dynamic>? _convertToMap(Object? data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  Future<void> loadSchedules({String? type}) async {
    try {
      _setLoading(true);
      _setError(null);
      _lastDocument = null;
      _schedules = [];

      Query query = _firestore.collection('schedules')
          .orderBy('departureTime')
          .limit(_limit);
      
      if (type != null) {
        query = query.where('type', isEqualTo: type.toLowerCase());
      }

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) {
        _schedules = [];
        return;
      }

      _lastDocument = snapshot.docs.last;
      _schedules = snapshot.docs.map((doc) {
        final data = _convertToMap(doc.data());
        if (data == null) return null;
        return Schedule.fromMap(doc.id, data);
      }).whereType<Schedule>().toList();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load schedules: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _lastDocument == null) return;

    try {
      _setLoading(true);
      _setError(null);

      final query = _firestore.collection('schedules')
          .orderBy('departureTime')
          .startAfterDocument(_lastDocument!)
          .limit(_limit);

      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) return;

      _lastDocument = snapshot.docs.last;
      final newSchedules = snapshot.docs.map((doc) {
        final data = _convertToMap(doc.data());
        if (data == null) return null;
        return Schedule.fromMap(doc.id, data);
      }).whereType<Schedule>().toList();

      _schedules.addAll(newSchedules);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load more schedules: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchSchedules({
    required String fromPort,
    required String toPort,
    required DateTime date,
    required String time,
    String? type,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Convert time string to DateTime
      final timeParts = time.split(':');
      final searchDate = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      // Create start and end time range (±2 hours)
      final startTime = searchDate.subtract(const Duration(hours: 2));
      final endTime = searchDate.add(const Duration(hours: 2));

      Query query = _firestore.collection('schedules')
          .where('fromPort', isEqualTo: fromPort)
          .where('toPort', isEqualTo: toPort)
          .where('departureTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startTime))
          .where('departureTime', isLessThanOrEqualTo: Timestamp.fromDate(endTime))
          .orderBy('departureTime');

      if (type != null) {
        query = query.where('type', isEqualTo: type.toLowerCase());
      }

      final snapshot = await query.get();
      _schedules = snapshot.docs.map((doc) {
        final data = _convertToMap(doc.data());
        if (data == null) return null;
        return Schedule.fromMap(doc.id, data);
      }).whereType<Schedule>().toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to search schedules: $e');
    } finally {
      _setLoading(false);
    }
  }
}