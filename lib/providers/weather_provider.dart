import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WeatherProvider with ChangeNotifier {
  Map<String, dynamic>? _currentWeather;
  String? _error;
  bool _isLoading = false;

  Map<String, dynamic>? get currentWeather => _currentWeather;
  String? get error => _error;
  bool get isLoading => _isLoading;

  static const String apiKey = '3ce1a493f06a3a12ea288356faffdf4a'; // Replace with your OpenWeatherMap API key
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<void> fetchWeather(String cityName) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl?q=$cityName&appid=$apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        _currentWeather = json.decode(response.body);
        _error = null;
      } else {
        _error = 'City not found or API error';
        _currentWeather = null;
      }
    } catch (e) {
      _error = 'Failed to fetch weather data: ${e.toString()}';
      _currentWeather = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}