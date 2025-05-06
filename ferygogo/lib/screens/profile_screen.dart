import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: const Color(0xFF0F52BA),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF0F52BA),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      'AP',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F52BA),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Angga Praja',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'angga@example.com',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  ProfileMenuItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profil',
                  ),
                  ProfileMenuItem(
                    icon: Icons.history,
                    title: 'Riwayat Pemesanan',
                  ),
                  ProfileMenuItem(
                    icon: Icons.payment,
                    title: 'Metode Pembayaran',
                  ),
                  ProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifikasi',
                  ),
                  ProfileMenuItem(
                    icon: Icons.help_outline,
                    title: 'Bantuan',
                  ),
                  ProfileMenuItem(
                    icon: Icons.logout,
                    title: 'Keluar',
                    textColor: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? textColor;

  const ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        // TODO: Implement navigation
      },
    );
  }
}
