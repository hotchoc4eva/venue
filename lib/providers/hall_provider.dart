import 'package:flutter/material.dart';
import '../models/hall_model.dart';
import '../services/firestore_db.dart';

// HallProvider manages inventory of venues
// acts as a middlewear that fetches data from firestore and provides search/filter capabilities to the UI without redundant netwoek calls
class HallProvider extends ChangeNotifier {
  final FirestoreService _dbService = FirestoreService();

  // --- STATE VARIABLES ---
  // "Mater List" (_allHalls_) acts as a local cache of the database
  List<HaallModel> _allHalls = [];  
  // "Presentation List" (_filteredHalls_) is what the user actually sees
  // we modify this during searches to keep Master List intact
  List<HallModel> _filteredHalls = []; // list shown on screen (after search)
  bool _isLoading = true;

  // --- GETTERS ---
  // ui componenets bind to 'halls'. this follows 'Info Hiding' principle
  List<HallModel> get halls => _filteredHalls; // UI always reads this one
  bool get isLoading => _isLoading;

  // constructor: triggers data stream as soon as Provider is created
  HallProvider() {
    fetchHalls();
  }

  // --- ACTIONS ---

  //1. fetch data 
  // establishes real-time listener from Firestore
  // uses Streams so that if admin updates hall price in the backend, user's app updates instantly without refresh
  void fetchHalls() {
    _isLoading = true;
    notifyListeners();

    // listening to a Stream ensures ui is always in sync with the db
    _dbService.getHalls().listen((hallsData) {
      _allHalls = hallsData;
      _filteredHalls = hallsData; // on initial load, display all venues
      _isLoading = false;
      notifyListeners();
    });
  }

  //2. search logiv
  // performs 'linear search' over local cache
  // sinve venue list is <100 iteams, local filtering is significantly faster than a server-side query
  void searchHalls(String query) {
    if (query.isEmpty) {
      _filteredHalls = _allHalls;  // reset to original list
    } else {
      // filter logic: case insensitive match on name or location
      _filteredHalls = _allHalls.where((hall) {
        return hall.name.toLowerCase().contains(query.toLowerCase()) || 
               hall.location.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners(); // updates ui instantly
  }

  //3. filter by capacity
  // useful for ux, ensuring users only see halls that fit their size
  void filterByCapacity(int minCapacity) {
    _filteredHalls = _allHalls.where((hall) {
      return hall.capacity >= minCapacity;
    }).toList();
    notifyListeners();
  }
}
