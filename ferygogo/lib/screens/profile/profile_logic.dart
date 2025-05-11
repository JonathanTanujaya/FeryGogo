import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'dart:io';
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

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      final file = File(pickedFile.path);
      final fileName = 'profile_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg';

      try {
        final ref = FirebaseStorage.instance.ref().child(fileName);
        await ref.putFile(file);
        final imageUrl = await ref.getDownloadURL();
        
        if (mounted) {
          await context.read<ProfileProvider>().updateProfilePicture(imageUrl);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengunggah gambar: $e')),
          );
        }
      }
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
