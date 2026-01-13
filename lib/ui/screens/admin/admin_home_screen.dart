import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../login_screen.dart';

// Import the tabs
import 'admin_analytics_tab.dart'; // 🟢 New
import 'admin_bookings_tab.dart';
import 'admin_venues_tab.dart';
import 'admin_users_tab.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 🟢 Updated length to 4 to include Analytics
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Instrument Serif for the Main Dashboard Title
        title: Text(
          'ADMIN REGISTRY', 
          style: GoogleFonts.instrumentSerif(
            letterSpacing: 1.5, 
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGold,
          )
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGold,
          labelColor: AppColors.primaryGold,
          unselectedLabelColor: Colors.grey,
          // Roboto for the Tab Labels to ensure clarity
          labelStyle: GoogleFonts.roboto(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined), text: "REVENUE"),
            Tab(icon: Icon(Icons.list_alt), text: "BOOKINGS"),
            Tab(icon: Icon(Icons.storefront_outlined), text: "VENUES"),
            Tab(icon: Icon(Icons.people_outline), text: "USERS"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Sign Out',
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AdminAnalyticsTab(), // 🟢 First Tab: Financial Overview
          AdminBookingsTab(),  // Second Tab: Management
          AdminVenuesTab(),    // Third Tab: Inventory
          AdminUsersTab(),     // Fourth Tab: Access Control
        ],
      ),
    );
  }
}