import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint
import '../models/hall_model.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';

/// FirestoreService handles all direct communication with Firebase Firestore.
/// This includes CRUD operations for Users, Halls (Venues), and Bookings.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  //               USER OPERATIONS
  // ==========================================

  /// Creates a new user document in the 'users' collection.
  Future<void> createUserRecord(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  /// Retrieves user data including roles (admin vs user).
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching user: $e");
      return null;
    }
  }

  /// Updates specific user fields (e.g., changing name or role).
  Future<void> updateUserRecord(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  /// Permanently removes a user record from the database.
  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  /// Fetches all registered users. Used exclusively for Admin Dashboard.
  Stream<List<UserModel>> getAllUsers() {
    return _db.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // ==========================================
  //               HALL OPERATIONS
  // ==========================================

  /// Stream of all available halls. Powering the "Discovery Engine" on Home Screen.
  Stream<List<HallModel>> getHalls() {
    return _db.collection('halls').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return HallModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Retrieves a specific hall by ID. Useful for deep-linking or editing bookings.
  Future<HallModel?> getHallById(String hallId) async {
    try {
      DocumentSnapshot doc = await _db.collection('halls').doc(hallId).get();
      if (doc.exists) {
        return HallModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching hall: $e");
      return null;
    }
  }

  /// Creates a new venue entry.
  Future<void> createHall(HallModel hall) async {
    await _db.collection('halls').doc(hall.id).set(hall.toMap());
  }

  /// Updates venue details like price, amenities, or images.
  Future<void> updateHall(String hallId, Map<String, dynamic> data) async {
    await _db.collection('halls').doc(hallId).update(data);
  }

  /// 🟢 NEW: Specifically updates the amenity list for a venue.
  /// This allows the Admin to choose exactly what is visible to the user.
  Future<void> updateHallAmenities(String hallId, List<String> selectedAmenities) async {
    await _db.collection('halls').doc(hallId).update({
      'amenities': selectedAmenities,
    });
  }

  /// Removes a venue from the database.
  Future<void> deleteHall(String hallId) async {
    await _db.collection('halls').doc(hallId).delete();
  }

  // ==========================================
  //             BOOKING OPERATIONS
  // ==========================================

  /// Validates if a specific date for a venue is available.
  /// 🟢 Logic Update: Now checks for both 'confirmed' AND 'pending' 
  /// to prevent double-booking while a request is under review.
  Future<bool> isSlotTaken(String hallId, DateTime date, {String? excludeBookingId}) async {
    DateTime start = DateTime(date.year, date.month, date.day);
    DateTime end = DateTime(date.year, date.month, date.day, 23, 59, 59);

    QuerySnapshot query = await _db
        .collection('bookings')
        .where('hallId', isEqualTo: hallId)
        .where('bookingDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('bookingDate', isLessThanOrEqualTo: Timestamp.fromDate(end))
        // Checks 'confirmed' and 'pending' to be safe
        .where('status', whereIn: ['confirmed', 'pending']) 
        .get();

    final clashes = query.docs.where((doc) => doc.id != excludeBookingId).toList();
    return clashes.isNotEmpty;
  }

  /// Saves a new booking to Firestore. Status starts as 'pending'.
  Future<void> createBooking(BookingModel booking) async {
    await _db.collection('bookings').doc(booking.id).set(booking.toMap());
  }

  /// Updates an existing booking.
  Future<void> updateBooking(String bookingId, Map<String, dynamic> newData) async {
    await _db.collection('bookings').doc(bookingId).update(newData);
  }

  /// Fetches bookings belonging to a specific user for history.
  Stream<List<BookingModel>> getUserBookings(String uid) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return BookingModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Fetches every booking in the system. Required for the Admin Dashboard.
  Stream<List<BookingModel>> getAllBookings() {
    return _db.collection('bookings')
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Quick action for Admin to Approve or Reject a reservation.
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    await _db.collection('bookings').doc(bookingId).update({'status': newStatus});
  }

  /// Fetches only confirmed bookings to calculate real revenue
Stream<List<BookingModel>> getConfirmedBookings() {
  return _db.collection('bookings')
      .where('status', isEqualTo: 'confirmed')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList());
}
}