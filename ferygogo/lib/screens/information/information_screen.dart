import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/information_provider.dart';
import '../../models/information_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'information_detail_screen.dart';

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

  const _InformationCard({
    required this.information,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openDetail(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (information.imageUrl.isNotEmpty)
              _buildImage(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 8),
                  _buildPublishDate(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InformationDetailScreen(
          documentId: information.id,
          title: information.title,
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(12),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image(
          image: information.imageProvider,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      information.title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPublishDate() {
    return Text(
      DateFormat('dd MMM yyyy HH:mm').format(information.publishDate),
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 12,
      ),
    );
  }
}
