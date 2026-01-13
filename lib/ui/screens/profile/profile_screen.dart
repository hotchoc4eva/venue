import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../services/firestore_db.dart';
import '../../../models/booking_model.dart';
import '../booking_wizard/booking_form_screen.dart';
import '../login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final db = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: Text('MY PROFILE', 
          style: GoogleFonts.instrumentSerif(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsSheet(context, authProvider),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserHeader(context, user),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Reservations', 
                    style: GoogleFonts.instrumentSerif(fontSize: 28, color: Colors.white)),
                  const Icon(Icons.history_edu, color: AppColors.primaryGold, size: 24),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildBookingList(context, db, user?.uid),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
  void _showRefundNotification(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "Cancellation processed. A refund confirmation email is being sent to your inbox.", 
        style: GoogleFonts.roboto()
      ),
      backgroundColor: AppColors.primaryGold,
      duration: const Duration(seconds: 4),
    ),
  );
  }
  // 🟢 SETTINGS MODAL (Now fully functional)
  void _showSettingsSheet(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ACCOUNT SETTINGS', 
                style: GoogleFonts.instrumentSerif(color: AppColors.primaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: Text('Edit Name', style: GoogleFonts.roboto(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditNameDialog(context, auth); // Triggers Part 2 Dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_open, color: Colors.white),
                title: Text('Change Password', style: GoogleFonts.roboto(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showChangePasswordDialog(context, auth); // Triggers Part 2 Dialog
                },
              ),
              const Divider(color: Colors.white10),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: Text('Sign Out', style: GoogleFonts.roboto(color: Colors.white)),
                onTap: () {
                  auth.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                title: Text('Delete Account', style: GoogleFonts.roboto(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteAccountDialog(context, auth); // Triggers Part 2 Dialog
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🟢 USER HEADER WIDGET
  Widget _buildUserHeader(BuildContext context, user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryGold,
            child: Text(user?.name[0].toUpperCase() ?? 'U', 
              style: GoogleFonts.instrumentSerif(fontSize: 40, color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Text(user?.name ?? 'Guest User', 
            style: GoogleFonts.instrumentSerif(fontSize: 32, color: AppColors.primaryGold)),
          Text(user?.email ?? '', style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
  // 🟢 BOOKING LIST & CANCELLATION LOGIC
  Widget _buildBookingList(BuildContext context, FirestoreService db, String? uid) {
    if (uid == null) return const Center(child: Text("Guest mode active."));

    return StreamBuilder<List<BookingModel>>(
      stream: db.getUserBookings(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primaryGold));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final booking = snapshot.data![index];
            final now = DateTime.now();
            // 🟢 Logic: Check if current time is at least 48 hours before booking
            final bool canCancel = booking.bookingDate.difference(now).inHours >= 48;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking.hallName, style: GoogleFonts.instrumentSerif(fontSize: 20, color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                          Text(DateFormat('dd MMM yyyy').format(booking.bookingDate), style: GoogleFonts.roboto(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                      _buildStatusBadge(booking.status),
                    ],
                  ),
                  const Divider(height: 32, color: Colors.white10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('RM ${booking.totalPrice.toStringAsFixed(0)}', style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.white)),
                      Row(
                        children: [
                          if (canCancel && booking.status != 'cancelled')
                            TextButton(
                              onPressed: () => _handleCancellation(context, db, booking),
                              child: Text("CANCEL", style: GoogleFonts.roboto(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          if (booking.status != 'cancelled' && booking.status != 'rejected')
                            TextButton(
                              onPressed: () => _handleEditBooking(context, booking),
                              child: Text("UPDATE", style: GoogleFonts.roboto(color: AppColors.primaryGold, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 🟢 ACTION: UPDATE RESERVATION (Hydrating the Form)
  void _handleEditBooking(BuildContext context, BookingModel booking) async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final db = FirestoreService();
    
    // Fetch Hall details first to avoid null errors in form
    final hall = await db.getHallById(booking.hallId);
    if (hall != null) {
      bookingProvider.selectHall(hall);
      
      // Pass the existing booking data to the provider's hydration method
      bookingProvider.loadBookingForEdit({
        'bookingDate': booking.bookingDate,
        'selectedServices': booking.selectedServices,
        'paxCount': booking.paxCount,
      }, booking.id);

      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingFormScreen()));
      }
    }
  }

  // 🟢 DIALOG: EDIT NAME
  void _showEditNameDialog(BuildContext context, AuthProvider auth) {
    final controller = TextEditingController(text: auth.currentUser?.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text("Edit Name", style: GoogleFonts.instrumentSerif(color: AppColors.primaryGold)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: "Display Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await auth.updateDisplayName(controller.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // 🟢 DIALOG: DELETE ACCOUNT (Requires Password)
  void _showDeleteAccountDialog(BuildContext context, AuthProvider auth) {
    final passController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Delete Account?", style: TextStyle(color: Colors.redAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("To confirm, please enter your password. This action is permanent.", style: TextStyle(color: Colors.grey, fontSize: 13)),
            TextField(controller: passController, obscureText: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Password")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              String? err = await auth.deleteAccountWithPassword(passController.text);
              if (ctx.mounted) {
                if (err == null) {
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                }
              }
            },
            child: const Text("Delete Forever"),
          ),
        ],
      ),
    );
  }

  // 🟢 STATUS BADGE HELPER
  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'confirmed': color = Colors.green; label = 'CONFIRMED'; break;
      case 'pending': color = Colors.orange; label = 'PENDING APPROVAL'; break;
      default: color = Colors.redAccent; label = status.toUpperCase();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(label, style: GoogleFonts.roboto(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
  // 🟢 FIX: Define the missing Cancellation Handler
  void _handleCancellation(BuildContext context, FirestoreService db, BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text("Cancel Reservation", style: GoogleFonts.instrumentSerif(color: Colors.redAccent)),
        content: Text(
          "Are you sure you want to cancel your booking for ${booking.hallName}? \n\nA refund confirmation email will be sent to your registered address shortly.",
          style: GoogleFonts.roboto(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Keep Booking")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await db.updateBookingStatus(booking.id, 'cancelled');
              if (context.mounted) {
                Navigator.pop(ctx);
                _showRefundNotification(context);
              }
            },
            child: const Text("Confirm Cancellation"),
          ),
        ],
      ),
    );
  }

  // 🟢 FIX: Define the missing Password Change Dialog
  void _showChangePasswordDialog(BuildContext context, AuthProvider auth) {
    final currentController = TextEditingController();
    final newController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text("Change Password", style: GoogleFonts.instrumentSerif(color: AppColors.primaryGold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController, 
              obscureText: true, 
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Current Password", labelStyle: TextStyle(color: Colors.grey)),
            ),
            TextField(
              controller: newController, 
              obscureText: true, 
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "New Password", labelStyle: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
            onPressed: () async {
              String? err = await auth.changePasswordInApp(
                currentPassword: currentController.text,
                newPassword: newController.text,
              );
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(err ?? "Password Updated Successfully!"), 
                  backgroundColor: err == null ? Colors.green : Colors.red)
                );
              }
            },
            child: const Text("Update", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}