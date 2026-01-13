import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_db.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _dbService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';

  User? get user => _auth.currentUser;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        _currentUser = await _dbService.getUserData(firebaseUser.uid);
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  // ==========================================
  //            AUTHENTICATION LOGIC
  // ==========================================

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signIn(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();
    try {
      User? user = await _authService.signUp(email: email, password: password);
      if (user != null) {
        UserModel newUser = UserModel(uid: user.uid, email: email, name: name);
        await _dbService.createUserRecord(newUser);
      }
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  //          ACCOUNT MANAGEMENT LOGIC
  // ==========================================

  /// 🟢 NEW: Direct in-app password change with re-authentication
  Future<String?> changePasswordInApp({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      User? user = _auth.currentUser;
      if (user == null || user.email == null) return "User session not found.";

      // 1. Re-authenticate for security (Required by Firebase for password changes)
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // 2. Perform the password update
      await user.updatePassword(newPassword);
      
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An error occurred while changing password.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateDisplayName(String newName) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.currentUser?.updateDisplayName(newName);
      
      await _dbService.updateUserRecord(_auth.currentUser!.uid, {
        'name': newName,
      });

      if (_currentUser != null) {
        _currentUser = UserModel(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          name: newName,
          role: _currentUser!.role,
        );
      }
      
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🟢 UPDATED: Account deletion with safety re-authentication check
  Future<String?> deleteAccountWithPassword(String currentPassword) async {
    try {
      _isLoading = true;
      notifyListeners();

      User? user = _auth.currentUser;
      if (user == null || user.email == null) return "User session not found.";

      // 1. Re-authenticate before final deletion
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // 2. Delete Firestore data and Auth record
      await _dbService.deleteUser(user.uid);
      await user.delete();
      
      await logout();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An error occurred during account deletion.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  //               EXIT LOGIC
  // ==========================================

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await signOut();
  }
}