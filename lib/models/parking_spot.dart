// parking_spot.dart içindeki değişiklik:
class ParkingSpot {
  final int spotNumber;
  final bool isOccupied;
  final bool isReserved; // <-- YENİ EKLENEN
  final DateTime? lastUpdated;

  const ParkingSpot({
    required this.spotNumber,
    required this.isOccupied,
    this.isReserved = false, // <-- YENİ EKLENEN (Varsayılan false)
    this.lastUpdated,
  });

  factory ParkingSpot.fromJson(Map<String, dynamic> json) {
    return ParkingSpot(
      spotNumber:  json['spot_number'] as int,
      isOccupied:  json['is_occupied'] as bool,
      isReserved:  json['is_reserved'] ?? false, // <-- YENİ EKLENEN
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'] as String)
          : null,
    );
  }
}

class ParkingSummary {
  final int total;
  final int occupied;
  final int empty;

  const ParkingSummary({
    required this.total,
    required this.occupied,
    required this.empty,
  });

  factory ParkingSummary.fromJson(Map<String, dynamic> json) {
    return ParkingSummary(
      total:    json['total']    as int,
      occupied: json['occupied'] as int,
      empty:    json['empty']    as int,
    );
  }

  double get occupancyRate => total > 0 ? occupied / total : 0.0;
}