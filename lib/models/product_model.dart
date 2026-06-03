class ProductModel {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool isAvailable;
  final String category;
  final int preparationTimeMinutes;

  ProductModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    required this.category,
    this.preparationTimeMinutes = 10,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProductModel(
      id: docId,
      storeId: map['storeId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      category: map['category'] ?? 'General',
      preparationTimeMinutes: map['preparationTimeMinutes'] ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'category': category,
      'preparationTimeMinutes': preparationTimeMinutes,
    };
  }
}
