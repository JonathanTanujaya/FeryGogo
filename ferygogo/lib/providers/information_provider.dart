import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/information_model.dart';

class InformationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<InformationModel> _information = [];
  bool _isLoading = false;
  String? _error;
  InformationModel? _selectedInfo;
  InformationModel? _mainAnnouncement;
  List<Map<String, dynamic>>? _subcollectionData;

  List<InformationModel> get information => _information;
  bool get isLoading => _isLoading;
  String? get error => _error;
  InformationModel? get selectedInfo => _selectedInfo;
  InformationModel? get mainAnnouncement => _mainAnnouncement;
  List<Map<String, dynamic>>? get subcollectionData => _subcollectionData;

  Future<void> fetchInformation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();    
    try {
      // Daftar ID yang ingin diambil
      final List<String> documentIds = ['N001', 'N002', 'N003', 'N004'];
      _information.clear();

      // Ambil dokumen satu per satu berdasarkan ID
      for (String id in documentIds) {
        final docSnapshot = await _firestore
            .collection('information')
            .doc(id)
            .get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data()!;
          final info = InformationModel.fromMap(data, docSnapshot.id);
          _information.add(info);
          
          // Jika ini pengumuman utama
          if (id == '1Z0A0MphzFKGdOoPdhUX') {
            _mainAnnouncement = info;
          }
        } else {
          print('Document $id does not exist');
        }
      }

      // Add main announcement at the beginning if it exists
      if (_mainAnnouncement != null) {
        _information.insert(0, _mainAnnouncement!);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat informasi: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshInformation() async {
    await fetchInformation();
  }

  Future<void> fetchSpecificInformation(String id) async {
    try {
      final docSnapshot = await _firestore
          .collection('information')
          .doc(id)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final info = InformationModel.fromMap(data, docSnapshot.id);
        
        if (id == '1Z0A0MphzFKGdOoPdhUX') {
          _mainAnnouncement = info;
        }
        _selectedInfo = info;

        // Fetch subcollection data based on document ID
        if (id == 'N004') {
          final subcollectionSnapshot = await _firestore
              .collection('information')
              .doc(id)
              .collection('IN004')
              .get();

          _subcollectionData = subcollectionSnapshot.docs
              .map((doc) => doc.data())
              .toList();
        } else if (id == 'N001') {
          final subcollectionSnapshot = await _firestore
              .collection('information')
              .doc(id)
              .collection('isi')
              .doc('IN001')
              .get();

          if (subcollectionSnapshot.exists) {
            _subcollectionData = [subcollectionSnapshot.data()!];
          } else {
            _subcollectionData = null;
          }
        } else {
          _subcollectionData = null;
        }
        
        notifyListeners();
      }
    } catch (e) {
      _error = 'Gagal memuat informasi spesifik: ${e.toString()}';
      notifyListeners();
    }
  }
}
