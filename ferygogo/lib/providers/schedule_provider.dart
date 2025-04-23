import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/cache_service.dart';
import '../services/error_handler.dart';
import '../utils/pagination_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Schedule {
  final String id;
  final String name;
  final String type;
  final String departure;
  final String arrival;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final int availability;

  Schedule({
    required this.id,
    required this.name,
    required this.type,
    required this.departure,
    required this.arrival,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.availability,
  });

  factory Schedule.fromMap(String id, Map<String, dynamic> map) {
    return Schedule(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? 'regular',
      departure: map['departure'] ?? '',
      arrival: map['arrival'] ?? '',
      departureTime: DateTime.parse(map['departure_time'] ?? DateTime.now().toIso8601String()),
      arrivalTime: DateTime.parse(map['arrival_time'] ?? DateTime.now().toIso8601String()),
      price: (map['price'] ?? 0.0).toDouble(),
      availability: map['availability'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'departure': departure,
      'arrival': arrival,
      'departure_time': departureTime.toIso8601String(),
      'arrival_time': arrivalTime.toIso8601String(),
      'price': price,
      'availability': availability,
    };
  }
}

class ScheduleProvider with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  late final CacheService _cacheService;
  late final PaginationController<Schedule> _paginationController;
  String _currentType = 'all';

  ScheduleProvider() {
    _initCache();
    _paginationController = PaginationController<Schedule>(
      fetchData: _fetchSchedules,
      limit: 10,
    );
  }

  Future<void> _initCache() async {
    final prefs = await SharedPreferences.getInstance();
    _cacheService = CacheService(prefs);
  }

  PaginationController<Schedule> get paginationController => _paginationController;

  Future<List<Schedule>> _fetchSchedules(int page, int limit) async {
    try {
      Query query = _database.child('schedules')
          .orderByChild('departure_time')
          .startAfter(DateTime.now().toIso8601String());
      
      if (_currentType != 'all') {
        query = query.orderByChild('type').equalTo(_currentType);
      }
      
      query = query.limitToFirst(limit);

      // Try to get from cache first
      final cacheKey = 'schedules_${_currentType}_${page}_$limit';
      final cachedData = _cacheService.getSchedules(cacheKey);
      if (cachedData != null) {
        final schedules = (cachedData as List)
            .map((item) => Schedule.fromMap(item['id'], item))
            .toList();
        
        // Check if cache is still valid (less than 5 minutes old)
        final cacheTimestamp = await _cacheService.getCacheTimestamp(cacheKey);
        if (cacheTimestamp != null &&
            DateTime.now().difference(cacheTimestamp).inMinutes < 5) {
          return schedules;
        }
      }

      final snapshot = await query.get();
      if (!snapshot.exists) return [];

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final schedules = data.entries
          .map((e) => Schedule.fromMap(e.key, e.value as Map<String, dynamic>))
          .toList();

      // Cache the results
      await _cacheService.cacheSchedules(cacheKey, schedules.map((s) => s.toMap()).toList());
      await _cacheService.setCacheTimestamp(cacheKey);

      return schedules;
    } catch (e) {
      throw ErrorHandler.getDatabaseErrorMessage(e);
    }
  }

  Future<void> loadSchedules({String type = 'all'}) async {
    _currentType = type;
    await _paginationController.loadInitial();
  }

  Future<void> loadMore() async {
    await _paginationController.loadMore();
  }

  Future<void> refreshSchedules() async {
    await _cacheService.clearScheduleCache();
    await loadSchedules(type: _currentType);
  }

  @override
  void dispose() {
    _paginationController.dispose();
    super.dispose();
  }
}