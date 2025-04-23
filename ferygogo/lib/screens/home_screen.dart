import 'package:ferry_ticket_app/services/error_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/schedule_provider.dart';
import 'package:intl/intl.dart';

const Color sapphire = Color(0xFF0F52BA);
const Color skyBlue = Color(0xFF3B7DE9);
const Color regularColor = Color(0xFFD4E4F7);
const Color expressColor = Color(0xFFCBA135);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedType = 'regular';
  String _selectedTripType = 'one_way'; // Added missing variable
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Defer loading until after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (_isInitialized) return;
    
    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    
    await Future.wait([
      scheduleProvider.loadSchedules(type: _selectedType),
      weatherProvider.loadWeatherInfo(),
    ]);

    _isInitialized = true;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<ScheduleProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final fibonacciUnit = screenHeight / 21;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: CustomScrollView(
        controller: _scrollController,
        // Using physics for better scroll performance
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: fibonacciUnit * 2,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [sapphire, skyBlue],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Row(
                        children: [
                          Image.asset(
                            'assets/ferry_icon.png',
                            width: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox(width: 24, height: 24),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'FeryGogo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text('AP', style: TextStyle(color: sapphire)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main content
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weather & Map section with provider
                    Consumer<WeatherProvider>(
                      builder: (context, weatherProvider, child) {
                        return _buildWeatherMapSection(
                          fibonacciUnit,
                          weatherProvider.weatherInfo,
                          weatherProvider.isLoading,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Trip toggle
                    _buildTripToggle(),
                    const SizedBox(height: 16),

                    // Search form
                    _buildSearchCard(),
                    const SizedBox(height: 16),

                    // Favorite routes
                    _buildSectionTitle('Rute Favorit'),
                    Consumer<ScheduleProvider>(
                      builder: (context, provider, _) {
                        return _buildFavoriteRoutes(['Merak - Bakauheni', 'Ketapang - Gilimanuk']);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Schedule list with provider
                    _buildSectionTitle('Jadwal Terdekat'),
                    _buildScheduleList(),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherMapSection(
    double unit,
    WeatherInfo? weatherInfo,
    bool isLoading,
  ) {
    return Container(
      height: unit * 3,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(sapphire),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.wb_sunny, color: Colors.amber),
                            const SizedBox(width: 8),
                            Text(
                              weatherInfo?.condition ?? 'Loading...',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                          weatherInfo?.waveCondition ?? 'Loading...',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: regularColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Center(
                    child: CustomPaint(
                      size: const Size(120, 40),
                      painter: DashedLinePainter(),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: CircleAvatar(radius: 5, backgroundColor: sapphire),
                  ),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: CircleAvatar(radius: 5, backgroundColor: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripToggle() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: regularColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            _buildTripToggleButton(
              label: 'Sekali Jalan',
              value: 'one_way',
              isSelected: _selectedTripType == 'one_way',
            ),
            _buildTripToggleButton(
              label: 'Pulang-Pergi',
              value: 'round_trip',
              isSelected: _selectedTripType == 'round_trip',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripToggleButton({
    required String label,
    required String value,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            setState(() => _selectedTripType = value);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? sapphire : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInputField('Dari', 'Merak')),
              IconButton(
                icon: Container(
                  decoration: BoxDecoration(
                    color: sapphire,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.swap_horiz, color: Colors.white),
                ),
                onPressed: () {},
              ),
              Expanded(child: _buildInputField('Ke', 'Bakauheni')),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInputField('Tanggal', '16 April 2025')),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: sapphire,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Cari Tiket',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: regularColor),
          ),
          child: Align(alignment: Alignment.centerLeft, child: Text(value)),
        ),
      ],
    );
  }

  Widget _buildFavoriteRoutes(List<String> favorites) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final route = favorites[index];
          return _buildRouteCard(
            route,
            '12 Apr',
            index.isEven ? sapphire : skyBlue,
          );
        },
      ),
    );
  }

  Widget _buildRouteCard(String route, String date, Color color) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: regularColor),
      ),
      child: Stack(
        children: [
          Container(
            width: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  'Terakhir: $date',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    return Consumer<ScheduleProvider>(
      builder: (context, provider, _) {
        final controller = provider.paginationController;
        
        if (controller.isLoading && controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.items.isEmpty) {
          return ErrorHandler.emptyStateWidget(
            'Tidak ada jadwal tersedia'
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshSchedules(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 8),
            itemCount: controller.items.length + (controller.hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.items.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final schedule = controller.items[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: InkWell(
                  onTap: () {
                    // Navigate to detail
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              schedule.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F52BA).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                schedule.type.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF0F52BA),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Keberangkatan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    schedule.departure,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('HH:mm, d MMM').format(
                                      schedule.departureTime,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward,
                              color: Colors.grey,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Kedatangan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    schedule.arrival,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('HH:mm, d MMM').format(
                                      schedule.arrivalTime,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              NumberFormat.currency(
                                locale: 'id',
                                symbol: 'Rp ',
                                decimalDigits: 0,
                              ).format(schedule.price),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F52BA),
                              ),
                            ),
                            Text(
                              'Tersedia: ${schedule.availability.toInt()}',
                              style: TextStyle(
                                color: schedule.availability > 0 
                                    ? Colors.green 
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final Schedule schedule;

  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final departureTime = DateFormat('HH:mm').format(schedule.departureTime);
    final arrivalTime = DateFormat('HH:mm').format(schedule.arrivalTime);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                schedule.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: schedule.type == 'regular'
                      ? regularColor
                      : expressColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  schedule.type,
                  style: TextStyle(
                    color: schedule.type == 'regular'
                        ? sapphire
                        : Colors.brown,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                departureTime,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: CustomPaint(
                  painter: DashedLinePainter(),
                  child: Container(height: 2),
                ),
              ),
              Text(
                arrivalTime,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.arrow_forward, color: sapphire),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: schedule.availability.toDouble(),
            backgroundColor: regularColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              schedule.availability > 0.8 ? Colors.red : sapphire,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(schedule.availability * 100).toInt()}% Tersedia',
              style: TextStyle(
                color: schedule.availability > 0.8 ? Colors.red : sapphire,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFD4E4F7)
          ..strokeWidth = 2;

    double startX = 0;
    const dashWidth = 4;
    const dashSpace = 2;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// KeepAlive widget to maintain tab state
class KeepAlive extends StatefulWidget {
  final Widget child;

  const KeepAlive({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _KeepAliveState createState() => _KeepAliveState();
}

class _KeepAliveState extends State<KeepAlive> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
