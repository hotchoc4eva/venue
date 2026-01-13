import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/booking_model.dart';
import '../../../services/firestore_db.dart';
import '../../../providers/booking_provider.dart';
import '../booking_wizard/booking_form_screen.dart';

class AdminBookingsTab extends StatelessWidget {
  const AdminBookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirestoreService();

    return StreamBuilder<List<BookingModel>>(
      stream: db.getAllBookings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryGold));
        }
        if (snapshot.data!.isEmpty) {
          return Center(
            child: Text("No bookings found in registry.", 
              style: GoogleFonts.roboto(color: Colors.white70))
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final booking = snapshot.data![index];
            return _buildLuxuryBookingCard(context, db, booking);
          },
        );
      },
    );
  }

  Widget _buildLuxuryBookingCard(BuildContext context, FirestoreService db, BookingModel booking) {
    final bool isConfirmed = booking.status == 'confirmed';
    final bool isCancelled = booking.status == 'cancelled' || booking.status == 'rejected';
    final bool isPending = booking.status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConfirmed ? AppColors.primaryGold : (isPending ? Colors.orange.withOpacity(0.5) : Colors.white10),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ExpansionTile(
        collapsedIconColor: AppColors.primaryGold,
        iconColor: AppColors.primaryGold,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        // GUEST NAME: Instrument Serif
        title: Text(
          booking.userName.isNotEmpty ? booking.userName : "Anonymous Guest",
          style: GoogleFonts.instrumentSerif(
            color: Colors.white, 
            fontWeight: FontWeight.bold, 
            fontSize: 22,
          ),
        ),
        // DETAILS: Roboto
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(booking.hallName.toUpperCase(), 
              style: GoogleFonts.roboto(color: AppColors.primaryGold, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            Text(DateFormat('EEEE, d MMMM yyyy').format(booking.bookingDate), 
              style: GoogleFonts.roboto(color: Colors.grey, fontSize: 13)),
          ],
        ),
        // STATUS BADGE
        trailing: _buildStatusBadge(booking.status),
        
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Column(
              children: [
                _detailRow("Booking ID", "#${booking.id.substring(0, 8)}"),
                _detailRow("Total Revenue", "RM ${booking.totalPrice.toStringAsFixed(2)}"),
                _detailRow("Requested Services", booking.selectedServices.isEmpty ? "Base Entry Only" : booking.selectedServices.join(" • ")),
                const Divider(height: 40, color: Colors.white10),
                
                // ACTION ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isCancelled)
                      TextButton(
                        onPressed: () => _showRejectDialog(context, db, booking),
                        child: Text("REJECT", style: GoogleFonts.roboto(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    
                    const SizedBox(width: 8),
                    
                    TextButton(
                      onPressed: () => _editBooking(context, db, booking),
                      child: Text("EDIT DETAILS", style: GoogleFonts.roboto(color: Colors.white70, fontSize: 12)),
                    ),

                    const SizedBox(width: 12),

                    if (isPending)
                      ElevatedButton(
                        onPressed: () => db.updateBookingStatus(booking.id, 'confirmed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text("APPROVE", style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    if (status == 'confirmed') color = AppColors.primaryGold;
    else if (status == 'pending') color = Colors.orange;
    else color = Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.roboto(
          fontSize: 9, 
          fontWeight: FontWeight.bold, 
          color: color,
          letterSpacing: 0.5
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.roboto(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value, 
              textAlign: TextAlign.right, 
              style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // --- ACTIONS ---

  void _showRejectDialog(BuildContext context, FirestoreService db, BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text("Reject Request", style: GoogleFonts.instrumentSerif(color: Colors.white, fontSize: 24)),
        content: Text("Are you sure you want to reject this reservation for ${booking.userName}?", 
          style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text("CANCEL", style: GoogleFonts.roboto(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              db.updateBookingStatus(booking.id, 'rejected');
              Navigator.pop(ctx);
            },
            child: Text("REJECT", style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _editBooking(BuildContext context, FirestoreService db, BookingModel booking) {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    
    db.getHallById(booking.hallId).then((hall) {
      if (hall != null) {
        provider.selectHall(hall);
        provider.loadBookingForEdit({
          'bookingDate': booking.bookingDate,
          'catering': booking.selectedServices.contains('Catering'),
          'photography': booking.selectedServices.contains('Photography'),
          'decoration': booking.selectedServices.contains('Decoration'),
          'liveBand': booking.selectedServices.contains('Live Band'),
        }, booking.id);
        
        Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingFormScreen()));
      }
    });
  }
}