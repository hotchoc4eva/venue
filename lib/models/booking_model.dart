import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String hallId;
  final String hallName;
  final DateTime bookingDate;
  final double totalPrice;
  final String status;
  final List<String> selectedServices;
  final int paxCount; // 🟢 Add this line

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
    required this.paxCount, // 🟢 Add this line
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'hallId': hallId,
      'hallName': hallName,
      'bookingDate': bookingDate,
      'totalPrice': totalPrice,
      'status': status,
      'selectedServices': selectedServices,
      'paxCount': paxCount, // 🟢 Add this line
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      hallId: map['hallId'] ?? '',
      hallName: map['hallName'] ?? '',
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      selectedServices: List<String>.from(map['selectedServices'] ?? []),
      paxCount: map['paxCount'] ?? 0, // 🟢 Add this line
    );
  }
}