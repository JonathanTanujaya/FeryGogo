import 'package:ferry_ticket_app/models/booking.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import 'dart:async';

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadBookings();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      context.read<BookingProvider>().loadBookings();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        context.read<BookingProvider>().loadBookings();
      } else {
        context.read<BookingProvider>().searchBookings(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F52BA),
        title: const Text(
          'Pemesanan Tiket',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<BookingProvider>().loadBookings(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: _SearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
              ),
            ),

            // Booking List
            Consumer<BookingProvider>(
              builder: (context, provider, child) {
                if (provider.bookings.isEmpty && !provider.isLoading) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('Tidak ada pemesanan'),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= provider.bookings.length) {
                          return provider.isLoading ? 
                            const _LoadingItem() : 
                            const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _BookingCard(
                            booking: provider.bookings[index],
                          ),
                        );
                      },
                      childCount: provider.bookings.length + 1,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF0F52BA),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: 'Cari pemesanan...',
            icon: Icon(Icons.search),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to booking detail
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
                      'Booking #${booking.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4E4F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        booking.status,
                        style: const TextStyle(
                          color: Color(0xFF0F52BA),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      booking.date,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.departureTime,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Pelabuhan Keberangkatan',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF0F52BA),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            booking.arrivalTime,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Pelabuhan Tujuan',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingItem extends StatelessWidget {
  const _LoadingItem();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F52BA)),
        ),
      ),
    );
  }
}