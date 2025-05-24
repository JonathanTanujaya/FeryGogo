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
    try {      _information.clear();
      final snapshot = await _firestore.collection('information').get();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        // Perbaikan: cek dan trim spasi pada imageUrl jika ada
        if (data['imageUrl'] is String) {
          data['imageUrl'] = data['imageUrl'].trim();
        }        final info = InformationModel.fromMap(data, doc.id);
        _information.add(info);
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
        // Perbaikan: cek dan trim spasi pada imageUrl jika ada
        if (data['imageUrl'] is String) {
          data['imageUrl'] = data['imageUrl'].trim();
        }
        final info = InformationModel.fromMap(data, docSnapshot.id);
        _selectedInfo = info;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat detail: ${e.toString()}';
      notifyListeners();
    }
  }
}
