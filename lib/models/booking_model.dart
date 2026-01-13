import 'package:cloud_firestore/cloud_firestore.dart';

// [BookingModel] is the blueprint for a reservation transaction
// encapsulates all data required for the booking logic, financial calculations, and admin tracking
class BookingModel {
  final String id;
  final String userId;      // foreign key link to the 'users' collection
  final String userName;    // snapshotted for quick ui display without secondary fetches
  final String hallId;      // foreign key link to 'halls' collection
  final String hallName;    // snapshotted to ensure historical record integrity
  final DateTime bookingDate;
  final double totalPrice;  // final calculated price
  final String status;      // enum-like string: 'pending', 'confirmed', 'cancelled'
  final List<String> selectedServices;
  final int paxCount;      // guest count constraint for capacity validation

  // constructor for dependency injection
  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.hallId,
    required this.hallName,
    required this.bookingDate,
    required this.totalPrice,
    required this.status,
    required this.selectedServices,
    required this.paxCount, 
  });

  //[toMap] converts Dart Object into a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'hallId': hallId,
      'hallName': hallName,
      'bookingDate': bookingDate,  // Firestore converts DateTime to Timestamp automatically
      'totalPrice': totalPrice,
      'status': status,
      'selectedServices': selectedServices,
      'paxCount': paxCount, 
    };
  }

  // [fromMap] is a factory constructor that creates Dart Onject from a Map
  // id is passed separately becauseFirestore stores document id otside document data fields
  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      // use (??) to ensure app doesnt crash if a firld is missing in database
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      hallId: map['hallId'] ?? '',
      hallName: map['hallName'] ?? '',
      // returns 'Timestamp' object which must be converted back to 'DateTime'
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
      // ensure num is treated as double evntho the input is an int
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      // cast dynamic List from Firestore into a typed List<String>
      selectedServices: List<String>.from(map['selectedServices'] ?? []),
      paxCount: map['paxCount'] ?? 0, 
    );
  }
}
