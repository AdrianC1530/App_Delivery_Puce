import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  String? _storeId;
  String? _storeName;
  final Map<String, CartItem> _items = {};

  String? get storeId => _storeId;
  String? get storeName => _storeName;
  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _items.values.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  int get maxPreparationTime => _items.values.fold(0, (max, item) => item.preparationTimeMinutes > max ? item.preparationTimeMinutes : max);

  bool addItem(ProductModel product, String storeName) {
    // If the cart already has items from another store, prevent adding
    if (_storeId != null && _storeId != product.storeId) {
      return false; // Return false to indicate store mismatch
    }

    _storeId = product.storeId;
    _storeName = storeName;

    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existing) => CartItem(
          productId: existing.productId,
          name: existing.name,
          quantity: existing.quantity + 1,
          price: existing.price,
          preparationTimeMinutes: existing.preparationTimeMinutes,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          productId: product.id,
          name: product.name,
          quantity: 1,
          price: product.price,
          preparationTimeMinutes: product.preparationTimeMinutes,
        ),
      );
    }
    notifyListeners();
    return true;
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
          productId: existing.productId,
          name: existing.name,
          quantity: existing.quantity - 1,
          price: existing.price,
          preparationTimeMinutes: existing.preparationTimeMinutes,
        ),
      );
    } else {
      _items.remove(productId);
    }

    if (_items.isEmpty) {
      _storeId = null;
      _storeName = null;
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    if (_items.isEmpty) {
      _storeId = null;
      _storeName = null;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _storeId = null;
    _storeName = null;
    notifyListeners();
  }
}
