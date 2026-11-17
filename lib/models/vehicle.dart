import '../core/utils/text_utils.dart';

class Vehicle {
  Vehicle({
    required this.id,
    this.name,
    this.regNumber,
    this.vehiclePassport,
    this.permitExpired,
  });

  final int id;
  final String? name;
  final String? regNumber;
  final String? vehiclePassport;
  final String? permitExpired;

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id:
          parseApiInt(json['id'] ?? json['vehicleId'] ?? json['vechicleId']) ??
          0,
      name: cleanApiTextOrNull(
        json['name'] ?? json['vehicleName'] ?? json['vechicleName'],
      ),
      regNumber: cleanApiTextOrNull(
        json['regNumber'] ??
            json['registrationNumber'] ??
            json['vehicleRegNumber'],
      ),
      vehiclePassport: cleanApiTextOrNull(
        json['vehiclePassport'] ??
            json['certNumber'] ??
            json['passport'] ??
            json['technicalPassport'],
      ),
      permitExpired: cleanApiTextOrNull(
        json['permitExpired'] ?? json['permissionExpired'],
      ),
    );
  }
}
