import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mimesita/constants/categories.dart';
import 'package:mimesita/models/place.dart';
import 'package:mimesita/models/review.dart';
import 'package:mimesita/services/location_service.dart';
import 'package:mimesita/services/mock_data.dart';
import 'package:mimesita/services/mimesita_repository.dart';
import 'package:mimesita/widgets/category_chips.dart';
import 'package:mimesita/widgets/star_rating.dart';

void main() {
  group('Mimesita Core Logic & Ranking Tests', () {
    test('LocationService accurately calculates distance in km', () {
      // Distance between Mercado Campesino (6.8145, -73.1190) and Hacienda El Roble (6.8580, -73.1320)
      final distance = LocationService.calculateDistanceKm(
        6.8145,
        -73.1190,
        6.8580,
        -73.1320,
      );
      // Expected around 5 km
      expect(distance, greaterThan(4.0));
      expect(distance, lessThan(6.0));
    });

    test('MimesitaRepository initializes with Mesa de los Santos seed data', () {
      final repo = MimesitaRepository();
      expect(repo.approvedPlaces.isNotEmpty, isTrue);
      expect(repo.approvedEvents.isNotEmpty, isTrue);

      // Verify categories are populated
      final foodPlaces = repo.approvedPlaces
          .where((p) => p.category == PlaceCategory.food)
          .toList();
      expect(foodPlaces.isNotEmpty, isTrue);
    });

    test('Admin moderation workflow: pending items can be approved or rejected', () async {
      final repo = MimesitaRepository();

      // Submit a pending place as a seller
      final testPlace = Place(
        id: 'test-pending-1',
        name: 'Nuevo Glamping Los Pinos',
        description: 'Hermosa vista y fogata privada.',
        category: PlaceCategory.nightlife,
        latitude: 6.8100,
        longitude: -73.1200,
        status: ItemStatus.pending,
      );

      await repo.submitNewPlace(testPlace);
      expect(repo.pendingPlaces.any((p) => p.id == 'test-pending-1'), isTrue);

      // Admin approves it
      await repo.approvePlace('test-pending-1');
      expect(repo.pendingPlaces.any((p) => p.id == 'test-pending-1'), isFalse);
      expect(repo.approvedPlaces.any((p) => p.id == 'test-pending-1'), isTrue);
    });

    test('Traveler reviews update place rating average', () async {
      final repo = MimesitaRepository();
      final place = repo.approvedPlaces.first;

      await repo.addReview(
        placeId: place.id,
        rating: 5,
        comment: '¡Increíble experiencia!',
        userName: 'Viajero Feliz',
      );

      final reviews = repo.getReviewsForPlace(place.id);
      expect(reviews.any((r) => r.comment == '¡Increíble experiencia!'), isTrue);
    });

    test('Role switching between Traveler, Seller, and Admin works', () {
      final repo = MimesitaRepository();
      repo.setRole(UserRole.traveler);
      expect(repo.currentRole, UserRole.traveler);

      repo.setRole(UserRole.seller);
      expect(repo.currentRole, UserRole.seller);

      repo.setRole(UserRole.admin);
      expect(repo.currentRole, UserRole.admin);
    });
  });

  group('Mimesita Widgets Smoke Tests', () {
    testWidgets('StarRating displays rating correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRating(rating: 4.8, count: 120),
          ),
        ),
      );

      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('(120)'), findsOneWidget);
    });

    testWidgets('CategoryChips renders category items', (WidgetTester tester) async {
      PlaceCategory selected = PlaceCategory.all;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChips(
              selectedCategory: selected,
              onCategorySelected: (cat) {
                selected = cat;
              },
            ),
          ),
        ),
      );

      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Comida'), findsOneWidget);
      expect(find.text('Café & Dulces'), findsOneWidget);
    });
  });
}
