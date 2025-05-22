import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/information_provider.dart';

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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image(
                            image: info.imageProvider,
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
                    const SizedBox(height: 16),
                    Text(
                      info.title.toUpperCase(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd MMM yyyy HH:mm').format(info.publishDate),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    ...info.description.map((desc) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            desc,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )),
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
