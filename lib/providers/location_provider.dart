import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  String? _error;
  String? _currentAddress;
  String? _currentCity;
  bool _isLoading = false;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  String? get currentCity => _currentCity;
  
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> initializeLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _checkLocationServices();
      await _getCurrentPosition();
      if (_currentPosition != null) {
        await _getAddressFromLatLng(_currentPosition!);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkLocationServices() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }
  }

  Future<void> _getCurrentPosition() async {
    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      _currentAddress = "${place.street}, ${place.locality}, ${place.country}";
      _currentCity = place.locality ?? place.administrativeArea ?? "Unknown City";
    } else {
      _currentCity = "City not available";
      _currentAddress = "Address not available";
    }
  }
}