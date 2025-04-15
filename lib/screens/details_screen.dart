import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailsScreen extends StatefulWidget {
  final String city;

  const DetailsScreen({super.key, required this.city});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  List<dynamic> forecastData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchForecast();
  }

  Future<void> fetchForecast() async {
    final apiKey = 'ceb7acd7ff0bed570c184ad38e092f42'; // Replace with your OpenWeatherMap API key
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?q=${widget.city}&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);
      final List<dynamic> list = data['list'];

      // Picking only one forecast per day at 12:00 PM
      final filtered = list.where((item) => item['dt_txt'].contains('12:00:00')).toList();

      setState(() {
        forecastData = filtered;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch forecast: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '${widget.city} Forecast',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          padding: const EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 16),
          itemCount: forecastData.length,
          itemBuilder: (context, index) {
            final day = forecastData[index];
            final date = DateTime.parse(day['dt_txt']);
            final temp = day['main']['temp'].round();
            final desc = day['weather'][0]['main'];
            final icon = day['weather'][0]['icon'];
            final wind = day['wind']['speed'];
            final humidity = day['main']['humidity'];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Image.network(
                    'https://openweathermap.org/img/wn/$icon@2x.png',
                    width: 60,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${date.weekdayName()}, ${date.day}/${date.month}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$desc • $temp°C',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          'Wind: ${wind.toStringAsFixed(1)} km/h • Humidity: $humidity%',
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

extension on DateTime {
  String weekdayName() {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday % 7];
  }
}
