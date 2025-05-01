import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/cache_service.dart';
import '../models/schedule.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleProvider with ChangeNotifier {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  late final CacheService _cacheService;
  List<Schedule> _schedules = [];
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;
  String? _lastKey;
  static const int _pageSize = 10;
  bool _hasMore = true;

  ScheduleProvider() {
    _initCache();
  }

  Future<void> _initCache() async {
    if (_initialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    _cacheService = CacheService(prefs);
    _initialized = true;

    final cachedSchedules = _cacheService.getSchedules('schedules');
    if (cachedSchedules != null) {
      _schedules = cachedSchedules
          .map((e) => Schedule.fromMap(e['id'], e))
          .toList();
      notifyListeners();
    }
  }

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

  Future<void> loadSchedules({String type = 'regular'}) async {
    if (!_initialized) await _initCache();

    try {
      _setLoading(true);
      _setError(null);
      _hasMore = true;
      _lastKey = null;

      final query = _database
          .child('schedules')
          .orderByChild('type')
          .equalTo(type)
          .limitToFirst(_pageSize);

      final snapshot = await query.get();
      if (!snapshot.exists) {
        _schedules = [];
        return;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      _schedules = data.entries
          .map((e) => Schedule.fromMap(e.key as String, e.value as Map<dynamic, dynamic>))
          .toList();

      if (_schedules.isNotEmpty) {
        _lastKey = _schedules.last.id;
        await _cacheService.cacheSchedules(
          'schedules',
          _schedules.map((s) => {...s.toMap(), 'id': s.id}).toList(),
        );
      }
    } catch (e) {
      _setError('Gagal memuat jadwal: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore || _lastKey == null) return;

    try {
      _setLoading(true);
      _setError(null);

      // Menggunakan orderByKey() dan startAt() untuk pagination yang benar
      final query = _database
          .child('schedules')
          .orderByKey()
          .startAt(_lastKey)
          .limitToFirst(_pageSize + 1); // +1 untuk mengecek item selanjutnya

      final snapshot = await query.get();
      if (!snapshot.exists) {
        _hasMore = false;
        return;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      final List<Schedule> newSchedules = [];
      
      // Skip item pertama karena itu adalah item terakhir dari batch sebelumnya
      var entries = data.entries.toList();
      if (entries.length > 1) {
        entries = entries.sublist(1);
      } else {
        _hasMore = false;
        return;
      }

      for (var entry in entries) {
        final schedule = Schedule.fromMap(
          entry.key as String, 
          entry.value as Map<dynamic, dynamic>
        );
        if (schedule.type == _schedules.first.type) {
          newSchedules.add(schedule);
        }
      }

      if (newSchedules.isNotEmpty) {
        _schedules.addAll(newSchedules);
        _lastKey = newSchedules.last.id;
        notifyListeners();
      } else {
        _hasMore = false;
      }
    } catch (e) {
      _setError('Gagal memuat jadwal tambahan: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshSchedules() async {
    await _cacheService.clearScheduleCache();
    await loadSchedules();
  }
}