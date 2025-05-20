import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../models/user_profile.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:convert';
import 'package:image_cropper/image_cropper.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({Key? key, required this.profile}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _identityNumberController;
  final TextEditingController _otherIdentityTypeController =
      TextEditingController(); // Inisialisasi langsung di sini
  DateTime? _selectedBirthDate;
  String? _selectedGender;
  String? _selectedIdentityType;
  bool _isOtherIdentityType = false;

  // Add image related variables
  File? _image;
  String? _base64Image;
  final ImagePicker _picker = ImagePicker();

  // Define gender options
  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];

  // Define identity type options
  final List<String> _identityTypes = [
    'KTP',
    'SIM',
    'NIK',
    'Kartu Pelajar',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
    _identityNumberController = TextEditingController(
      text: widget.profile.identityNumber,
    );

    _selectedBirthDate = widget.profile.birthDate;
    _selectedGender = widget.profile.gender;

    // Initialize base64Image from profile if exists
    if (widget.profile.imageBase64 != null &&
        widget.profile.imageBase64!.isNotEmpty) {
      _base64Image = widget.profile.imageBase64;
    }

    // Initialize identity type
    if (widget.profile.identityType.isNotEmpty) {
      if (_identityTypes.contains(widget.profile.identityType)) {
        _selectedIdentityType = widget.profile.identityType;
      } else {
        _selectedIdentityType = 'Lainnya';
        _isOtherIdentityType = true;
        _otherIdentityTypeController.text = widget.profile.identityType;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _identityNumberController.dispose();
    _otherIdentityTypeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      // Crop image to circle (image_cropper v2.x-5.x.x)
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Potong Gambar',
            toolbarColor: const Color(0xFF0F52BA),
            toolbarWidgetColor: Colors.white,
            hideBottomControls: true,
          ),
          IOSUiSettings(
            title: 'Potong Gambar',
            aspectRatioLockEnabled: true,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _image = File(croppedFile.path);
        });
        await _compressAndEncodeImage();
      }
    }
  }

  Future<void> _compressAndEncodeImage() async {
    if (_image == null) return;
    final compressedImage = await FlutterImageCompress.compressWithFile(
      _image!.path,
      quality: 50,
    );
    if (compressedImage == null) return;
    setState(() {
      _base64Image = base64Encode(compressedImage);
    });
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pilih Sumber Gambar"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
            child: const Text("Kamera"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: const Text("Galeri"),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<ProfileProvider>().updateProfile(
            name: _nameController.text,
            phoneNumber: _phoneController.text,
            gender: _selectedGender ?? '',
            birthDate: _selectedBirthDate,
            identityType: _isOtherIdentityType
                ? _otherIdentityTypeController.text
                : _selectedIdentityType ?? '',
            identityNumber: _identityNumberController.text,
            imageBase64: _base64Image, // Add the base64 image
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: const Color(0xFF0F52BA),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: 120,
                    height: 120,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: _image != null
                        ? Image.file(_image!, fit: BoxFit.cover, width: 120, height: 120)
                        : _base64Image != null
                            ? Image.memory(base64Decode(_base64Image!), fit: BoxFit.cover, width: 120, height: 120)
                            : const Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Informasi Akun',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              const Text(
                'Informasi Pribadi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Gender Radio Buttons
              const Text('Jenis Kelamin'),
              const SizedBox(height: 8),
              ...List.generate(_genderOptions.length, (index) {
                return RadioListTile<String>(
                  title: Text(_genderOptions[index]),
                  value: _genderOptions[index],
                  groupValue: _selectedGender,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                );
              }),
              const SizedBox(height: 16),

              // Birth Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Lahir',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedBirthDate != null
                        ? DateFormat('dd MMMM yyyy')
                            .format(_selectedBirthDate!)
                        : 'Pilih tanggal lahir',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Identity Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedIdentityType,
                decoration: const InputDecoration(
                  labelText: 'Jenis Identitas',
                  border: OutlineInputBorder(),
                ),
                items: _identityTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedIdentityType = value;
                    _isOtherIdentityType = value == 'Lainnya';
                    if (!_isOtherIdentityType) {
                      _otherIdentityTypeController
                          .clear(); // Clear ketika bukan Lainnya
                    }
                  });
                },
              ),
              if (_isOtherIdentityType) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _otherIdentityTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Masukkan Jenis Identitas Lainnya',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_isOtherIdentityType &&
                        (value == null || value.isEmpty)) {
                      return 'Jenis identitas tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _identityNumberController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Identitas',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F52BA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
