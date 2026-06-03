import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'student' | 'merchant' | 'delivery' | 'admin'
  final String phoneNumber;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.phoneNumber,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
