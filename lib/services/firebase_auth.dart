import 'package:firebase_auth/firebase_auth.dart';

// FirebaseAuthService acts as a dedicated wrapper for Firebase Auth SDK
// this abstraction layer decouples the business logic from the specific authentication provider, making the code easier to maintain and test
class FirebaseAuthService {
  // instance of Firebase Authentication entry point
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //1. get current user
  // [authStateChanges] pro
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 2. Sign Up (Register)
  Future<User?> signUp({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred';
    }
  }

  // 3. Sign In (Login)
  Future<User?> signIn({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Login failed';
    }
  }

  // 4. Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
