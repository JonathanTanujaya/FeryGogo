import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/ticket.dart';
import 'ticket_detail_screen.dart';

class TicketListScreen extends StatelessWidget {
  const TicketListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tickets = Ticket.getDummyTickets();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tiket'),
        backgroundColor: const Color(0xFF0F52BA),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicketDetailScreen(ticket: ticket),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.routeName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.directions_boat, color: Color(0xFF0F52BA)),
                        const SizedBox(width: 8),
                        Text(ticket.shipName),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Keberangkatan',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy, HH:mm').format(ticket.departureTime),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F52BA).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            NumberFormat.currency(
                              locale: 'id',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(ticket.price),
                            style: TextStyle(
                              color: const Color(0xFF0F52BA),
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
}