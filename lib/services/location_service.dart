import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'mock_data.dart';
import '../models/place.dart';
import '../models/event.dart';

class LocationService {
  static double currentLat = MockData.defaultLat;
  static double currentLng = MockData.defaultLng;
  static bool hasRealLocation = false;

  /// Request GPS permission and fetch user's real location
  static Future<Position?> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );

      currentLat = position.latitude;
      currentLng = position.longitude;
      hasRealLocation = true;
      return position;
    } catch (e) {
      // Fallback gracefully to default coordinates (Mesa de los Santos)
      return null;
    }
  }

  /// Calculates distance in kilometers between two coordinates
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double p = 0.017453292519943295; // Math.PI / 180
    final double a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  /// Injects distance into places and sorts them
  static List<Place> enrichAndSortPlaces(
    List<Place> places, {
    double? originLat,
    double? originLng,
    bool sortByDistance = true,
  }) {
    final lat = originLat ?? currentLat;
    final lng = originLng ?? currentLng;

    for (final place in places) {
      place.distanceKm = calculateDistanceKm(
        lat,
        lng,
        place.latitude,
        place.longitude,
      );
    }

    final sorted = List<Place>.from(places);
    if (sortByDistance) {
      sorted.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
    } else {
      // Sort by rating & imperdible
      sorted.sort((a, b) {
        if (a.isImperdible && !b.isImperdible) return -1;
        if (!a.isImperdible && b.isImperdible) return 1;
        return b.ratingAvg.compareTo(a.ratingAvg);
      });
    }

    return sorted;
  }

  /// Injects distance into events and sorts them
  static List<WeekendEvent> enrichAndSortEvents(
    List<WeekendEvent> events, {
    double? originLat,
    double? originLng,
  }) {
    final lat = originLat ?? currentLat;
    final lng = originLng ?? currentLng;

    for (final event in events) {
      event.distanceKm = calculateDistanceKm(
        lat,
        lng,
        event.latitude,
        event.longitude,
      );
    }

    final sorted = List<WeekendEvent>.from(events);
    // Sort by proximity and urgency
    sorted.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
    return sorted;
  }
}
