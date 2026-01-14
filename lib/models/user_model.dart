import 'package:cloud_firestore/cloud_firestore.dart';

// [UserModel] defines the schema for registered accounts
// primary data structure for RBAC
class UserModel {
  // 'uid' is the unique primary key provided by Firebase Authentication
  final String uid;
  final String email;
  final String name;
  // 'role' attribute determines system permissions
  // values : 'user' or 'admin'
  final String role; 

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.role = 'user', // defaults to 'user' for security
  });

  // fromMap is the factory constructor for deserialisation
  // converts 'snapshot' from Firestore back into Dart Object
  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      // defaulting empty strings prevents UI crashes if a document is partially missing data
      email: data['email'] ?? '',
      name: data['name'] ?? 'Guest',
      role: data['role'] ?? 'user',
    );
  }

  // toMap prepares object for a Firestore Write operation
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
    };
  }
  
  // isAdmin is a computed property (getter)
  // simplifies logic throughout app, allows us to write 'if(user.isAdmin)' instead of checking strings repeatedly
  bool get isAdmin => role == 'admin';
}
