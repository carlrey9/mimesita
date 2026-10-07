import '../constants/categories.dart';
import 'place.dart';

class WeekendEvent {
  final String id;
  final String? sellerId;
  final String? placeId;
  final String title;
  final String description;
  final PlaceCategory category;
  final double latitude;
  final double longitude;
  final DateTime startTime;
  final DateTime endTime;
  final String ticketPrice;
  final String? bannerUrl;
  final String? whatsapp;
  final bool isFeatured;
  final ItemStatus status;
  final String? rejectionReason;
  
  double? distanceKm;

  WeekendEvent({
    required this.id,
    this.sellerId,
    this.placeId,
    required this.title,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.startTime,
    required this.endTime,
    this.ticketPrice = 'Entrada Libre',
    this.bannerUrl,
    this.whatsapp,
    this.isFeatured = false,
    this.status = ItemStatus.approved,
    this.rejectionReason,
    this.distanceKm,
  });

  factory WeekendEvent.fromJson(Map<String, dynamic> json) {
    return WeekendEvent(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String?,
      placeId: json['place_id'] as String?,
      title: json['title'] as String? ?? 'Evento',
      description: json['description'] as String? ?? '',
      category: CategoryHelper.fromString(json['category'] as String? ?? 'sports'),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      startTime: DateTime.parse(json['start_time'].toString()),
      endTime: DateTime.parse(json['end_time'].toString()),
      ticketPrice: json['ticket_price'] as String? ?? 'Entrada Libre',
      bannerUrl: json['banner_url'] as String?,
      whatsapp: json['whatsapp'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
      status: json['status'] == 'rejected'
          ? ItemStatus.rejected
          : (json['status'] == 'pending' ? ItemStatus.pending : ItemStatus.approved),
      rejectionReason: json['rejection_reason'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (sellerId != null) 'seller_id': sellerId,
      if (placeId != null) 'place_id': placeId,
      'title': title,
      'description': description,
      'category': CategoryHelper.toDbString(category),
      'latitude': latitude,
      'longitude': longitude,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'ticket_price': ticketPrice,
      'banner_url': bannerUrl,
      'whatsapp': whatsapp,
      'is_featured': isFeatured,
      'status': status.name,
      'rejection_reason': rejectionReason,
    };
  }

  bool get isHappeningThisWeekend {
    final now = DateTime.now();
    // In next 4 days
    final diff = startTime.difference(now).inDays;
    return diff >= -1 && diff <= 4;
  }
}
