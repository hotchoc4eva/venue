import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_db.dart';
import '../models/user_model.dart';

// AuthProvider manages global authentication state and user profile
// acts as a ViewModel in the MVVM pattern,bridging UI and Firebase Services
class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _dbService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // local state variable
  UserModel? _currentUser; // holds our custom User data
  bool _isLoading = false; // used to trigger loading spinners in the UI

  // getters for Reactive UI updates
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin'; // RBAC check
  
  User? get user => _auth.currentUser;

  // constructor initialises listener immediately upon app launch
  AuthProvider() {
    _init();
  }

  // listens to the Firebase Auth Stream
  // if user logs in/out elsewhere, app reacts automatically
  void _init() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        // fetch extended profile from Firestore (role, display name, etc)
        _currentUser = await _dbService.getUserData(firebaseUser.uid);
      } else {
        _currentUser = null;
      }
      notifyListeners(); // forces ui to rebuild, like switching login screen to home
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
      return null; // null return signifies success in our pattern
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // registration handles a 2 step process
  // 1. create entry in Firebase Auth (Credentials)
  // 2. create entry in Firestore (Profile Metadata)
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

  // SECURITY FEATURE: re-autheentication logic
  // Firebase requires fresh login (credentials) before allowing password changes  or account deletion 
  Future<String?> changePasswordInApp({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      User? user = _auth.currentUser;
      if (user == null || user.email == null) return "User session not found.";

      // 1. re-authentication gate (required by Firebase for password changes)
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // 2. perform the password update
      await user.updatePassword(newPassword);
      
      return null; 
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An error occurred while changing password.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // UPDATING USER PROFILE: handles 'Synchronous Update' across 3 different layers: Firebase Auth, Cloud Firestore, Local State
  Future<String?> updateDisplayName(String newName) async {
    try {
      _isLoading = true;
      notifyListeners(); // trigger UI loading state

      //1. update firebase auth
      await _auth.currentUser?.updateDisplayName(newName);

      //2. update cloud firestore
      await _dbService.updateUserRecord(_auth.currentUser!.uid, {
        'name': newName,
      });

      //3. update local state
      // we manually rebuild [_currentUser_] object
      // since 'UserModel' is immutable, we create new instance to reflect change in UI immediately without page refresh
      if (_currentUser != null) {
        _currentUser = UserModel(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          name: newName,
          role: _currentUser!.role,
        );
      }
      
      return null; // success
    } catch (e) {
      return e.toString(); // return error
    } finally {
      _isLoading = false;
      notifyListeners(); // stop loading state
    }
  }

  // ACCOUNT DELETION: cleans up both database records and auth credentials
  Future<String?> deleteAccountWithPassword(String currentPassword) async {
    try {
      _isLoading = true;
      notifyListeners();

      User? user = _auth.currentUser;
      if (user == null || user.email == null) return "User session not found.";

      // 1. re-authenticate before final deletion as final security check
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // 2. Delete data from Firestore first, then Auth 
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

  // signOut handles graceful termination of user session
  Future<void> signOut() async {
    //1. clear cloud session
    // notifies firebase to invalidate the local token
    await _authService.signOut();
    //2. clear local memory
    // 'ghost' data from being visible if a different user logs in later
    _currentUser = null;
    //3. rebuild ui
    // redirects user back to the Auth wrapper
    notifyListeners();
  }

  // alias for signOut to match naming conventions
  Future<void> logout() async {
    await signOut();
  }
}
