import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp3/home.dart';
import 'package:weatherapp3/providers/location_provider.dart';
import 'package:weatherapp3/providers/weather_provider.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
          ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home:Homepage()
    );
  }
}
