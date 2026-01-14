import 'package:cloud_firestore/cloud_firestore.dart';

// [HallModel] represents a physical venue asset
//  it defines structural requirements for how venue data  is stored in Firestore n how it's rendered within 'Discovery Engine' UI
class HallModel {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final int capacity;
  final String imageUrl;
  final String location; // for geographical filtering
  final List<String> amenities; // to populate Details Screen features

  // we provide default values for location and amenities in case record is created without these specific fields
  HallModel({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.capacity,
    required this.imageUrl,
    this.location = "Kuala Lumpur", // Default value
    this.amenities = const ["Air Conditioning", "Parking", "WiFi"], // Default value
  });

  // getter provides alias for imageUrl
  // it's a convenience property often used to simplify widget code
  String get image => imageUrl; 

  // toMap transforms Object properties into a JSON-compatible Map
  // this is used by the 'DataSeeder' or 'AdminDashboard' to write to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'capacity': capacity,
      'imageUrl': imageUrl,
      'location': location,
      'amenities': amenities,
    };
  }

  // fromMap is factory constructor for deserialisation
  // it maps Firestore fields back to Dart types
  factory HallModel.fromMap(Map<String, dynamic> map, String id) {
    return HallModel(
      id: id, // the document ID is passed from Firestore snapshot
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      // we explicitly cast Double to handle numeric precision in NoSQL
      basePrice: (map['basePrice'] ?? 0).toDouble(),
      capacity: map['capacity'] ?? 0,
      // default placeholder image is used if a URL is broken/missing
      imageUrl: map['imageUrl'] ?? 'https://via.placeholder.com/150',
      location: map['location'] ?? 'Kuala Lumpur',
      // List<String>.from is to ensure dynamic Firestore list is correctly typed for Flutter iterations 
      amenities: List<String>.from(map['amenities'] ?? ["Air Conditioning", "Parking"]),
    );
  }
}
