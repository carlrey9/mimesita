class Review {
  final String id;
  final String placeId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final int rating; // 1 to 5
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      placeId: json['place_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? 'Viajero Mimesita',
      userAvatar: json['user_avatar'] as String?,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String? ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'place_id': placeId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
    };
  }
}

enum UserRole { traveler, seller, admin }

class AppUser {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? phone;

  AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
  });
}
