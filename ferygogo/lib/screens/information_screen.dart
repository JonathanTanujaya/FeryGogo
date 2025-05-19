import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/information_provider.dart';
import '../models/information_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({Key? key}) : super(key: key);

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<InformationProvider>();
      // Fetch specific information first
      provider.fetchSpecificInformation('1Z0A0MphzFKGdOoPdhUX');
      // Then fetch all information
      provider.fetchInformation();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Informasi Terkini',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F52BA), Color(0xFF3B7DE9)],
            ),
          ),
        ),
      ),
      body: Consumer<InformationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refreshInformation(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (provider.information.isEmpty) {
            return const Center(
              child: Text('Belum ada informasi'),
            );
          }          
          return RefreshIndicator(
            onRefresh: () => provider.refreshInformation(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.information.length,
              itemBuilder: (context, index) {
                final info = provider.information[index];
                
                if (info.id == '1Z0A0MphzFKGdOoPdhUX') {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.campaign_rounded,
                                    color: Theme.of(context).primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Pengumuman Penting',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _InformationCard(
                              information: info,
                              isHighlighted: true,
                            ),
                          ],
                        ),
                      ),
                      if (index == 0) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(thickness: 1),
                        ),
                        const Text(
                          'Informasi Lainnya',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  );
                }
                return _InformationCard(information: info);
              },
            ),
          );
        },
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  final InformationModel information;
  final bool isHighlighted;

  const _InformationCard({
    required this.information,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isHighlighted ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isHighlighted
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (information.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  information.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    information.category,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  information.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  information.content,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Oleh: ${information.author}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy HH:mm')
                          .format(information.publishDate),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
