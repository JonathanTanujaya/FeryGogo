import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionHandler {
  static Future<bool> requestLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;


    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showDialog(
        context,
        'Layanan lokasi tidak aktif. Aktifkan GPS untuk melanjutkan.',
      );
      return false;
    }
//seharusnya masih error
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        await _showDialog(
          context,
          'Akses lokasi diperlukan untuk menggunakan aplikasi ini.',
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await _showDialog(
        context,
        'Akses lokasi ditolak permanen. Buka pengaturan untuk mengaktifkannya.',
      );
      return false;
    }

    return true;
  }

  static Future<void> _showDialog(BuildContext context, String message) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Izin Lokasi'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }
}
