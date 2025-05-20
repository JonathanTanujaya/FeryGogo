import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/information_provider.dart';
import '../models/information_model.dart';

class InformationDetailScreen extends StatelessWidget {
  final String documentId;
  final String title;

  const InformationDetailScreen({
    Key? key,
    required this.documentId,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder(
        future: Provider.of<InformationProvider>(context, listen: false)
            .fetchSpecificInformation(documentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Consumer<InformationProvider>(
            builder: (context, provider, child) {
              if (provider.error != null) {
                return Center(child: Text(provider.error!));
              }

              final info = provider.selectedInfo;
              if (info == null) {
                return const Center(child: Text('Informasi tidak ditemukan'));
              }

              // Get subcollection data for both N004 and N001
              final subcollectionData = (documentId == 'N004' || documentId == 'N001') 
                  ? provider.subcollectionData 
                  : null;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (info.imageUrl.isNotEmpty)
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(info.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      info.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dipublikasikan: ${info.publishDate}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      info.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (subcollectionData != null && subcollectionData.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      for (final data in subcollectionData) ...[
                        if (data['location'] != null) ...[
                          Text(
                            'Lokasi:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['location'],
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (data['history'] != null) ...[
                          Text(
                            'Sejarah:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['history'],
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ],
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
