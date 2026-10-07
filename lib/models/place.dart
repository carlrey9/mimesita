import '../constants/categories.dart';

enum ItemStatus { pending, approved, rejected }

class Place {
  final String id;
  final String? sellerId;
  final String name;
  final String description;
  final PlaceCategory category;
  final double latitude;
  final double longitude;
  final String address;
  final String town;
  final String? phone;
  final String? whatsapp;
  final String? instagram;
  final String priceLevel;
  final List<String> photos;
  final bool isFeatured;
  final bool isImperdible;
  final ItemStatus status;
  final String? rejectionReason;
  final double ratingAvg;
  final int ratingCount;
  final DateTime? createdAt;
  
  // Transient field calculated dynamically based on user's GPS
  double? distanceKm;

  Place({
    required this.id,
    this.sellerId,
    required this.name,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.address = 'Mesa de los Santos, Santander',
    this.town = 'Mesa de los Santos',
    this.phone,
    this.whatsapp,
    this.instagram,
    this.priceLevel = '\$\$',
    this.photos = const [],
    this.isFeatured = false,
    this.isImperdible = false,
    this.status = ItemStatus.approved,
    this.rejectionReason,
    this.ratingAvg = 5.0,
    this.ratingCount = 0,
    this.createdAt,
    this.distanceKm,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String?,
      name: json['name'] as String? ?? 'Sin nombre',
      description: json['description'] as String? ?? '',
      category: CategoryHelper.fromString(json['category'] as String? ?? 'food'),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String? ?? 'Mesa de los Santos',
      town: json['town'] as String? ?? 'Mesa de los Santos',
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      instagram: json['instagram'] as String?,
      priceLevel: json['price_level'] as String? ?? '\$\$',
      photos: (json['photos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isFeatured: json['is_featured'] as bool? ?? false,
      isImperdible: json['is_imperdible'] as bool? ?? false,
      status: _statusFromString(json['status'] as String?),
      rejectionReason: json['rejection_reason'] as String?,
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 5.0,
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (sellerId != null) 'seller_id': sellerId,
      'name': name,
      'description': description,
      'category': CategoryHelper.toDbString(category),
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'town': town,
      'phone': phone,
      'whatsapp': whatsapp,
      'instagram': instagram,
      'price_level': priceLevel,
      'photos': photos,
      'is_featured': isFeatured,
      'is_imperdible': isImperdible,
      'status': status.name,
      'rejection_reason': rejectionReason,
      'rating_avg': ratingAvg,
      'rating_count': ratingCount,
    };
  }

  static ItemStatus _statusFromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'approved':
        return ItemStatus.approved;
      case 'rejected':
        return ItemStatus.rejected;
      case 'pending':
      default:
        return ItemStatus.pending;
    }
  }

  Place copyWith({
    String? id,
    String? sellerId,
    String? name,
    String? description,
    PlaceCategory? category,
    double? latitude,
    double? longitude,
    String? address,
    String? town,
    String? phone,
    String? whatsapp,
    String? instagram,
    String? priceLevel,
    List<String>? photos,
    bool? isFeatured,
    bool? isImperdible,
    ItemStatus? status,
    String? rejectionReason,
    double? ratingAvg,
    int? ratingCount,
    DateTime? createdAt,
    double? distanceKm,
  }) {
    return Place(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      town: town ?? this.town,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      instagram: instagram ?? this.instagram,
      priceLevel: priceLevel ?? this.priceLevel,
      photos: photos ?? this.photos,
      isFeatured: isFeatured ?? this.isFeatured,
      isImperdible: isImperdible ?? this.isImperdible,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt ?? this.createdAt,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}
