import 'package:flutter/material.dart';
import '../models/hall_model.dart';
import '../services/firestore_db.dart';

class HallProvider extends ChangeNotifier {
  final FirestoreService _dbService = FirestoreService();

  // --- STATE VARIABLES ---
  List<HallModel> _allHalls = [];  // The "Master List" from DB
  List<HallModel> _filteredHalls = []; // The list shown on screen (after search)
  bool _isLoading = true;

  // --- GETTERS ---
  List<HallModel> get halls => _filteredHalls; // UI always reads this one
  bool get isLoading => _isLoading;

  // Constructor: Load halls immediately when app starts
  HallProvider() {
    fetchHalls();
  }

  // --- ACTIONS ---

  // 1. Fetch Data from Firestore
  void fetchHalls() {
    _isLoading = true;
    notifyListeners();

    _dbService.getHalls().listen((hallsData) {
      _allHalls = hallsData;
      _filteredHalls = hallsData; // Initially, show everything
      _isLoading = false;
      notifyListeners();
    });
  }

  // 2. Search Logic (The "Discovery Engine")
  void searchHalls(String query) {
    if (query.isEmpty) {
      _filteredHalls = _allHalls;
    } else {
      _filteredHalls = _allHalls.where((hall) {
        return hall.name.toLowerCase().contains(query.toLowerCase()) || 
               hall.location.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners(); // Update UI instantly
  }

  // 3. Filter by Capacity
  void filterByCapacity(int minCapacity) {
    _filteredHalls = _allHalls.where((hall) {
      return hall.capacity >= minCapacity;
    }).toList();
    notifyListeners();
  }
}