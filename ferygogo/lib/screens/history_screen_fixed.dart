import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/error_handler.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _error;
  List<QueryDocumentSnapshot> _tickets = [];
  DocumentSnapshot? _lastDocument;
  static const int _pageSize = 10;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadTickets();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMoreTickets();
    }
  }

  Future<void> _loadTickets() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = 'Silakan login terlebih dahulu';
          _isLoading = false;
        });
        return;
      }

      // Query tickets from Firestore - without complex filters that require composite index
      final query = FirebaseFirestore.instance
          .collection('tiket')
          .where('bookerEmail', isEqualTo: user.email)
          .limit(_pageSize);

      final snapshot = await query.get();
      
      // Sort tickets manually by departure time
      final sorted = snapshot.docs.toList()
        ..sort((a, b) {
          final dateA = DateTime.parse((a.data() as Map)['departureTime'] as String);
          final dateB = DateTime.parse((b.data() as Map)['departureTime'] as String);
          return dateB.compareTo(dateA); // descending order
        });
      
      setState(() {
        _tickets = sorted;
        _isLoading = false;
        if (sorted.isNotEmpty) {
          _lastDocument = sorted.last;
          _hasMore = sorted.length >= _pageSize;
        } else {
          _hasMore = false;
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreTickets() async {
    if (_isLoading || !_hasMore || _lastDocument == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get all tickets and filter manually instead of using startAfter
      final moreTicketsQuery = FirebaseFirestore.instance
          .collection('tiket')
          .where('bookerEmail', isEqualTo: user.email)
          .limit(_pageSize * 2); // Get more to filter later
          
      final snapshot = await moreTicketsQuery.get();

      // Sort all tickets
      final allDocs = snapshot.docs.toList()
        ..sort((a, b) {
          final dateA = DateTime.parse((a.data() as Map)['departureTime'] as String);
          final dateB = DateTime.parse((b.data() as Map)['departureTime'] as String);
          return dateB.compareTo(dateA);
        });
        
      // Filter out tickets we already have
      final existingIds = _tickets.map((doc) => (doc.data() as Map)['id']).toSet();
      final newDocs = allDocs.where((doc) => 
          !existingIds.contains((doc.data() as Map)['id'])).toList();
      
      // Limit to page size
      final docsToAdd = newDocs.take(_pageSize).toList();
      
      setState(() {
        _tickets.addAll(docsToAdd);
        _isLoading = false;
        if (docsToAdd.isNotEmpty) {
          _lastDocument = docsToAdd.last;
          _hasMore = docsToAdd.length >= _pageSize;
        } else {
          _hasMore = false;
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Tiket'),
        backgroundColor: const Color(0xFF0F52BA),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return ErrorHandler.errorWidget(
        _error!,
        _loadTickets,
      );
    }

    if (_tickets.isEmpty) {
      if (_isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return ErrorHandler.emptyStateWidget('Belum ada tiket dalam riwayat');
    }

    return RefreshIndicator(
      onRefresh: _loadTickets,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _tickets.length + (_isLoading && _hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _tickets.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final ticketData = _tickets[index].data() as Map<String, dynamic>;
          final departureTime = DateTime.parse(ticketData['departureTime']);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryDetailScreen(
                      ticketId: ticketData['id'],
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_boat, color: Color(0xFF0F52BA)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ticketData['routeName'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ticketData['shipName'] ?? 'Tidak ada kapal aktif',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tanggal Keberangkatan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy').format(departureTime),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Waktu',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              DateFormat('HH:mm').format(departureTime),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kelas: ${ticketData['ticketClass']}',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(ticketData['status']).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ticketData['status'],
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(ticketData['status']),
                              fontWeight: FontWeight.bold,
                            ),
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
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
        return Colors.green;
      case 'selesai':
        return Colors.blue;
      case 'dibatalkan':
        return Colors.red;
      default:
        return const Color(0xFF0F52BA);
    }
  }
}
