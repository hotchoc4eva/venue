import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../core/constants/app_colors.dart';
import '../../../models/booking_model.dart';
import '../../../providers/booking_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/firestore_db.dart';
import '../home/home_screen.dart'; 

class BookingSummaryScreen extends StatefulWidget {
  const BookingSummaryScreen({super.key});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardController = TextEditingController();
  final FirestoreService _dbService = FirestoreService();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('FINAL REVIEW', 
          style: GoogleFonts.instrumentSerif(letterSpacing: 1.2, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reservation Summary', 
                style: GoogleFonts.instrumentSerif(fontSize: 32, color: Colors.white, height: 1.1)),
              const SizedBox(height: 24),
              
              _buildReceipt(provider),
              const SizedBox(height: 40),

              Text('Secure Payment', 
                style: GoogleFonts.instrumentSerif(fontSize: 26, color: AppColors.primaryGold)),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _cardController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.roboto(color: Colors.white, letterSpacing: 2.0, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Credit Card Number',
                  labelStyle: GoogleFonts.roboto(color: Colors.grey),
                  hintText: 'xxxx xxxx xxxx xxxx',
                  hintStyle: GoogleFonts.roboto(color: Colors.white10),
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryGold),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryGold),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Card info required';
                  if (!provider.validateCard(value)) return 'Invalid card signature';
                  return null;
                },
              ),
              
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isProcessing 
                      ? null 
                      : () => _submitBooking(context, provider, authProvider),
                  child: _isProcessing 
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          provider.editingBookingId != null 
                              ? 'UPDATE RESERVATION' 
                              : 'CONFIRM & PAY',
                          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, letterSpacing: 1.1)
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text("Encrypted by Royal Secure Systems", 
                  style: GoogleFonts.roboto(color: Colors.grey, fontSize: 10, letterSpacing: 0.5)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceipt(BookingProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _row('Venue', provider.selectedHall!.name, isHeader: true),
          _row('Date', DateFormat('EEEE, d MMMM yyyy').format(provider.selectedDate!)),
          const Divider(height: 32, color: Colors.white10),
          
          if (provider.selectedServices.isEmpty)
            _row('Services', 'Standard Entry')
          else
            ...provider.selectedServices.map((s) => _row(s, 'Premium Add-on')),
            
          const Divider(height: 32, color: Colors.white10),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL AMOUNT', 
                style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey, letterSpacing: 1.2, fontWeight: FontWeight.w500)),
              Text('RM ${provider.totalPrice.toStringAsFixed(2)}', 
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold, 
                  fontSize: 24, 
                  color: AppColors.primaryGold
                )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.roboto(color: isHeader ? Colors.white : Colors.grey, fontSize: 14)),
          Text(value, 
            style: GoogleFonts.roboto(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.w500, 
              color: Colors.white, 
              fontSize: 14
            )),
        ],
      ),
    );
  }

  Future<void> _submitBooking(BuildContext context, BookingProvider provider, AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return; 

    setState(() => _isProcessing = true);
    final user = auth.currentUser;

    try {
      if (provider.editingBookingId != null) {
          await _dbService.updateBooking(provider.editingBookingId!, {
            'hallId': provider.selectedHall!.id,
            'hallName': provider.selectedHall!.name,
            'bookingDate': provider.selectedDate!,
            'totalPrice': provider.totalPrice,
            'selectedServices': provider.selectedServices.toList(),
            'paxCount': int.tryParse(provider.paxCount) ?? 0, 
            'status': 'pending', 
          });
        } else {
        // NEW BOOKINGS: Set status to 'pending'
        final newBooking = BookingModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(), 
          userId: user?.uid ?? 'guest',
          userName: user?.name ?? 'Guest User', 
          hallId: provider.selectedHall!.id,
          hallName: provider.selectedHall!.name,
          bookingDate: provider.selectedDate!,
          totalPrice: provider.totalPrice,
          status: 'pending', 
          selectedServices: provider.selectedServices.toList(),
          paxCount: int.tryParse(provider.paxCount) ?? 0, 
        );
        await _dbService.createBooking(newBooking);
      }

      if (mounted) {
        _showSuccessDialog(context, provider);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Processing Error: $e', style: GoogleFonts.roboto()),
        backgroundColor: Colors.redAccent,
      ));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog(BuildContext context, BookingProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('Request Received', 
          style: GoogleFonts.instrumentSerif(color: AppColors.primaryGold, fontSize: 26, fontWeight: FontWeight.bold)),
        content: Text(
          provider.editingBookingId != null 
            ? 'Your update has been submitted and is pending review.'
            : 'Your payment was successful. Your reservation is now pending admin approval.',
          style: GoogleFonts.roboto(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              provider.reset();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            child: Text('Return to Home', 
              style: GoogleFonts.roboto(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
