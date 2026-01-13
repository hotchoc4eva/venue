import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/hall_model.dart';
import '../../../core/constants/app_colors.dart';

class HallCard extends StatelessWidget {
  final HallModel hall;
  final VoidCallback onTap;

  const HallCard({super.key, required this.hall, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 1. BACKGROUND IMAGE
              Hero(
                tag: hall.id,
                child: SizedBox(
                  height: 240, // Slightly increased height
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: hall.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.surfaceGrey,
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryGold),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surfaceGrey,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),

              // 2. TRANSLUCENT BLACK CARD (Text Container)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    // Solid translucent black for high contrast
                    color: Colors.black.withOpacity(0.7), 
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Venue Name: Luxury Serif
                      Text(
                        hall.name.toUpperCase(),
                        style: GoogleFonts.instrumentSerif(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          // Location: Modern Roboto
                          Expanded(
                            child: Text(
                              hall.location,
                              style: GoogleFonts.roboto(
                                color: Colors.white70,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Price: Bold Roboto
                          Text(
                            'RM ${hall.basePrice.toStringAsFixed(0)}',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}