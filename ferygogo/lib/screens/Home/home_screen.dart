import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/weather_provider.dart';
import '../../providers/navigation_provider.dart';
import 'weather_header.dart';
import 'search_form.dart';
import 'schedule_list_view.dart';
import 'error_state.dart';
import 'loading_shimmer.dart';

const Color sapphire = Color(0xFF0F52BA);
const Color skyBlue = Color(0xFF3B7DE9);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<ScheduleProvider>().loadMore();
    }
  }

  Future<void> _loadInitialData() async {
    if (_isInitialized) return;
    
    try {
      final scheduleProvider = context.read<ScheduleProvider>();
      final weatherProvider = context.read<WeatherProvider>();
      
      await Future.wait([
        scheduleProvider.loadSchedules(),
        weatherProvider.loadWeatherInfo(),
      ]);

      _isInitialized = true;
    } catch (e) {
      // Error handling is now delegated to the ErrorState component
      setState(() => _isInitialized = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FeryGogo', style: TextStyle(color: Colors.white),),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [sapphire, skyBlue],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                if (mounted) {
                  // Use NavigationProvider to switch to profile tab
                  context.read<NavigationProvider>().setIndex(3);
                }
              },
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: sapphire,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: sapphire,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() => _isInitialized = false);
            return _loadInitialData();
          },
          child: Consumer<ScheduleProvider>(
            builder: (context, scheduleProvider, _) {
              if (scheduleProvider.error != null) {
                return ErrorState(
                  message: scheduleProvider.error!,
                  onRetry: () {
                    setState(() => _isInitialized = false);
                    _loadInitialData();
                  },
                  imagePath: 'assets/waves.png',
                );
              }

              return SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WeatherHeader(),
                    const SearchForm(),
                    if (!_isInitialized)
                      const LoadingShimmer()
                    else
                      const ScheduleListView(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}