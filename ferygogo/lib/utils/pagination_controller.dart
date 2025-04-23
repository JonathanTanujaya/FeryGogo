import 'package:flutter/foundation.dart';
import 'dart:async';

class PaginationController<T> extends ChangeNotifier {
  final Future<List<T>> Function(int page, int limit) fetchData;
  final int limit;
  final Duration throttleDuration;
  
  List<T> _items = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  String? _error;
  Timer? _throttleTimer;
  int _retryCount = 0;
  static const int maxRetries = 3;

  PaginationController({
    required this.fetchData,
    this.limit = 15,
    this.throttleDuration = const Duration(milliseconds: 500),
  });

  List<T> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasMoreData => _hasMoreData;
  String? get error => _error;

  Future<void> loadInitial() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    _currentPage = 1;
    _retryCount = 0;
    notifyListeners();

    try {
      final items = await compute(_fetchDataIsolate, _FetchParams(
        page: _currentPage,
        limit: limit,
        fetcher: fetchData,
      )) as List<T>;
      _items = items;
      _hasMoreData = items.length >= limit;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMoreData) return;
    if (_throttleTimer?.isActive ?? false) return;

    _throttleTimer?.cancel();
    _throttleTimer = Timer(throttleDuration, () async {
      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        final nextPage = _currentPage + 1;
        final newItems = await compute(_fetchDataIsolate, _FetchParams(
          page: nextPage,
          limit: limit,
          fetcher: fetchData,
        )) as List<T>;
        
        if (newItems.isNotEmpty) {
          // Process items in smaller batches to avoid UI jank
          final batches = _splitIntoBatches(newItems, 10);
          for (final batch in batches) {
            _items.addAll(batch);
            await Future.delayed(const Duration(milliseconds: 16)); // Wait for next frame
            notifyListeners();
          }
          
          _currentPage = nextPage;
          _hasMoreData = newItems.length >= limit;
          _retryCount = 0;
        } else {
          _hasMoreData = false;
        }
      } catch (e) {
        _error = e.toString();
        if (_retryCount < maxRetries) {
          _retryCount++;
          await Future.delayed(Duration(seconds: _retryCount));
          await loadMore();
        }
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  List<List<T>> _splitIntoBatches(List<T> items, int batchSize) {
    final result = <List<T>>[];
    for (var i = 0; i < items.length; i += batchSize) {
      final end = (i + batchSize < items.length) ? i + batchSize : items.length;
      result.add(items.sublist(i, end));
    }
    return result;
  }

  void reset() {
    _throttleTimer?.cancel();
    _items = [];
    _isLoading = false;
    _hasMoreData = true;
    _currentPage = 0;
    _error = null;
    _retryCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    _items = [];
    super.dispose();
  }
}

class _FetchParams<T> {
  final int page;
  final int limit;
  final Future<List<T>> Function(int page, int limit) fetcher;

  _FetchParams({
    required this.page,
    required this.limit,
    required this.fetcher,
  });
}

Future<List<T>> _fetchDataIsolate<T>(_FetchParams<T> params) async {
  return await params.fetcher(params.page, params.limit);
}