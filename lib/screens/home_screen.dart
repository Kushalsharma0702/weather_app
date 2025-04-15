import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'search_screen.dart';
import '../services/weather_service.dart';
import 'details_screen.dart';
import 'stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String cityName = 'Greater Noida';
  String temperature = '';
  String description = '';
  String icon = '';
  double windSpeed = 0;
  int humidity = 0;
  int pressure = 0;
  bool isLoading = true;

  void fetchWeather(String city) async {
    setState(() => isLoading = true);
    try {
      final data = await WeatherService.getWeather(city);
      setState(() {
        cityName = city;
        temperature = '${data['main']['temp'].round()}°C';
        description = data['weather'][0]['main'];
        icon = data['weather'][0]['icon'];
        windSpeed = data['wind']['speed']?.toDouble() ?? 0;
        humidity = data['main']['humidity']?.toInt() ?? 0;
        pressure = data['main']['pressure']?.toInt() ?? 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load weather: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather(cityName);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMM d, yyyy – hh:mm a').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Today',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const SearchScreen(),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
              if (result != null) {
                fetchWeather(result);
              }
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF48C6EF), Color(0xFF6F86D6)],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              cityName,
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              formattedDate,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 30),
            Image.network(
              'https://openweathermap.org/img/wn/$icon@4x.png',
              height: 150,
            ),
            const SizedBox(height: 10),
            Text(
              temperature,
              style: GoogleFonts.poppins(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              description,
              style: GoogleFonts.poppins(fontSize: 22, color: Colors.white70),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StatCard(label: 'Wind', value: '${windSpeed.toStringAsFixed(1)} km/h'),
                StatCard(label: 'Humidity', value: '$humidity%'),
                StatCard(label: 'Pressure', value: '$pressure hPa'),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  buildHourlyCard('23°C', Icons.cloud),
                  buildHourlyCard('21°C', Icons.bolt),
                  buildHourlyCard('22°C', Icons.cloud_outlined),
                  buildHourlyCard('19°C', Icons.nightlight_round),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailsScreen(city: cityName),
                  ),
                );
              },
              child: Text(
                '7-Day Forecast',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHourlyCard(String temp, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            temp,
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
