import 'package:flutter/material.dart';

const Color sapphire = Color(0xFF0F52BA);
const Color skyBlue = Color(0xFF3B7DE9);
const Color regularColor = Color(0xFFD4E4F7);
const Color expressColor = Color(0xFFCBA135);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final fibonacciUnit = screenHeight / 21;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: CustomScrollView(
        slivers: [
          // App Bar dengan gradient
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
                          Image.asset('assets/ferry_icon.png', width: 24),
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
                      // Profile
                      const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text('AP', style: TextStyle(color: sapphire)),
                  )],
                  ),
                ),
              ),
            ),
          ),

          // Konten utama
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cuaca & Peta
                    _buildWeatherMapSection(fibonacciUnit),
                    const SizedBox(height: 16),

                    // Toggle Trip
                    _buildTripToggle(),
                    const SizedBox(height: 16),

                    // Form Pencarian
                    _buildSearchCard(),
                    const SizedBox(height: 16),

                    // Rute Favorit
                    _buildSectionTitle('Rute Favorit'),
                    _buildFavoriteRoutes(),
                    const SizedBox(height: 16),

                    // Jadwal Terdekat
                    _buildSectionTitle('Jadwal Terdekat'),
                    _buildScheduleList(),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildWeatherMapSection(double unit) {
    return Container(
      height: unit * 3,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(2, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wb_sunny, color: Colors.amber),
                      const SizedBox(width: 8),
                      const Text('Cerah', 
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Text('Gelombang Tenang',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                  // Implementasi peta mini
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
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: regularColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: sapphire,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text('Sekali Jalan', 
                  style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: const Center(
                child: Text('Pulang-Pergi', 
                  style: TextStyle(color: Colors.grey)),
              ),
            ),
          ),
        ],
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
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInputField('Dari', 'Merak'),
              ),
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
              Expanded(
                child: _buildInputField('Ke', 'Bakauheni'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField('Tanggal', '16 April 2025'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: sapphire,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('Cari Tiket',
                      style: TextStyle(color: Colors.white)),
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
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(value),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteRoutes() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildRouteCard('Merak → Bakauheni', '12 Apr', sapphire),
          _buildRouteCard('Ketapang → Gilimanuk', '25 Mar', skyBlue),
        ],
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
                Text(route, 
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('Terakhir: $date',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    return Column(
      children: [
        DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                labelColor: sapphire,
                unselectedLabelColor: Colors.grey,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: sapphire.withOpacity(0.1),
                ),
                tabs: const [
                  Tab(text: 'Semua'),
                  Tab(text: 'Reguler'),
                  Tab(text: 'Express'),
                ],
              ),
              SizedBox(
                height: 300,
                child: TabBarView(
                  children: [
                    _buildScheduleItems(),
                    _buildScheduleItems(),
                    _buildScheduleItems(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleItems() {
    return ListView(
      children: [
        _buildScheduleItem('KMP Pertiwi', 'Reguler', '10:30', '12:00', 0.25),
        _buildScheduleItem('KMP Express', 'Express', '11:00', '12:15', 0.85),
      ],
    );
  }

  Widget _buildScheduleItem(String name, String type, String start, String end, double progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(2, 2),
          )   
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: type == 'Reguler' ? regularColor : expressColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(type, 
                  style: TextStyle(
                    color: type == 'Reguler' ? sapphire : Colors.brown,
                    fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(start, style: const TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: CustomPaint(
                  painter: DashedLinePainter(),
                  child: Container(height: 2),
                ),
              ),
              Text(end, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              const Icon(Icons.arrow_forward, color: sapphire),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: regularColor,
            color: progress > 0.8 ? Colors.red : sapphire,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).toInt()}% Tersedia',
              style: TextStyle(
                color: progress > 0.8 ? Colors.red : sapphire,
                fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: sapphire,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Tiket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.radar),
            label: 'Tracking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4E4F7)
      ..strokeWidth = 2;
    
    double startX = 0;
    const dashWidth = 4;
    const dashSpace = 2;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height/2),
        Offset(startX + dashWidth, size.height/2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}