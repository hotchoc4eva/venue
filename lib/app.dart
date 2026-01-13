import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/home/home_screen.dart';
import 'ui/screens/admin/admin_home_screen.dart';

class VenueApp extends StatelessWidget {
  const VenueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luxury Venue Booking',
      debugShowCheckedModeBanner: false,
      
      // --- THEME SETUP (Instrument Serif + Roboto Pairing) ---
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        
        // 1. TYPOGRAPHY CONFIGURATION
        // Roboto is the base for body text
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme).copyWith(
          // Instrument Serif for Display & Headlines
          displayLarge: GoogleFonts.instrumentSerif(),
          displayMedium: GoogleFonts.instrumentSerif(),
          displaySmall: GoogleFonts.instrumentSerif(),
          headlineLarge: GoogleFonts.instrumentSerif(),
          headlineMedium: GoogleFonts.instrumentSerif(),
          headlineSmall: GoogleFonts.instrumentSerif(),
          titleLarge: GoogleFonts.instrumentSerif(
            fontSize: 22, 
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ).apply(
          bodyColor: Colors.white,       // Roboto body text
          displayColor: const Color(0xFFD4AF37), // Serif headers in Gold
        ),

        // 2. APP BAR THEME
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          centerTitle: true,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.instrumentSerif(
            color: const Color(0xFFD4AF37), 
            fontSize: 26, 
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),

        // 3. BUTTON THEME (Always Roboto for readability)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: Colors.black,
            textStyle: GoogleFonts.roboto(
              fontWeight: FontWeight.bold, 
              letterSpacing: 1.1,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        // 4. COLOR SCHEME
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37), // Gold
          secondary: Colors.white,
          surface: Color(0xFF1E1E1E), // Dark Grey
        ),
        
        useMaterial3: true,
      ),
      
      // --- AUTH GATE ---
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // 1. Initial Loading State (Checks Firebase Auth status)
          if (auth.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
            );
          }

          // 2. Authenticated User Routing
          if (auth.isLoggedIn) {
            return auth.isAdmin ? const AdminHomeScreen() : const HomeScreen();
          } 
          
          // 3. Guest/Unauthenticated State
          // Handled as the default landing; LoginScreen contains the "Browse as Guest" bypass
          else {
            return const LoginScreen(); 
          }
        },
      ),
    );
  }
}