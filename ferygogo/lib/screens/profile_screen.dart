import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadUserProfile();
    });
  }

  void _signOut() async {
    await context.read<AuthProvider>().signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: const Color(0xFF0F52BA),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit profile
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
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
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadUserProfile(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final profile = provider.userProfile;
          if (profile == null) {
            return const Center(
              child: Text('Profil tidak ditemukan'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileHeader(profile),
                const SizedBox(height: 24),
                _buildInfoCard(profile),
                const SizedBox(height: 24),
                _buildStatsCard(profile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: profile.profilePicture.isNotEmpty 
            ? NetworkImage(profile.profilePicture)
            : null,
          child: profile.profilePicture.isEmpty
            ? Text(
                profile.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 32),
              )
            : null,
        ),
        const SizedBox(height: 16),
        Text(
          profile.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.email,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(UserProfile profile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Kontak',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.phone,
              'Nomor Telepon',
              profile.phoneNumber.isNotEmpty 
                ? profile.phoneNumber 
                : 'Belum diatur',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.calendar_today,
              'Bergabung Sejak',
              '${profile.createdAt.day}/${profile.createdAt.month}/${profile.createdAt.year}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(UserProfile profile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistik',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Perjalanan',
                  '${profile.totalTrips}',
                  Icons.directions_ferry,
                ),
                _buildStatItem(
                  'Rute Favorit',
                  '${profile.favoriteRoutes.length}',
                  Icons.favorite,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF0F52BA),
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F52BA),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
