import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../services/error_handler.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadHistory();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<HistoryProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        backgroundColor: const Color(0xFF0F52BA),
        foregroundColor: Colors.white,
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return ErrorHandler.errorWidget(
              provider.error!,
              () => provider.loadHistory(),
            );
          }

          if (provider.bookings.isEmpty) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ErrorHandler.emptyStateWidget(
              'Belum ada riwayat pemesanan'
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadHistory(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.bookings.length + (provider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.bookings.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final booking = provider.bookings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(
                      booking.route_name ?? 'No Route',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(booking.toString()),
                    trailing: Text(
                      booking.status ?? 'Unknown Status',
                      style: TextStyle(
                        color: booking.status == 'Selesai'
                            ? Colors.green
                            : const Color(0xFF0F52BA),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}