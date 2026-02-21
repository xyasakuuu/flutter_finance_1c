import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../models/weather_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isIntegrationEnabled = false;
  Future<WeatherData>? futureWeather;
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Глубокий темный фон
      appBar: AppBar(
        title: const Text('Мой Гараж', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      // Используем SingleChildScrollView, чтобы экран можно было листать
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Главная карточка автомобиля (с картинкой из интернета)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    image: const DecorationImage(
                      // Прямая ссылка на стильное фото внедорожника
                      image: NetworkImage('https://yandex-images.clstorage.net/F9QHF8399/d7ad0cVAn/JRo6gkRPhs17FZlq86i5SC0Sudwfrq6IQsKBbHsfIwvPd3k5L15Y3AYERHrpIiR6CrDXcMcWfGbdcRY15ag0ZiwaZrN0J5qZagTcY_qJ7U0FS4HRGvvzqDqb8HwH_8vef_vR1duykUzmXA1_sHMgH3u9frHe1-jnIOG79Sh91NO1ep9nsf_mAathUcYKBMmMALbVnLsi9lVeaqmJa9OTmt83lQm3OlF8-rzd52zjKa_b3bbY2p8Qp3htN5G49ezz_QbH-8VDOgXn8dmCFowpBKQKfXg3Jo4BOlrF5ftDm77Lp4FlB_7VUIqEYc-Mz903c92GcH5vRB9g7QsRLPmgx2kW20fBk169t4UpRoYg0YzM4kmwi9qq5TZ2ieUTU1-Soxu1VdNaKVDKaGFbtCMdQ9vpitxCq4BrrK2zifglTPPllstXPUfeva8FwSb2MLXcpOLFsCvmmil2qsXxZ4v3Fn9fFSHziq1w0tANd3RbIZt3hRqc_udwXzx9ix187WCjOb77W113mqFjBX0e6pjJ6DxCTXw3jha5_iYZkW_XVwZTS6nZ-x5lWA4UGeNEo_VH7x3CyApziDegIT_5oKlk-33Wl8_lF7Lx09X9-jYsyRzQakWMby7-Ma5yQXGHr1cG8xvJXYNaleAeDK0j_Ptpz9MdrgiOU7AriIm3BVyBXCtVnv__vRcuydeN2SpejEVEtHJhvAMuPnkmqg35p1-vcp9bAXmDCjmwChTpd_hbEWtP9apI5hPwW2Rpv02wpdBnuUqvW9FT1jWXQdUq4tRtHEw6QVCjguZxVlI1WQ_TX7qzT7lJL97NsEpQ2UPI_22Tl80WcBJzmF9QBZMFYAFE52UyH_-l95IRd9mNjuZcpZAkemX8H2aO9To-rSUvk3-eM_cB4aMaFcTGPFXfMLNhB2eVnoTWY5h3gO2HTezt9Dcx4t9nKdfWRe_1BYamKBUMCBY9dAv-hg3uHs3tl5tc'),
                      fit: BoxFit.cover,
                      opacity: 0.6, // Слегка затемняем картинку, чтобы текст читался
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Toyota RAV4 (XA10)', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Двигатель: 3S-FE • 1997 г.в.', style: TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text('ИНСТРУМЕНТЫ ДЛЯ ВЫЕЗДА', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 12),

              // 2. Модуль погоды (Компактный)
              Card(
                color: const Color(0xFF1E1E1E),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.radar, color: Colors.orangeAccent),
                              SizedBox(width: 10),
                              Text('Радар погоды', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Switch(
                            activeColor: Colors.orangeAccent,
                            value: _isIntegrationEnabled,
                            onChanged: (bool value) {
                              setState(() {
                                _isIntegrationEnabled = value;
                                futureWeather = _isIntegrationEnabled ? _apiService.fetchWeather() : null;
                              });
                            },
                          ),
                        ],
                      ),
                      if (_isIntegrationEnabled) ...[
                        const Divider(color: Colors.white24, height: 24),
                        FutureBuilder<WeatherData>(
                          future: futureWeather,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildWeatherInfo(Icons.thermostat, '${snapshot.data!.temperature} °C', 'Температура'),
                                  _buildWeatherInfo(Icons.air, '${snapshot.data!.windSpeed} км/ч', 'Ветер'),
                                ],
                              );
                            } else if (snapshot.hasError) {
                              return Text('Ошибка: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent));
                            }
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(color: Colors.orangeAccent),
                            );
                          },
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Модуль управления (Кнопка уведомлений)
              Card(
                color: const Color(0xFF1E1E1E),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.build, color: Colors.orangeAccent),
                  ),
                  title: const Text('Чек-лист перед выездом', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Напоминание о проверке жидкостей', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    NotificationService().showNotification(
                      title: 'Гараж',
                      body: 'Проверь уровень масла в двигателе и давление в шинах!',
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Вспомогательный виджет для красивого отображения погоды
  Widget _buildWeatherInfo(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}