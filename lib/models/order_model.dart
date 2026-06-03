import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final int preparationTimeMinutes;

  CartItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    this.preparationTimeMinutes = 10,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 1,
      price: (map['price'] ?? 0.0).toDouble(),
      preparationTimeMinutes: map['preparationTimeMinutes'] ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'preparationTimeMinutes': preparationTimeMinutes,
    };
  }
}

class OrderModel {
  final String id;
  final String clientId;
  final String storeId;
  final String storeName;
  final List<CartItem> items;
  final double total;
  final String status; // 'pending' | 'preparing' | 'ready_for_pickup' | 'delivering' | 'completed' | 'cancelled'
  final String deliveryLocation;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.clientId,
    required this.storeId,
    required this.storeName,
    required this.items,
    required this.total,
    required this.status,
    required this.deliveryLocation,
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    var itemsList = map['items'] as List<dynamic>? ?? [];
    List<CartItem> parsedItems = itemsList.map((item) => CartItem.fromMap(item as Map<String, dynamic>)).toList();

    return OrderModel(
      id: docId,
      clientId: map['clientId'] ?? '',
      storeId: map['storeId'] ?? '',
      storeName: map['storeName'] ?? '',
      items: parsedItems,
      total: (map['total'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      deliveryLocation: map['deliveryLocation'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'storeId': storeId,
      'storeName': storeName,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': status,
      'deliveryLocation': deliveryLocation,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
