import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parking_spot.dart';

class ApiResult<T> {
  final T? data;
  final String? error;
  bool get isSuccess => error == null;

  const ApiResult.success(this.data) : error = null;
  const ApiResult.failure(this.error) : data = null;
}

class ApiService {
  static const _defaultBase = 'http://10.0.2.2:8000'; // Android emülatör → localhost
  static const _spotsPath   = '/api/spots/';
  static const _healthPath  = '/api/health/';
  static const _timeout     = Duration(seconds: 8);

  /// Kaydedilmiş ya da varsayılan base URL'yi döner.
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('server_url') ?? _defaultBase;
  }

  /// Sunucu adresini kaydeder.
  static Future<void> saveBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    // Sondaki / varsa temizle
    await prefs.setString('server_url', url.trimRight().replaceAll(RegExp(r'/+$'), ''));
  }

  /// Park yerlerini ve özet istatistiği çeker.
  static Future<ApiResult<({List<ParkingSpot> spots, ParkingSummary summary})>>
  fetchSpots() async {
    try {
      final base = await getBaseUrl();
      final uri  = Uri.parse('$base$_spotsPath');
      final res  = await http.get(uri).timeout(_timeout);

      if (res.statusCode == 200) {
        final body    = jsonDecode(res.body) as Map<String, dynamic>;
        final spots   = (body['spots'] as List)
            .map((e) => ParkingSpot.fromJson(e as Map<String, dynamic>))
            .toList();
        final summary = ParkingSummary.fromJson(body['summary'] as Map<String, dynamic>);
        return ApiResult.success((spots: spots, summary: summary));
      }
      return ApiResult.failure('Sunucu hatası: ${res.statusCode}');
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('TimeoutException')) return ApiResult.failure('Zaman aşımı — sunucu yanıt vermiyor');
      if (msg.contains('SocketException'))  return ApiResult.failure('Bağlantı kurulamadı — IP adresi doğru mu?');
      return ApiResult.failure('Hata: $msg');
    }
  }

  /// Sunucuya ping atar; bağlantı durumunu döner.
  static Future<bool> healthCheck() async {
    try {
      final base = await getBaseUrl();
      final res  = await http.get(Uri.parse('$base$_healthPath')).timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}