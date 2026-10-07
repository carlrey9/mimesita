import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/categories.dart';
import '../models/place.dart';
import '../models/event.dart';
import '../models/review.dart';
import 'mock_data.dart';
import 'location_service.dart';

class MimesitaRepository extends ChangeNotifier {
  static final MimesitaRepository _instance = MimesitaRepository._internal();
  factory MimesitaRepository() => _instance;

  MimesitaRepository._internal() {
    _places = MockData.getInitialPlaces();
    _events = MockData.getInitialEvents();
    _reviews = MockData.getInitialReviews();
  }

  bool _isSupabaseConfigured = false;
  bool get isSupabaseConfigured => _isSupabaseConfigured;

  // Active Role Simulation (for quick testing: Traveler, Seller, Admin)
  UserRole _currentRole = UserRole.traveler;
  UserRole get currentRole => _currentRole;

  void setRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  // In-memory data store
  List<Place> _places = [];
  List<WeekendEvent> _events = [];
  List<Review> _reviews = [];

  // Filter State
  PlaceCategory _selectedCategory = PlaceCategory.all;
  PlaceCategory get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setCategory(PlaceCategory cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Configure Supabase credentials dynamically
  Future<bool> initializeSupabase({required String url, required String anonKey}) async {
    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      _isSupabaseConfigured = true;
      await fetchRemoteData();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Supabase initialization error: $e");
      return false;
    }
  }

  Future<void> fetchRemoteData() async {
    if (!_isSupabaseConfigured) return;
    try {
      final supabase = Supabase.instance.client;
      final placesRes = await supabase.from('places').select();
      final eventsRes = await supabase.from('events').select();
      
      _places = (placesRes as List).map((json) => Place.fromJson(json)).toList();
      _events = (eventsRes as List).map((json) => WeekendEvent.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch remote data: $e");
    }
  }

  // --- Traveler Getters ---

  List<Place> get approvedPlaces {
    var list = _places.where((p) => p.status == ItemStatus.approved).toList();

    if (_selectedCategory != PlaceCategory.all) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.town.toLowerCase().contains(q)).toList();
    }

    return LocationService.enrichAndSortPlaces(list);
  }

  List<WeekendEvent> get approvedEvents {
    var list = _events.where((e) => e.status == ItemStatus.approved).toList();

    if (_selectedCategory != PlaceCategory.all) {
      list = list.where((e) => e.category == _selectedCategory).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((e) =>
          e.title.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q)).toList();
    }

    return LocationService.enrichAndSortEvents(list);
  }

  List<Review> getReviewsForPlace(String placeId) {
    return _reviews.where((r) => r.placeId == placeId).toList();
  }

  // --- Seller Operations ---

  Future<void> submitNewPlace(Place place) async {
    // Add locally
    _places.add(place.copyWith(status: ItemStatus.pending));

    if (_isSupabaseConfigured) {
      try {
        await Supabase.instance.client.from('places').insert(place.toJson());
      } catch (e) {
        debugPrint("Supabase place insert error: $e");
      }
    }

    notifyListeners();
  }

  Future<void> submitNewEvent(WeekendEvent event) async {
    _events.add(event);

    if (_isSupabaseConfigured) {
      try {
        await Supabase.instance.client.from('events').insert(event.toJson());
      } catch (e) {
        debugPrint("Supabase event insert error: $e");
      }
    }

    notifyListeners();
  }

  // --- Admin Moderation Operations ---

  List<Place> get pendingPlaces =>
      _places.where((p) => p.status == ItemStatus.pending).toList();

  List<WeekendEvent> get pendingEvents =>
      _events.where((e) => e.status == ItemStatus.pending).toList();

  int get totalPendingCount => pendingPlaces.length + pendingEvents.length;

  Future<void> approvePlace(String placeId) async {
    final idx = _places.indexWhere((p) => p.id == placeId);
    if (idx != -1) {
      _places[idx] = _places[idx].copyWith(status: ItemStatus.approved);
      if (_isSupabaseConfigured) {
        await Supabase.instance.client
            .from('places')
            .update({'status': 'approved'}).eq('id', placeId);
      }
      notifyListeners();
    }
  }

  Future<void> rejectPlace(String placeId, String reason) async {
    final idx = _places.indexWhere((p) => p.id == placeId);
    if (idx != -1) {
      _places[idx] = _places[idx].copyWith(
        status: ItemStatus.rejected,
        rejectionReason: reason,
      );
      if (_isSupabaseConfigured) {
        await Supabase.instance.client
            .from('places')
            .update({'status': 'rejected', 'rejection_reason': reason}).eq('id', placeId);
      }
      notifyListeners();
    }
  }

  Future<void> approveEvent(String eventId) async {
    final idx = _events.indexWhere((e) => e.id == eventId);
    if (idx != -1) {
      _events[idx] = WeekendEvent(
        id: _events[idx].id,
        sellerId: _events[idx].sellerId,
        placeId: _events[idx].placeId,
        title: _events[idx].title,
        description: _events[idx].description,
        category: _events[idx].category,
        latitude: _events[idx].latitude,
        longitude: _events[idx].longitude,
        startTime: _events[idx].startTime,
        endTime: _events[idx].endTime,
        ticketPrice: _events[idx].ticketPrice,
        bannerUrl: _events[idx].bannerUrl,
        whatsapp: _events[idx].whatsapp,
        isFeatured: _events[idx].isFeatured,
        status: ItemStatus.approved,
      );
      if (_isSupabaseConfigured) {
        await Supabase.instance.client
            .from('events')
            .update({'status': 'approved'}).eq('id', eventId);
      }
      notifyListeners();
    }
  }

  Future<void> rejectEvent(String eventId, String reason) async {
    final idx = _events.indexWhere((e) => e.id == eventId);
    if (idx != -1) {
      _events[idx] = WeekendEvent(
        id: _events[idx].id,
        sellerId: _events[idx].sellerId,
        placeId: _events[idx].placeId,
        title: _events[idx].title,
        description: _events[idx].description,
        category: _events[idx].category,
        latitude: _events[idx].latitude,
        longitude: _events[idx].longitude,
        startTime: _events[idx].startTime,
        endTime: _events[idx].endTime,
        ticketPrice: _events[idx].ticketPrice,
        bannerUrl: _events[idx].bannerUrl,
        whatsapp: _events[idx].whatsapp,
        isFeatured: _events[idx].isFeatured,
        status: ItemStatus.rejected,
        rejectionReason: reason,
      );
      if (_isSupabaseConfigured) {
        await Supabase.instance.client
            .from('events')
            .update({'status': 'rejected', 'rejection_reason': reason}).eq('id', eventId);
      }
      notifyListeners();
    }
  }

  // --- Review Submission ---

  Future<void> addReview({
    required String placeId,
    required int rating,
    required String comment,
    required String userName,
  }) async {
    final newReview = Review(
      id: 'rev-${DateTime.now().millisecondsSinceEpoch}',
      placeId: placeId,
      userId: 'user-${DateTime.now().millisecondsSinceEpoch}',
      userName: userName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );
    _reviews.insert(0, newReview);

    // Update place average
    final placeReviews = _reviews.where((r) => r.placeId == placeId).toList();
    final avg = placeReviews.map((r) => r.rating).reduce((a, b) => a + b) / placeReviews.length;

    final pIdx = _places.indexWhere((p) => p.id == placeId);
    if (pIdx != -1) {
      _places[pIdx] = _places[pIdx].copyWith(
        ratingAvg: double.parse(avg.toStringAsFixed(1)),
        ratingCount: placeReviews.length,
      );
    }

    notifyListeners();
  }
}
