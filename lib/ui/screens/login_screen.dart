import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// 🟢 FIX: Hide the conflicting AuthProvider from Firebase
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider; 
import '../../../providers/auth_provider.dart'; 
import '../../../services/firestore_db.dart';
import 'register_screen.dart';
import 'home/home_screen.dart';
import 'admin/admin_home_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isCheckingRole = false; 

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Logo / Branding (Instrument Serif)
                const Icon(Icons.diamond_outlined, size: 80, color: Color(0xFFD4AF37)),
                const SizedBox(height: 16),
                Text(
                  'ROYAL VENUES',
                  style: GoogleFonts.instrumentSerif(
                    fontSize: 42,               
                    fontWeight: FontWeight.w400, 
                    color: const Color(0xFFD4AF37), 
                    letterSpacing: 4.0,         
                    height: 1.0,
                  ),
                ),
                Text(
                  'PREMIUM EVENT BOOKING', 
                  style: GoogleFonts.roboto(     
                    color: Colors.grey,
                    fontSize: 11,
                    letterSpacing: 3.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                
                const SizedBox(height: 40),

                // 2. Email Field (Roboto)
                TextFormField(
                  controller: _emailController,
                  style: GoogleFonts.roboto(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: GoogleFonts.roboto(color: Colors.grey),
                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFD4AF37)),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (val) => val!.contains('@') ? null : 'Invalid Email',
                ),
                const SizedBox(height: 16),

                // 3. Password Field (Roboto)
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: GoogleFonts.roboto(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: GoogleFonts.roboto(color: Colors.grey),
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFD4AF37)),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (val) => val!.length < 6 ? 'Password too short' : null,
                ),
                const SizedBox(height: 24),

                // 4. Action Button (Roboto via Theme)
                if (authProvider.isLoading || _isCheckingRole)
                  const CircularProgressIndicator(color: Color(0xFFD4AF37))
                else
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String? error = await authProvider.login(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );
                          
                          if (error != null) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error), backgroundColor: Colors.red),
                              );
                            }
                          } else {
                            if (mounted) setState(() => _isCheckingRole = true);

                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              final userData = await FirestoreService().getUserData(user.uid);
                              
                              if (mounted) {
                                setState(() => _isCheckingRole = false);
                                if (userData?.role == 'admin') {
                                  Navigator.pushReplacement(
                                    context, 
                                    MaterialPageRoute(builder: (_) => const AdminHomeScreen())
                                  );
                                } else {
                                  Navigator.pushReplacement(
                                    context, 
                                    MaterialPageRoute(builder: (_) => const HomeScreen())
                                  );
                                }
                              }
                            }
                          }
                        }
                      },
                      child: const Text('SIGN IN'),
                    ),
                  ),

                // 5. Register Link (Roboto)
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", 
                      style: GoogleFonts.roboto(color: Colors.grey, fontSize: 13)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: Text('Register', 
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),

                // 6. GUEST BYPASS (Roboto)
                const SizedBox(height: 16),
                const Divider(color: Colors.white10, indent: 50, endIndent: 50),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                  child: Text(
                    'Browse as Guest',
                    style: GoogleFonts.roboto(
                      color: Colors.grey.shade500, 
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}