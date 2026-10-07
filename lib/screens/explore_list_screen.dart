import 'package:flutter/material.dart';
import '../services/mimesita_repository.dart';
import '../constants/app_colors.dart';
import '../constants/categories.dart';
import '../widgets/category_chips.dart';
import '../widgets/place_card.dart';
import '../widgets/event_card.dart';
import 'place_detail_screen.dart';

class ExploreListScreen extends StatelessWidget {
  final MimesitaRepository repository;

  const ExploreListScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final places = repository.approvedPlaces;
        final events = repository.approvedEvents;

        return CustomScrollView(
          slivers: [
            // Search Bar & Location Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search TextField
                    TextField(
                      onChanged: (val) => repository.setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Buscar comida, fotos, escalada, café...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                        suffixIcon: repository.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => repository.setSearchQuery(''),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal Categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: CategoryChips(
                  selectedCategory: repository.selectedCategory,
                  onCategorySelected: (cat) => repository.setCategory(cat),
                ),
              ),
            ),

            // Weekend Events Carousel
            if (events.isNotEmpty && repository.searchQuery.isEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      const Text(
                        '🎉 Eventos del Fin de Semana',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${events.length} disponibles',
                        style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return EventCard(
                        event: event,
                        onTap: () {
                          // Show event quick dialog
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: Text(event.title),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(event.description),
                                  const SizedBox(height: 12),
                                  Text('🎟️ Costo: ${event.ticketPrice}',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  if (event.distanceKm != null)
                                    Text('📍 Distancia: ${event.distanceKm!.toStringAsFixed(1)} km'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],

            // Top Places Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  children: [
                    const Text(
                      '🌟 Los Mejores Lugares',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${places.length} lugares ordenados por distancia',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),

            // Places List
            if (places.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 54, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No se encontraron lugares en esta categoría',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () {
                            repository.setCategory(PlaceCategory.all);
                            repository.setSearchQuery('');
                          },
                          child: const Text('Ver todos los lugares'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final place = places[index];
                      return PlaceCard(
                        place: place,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PlaceDetailScreen(
                                place: place,
                                repository: repository,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: places.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 30),
            ),
          ],
        );
      },
    );
  }
}
