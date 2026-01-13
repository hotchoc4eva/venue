class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'user' or 'admin'

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.role = 'user',
  });

  // Read from Firestore
  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? 'Guest',
      role: data['role'] ?? 'user',
    );
  }

  // Write to Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
    };
  }
  
  // Helper to check for Admin "Super Power"
  bool get isAdmin => role == 'admin';
}