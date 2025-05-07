import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _loadProfile() async {
    await context.read<ProfileProvider>().loadUserProfile();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = 'profile_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg';

      try {
        final ref = FirebaseStorage.instance.ref().child(fileName);
        await ref.putFile(file);
        final imageUrl = await ref.getDownloadURL();
        await context.read<ProfileProvider>().updateProfilePicture(imageUrl);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah gambar: $e')),
        );
      }
    }
  }

  void _signOut() async {
    try {
      await context.read<AuthProvider>().signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  void _navigateToEditProfile(UserProfile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profile: profile),
      ),
    ).then((_) {
      context.read<ProfileProvider>().loadUserProfile();
    });
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
              final profile = context.read<ProfileProvider>().userProfile;
              if (profile != null) {
                _navigateToEditProfile(profile);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: Consumer<ProfileProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
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
                      onPressed: _loadProfile,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            final profile = provider.userProfile;
            if (profile == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Profil tidak ditemukan'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadProfile,
                      child: const Text('Muat Ulang'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(profile),
                  const SizedBox(height: 24),
                  _buildAccountInfo(profile),
                  const SizedBox(height: 16),
                  _buildPersonalInfo(profile),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickAndUploadImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profile.profilePicture.isNotEmpty
                      ? NetworkImage(profile.profilePicture)
                      : null,
                  child: profile.profilePicture.isEmpty && profile.name.isNotEmpty
                      ? Text(
                          profile.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 32),
                        )
                      : const Icon(Icons.person, size: 32),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.name.isNotEmpty ? profile.name : 'Belum diatur',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(UserProfile profile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informasi Akun', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.email, 'Email', profile.email),
            const Divider(height: 24),
            _buildInfoRow(Icons.phone, 'Nomor Telepon', profile.phoneNumber.isNotEmpty ? profile.phoneNumber : 'Belum diatur'),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(UserProfile profile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informasi Pribadi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, 'Nama Lengkap', profile.name),
            const Divider(height: 24),
            _buildInfoRow(Icons.people, 'Jenis Kelamin', profile.gender.isNotEmpty ? profile.gender : 'Belum diatur'),
            const Divider(height: 24),
            _buildInfoRow(Icons.cake, 'Tanggal Lahir', profile.birthDate != null ? DateFormat('dd MMMM yyyy').format(profile.birthDate!) : 'Belum diatur'),
            const Divider(height: 24),
            _buildInfoRow(Icons.badge, 'Jenis Identitas', profile.identityType.isNotEmpty ? profile.identityType : 'Belum diatur'),
            const Divider(height: 24),
            _buildInfoRow(Icons.credit_card, 'Nomor Identitas', profile.identityNumber.isNotEmpty ? profile.identityNumber : 'Belum diatur'),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
