import 'package:flutter/material.dart';

enum PlaceCategory {
  all,
  food,
  coffee,
  photoSpot,
  extremeSports,
  culture,
  nightlife,
  sports,
  business,
}

class CategoryInfo {
  final PlaceCategory category;
  final String label;
  final String emoji;
  final IconData icon;
  final Color color;

  const CategoryInfo({
    required this.category,
    required this.label,
    required this.emoji,
    required this.icon,
    required this.color,
  });
}

class CategoryHelper {
  static const List<CategoryInfo> allCategories = [
    CategoryInfo(
      category: PlaceCategory.all,
      label: 'Todos',
      emoji: '✨',
      icon: Icons.explore,
      color: Color(0xFF2E7D32),
    ),
    CategoryInfo(
      category: PlaceCategory.food,
      label: 'Comida',
      emoji: '🥘',
      icon: Icons.restaurant,
      color: Color(0xFFE65100),
    ),
    CategoryInfo(
      category: PlaceCategory.coffee,
      label: 'Café & Dulces',
      emoji: '☕',
      icon: Icons.coffee,
      color: Color(0xFF795548),
    ),
    CategoryInfo(
      category: PlaceCategory.photoSpot,
      label: 'Fotos & Vistas',
      emoji: '📸',
      icon: Icons.camera_alt,
      color: Color(0xFF00838F),
    ),
    CategoryInfo(
      category: PlaceCategory.extremeSports,
      label: 'Aventura',
      emoji: '🧗',
      icon: Icons.terrain,
      color: Color(0xFFC2185B),
    ),
    CategoryInfo(
      category: PlaceCategory.culture,
      label: 'Cultura',
      emoji: '🏺',
      icon: Icons.palette,
      color: Color(0xFF6A1B9A),
    ),
    CategoryInfo(
      category: PlaceCategory.nightlife,
      label: 'Noche & Fogata',
      emoji: '🔥',
      icon: Icons.nightlife,
      color: Color(0xFF283593),
    ),
    CategoryInfo(
      category: PlaceCategory.sports,
      label: 'Torneos',
      emoji: '⚽',
      icon: Icons.sports_soccer,
      color: Color(0xFF2E7D32),
    ),
    CategoryInfo(
      category: PlaceCategory.business,
      label: 'Nuevos Negocios',
      emoji: '💈',
      icon: Icons.storefront,
      color: Color(0xFF455A64),
    ),
  ];

  static CategoryInfo getInfo(PlaceCategory cat) {
    return allCategories.firstWhere(
      (c) => c.category == cat,
      orElse: () => allCategories.first,
    );
  }

  static PlaceCategory fromString(String val) {
    switch (val.toLowerCase()) {
      case 'food':
        return PlaceCategory.food;
      case 'coffee':
        return PlaceCategory.coffee;
      case 'photo_spot':
      case 'photospot':
        return PlaceCategory.photoSpot;
      case 'extreme_sports':
      case 'extremesports':
        return PlaceCategory.extremeSports;
      case 'culture':
        return PlaceCategory.culture;
      case 'nightlife':
        return PlaceCategory.nightlife;
      case 'sports':
        return PlaceCategory.sports;
      case 'business':
        return PlaceCategory.business;
      default:
        return PlaceCategory.all;
    }
  }

  static String toDbString(PlaceCategory cat) {
    switch (cat) {
      case PlaceCategory.food:
        return 'food';
      case PlaceCategory.coffee:
        return 'coffee';
      case PlaceCategory.photoSpot:
        return 'photo_spot';
      case PlaceCategory.extremeSports:
        return 'extreme_sports';
      case PlaceCategory.culture:
        return 'culture';
      case PlaceCategory.nightlife:
        return 'nightlife';
      case PlaceCategory.sports:
        return 'sports';
      case PlaceCategory.business:
        return 'business';
      case PlaceCategory.all:
        return 'all';
    }
  }
}
