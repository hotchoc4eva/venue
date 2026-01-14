import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../core/constants/app_colors.dart';
import '../../../providers/booking_provider.dart';
import 'booking_summary_screen.dart';

class ServiceSelectionScreen extends StatelessWidget {
  const ServiceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookingProvider>(context);
    final services = provider.servicesList; 

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PREMIUM SERVICES', 
          style: GoogleFonts.instrumentSerif(letterSpacing: 1.2, fontWeight: FontWeight.bold)
        ),
      ),
      
      // LUXURY PRICE FOOTER (Roboto for Numbers)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          border: Border(top: BorderSide(color: Colors.grey.shade900)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ESTIMATED TOTAL', 
                    style: GoogleFonts.roboto(color: Colors.grey, fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w500)),
                  Text(
                    'RM ${provider.totalPrice.toStringAsFixed(0)}',
                    style: GoogleFonts.roboto(
                      color: AppColors.primaryGold, 
                      fontSize: 26, 
                      fontWeight: FontWeight.w700
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookingSummaryScreen()),
                  );
                },
                child: Text('REVIEW & PAY', 
                  style: GoogleFonts.roboto(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ],
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // 1. Header (Instrument Serif)
          Text(
            "Customize Your Experience", 
            style: GoogleFonts.instrumentSerif(fontSize: 32, color: Colors.white, height: 1.1)
          ),
          const SizedBox(height: 12),
          // Sub-description (Roboto)
          Text(
            "Enhance your event with our exclusive amenities. The total updates in real-time.",
            style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 32),

          // 2. Weekend Surcharge Notice (Roboto)
          if (provider.selectedDate != null && provider.selectedDate!.weekday >= 5) 
            _buildSurchargeNotice(),

          // 3. Dynamic List of Services (Roboto)
          ...services.entries.map((entry) {
            final name = entry.key;
            final price = entry.value;
            final isSelected = provider.selectedServices.contains(name);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => provider.toggleService(name),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryGold.withOpacity(0.05) : const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryGold : Colors.white.withOpacity(0.05),
                      width: 1.5
                    ),
                  ),
                  child: CheckboxListTile(
                    activeColor: AppColors.primaryGold,
                    checkColor: Colors.black,
                    controlAffinity: ListTileControlAffinity.trailing,
                    title: Text(name, 
                      style: GoogleFonts.roboto(
                        color: isSelected ? Colors.white : Colors.grey.shade300,
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                      )),
                    subtitle: Text('RM ${price.toStringAsFixed(0)}', 
                      style: GoogleFonts.roboto(color: AppColors.primaryGold, fontWeight: FontWeight.w500, fontSize: 14)),
                    value: isSelected,
                    onChanged: (bool? value) {
                      provider.toggleService(name);
                    },
                    secondary: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryGold.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForService(name), 
                        color: isSelected ? AppColors.primaryGold : Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSurchargeNotice() {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2100), 
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.primaryGold, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Elite Weekend Rate Applied (+20% on base price)",
              style: GoogleFonts.roboto(color: AppColors.primaryGold, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForService(String name) {
    switch (name) {
      case 'Catering': return Icons.restaurant;
      case 'Live Band': return Icons.music_note;
      case 'Decoration': return Icons.local_florist;
      case 'Photography': return Icons.camera_alt; 
      case 'PA System': return Icons.speaker;
      default: return Icons.auto_awesome;
    }
  }
}
