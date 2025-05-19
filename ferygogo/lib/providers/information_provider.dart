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

  List<InformationModel> get information => _information;
  bool get isLoading => _isLoading;
  String? get error => _error;
  InformationModel? get selectedInfo => _selectedInfo;
  InformationModel? get mainAnnouncement => _mainAnnouncement;
  Future<void> fetchInformation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('information')
          .orderBy('publishDate', descending: true)
          .get();      _information.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final info = InformationModel.fromMap(data, doc.id);
        
        // Store main announcement separately
        if (doc.id == '1Z0A0MphzFKGdOoPdhUX') {
          _mainAnnouncement = info;
        } else {
          _information.add(info);
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
        notifyListeners();
      }
    } catch (e) {
      _error = 'Gagal memuat informasi spesifik: ${e.toString()}';
      notifyListeners();
    }
  }
}
