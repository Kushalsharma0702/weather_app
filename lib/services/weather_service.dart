import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = 'ceb7acd7ff0bed570c184ad38e092f42';
  static const String _weatherUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const String _forecastUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  static Future<Map<String, dynamic>> getWeather(String city) async {
    final url = Uri.parse('$_weatherUrl?q=$city&appid=$_apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  static Future<Map<String, dynamic>> getForecast(String city) async {
    final url = Uri.parse('$_forecastUrl?q=$city&appid=$_apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load forecast data');
    }
  }
}
