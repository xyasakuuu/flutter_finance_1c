class WeatherData {
  final double temperature;
  final double windSpeed;

  WeatherData({required this.temperature, required this.windSpeed});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['current_weather']['temperature'],
      windSpeed: json['current_weather']['windspeed'],
    );
  }
}