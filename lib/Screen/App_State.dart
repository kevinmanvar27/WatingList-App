import 'package:flutter/material.dart';
import 'database.dart';
import 'models/restaurant.dart';
import 'models/waiting_person.dart';

class AppState extends ChangeNotifier {
  final AppDatabase database;

  String selectedState = 'Gujarat';
  String _searchQuery = '';

  /// Original list from database
  List<Restaurant> _allRestaurants = [];

  /// UI displayed list
  List<Restaurant> restaurants = [];

  AppState(this.database) {
    loadRestaurants();
  }

  /// Load restaurants from DB & apply filters
  Future<void> loadRestaurants() async {
    _allRestaurants = await database.getRestaurants(state: selectedState);
    _applyFilters();
  }

  /// Add Restaurant
  Future<void> addRestaurant(String name) async {
    await database.insertRestaurant(
      Restaurant(name: name, state: selectedState),
    );
    await loadRestaurants();
  }

  /// Add Person to waiting list
  Future<void> addPerson(int restaurantId, String name, int partySize) async {
    await database.insertWaiting(
      WaitingPerson(
        restaurantId: restaurantId,
        name: name,
        partySize: partySize,
      ),
    );
    notifyListeners();
  }

  /// Change State Filter (Popup menu in UI)
  void setStateFilter(String state) {
    selectedState = state;
    loadRestaurants();
  }

  /// Search filter method (Fixes your error)
  void searchRestaurants(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilters();
  }

  /// Apply search + state filter to final restaurants list
  void _applyFilters() {
    restaurants = _allRestaurants.where((r) {
      if (_searchQuery.isEmpty) return true;
      return r.name.toLowerCase().contains(_searchQuery);
    }).toList();

    notifyListeners();
  }
}
