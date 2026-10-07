import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/place.dart';
import '../services/mimesita_repository.dart';
import '../constants/app_colors.dart';
import '../constants/categories.dart';
import '../widgets/star_rating.dart';

class PlaceDetailScreen extends StatefulWidget {
  final Place place;
  final MimesitaRepository repository;

  const PlaceDetailScreen({
    super.key,
    required this.place,
    required this.repository,
  });

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  Future<void> _openMaps(double lat, double lng, String name) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWhatsApp(String phone, String placeName) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final msg = Uri.encodeComponent(
      'Hola! Vi tu negocio "$placeName" en la app Mimesita y quisiera más información para este fin de semana.',
    );
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$msg');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callPhone(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showAddReviewDialog() {
    int selectedRating = 5;
    final commentCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Calificar este Lugar'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Cómo fue tu experiencia?',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                // Star Selector
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNum = index + 1;
                      return IconButton(
                        iconSize: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        icon: Icon(
                          starNum <= selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: AppColors.starGold,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            selectedRating = starNum;
                          });
                        },
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Tu nombre',
                    hintText: 'Ej. Laura Sánchez',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Tu reseña o recomendación',
                    hintText: '¿Qué plato probar? ¿A qué hora ir?',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (commentCtrl.text.trim().isNotEmpty) {
                  widget.repository.addReview(
                    placeId: widget.place.id,
                    rating: selectedRating,
                    comment: commentCtrl.text.trim(),
                    userName: nameCtrl.text.trim().isNotEmpty
                        ? nameCtrl.text.trim()
                        : 'Viajero Mimesita',
                  );
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Gracias por tu reseña! Ayuda a otros viajeros.'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              },
              child: const Text('Publicar Reseña'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catInfo = CategoryHelper.getInfo(widget.place.category);
    final reviews = widget.repository.getReviewsForPlace(widget.place.id);
    final photoUrl = widget.place.photos.isNotEmpty ? widget.place.photos.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Collapsible Image Header
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.place.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  photoUrl != null
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade400),
                        )
                      : Container(color: AppColors.primary),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: catInfo.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: catInfo.color.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(catInfo.emoji, style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 4),
                            Text(
                              catInfo.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: catInfo.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (widget.place.isImperdible) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified, size: 12, color: Colors.white),
                              SizedBox(width: 3),
                              Text(
                                'IMPERDIBLE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          widget.place.priceLevel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Rating & Distance Row
                  Row(
                    children: [
                      StarRating(
                        rating: widget.place.ratingAvg,
                        count: widget.place.ratingCount,
                        size: 18,
                      ),
                      const Spacer(),
                      if (widget.place.distanceKm != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.near_me, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                'A ${widget.place.distanceKm!.toStringAsFixed(1)} km de ti',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Quick Action Buttons
                  Row(
                    children: [
                      // Open GPS
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.directions, size: 18),
                          label: const Text('Cómo Llegar'),
                          onPressed: () => _openMaps(
                            widget.place.latitude,
                            widget.place.longitude,
                            widget.place.name,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // WhatsApp
                      if (widget.place.whatsapp != null) ...[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _openWhatsApp(
                            widget.place.whatsapp!,
                            widget.place.name,
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.chat, size: 18),
                              SizedBox(width: 4),
                              Text('WhatsApp'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      // Phone call
                      if (widget.place.phone != null)
                        IconButton.filledTonal(
                          icon: const Icon(Icons.phone),
                          onPressed: () => _callPhone(widget.place.phone!),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Description
                  const Text(
                    'Acerca del Lugar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.place.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF424242),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Location Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.place.address,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                widget.place.town,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Reviews & Rating Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Opiniones de Viajeros',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.rate_review, size: 18),
                        label: const Text('Calificar'),
                        onPressed: _showAddReviewDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Reviews List
                  if (reviews.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.rate_review_outlined, size: 36, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            const Text(
                              'Aún no hay reseñas registradas.',
                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            TextButton(
                              onPressed: _showAddReviewDialog,
                              child: const Text('¡Sé el primero en calificar!'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...reviews.map((rev) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                                    child: Text(
                                      rev.userName.isNotEmpty ? rev.userName[0].toUpperCase() : 'V',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      rev.userName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  StarRating(rating: rev.rating.toDouble(), showNumber: false),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                rev.comment,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade800,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        )),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
