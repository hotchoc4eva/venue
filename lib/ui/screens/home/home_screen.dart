import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/hall_model.dart';
import '../../../services/firestore_db.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/hall_card.dart';
import '../details/hall_details_screen.dart';
import '../admin/admin_home_screen.dart';
import '../profile/profile_screen.dart';
import '../login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _db = FirestoreService();
  String _searchQuery = "";

  // Helper to handle protected actions
  void _protectedAction(BuildContext context, AuthProvider auth, Widget destination) {
    if (auth.isLoggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
    } else {
      _showLoginPrompt(context);
    }
  }

  // Updated Dialog with font pairing
  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          "Sign In Required", 
          style: GoogleFonts.instrumentSerif(
            color: AppColors.primaryGold, 
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "To access your profile and book luxury venues, please sign in to your account.",
          style: GoogleFonts.roboto(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Maybe Later", 
              style: GoogleFonts.roboto(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
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
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isGuest = !authProvider.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ROYAL VENUES',
          style: GoogleFonts.instrumentSerif(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: const Color(0xFFD4AF37),
          ),
        ),
        centerTitle: true,
        actions: [
          if (!isGuest && authProvider.isAdmin)
            IconButton(
              tooltip: 'Admin Dashboard',
              icon: const Icon(Icons.dashboard, color: AppColors.primaryGold),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'My Profile',
            onPressed: () => _protectedAction(context, authProvider, const ProfileScreen()),
          ),
          IconButton(
            icon: Icon(isGuest ? Icons.login : Icons.logout),
            tooltip: isGuest ? 'Sign In' : 'Logout',
            onPressed: () {
              if (isGuest) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              } else {
                authProvider.logout();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar with Roboto
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: GoogleFonts.roboto(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by name or location...',
                hintStyle: GoogleFonts.roboto(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryGold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<HallModel>>(
              stream: _db.getHalls(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryGold),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "No venues found.",
                      style: GoogleFonts.roboto(color: Colors.grey),
                    ),
                  );
                }

                final filteredHalls = snapshot.data!.where((hall) {
                  return hall.name.toLowerCase().contains(_searchQuery) ||
                         hall.location.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredHalls.isEmpty) {
                  return Center(
                    child: Text(
                      "No results match your search.",
                      style: GoogleFonts.roboto(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredHalls.length,
                  itemBuilder: (context, index) {
                    final hall = filteredHalls[index];
                    return HallCard(
                      hall: hall,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HallDetailsScreen(hall: hall),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}