import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../models/hall_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/booking_provider.dart';
import '../../../providers/auth_provider.dart'; 
import '../booking_wizard/booking_form_screen.dart';
import '../login_screen.dart';

class HallDetailsScreen extends StatelessWidget {
  final HallModel hall;

  const HallDetailsScreen({super.key, required this.hall});

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Reservation Required", 
          style: GoogleFonts.instrumentSerif(
            color: AppColors.primaryGold, 
            fontSize: 26,
            fontWeight: FontWeight.bold,
          )
        ),
        content: Text(
          "To check availability and book this venue, please sign in to your Royal Venues account.",
          style: GoogleFonts.roboto(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Maybe Later", 
              style: GoogleFonts.roboto(color: Colors.grey, fontWeight: FontWeight.w500)
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              "Sign In",
              style: GoogleFonts.roboto(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGold,
        onPressed: () {
          if (!authProvider.isLoggedIn) {
            _showLoginPrompt(context);
          } else {
            Provider.of<BookingProvider>(context, listen: false).selectHall(hall);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookingFormScreen()),
            );
          }
        },
        label: Text(
          'BOOK NOW', 
          style: GoogleFonts.roboto(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.1)
        ),
        icon: const Icon(Icons.calendar_today, color: Colors.black),
      ),
      
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                hall.name, 
                style: GoogleFonts.instrumentSerif(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                  shadows: [const Shadow(color: Colors.black, blurRadius: 10)]
                )
              ),
              background: Hero(
                tag: hall.id,
                child: CachedNetworkImage(
                  imageUrl: hall.imageUrl,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.3),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            ),
          ),
          
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primaryGold, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hall.location, 
                            style: GoogleFonts.instrumentSerif(fontSize: 28, color: Colors.white)
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Price: RM ${hall.basePrice.toStringAsFixed(0)} / day',
                      style: GoogleFonts.roboto(
                        color: AppColors.primaryGold, 
                        fontSize: 18, 
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Divider(height: 48, color: Colors.white10),

                    Text(
                      'Amenities', 
                      style: GoogleFonts.instrumentSerif(fontSize: 26, color: AppColors.primaryGold)
                    ),
                    const SizedBox(height: 16),
                    // 🟢 Dynamically shows only amenities selected by Admin
                    Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      children: hall.amenities.map((amenity) {
                        return Chip(
                          label: Text(
                            amenity, 
                            style: GoogleFonts.roboto(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)
                          ),
                          backgroundColor: const Color(0xFF1E1E1E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: BorderSide(color: Colors.white.withOpacity(0.05)),
                          avatar: const Icon(Icons.check, color: AppColors.primaryGold, size: 16),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 32),
                    Text(
                      "Description",
                      style: GoogleFonts.instrumentSerif(fontSize: 26, color: AppColors.primaryGold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      hall.description.isNotEmpty 
                        ? hall.description 
                        : "Experience luxury in this state-of-the-art venue. Perfect for weddings, corporate galas, and grand celebrations.",
                      style: GoogleFonts.roboto(
                        color: Colors.grey.shade400, 
                        height: 1.6, 
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 120), 
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}