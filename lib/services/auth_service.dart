import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String?> register(String login, String password) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('hash_$login')) {
      return 'Логин уже занят';
    }
    await prefs.setString('hash_$login', _hashPassword(password));
    return null;
  }

  Future<String?> login(String login, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedHash = prefs.getString('hash_$login');

    if (savedHash == null) return 'Пользователь не найден';
    if (savedHash != _hashPassword(password)) return 'Неверный пароль';

    return null;
  }
}