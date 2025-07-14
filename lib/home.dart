import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp3/providers/location_provider.dart';
import 'package:weatherapp3/providers/weather_provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _cityController = TextEditingController();

Widget _buildWeatherCard(Map<String, dynamic>? weather) {
  if (weather == null) {
    return const Center(
      child: Text('Search for a city to see weather'),
    );
  }

  // Determine which image to show based on weather condition
  String weatherImage;
  String weatherCondition = weather['weather'][0]['main'].toLowerCase();
  
  if (weatherCondition.contains('clear')) {
    weatherImage = 'assets/sunny1.png';
  } else if (weatherCondition.contains('cloud')) {
    weatherImage = 'assets/cloudy1.png';
  } else if (weatherCondition.contains('rain') || weatherCondition.contains('drizzle')) {
    weatherImage = 'assets/rainy1.png';

  } else {
    weatherImage = 'assets/sunny1.png'; // Fallback image
  }

  return Card(
    color: Colors.amber[100],
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            '${weather['name']} - ${weather['main']['temp']?.toStringAsFixed(1) ?? 'N/A'}°C',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            weather['weather'][0]['main'],
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Image.asset(
            weatherImage,
            height: 200,
            width: 300,
            fit: BoxFit.contain,
          ),
        ],
      ),
    ),
  );
}

  Future<void> checkWeather(BuildContext context) async {
  final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
  
  if (_cityController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a city name')),
    );
    return;
  }

  try {
    await weatherProvider.fetchWeather(_cityController.text);
    
    if (weatherProvider.currentWeather == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('City not found! Please try again.')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching weather: ${e.toString()}')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Weather App')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(21.0),
              child: TextField(
                
                controller: _cityController,
                decoration: InputDecoration(
                   border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0), // Rounded corners
                    ),
                  labelText: 'Enter city name',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {

                      checkWeather(context);


                    },
                  ),
                ),
              ),
            ),
            
          
            
            const SizedBox(height: 15),
            
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.amber[100],
              ),
              height: 400,
              width: 370,
              child: weatherProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildWeatherCard(weatherProvider.currentWeather),
            ),
            
            const SizedBox(height: 15),
            
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.amber[100],
              ),
              height: 200,
              width: 370,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWeatherDetail(Icons.wb_sunny, "Sunrise", "6:30 AM"),
                        _buildWeatherDetail(Icons.air, "Wind", "${weatherProvider.currentWeather?['wind']['speed'] ?? '0'} m/s"),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWeatherDetail(Icons.thermostat, "Temp", "${weatherProvider.currentWeather?['main']['temp'] ?? '0'}°C"),
                        _buildWeatherDetail(Icons.water_drop, "Humidity", "${weatherProvider.currentWeather?['main']['humidity'] ?? '0'}%"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 30),
       
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }


Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permission permanently denied.');
      await Geolocator.openAppSettings(); // You can also show a dialog
      return;
    }

    // Permissions granted – get position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        forceAndroidLocationManager: true,
      );
      print("Lat: ${position.latitude}, Long: ${position.longitude}");
      // getCurrentCityWeather(position);

    } catch (e) {
      print('Error getting location: $e');
    }
  }


     


    }











