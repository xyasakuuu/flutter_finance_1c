import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class ApiService {
  Future<WeatherData> fetchWeather() async {
    // Координаты Караганды
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=49.8&longitude=73.1&current_weather=true');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка загрузки данных о погоде');
    }
  }
}