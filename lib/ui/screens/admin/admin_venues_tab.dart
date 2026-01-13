import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/hall_model.dart';
import '../../../services/firestore_db.dart';

class AdminVenuesTab extends StatelessWidget {
  const AdminVenuesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGold,
        icon: const Icon(Icons.add, color: Colors.black),
        label: Text("ADD VENUE", style: GoogleFonts.roboto(color: Colors.black, fontWeight: FontWeight.bold)),
        onPressed: () => _showHallDialog(context, db, null),
      ),
      body: StreamBuilder<List<HallModel>>(
        stream: db.getHalls(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primaryGold));
          if (snapshot.data!.isEmpty) return const Center(child: Text("No venues in registry."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final hall = snapshot.data![index];
              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: hall.imageUrl, 
                      width: 70, height: 70, fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.black12),
                      errorWidget: (c, o, s) => Container(color: Colors.grey, child: const Icon(Icons.broken_image)),
                    ),
                  ),
                  title: Text(hall.name, 
                    style: GoogleFonts.instrumentSerif(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("RM ${hall.basePrice.toStringAsFixed(0)} / day", 
                        style: GoogleFonts.roboto(color: AppColors.primaryGold, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(hall.amenities.isEmpty ? "No amenities selected" : hall.amenities.join(" • "), 
                        style: GoogleFonts.roboto(color: Colors.grey, fontSize: 11), 
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.white70),
                        onPressed: () => _showHallDialog(context, db, hall),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _confirmDeleteVenue(context, db, hall),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- INTEGRATED DIALOG WITH AMENITY CHECKLIST ---
  void _showHallDialog(BuildContext context, FirestoreService db, HallModel? hall) {
    final isEditing = hall != null;
    final nameController = TextEditingController(text: hall?.name);
    final priceController = TextEditingController(text: hall?.basePrice.toString());
    final imageController = TextEditingController(text: hall?.imageUrl);
    final locationController = TextEditingController(text: hall?.location);
    final capacityController = TextEditingController(text: hall?.capacity.toString() ?? "500");

    final List<String> masterAmenities = [
      'VIP Lounge', 'High-Speed WiFi', 'Valet Parking', 
      'Stage Lighting', 'Climate Control', 'Bridal Suite', 
      'Projector & Screen', 'Surround Sound'
    ];
    List<String> selectedAmenities = List.from(hall?.amenities ?? []);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(isEditing ? "Modify Venue" : "Register New Venue", 
              style: GoogleFonts.instrumentSerif(color: AppColors.primaryGold, fontSize: 26)),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField(nameController, "Venue Name"),
                    _buildField(priceController, "Price per Day (RM)", isNumber: true),
                    _buildField(locationController, "Location"),
                    _buildField(capacityController, "Max Capacity", isNumber: true),
                    _buildField(imageController, "Image URL"),
                    
                    const SizedBox(height: 20),
                    Text("AVAILABLE AMENITIES", 
                      style: GoogleFonts.roboto(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 10),
                    
                    // The Amenities Checklist
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: masterAmenities.map((item) {
                          final isChecked = selectedAmenities.contains(item);
                          return CheckboxListTile(
                            dense: true,
                            activeColor: AppColors.primaryGold,
                            title: Text(item, style: GoogleFonts.roboto(color: isChecked ? Colors.white : Colors.grey, fontSize: 14)),
                            value: isChecked,
                            onChanged: (val) {
                              setDialogState(() {
                                val! ? selectedAmenities.add(item) : selectedAmenities.remove(item);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text("CANCEL", style: GoogleFonts.roboto(color: Colors.grey))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: Colors.black),
                onPressed: () {
                  final double price = double.tryParse(priceController.text) ?? 0;
                  final int capacity = int.tryParse(capacityController.text) ?? 500;
                  
                  if (isEditing) {
                    db.updateHall(hall.id, {
                      'name': nameController.text,
                      'basePrice': price,
                      'imageUrl': imageController.text,
                      'location': locationController.text,
                      'capacity': capacity,
                      'amenities': selectedAmenities,
                    });
                  } else {
                    final newHall = HallModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      description: "Experience absolute luxury in this premium venue.",
                      basePrice: price,
                      capacity: capacity,
                      imageUrl: imageController.text.isEmpty ? "https://images.unsplash.com/photo-1519167758481-83f550bb49b3" : imageController.text,
                      location: locationController.text,
                      amenities: selectedAmenities,
                    );
                    db.createHall(newHall);
                  }
                  Navigator.pop(ctx);
                },
                child: Text(isEditing ? "SAVE" : "CREATE", style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
              )
            ],
          );
        }
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        style: GoogleFonts.roboto(color: Colors.white, fontSize: 14),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.roboto(color: Colors.grey, fontSize: 12),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryGold)),
        ),
      ),
    );
  }

  void _confirmDeleteVenue(BuildContext context, FirestoreService db, HallModel hall) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text("Delete Venue?", style: GoogleFonts.instrumentSerif(color: Colors.redAccent)),
        content: Text("Are you sure you want to remove ${hall.name} from the collection?", style: GoogleFonts.roboto(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              db.deleteHall(hall.id);
              Navigator.pop(ctx);
            },
            child: const Text("DELETE"),
          )
        ],
      ),
    );
  }
}