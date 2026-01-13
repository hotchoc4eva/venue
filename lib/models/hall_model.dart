class HallModel {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final int capacity;
  final String imageUrl;
  final String location; // 🟢 Re-added
  final List<String> amenities; // 🟢 Re-added

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

  // Getter for easy access
  String get image => imageUrl; 

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

  factory HallModel.fromMap(Map<String, dynamic> map, String id) {
    return HallModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      basePrice: (map['basePrice'] ?? 0).toDouble(),
      capacity: map['capacity'] ?? 0,
      imageUrl: map['imageUrl'] ?? 'https://via.placeholder.com/150',
      location: map['location'] ?? 'Kuala Lumpur',
      amenities: List<String>.from(map['amenities'] ?? ["Air Conditioning", "Parking"]),
    );
  }
}