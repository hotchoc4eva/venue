import 'package:flutter/material.dart';
import '../models/hall_model.dart';

// BookingProvider centralises state  for the multi-step booking wizard
// it implements the 'Single Source of Truth' principle, ensuring Hall, Date, Services are synchronised across different screens
class BookingProvider extends ChangeNotifier {
  
  // --- STATE VARIABLES ---
  HallModel? _selectedHall;
  DateTime? _selectedDate;
  
  // hydration state stores data temporarily during 'Edit Mode'
  String _paxCount = ""; 
  String? _editingBookingId; 

  // master price mao for add on services (constant data)
  final Map<String, double> _availableServices = {
    'Catering': 1500.0,
    'Photography': 1500.0,
    'Decoration': 2000.0,
    'Live Band': 1200.0,
    'PA System': 250.0,
  };

  // using a set for selected services to prevent duplicate entries
  final Set<String> _selectedServiceKeys = {};

  // --- GETTERS ---
  // provides read-only access to private variables, following the encapsulation principle
  // to prevent external classes from modifying state directly
  HallModel? get selectedHall => _selectedHall;
  DateTime? get selectedDate => _selectedDate;
  Set<String> get selectedServices => _selectedServiceKeys;
  Map<String, double> get servicesList => _availableServices;
  String? get editingBookingId => _editingBookingId;
  String get paxCount => _paxCount; 

  // --- ACTIONS ---

  // sets venue for current session
  // if [_editingBookingId_] is null, it triggers a 'Fresh State' reset to avoid data bleeding from previous booking attempts
  void selectHall(HallModel hall) {
    _selectedHall = hall;
    // if we're not in edit mode, reset everything for a fresh booking
    if (_editingBookingId == null) {
      _selectedDate = null; 
      _selectedServiceKeys.clear();
      _paxCount = "";
    }
    notifyListeners(); // updates ui immediately
  }

  // updates temporal state of booking
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // synchronises pax count from Textfield to Provider state
  void setPaxCount(String count) {
    _paxCount = count;
    notifyListeners();
  }

  // implements toggle logic for add-on services
  // uses set operations when adding/removing items
  void toggleService(String serviceName) {
    if (_selectedServiceKeys.contains(serviceName)) {
      _selectedServiceKeys.remove(serviceName);
    } else {
      _selectedServiceKeys.add(serviceName);
    }
    notifyListeners();
  }

  // --- RESTORE STATE  ---
  // function re-hydrates app state from Firestore Map
  // critical for update bboking feature so users dont lose data
  void loadBookingForEdit(Map<String, dynamic> data, String bookingId) {
    _editingBookingId = bookingId;
    
    //1. hydrate date
    if (data['bookingDate'] != null) {
      try {
        _selectedDate = data['bookingDate'].toDate();
      } catch (e) {
        _selectedDate = data['bookingDate']; 
      }
    }

    //2. hydrate pax count
    _paxCount = data['paxCount']?.toString() ?? "";

    //3. Hydrate Services
    _selectedServiceKeys.clear();
    if (data['selectedServices'] != null) {
      List<dynamic> services = data['selectedServices'];
      for (var s in services) {
        if (_availableServices.containsKey(s)) {
          _selectedServiceKeys.add(s);
        }
      }
    }
    
    notifyListeners();
  }

  // --- CORE LOGIC: PRICE CALCULATION ---
  // calculates final invoice in real-time
  double get totalPrice {
    if (_selectedHall == null || _selectedDate == null) return 0.0;

    double base = _selectedHall!.basePrice;
    
    // weekend surcharge (+20%)
    // in Dart, weekday 5 is fri, 6 is sat, 7 is sun
    bool isWeekend = _selectedDate!.weekday >= 5; 
    double multiplier = isWeekend ? 1.2 : 1.0;
    double venueCost = base * multiplier;

    // aggregate cost of all selected add-ons
    double servicesCost = 0.0;
    for (var key in _selectedServiceKeys) {
      servicesCost += _availableServices[key] ?? 0.0;
    }

    return venueCost + servicesCost;
  }

  // --- CORE LOGIC: LUHN ALGORITHM ---
  // validates credit card numbers offline usig a checksumalgorithm
  bool validateCard(String cardNumber) {
    // strip non-numeric characters
    String cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 13) return false;

    int sum = 0;
    bool isSecond = false;
    // iterate backwards through digits
    for (int i = cleaned.length - 1; i >= 0; i--) {
      int d = int.parse(cleaned[i]);
      if (isSecond) {
        d = d * 2;
        if (d > 9) d -= 9; // subtract 9 if double is 2 digits
      }
      sum += d;
      isSecond = !isSecond;
    }
    return (sum % 10 == 0); // check if total sum is multiple of 10
  }

  // factory reset for booking flow state
  void reset() {
    _editingBookingId = null;
    _selectedHall = null;
    _selectedDate = null;
    _paxCount = "";
    _selectedServiceKeys.clear();
    notifyListeners();
  }
  
  void clearBooking() => reset();
}
