import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import '../../models/hall_model.dart';

class DataSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedHalls() async {
    try {
      // Check if data already exists to prevent duplicates
      final snapshot = await _db.collection('halls').get();
      if (snapshot.docs.isNotEmpty) {
        debugPrint("Registry already populated. Skipping seed.");
        return;
      }

      // List of Curated Luxury Venues
      List<HallModel> sampleHalls = [
        HallModel(
          id: 'hall_001',
          name: 'THE GRAND BALLROOM',
          description: 'Our flagship venue featuring Victorian architecture and crystal chandeliers. Perfect for prestigious weddings and gala dinners.',
          basePrice: 5500.0,
          capacity: 800,
          location: 'Kuala Lumpur City Centre',
          imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?q=80&w=2098&auto=format&fit=crop',
          amenities: ['VIP Lounge', 'Stage Lighting', 'Climate Control', 'Surround Sound'],
        ),
        HallModel(
          id: 'hall_002',
          name: 'SKY GARDEN PAVILION',
          description: 'A modern, glass-walled sanctuary offering panoramic views of the skyline. Ideal for sunset cocktail parties and intimate ceremonies.',
          basePrice: 3200.0,
          capacity: 200,
          location: 'Bangsar South',
          imageUrl: 'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?q=80&w=2070&auto=format&fit=crop',
          amenities: ['High-Speed WiFi', 'Valet Parking', 'Climate Control'],
        ),
        HallModel(
          id: 'hall_003',
          name: 'ROYAL CONFERENCE HALL',
          description: 'State-of-the-art auditorium equipped with world-class acoustics and high-fidelity projection systems for international summits.',
          basePrice: 7500.0,
          capacity: 1200,
          location: 'Putrajaya',
          imageUrl: 'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?q=80&w=2012&auto=format&fit=crop',
          amenities: ['Projector & Screen', 'High-Speed WiFi', 'Stage Lighting', 'VIP Lounge'],
        ),
      ];

      // Upload Loop
      for (var hall in sampleHalls) {
        await _db.collection('halls').doc(hall.id).set(hall.toMap());
      }
      
      debugPrint("SUCCESS: Luxury registry populated with ${sampleHalls.length} venues.");
    } catch (e) {
      debugPrint("SEEDING ERROR: $e");
    }
  }
}