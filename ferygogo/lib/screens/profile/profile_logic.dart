import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../models/user_profile.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreenLogic {
  final BuildContext context;
  bool _mounted = true;
  
  bool get mounted => _mounted;

  ProfileScreenLogic(this.context);

  void dispose() {
    _mounted = false;
  }

  Future<void> loadProfile() async {
    await context.read<ProfileProvider>().loadUserProfile();
  }

  // Hanya ambil gambar, kompres, encode base64, dan update ke Firestore
  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      final file = File(pickedFile.path);
      // Kompres gambar
      final compressedImage = await FlutterImageCompress.compressWithFile(
        file.path,
        quality: 50,
      );
      if (compressedImage == null) return;
      final base64Image = base64Encode(compressedImage);
      // Update profile dengan base64Image
      await context.read<ProfileProvider>().updateProfile(
        imageBase64: base64Image,
        // ...tambahkan field lain jika perlu
      );
      // Setelah update, refresh profile
      await context.read<ProfileProvider>().loadUserProfile();
    }
  }

  Future<void> signOut() async {
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

  void navigateToEditProfile(UserProfile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profile: profile),
      ),
    ).then((_) {
      if (mounted) {
        context.read<ProfileProvider>().loadUserProfile();
      }
    });
  }
}
