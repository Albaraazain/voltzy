import 'package:geolocator/geolocator.dart';
import '../utils/error_handler.dart';

class LocationService {
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const ErrorHandler('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const ErrorHandler('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const ErrorHandler(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream();
  }

  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert to kilometers
  }

  static bool isWithinRadius(
    double centerLat,
    double centerLng,
    double pointLat,
    double pointLng,
    double radiusKm,
  ) {
    double distance = calculateDistance(
      centerLat,
      centerLng,
      pointLat,
      pointLng,
    );
    return distance <= radiusKm;
  }
}
