import 'package:cloud_firestore/cloud_firestore.dart';

class EntrepreneurshipModel {
  final String id;
  final String studentId;
  final String studentName;
  final String title;
  final String description;
  final String category;
  final String contactPhone;
  final String imageUrl;
  final DateTime createdAt;
  final bool approved;

  EntrepreneurshipModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.title,
    required this.description,
    required this.category,
    required this.contactPhone,
    required this.imageUrl,
    required this.createdAt,
    required this.approved,
  });

  factory EntrepreneurshipModel.fromMap(Map<String, dynamic> map, String docId) {
    return EntrepreneurshipModel(
      id: docId,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'General',
      contactPhone: map['contactPhone'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approved: map['approved'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'title': title,
      'description': description,
      'category': category,
      'contactPhone': contactPhone,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'approved': approved,
    };
  }
}
