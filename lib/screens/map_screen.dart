import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/place.dart';
import '../models/event.dart';
import '../services/mimesita_repository.dart';
import '../services/location_service.dart';
import '../services/mock_data.dart';
import '../constants/app_colors.dart';
import '../constants/categories.dart';
import '../widgets/category_chips.dart';
import '../widgets/star_rating.dart';
import 'place_detail_screen.dart';

class MapScreen extends StatefulWidget {
  final MimesitaRepository repository;

  const MapScreen({super.key, required this.repository});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Place? _selectedPlace;
  WeekendEvent? _selectedEvent;

  @override
  Widget build(BuildContext context) {
    final places = widget.repository.approvedPlaces;
    final events = widget.repository.approvedEvents;

    final markers = <Marker>[];

    // 1. Current user location marker
    markers.add(
      Marker(
        point: LatLng(LocationService.currentLat, LocationService.currentLng),
        width: 36,
        height: 36,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // 2. Places Markers
    for (final place in places) {
      final catInfo = CategoryHelper.getInfo(place.category);
      final isSelected = _selectedPlace?.id == place.id;

      markers.add(
        Marker(
          point: LatLng(place.latitude, place.longitude),
          width: isSelected ? 54 : 44,
          height: isSelected ? 54 : 44,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedPlace = place;
                _selectedEvent = null;
              });
              _mapController.move(
                LatLng(place.latitude - 0.005, place.longitude),
                14.5,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : catInfo.color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  catInfo.emoji,
                  style: TextStyle(fontSize: isSelected ? 24 : 18),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 3. Events Markers
    for (final event in events) {
      final isSelected = _selectedEvent?.id == event.id;

      markers.add(
        Marker(
          point: LatLng(event.latitude, event.longitude),
          width: isSelected ? 54 : 44,
          height: isSelected ? 54 : 44,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedEvent = event;
                _selectedPlace = null;
              });
              _mapController.move(
                LatLng(event.latitude - 0.005, event.longitude),
                14.5,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white,
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🎉', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        // OpenStreetMap Layer
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(MockData.defaultLat, MockData.defaultLng),
            initialZoom: 13.0,
            onTap: (_, __) {
              if (_selectedPlace != null || _selectedEvent != null) {
                setState(() {
                  _selectedPlace = null;
                  _selectedEvent = null;
                });
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.mimesita.app',
            ),
            MarkerLayer(markers: markers),
          ],
        ),

        // Floating Top Category Chips
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: CategoryChips(
              selectedCategory: widget.repository.selectedCategory,
              onCategorySelected: (cat) {
                widget.repository.setCategory(cat);
              },
            ),
          ),
        ),

        // Recenter Button
        Positioned(
          right: 16,
          bottom: _selectedPlace != null || _selectedEvent != null ? 180 : 24,
          child: FloatingActionButton.small(
            heroTag: 'recenter_btn',
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            elevation: 3,
            onPressed: () {
              _mapController.move(
                LatLng(MockData.defaultLat, MockData.defaultLng),
                13.0,
              );
            },
            child: const Icon(Icons.my_location),
          ),
        ),

        // Floating Bottom Preview Sheet (Place)
        if (_selectedPlace != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: _buildPlaceBottomPreview(_selectedPlace!),
          ),

        // Floating Bottom Preview Sheet (Event)
        if (_selectedEvent != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: _buildEventBottomPreview(_selectedEvent!),
          ),
      ],
    );
  }

  Widget _buildPlaceBottomPreview(Place place) {
    final catInfo = CategoryHelper.getInfo(place.category);
    final photoUrl = place.photos.isNotEmpty ? place.photos.first : null;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade200,
                child: photoUrl != null
                    ? Image.network(photoUrl, fit: BoxFit.cover)
                    : const Icon(Icons.place, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(catInfo.emoji, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        catInfo.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: catInfo.color,
                        ),
                      ),
                      const Spacer(),
                      StarRating(
                        rating: place.ratingAvg,
                        count: place.ratingCount,
                        size: 13,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (place.distanceKm != null) ...[
                        const Icon(Icons.near_me, size: 12, color: AppColors.primary),
                        const SizedBox(width: 2),
                        Text(
                          '${place.distanceKm!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        place.priceLevel,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // View Details Action
            IconButton.filled(
              icon: const Icon(Icons.arrow_forward, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PlaceDetailScreen(
                      place: place,
                      repository: widget.repository,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventBottomPreview(WeekendEvent event) {
    final catInfo = CategoryHelper.getInfo(event.category);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('🎉', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'FIN DE SEMANA',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(catInfo.emoji, style: const TextStyle(fontSize: 10)),
                      const SizedBox(width: 2),
                      Text(
                        catInfo.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: catInfo.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${event.ticketPrice} • ${event.distanceKm != null ? '${event.distanceKm!.toStringAsFixed(1)} km' : ''}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
