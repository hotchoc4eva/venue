import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../core/constants/app_colors.dart';
import '../../../providers/booking_provider.dart';
import '../../../services/firestore_db.dart';
import 'service_selection_screen.dart';

class BookingFormScreen extends StatefulWidget {
  final String? initialGuests; 

  const BookingFormScreen({super.key, this.initialGuests});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final FirestoreService _dbService = FirestoreService();
  final _guestController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isChecking = false;
  String? _availabilityStatus; 

  @override
  void initState() {
    super.initState();
    // Pre-fill if editing an existing booking
    if (widget.initialGuests != null) {
      _guestController.text = widget.initialGuests!;
      _availabilityStatus = 'Available'; 
    }
  }

  @override
  void dispose() {
    _guestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final hall = bookingProvider.selectedHall!;

    return Scaffold(
      appBar: AppBar(
        title: Text('EVENT DETAILS', 
          style: GoogleFonts.instrumentSerif(letterSpacing: 1.2, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hall Info Header (Instrument Serif)
              Text(hall.name, 
                style: GoogleFonts.instrumentSerif(fontSize: 32, color: AppColors.primaryGold, height: 1.1)),
              const SizedBox(height: 4),
              // Sub-info (Roboto)
              Text(
                'Maximum Capacity: ${hall.capacity} Guests',
                style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14, letterSpacing: 0.5)
              ),
              const SizedBox(height: 32),

              // 2. Date Picker Section
              Text('Select Event Date', 
                style: GoogleFonts.instrumentSerif(fontSize: 24, color: Colors.white)),
              const SizedBox(height: 16),
              
              InkWell(
                onTap: () => _pickDate(context, bookingProvider),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        bookingProvider.selectedDate == null
                            ? 'Tap to choose date'
                            : DateFormat('EEEE, d MMMM yyyy').format(bookingProvider.selectedDate!),
                        style: GoogleFonts.roboto(fontSize: 16, color: Colors.white),
                      ),
                      const Icon(Icons.calendar_month, color: AppColors.primaryGold),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              // Note (Roboto)
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.grey, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    "Note: Reservations must be made 48 hours in advance.",
                    style: GoogleFonts.roboto(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),

              // Availability Feedback UI
              if (_isChecking)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
                )
              else if (_availabilityStatus != null)
                _buildAvailabilityBadge(),

              const SizedBox(height: 40),

              // 3. Guest Count Input
              Text('Estimated Guest Count', 
                style: GoogleFonts.instrumentSerif(fontSize: 24, color: Colors.white)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _guestController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.roboto(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Number of Pax',
                  labelStyle: GoogleFonts.roboto(color: Colors.grey),
                  prefixIcon: const Icon(Icons.people_outline, color: AppColors.primaryGold),
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
                  if (value == null || value.isEmpty) return 'Required';
                  int? guests = int.tryParse(value);
                  if (guests == null || guests <= 0) return 'Enter a valid count';
                  if (guests > hall.capacity) return 'Exceeds limit (${hall.capacity})';
                  return null;
                },
              ),

              const SizedBox(height: 60),

              // 4. Navigation Button (Roboto)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: (_availabilityStatus == 'Available') 
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ServiceSelectionScreen()),
                            );
                          }
                        }
                      : null,
                  child: Text(
                    bookingProvider.editingBookingId != null 
                      ? 'UPDATE SERVICES' 
                      : 'PROCEED TO SERVICES',
                    style: GoogleFonts.roboto(fontWeight: FontWeight.bold, letterSpacing: 1.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityBadge() {
    bool available = _availabilityStatus == 'Available';
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: available ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: available ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(available ? Icons.check_circle_outline : Icons.error_outline,
              color: available ? Colors.green : Colors.red, size: 20),
          const SizedBox(width: 12),
          Text(
            available ? 'This luxury slot is available' : 'Date is currently unavailable',
            style: GoogleFonts.roboto(
              color: available ? Colors.green : Colors.red, 
              fontWeight: FontWeight.bold,
              fontSize: 14
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, BookingProvider provider) async {
    final DateTime earliestDate = DateTime.now().add(const Duration(days: 2));
    final DateTime latestDate = DateTime.now().add(const Duration(days: 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate ?? earliestDate,
      firstDate: earliestDate,
      lastDate: latestDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGold,
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1E1E1E),
            textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final DateTime normalizedDate = DateTime(picked.year, picked.month, picked.day);
      setState(() {
        _isChecking = true;
        _availabilityStatus = null;
      });

      try {
        provider.selectDate(normalizedDate);
        bool isTaken = await _dbService.isSlotTaken(
          provider.selectedHall!.id, 
          normalizedDate,
          excludeBookingId: provider.editingBookingId,
        );

        if (mounted) {
          setState(() => _availabilityStatus = isTaken ? 'Taken' : 'Available');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Conflict Check Failed: $e"), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isChecking = false);
      }
    }
  }
}