import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/parking_spot.dart';
import '../services/api_service.dart';

enum ConnectionStatus { connecting, connected, error }

class ParkingProvider extends ChangeNotifier {
  List<ParkingSpot>  spots   = [];
  ParkingSummary?    summary;
  ConnectionStatus   status  = ConnectionStatus.connecting;
  String             errorMsg = '';
  DateTime?          lastUpdated;

  Timer? _timer;
  static const _interval = Duration(seconds: 3);

  // ── YENİ EKLENEN: REZERVASYON DEĞİŞKENLERİ ──
  int? activeReservationSpot;
  int reservationSecondsLeft = 0;
  Timer? _reservationCountdown;

  ParkingProvider() {
    _fetch();
    _timer = Timer.periodic(_interval, (_) => _fetch());
  }

  Future<void> _fetch() async {
    final result = await ApiService.fetchSpots();
    if (result.isSuccess) {
      spots       = result.data!.spots;
      summary     = result.data!.summary;
      status      = ConnectionStatus.connected;
      errorMsg    = '';
      lastUpdated = DateTime.now();

      // MANTIK: Eğer rezerve ettiğimiz yere fiziksel olarak araba gelirse (isOccupied true olursa)
      // rezervasyon geri sayımını otomatik olarak durdur ve kapat.
      if (activeReservationSpot != null) {
        final reservedSpotData = spots.firstWhere(
                (s) => s.spotNumber == activeReservationSpot,
            orElse: () => const ParkingSpot(spotNumber: -1, isOccupied: false)
        );
        if (reservedSpotData.isOccupied) {
          cancelReservation();
        }
      }

    } else {
      status   = ConnectionStatus.error;
      errorMsg = result.error!;
    }
    notifyListeners();
  }

  /// Anlık yenileme (pull-to-refresh için)
  Future<void> refresh() => _fetch();

  // ── YENİ EKLENEN: REZERVASYON FONKSİYONLARI ──

  // 1. Rezervasyonu Başlat
  void reserveSpot(int spotNumber) {
    activeReservationSpot = spotNumber;
    reservationSecondsLeft = 15 * 60; // 15 dakika (900 saniye)

    _reservationCountdown?.cancel(); // Varsa eski sayacı durdur
    _reservationCountdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (reservationSecondsLeft > 0) {
        reservationSecondsLeft--;
        notifyListeners(); // Her saniye arayüzü güncelle
      } else {
        cancelReservation(); // Süre biterse iptal et
      }
    });
    notifyListeners();
  }

  // 2. Rezervasyonu İptal Et
  void cancelReservation() {
    _reservationCountdown?.cancel();
    activeReservationSpot = null;
    reservationSecondsLeft = 0;
    notifyListeners();
  }

  // 3. Süreyi MM:SS formatında (Örn: 14:59) arayüze gönder
  String get formattedTime {
    final minutes = (reservationSecondsLeft / 60).floor();
    final seconds = reservationSecondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _reservationCountdown?.cancel(); // Çıkışta geri sayımı da temizle
    super.dispose();
  }
}