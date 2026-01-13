import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../services/firestore_db.dart';

class AdminUsersTab extends StatelessWidget {
  const AdminUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirestoreService();
    final currentAdminUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<List<UserModel>>(
      stream: db.getAllUsers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryGold));
        }
        if (snapshot.data!.isEmpty) {
          return Center(
            child: Text("No users found.", 
              style: GoogleFonts.roboto(color: Colors.grey))
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final user = snapshot.data![index];
            final bool isMe = user.uid == currentAdminUid;

            return Card(
              color: const Color(0xFF1E1E1E),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: user.role == 'admin' 
                      ? AppColors.primaryGold.withOpacity(0.1) 
                      : Colors.white.withOpacity(0.05),
                  child: Icon(
                    user.role == 'admin' ? Icons.security : Icons.person_outline, 
                    color: user.role == 'admin' ? AppColors.primaryGold : Colors.grey
                  ),
                ),
                // Instrument Serif for Names
                title: Text(
                  "${user.name} ${isMe ? '(You)' : ''}", 
                  style: GoogleFonts.instrumentSerif(
                    color: isMe ? AppColors.primaryGold : Colors.white, 
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  )
                ),
                // Roboto for Emails and technical details
                subtitle: Text(
                  user.email, 
                  style: GoogleFonts.roboto(color: Colors.grey, fontSize: 13, letterSpacing: 0.3)
                ),
                trailing: isMe 
                  ? null 
                  : PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white70),
                      color: const Color(0xFF2C2C2C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditUserDialog(context, db, user);
                        } else if (value == 'reset_password') {
                          _sendPasswordReset(context, user.email);
                        } else if (value == 'delete') {
                          _confirmDeleteUser(context, db, user);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit', 
                          child: Text('Edit Profile', style: GoogleFonts.roboto(fontSize: 14))
                        ),
                        PopupMenuItem(
                          value: 'reset_password', 
                          child: Text('Send Reset Email', style: GoogleFonts.roboto(fontSize: 14))
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete', 
                          child: Text('Delete User', 
                            style: GoogleFonts.roboto(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold))
                        ),
                      ],
                    ),
              ),
            );
          },
        );
      },
    );
  }

  // --- UPDATED EDIT DIALOG ---
  void _showEditUserDialog(BuildContext context, FirestoreService db, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Modify User", 
              style: GoogleFonts.instrumentSerif(color: AppColors.primaryGold, fontSize: 24, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  style: GoogleFonts.roboto(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Display Name",
                    labelStyle: GoogleFonts.roboto(color: Colors.grey),
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                  ),
                ),
                const SizedBox(height: 24),
                Text("Account Role", style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12)),
                DropdownButton<String>(
                  value: selectedRole,
                  dropdownColor: const Color(0xFF2C2C2C),
                  style: GoogleFonts.roboto(color: Colors.white),
                  isExpanded: true,
                  underline: Container(height: 1, color: AppColors.primaryGold.withOpacity(0.5)),
                  onChanged: (String? newValue) {
                    setState(() => selectedRole = newValue!);
                  },
                  items: <String>['user', 'admin'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.toUpperCase(), style: GoogleFonts.roboto(letterSpacing: 1.1, fontSize: 13)),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx), 
                child: Text("CANCEL", style: GoogleFonts.roboto(color: Colors.grey))
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold, 
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  db.updateUserRecord(user.uid, {
                    'name': nameController.text.trim(),
                    'role': selectedRole,
                  });
                  Navigator.pop(ctx);
                },
                child: Text("SAVE CHANGES", style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
              )
            ],
          );
        }
      ),
    );
  }

  // --- PASSWORD RESET ---
  Future<void> _sendPasswordReset(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Reset email sent to $email", style: GoogleFonts.roboto()), 
            backgroundColor: Colors.green
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- DELETE CONFIRMATION ---
  void _confirmDeleteUser(BuildContext context, FirestoreService db, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Remove User?", style: GoogleFonts.instrumentSerif(color: Colors.redAccent, fontSize: 22)),
        content: Text(
          "This will delete ${user.name}'s record from the database. Note: This does not delete their Firebase Auth account.", 
          style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text("CANCEL", style: GoogleFonts.roboto(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              db.deleteUser(user.uid);
              Navigator.pop(ctx);
            },
            child: Text("DELETE", style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}