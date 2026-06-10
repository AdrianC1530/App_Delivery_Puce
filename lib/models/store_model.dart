class StoreModel {
  final String id;
  final String name;
  final String type; // 'bar' | 'stationery'
  final String imageUrl;
  final String locationDescription;
  final bool isOpen;
  final double rating;
  final String? ownerEmail;
  final String? paymentQrBase64;
  final String? paymentAccountInfo;

  StoreModel({
    required this.id,
    required this.name,
    required this.type,
    required this.imageUrl,
    required this.locationDescription,
    required this.isOpen,
    required this.rating,
    this.ownerEmail,
    this.paymentQrBase64,
    this.paymentAccountInfo,
  });

  factory StoreModel.fromMap(Map<String, dynamic> map, String docId) {
    return StoreModel(
      id: docId,
      name: map['name'] ?? '',
      type: map['type'] ?? 'bar',
      imageUrl: map['imageUrl'] ?? '',
      locationDescription: map['locationDescription'] ?? '',
      isOpen: map['isOpen'] ?? true,
      rating: (map['rating'] ?? 5.0).toDouble(),
      ownerEmail: map['ownerEmail'],
      paymentQrBase64: map['paymentQrBase64'],
      paymentAccountInfo: map['paymentAccountInfo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'imageUrl': imageUrl,
      'locationDescription': locationDescription,
      'isOpen': isOpen,
      'rating': rating,
      if (ownerEmail != null) 'ownerEmail': ownerEmail,
      if (paymentQrBase64 != null) 'paymentQrBase64': paymentQrBase64,
      if (paymentAccountInfo != null) 'paymentAccountInfo': paymentAccountInfo,
    };
  }
}
