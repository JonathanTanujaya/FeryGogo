import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../providers/profile_provider.dart';
import '../../providers/theme_provider.dart';
import 'package:intl/intl.dart';
import 'profile_logic.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileScreenLogic _logic;
  final primaryColor = const Color(0xFF0F52BA);

  @override
  void initState() {
    super.initState();
    _logic = ProfileScreenLogic(context);
    _logic.loadProfile(); // Load profile when screen initializes
  }

  @override
  void dispose() {
    _logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: _logic.loadProfile,
            color: primaryColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildAppBar(provider),
                SliverToBoxAdapter(
                  child: _buildBody(provider, size, isDarkMode),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final profile = context.read<ProfileProvider>().userProfile;
          if (profile != null) {
            _logic.navigateToEditProfile(profile);
          }
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar(ProfileProvider provider) {
    final profile = provider.userProfile;
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      title: const Text('Profil'),
      actions: [
        IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: Colors.white,
          ),
          onPressed: () => themeProvider.toggleTheme(),
          tooltip: themeProvider.isDarkMode ? 'Mode Terang' : 'Mode Gelap',
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => _showLogoutDialog(),
          tooltip: 'Keluar',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor,
                primaryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: profile != null ? SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                _buildProfileImage(profile),
                const SizedBox(height: 8),
                Text(
                  profile.name.isNotEmpty ? profile.name : 'Belum diatur',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (profile.email.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      profile.email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ) : null,
        ),
      ),
    );
  }

  Widget _buildBody(ProfileProvider provider, Size size, bool isDarkMode) {
    if (provider.isLoading) {
      return SizedBox(
        height: size.height - 200,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (provider.error != null) {
      return SizedBox(
        height: size.height - 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                provider.error!,
                style: TextStyle(color: Colors.red[300]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _logic.loadProfile,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: primaryColor,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final profile = provider.userProfile;
    if (profile == null) {
      return SizedBox(
        height: size.height - 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Profil tidak ditemukan',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _logic.loadProfile,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: primaryColor,
                ),
                child: const Text('Muat Ulang'),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildInfoSection(
            title: 'Informasi Akun',
            icon: Icons.person_outline,
            isDarkMode: isDarkMode,
            children: [
              _buildInfoTile(
                icon: Icons.email,
                label: 'Email',
                value: profile.email,
                isDarkMode: isDarkMode,
              ),
              const Divider(height: 1),
              _buildInfoTile(
                icon: Icons.phone,
                label: 'Nomor Telepon',
                value: profile.phoneNumber.isNotEmpty ? profile.phoneNumber : 'Belum diatur',
                isDarkMode: isDarkMode,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            title: 'Informasi Pribadi',
            icon: Icons.badge_outlined,
            isDarkMode: isDarkMode,
            children: [
              _buildInfoTile(
                icon: Icons.person,
                label: 'Nama Lengkap',
                value: profile.name,
                isDarkMode: isDarkMode,
              ),
              const Divider(height: 1),
              _buildInfoTile(
                icon: Icons.people,
                label: 'Jenis Kelamin',
                value: profile.gender.isNotEmpty ? profile.gender : 'Belum diatur',
                isDarkMode: isDarkMode,
              ),
              const Divider(height: 1),
              _buildInfoTile(
                icon: Icons.cake,
                label: 'Tanggal Lahir',
                value: profile.birthDate != null 
                    ? DateFormat('dd MMMM yyyy').format(profile.birthDate!)
                    : 'Belum diatur',
                isDarkMode: isDarkMode,
              ),
              const Divider(height: 1),
              _buildInfoTile(
                icon: Icons.badge,
                label: 'Jenis Identitas',
                value: profile.identityType.isNotEmpty ? profile.identityType : 'Belum diatur',
                isDarkMode: isDarkMode,
              ),
              const Divider(height: 1),
              _buildInfoTile(
                icon: Icons.credit_card,
                label: 'Nomor Identitas',
                value: profile.identityNumber.isNotEmpty ? profile.identityNumber : 'Belum diatur',
                isDarkMode: isDarkMode,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileImage(UserProfile profile) {
    return GestureDetector(
      onTap: _logic.pickAndUploadImage,
      child: Stack(
        children: [
          Hero(
            tag: 'profile-image',
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 48,
                backgroundImage: profile.profilePicture.isNotEmpty
                    ? NetworkImage(profile.profilePicture)
                    : null,
                child: profile.profilePicture.isEmpty
                    ? profile.name.isNotEmpty
                        ? Text(
                            profile.name[0].toUpperCase(),
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                          )
                        : const Icon(Icons.person, size: 48)
                    : null,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.camera_alt, color: primaryColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      dense: true,
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            final profile = context.read<ProfileProvider>().userProfile;
            if (profile != null) {
              _logic.navigateToEditProfile(profile);
            }
          },
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profil'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _showLogoutDialog(),
          icon: const Icon(Icons.logout),
          label: const Text('Keluar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logic.signOut();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primaryColor,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}