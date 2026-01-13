import 'package:flutter/material.dart';
import '../models/hall_model.dart';

class BookingProvider extends ChangeNotifier {
  
  // --- STATE VARIABLES ---
  HallModel? _selectedHall;
  DateTime? _selectedDate;
  
  // 🟢 NEW: Hydration for Text Fields
  String _paxCount = ""; 
  String? _editingBookingId; 

  final Map<String, double> _availableServices = {
    'Catering': 1500.0,
    'Photography': 1500.0,
    'Decoration': 2000.0,
    'Live Band': 1200.0,
    'PA System': 250.0,
  };
  
  final Set<String> _selectedServiceKeys = {};

  // --- GETTERS ---
  HallModel? get selectedHall => _selectedHall;
  DateTime? get selectedDate => _selectedDate;
  Set<String> get selectedServices => _selectedServiceKeys;
  Map<String, double> get servicesList => _availableServices;
  String? get editingBookingId => _editingBookingId;
  String get paxCount => _paxCount; // 🟢 Getter for hydration

  // --- ACTIONS ---

  void selectHall(HallModel hall) {
    _selectedHall = hall;
    // Only reset if NOT editing
    if (_editingBookingId == null) {
      _selectedDate = null; 
      _selectedServiceKeys.clear();
      _paxCount = "";
    }
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setPaxCount(String count) {
    _paxCount = count;
    notifyListeners();
  }

  void toggleService(String serviceName) {
    if (_selectedServiceKeys.contains(serviceName)) {
      _selectedServiceKeys.remove(serviceName);
    } else {
      _selectedServiceKeys.add(serviceName);
    }
    notifyListeners();
  }

  // --- 🟢 UPDATED: Load Existing Data (Hydration) ---
  void loadBookingForEdit(Map<String, dynamic> data, String bookingId) {
    _editingBookingId = bookingId;
    
    // 1. Hydrate Date
    if (data['bookingDate'] != null) {
      try {
        _selectedDate = data['bookingDate'].toDate();
      } catch (e) {
        _selectedDate = data['bookingDate']; 
      }
    }

    // 2. Hydrate Pax Count
    _paxCount = data['paxCount']?.toString() ?? "";

    // 3. Hydrate Services
    _selectedServiceKeys.clear();
    // Assuming data['selectedServices'] is a List<String> from Firestore
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
  double get totalPrice {
    if (_selectedHall == null || _selectedDate == null) return 0.0;

    double base = _selectedHall!.basePrice;
    
    // Weekend Surcharge (+20%)
    bool isWeekend = _selectedDate!.weekday >= 5; 
    double multiplier = isWeekend ? 1.2 : 1.0;
    double venueCost = base * multiplier;

    // Add Services from the Master Map
    double servicesCost = 0.0;
    for (var key in _selectedServiceKeys) {
      servicesCost += _availableServices[key] ?? 0.0;
    }

    return venueCost + servicesCost;
  }

  // --- CORE LOGIC: LUHN ALGORITHM ---
  bool validateCard(String cardNumber) {
    String cleaned = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 13) return false;

    int sum = 0;
    bool isSecond = false;
    for (int i = cleaned.length - 1; i >= 0; i--) {
      int d = int.parse(cleaned[i]);
      if (isSecond) {
        d = d * 2;
        if (d > 9) d -= 9;
      }
      sum += d;
      isSecond = !isSecond;
    }
    return (sum % 10 == 0);
  }
  
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