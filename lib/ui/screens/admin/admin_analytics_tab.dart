import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/booking_model.dart';
import '../../../services/firestore_db.dart';

class AdminAnalyticsTab extends StatelessWidget {
  const AdminAnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirestoreService();

    return StreamBuilder<List<BookingModel>>(
      // Only confirmed bookings contribute to revenue
      stream: db.getConfirmedBookings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryGold));
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.analytics_outlined, color: Colors.white24, size: 64),
                const SizedBox(height: 16),
                Text('No revenue data recorded yet.', 
                  style: GoogleFonts.roboto(color: Colors.grey)),
              ],
            ),
          );
        }

        final bookings = snapshot.data!;
        double totalRevenue = bookings.fold(0, (sum, item) => sum + item.totalPrice);
        int totalEvents = bookings.length;
        double avgRevenue = totalEvents > 0 ? totalRevenue / totalEvents : 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('Financial Overview', 
                style: GoogleFonts.instrumentSerif(
                  fontSize: 36, 
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                )),
              const SizedBox(height: 8),
              Text('Real-time tracking of confirmed venue revenue.', 
                style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14)),
              
              const SizedBox(height: 32),

              // 🟢 REVENUE HERO CARD
              _buildRevenueHero(totalRevenue, totalEvents, avgRevenue),

              const SizedBox(height: 40),
              
              Text('Confirmed Transactions', 
                style: GoogleFonts.instrumentSerif(
                  fontSize: 26, 
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.w600
                )),
              const SizedBox(height: 16),

              // 🟢 TRANSACTION LIST
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final b = bookings[index];
                  return _buildTransactionRow(b);
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRevenueHero(double total, int count, double avg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGold, Color(0xFFD4AF37)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.2), 
            blurRadius: 25, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TOTAL REVENUE', 
            style: GoogleFonts.roboto(
              color: Colors.black.withOpacity(0.6), 
              fontWeight: FontWeight.bold, 
              letterSpacing: 2.0, 
              fontSize: 11
            )),
          const SizedBox(height: 12),
          Text('RM ${total.toStringAsFixed(2)}', 
            style: GoogleFonts.roboto(
              color: Colors.black, 
              fontSize: 42, 
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            )),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _heroStat('Confirmed', count.toString()),
              _heroStat('Average Value', 'RM ${avg.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.roboto(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold)),
        Text(value, style: GoogleFonts.roboto(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTransactionRow(BookingModel booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.payments_outlined, color: AppColors.primaryGold, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.hallName, 
                  style: GoogleFonts.instrumentSerif(
                    fontSize: 19, 
                    color: Colors.white, 
                    fontWeight: FontWeight.bold
                  )),
                Text('Guest: ${booking.userName}', 
                  style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12, letterSpacing: 0.3)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('+ RM ${booking.totalPrice.toStringAsFixed(0)}', 
                style: GoogleFonts.roboto(
                  color: const Color(0xFF00E676), 
                  fontWeight: FontWeight.bold, 
                  fontSize: 17
                )),
              Text('Settled', style: GoogleFonts.roboto(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}