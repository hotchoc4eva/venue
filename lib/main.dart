import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // Ensure you ran 'flutterfire configure'
import 'app.dart'; // We will create this file next

// Providers
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
// import 'providers/hall_provider.dart'; // Commented out (We are using FirestoreService directly for now)
// import 'core/utils/data_seeder.dart';  // Commented out (We will seed data manually or add this later)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Data Seeding (Optional - enable when you have the seeder file)
  // await DataSeeder().seedHalls(); 

  runApp(
    MultiProvider(
      providers: [
        // Auth Provider (User Logic)
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        // Booking Provider (Pricing & Transaction Logic)
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        
        // Hall Provider (Optional - we are currently using streams in UI)
        // ChangeNotifierProvider(create: (_) => HallProvider()),
      ],
      child: const VenueApp(),
    ),
  );
}