import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/store_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/entrepreneurship_model.dart';

class FirebaseService extends ChangeNotifier {
  static bool useMock = true;

  FirebaseAuth? _auth;
  FirebaseFirestore? _db;

  FirebaseAuth get auth => _auth ??= FirebaseAuth.instance;
  FirebaseFirestore get db => _db ??= FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? merchantStoreId;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // In-memory collections for Mock Mode
  final List<StoreModel> _mockStores = [];
  final List<ProductModel> _mockProducts = [];
  final List<OrderModel> _mockOrders = [];
  final List<EntrepreneurshipModel> _mockEntrepreneurships = [];

  FirebaseService() {
    _initMocks(); // Always initialize mock arrays so seedDatabase has data
    if (!useMock) {
      try {
        auth.authStateChanges().listen(_onAuthStateChanged);
      } catch (e) {
        debugPrint("Firebase services access failed, falling back to Mock mode: $e");
        useMock = true;
      }
    }
  }

  void _initMocks() {
    // Default logged in user so user doesn't have to register to see the app (only in Mock Mode)
    if (useMock) {
      _currentUser = UserModel(
        uid: "mock-student-123",
        name: "Daniela Ibarra",
        email: "daniela.ibarra@demo.app",
        role: "student",
        phoneNumber: "0991234567",
        createdAt: DateTime.now(),
      );
    }

    _mockStores.addAll([
      StoreModel(
        id: "store-1",
        name: "Bar Central - Cafetería",
        type: "bar",
        rating: 4.8,
        isOpen: true,
        imageUrl: "",
        locationDescription: "Bloque A (Aulas), Planta Baja",
        ownerEmail: "bar1@demo.app",
      ),
      StoreModel(
        id: "store-2",
        name: "El Rincón del Dulce",
        type: "bar",
        rating: 4.5,
        isOpen: true,
        imageUrl: "",
        locationDescription: "Junto a la pileta del Bloque B",
        ownerEmail: "bar2@demo.app",
      ),
      StoreModel(
        id: "store-3",
        name: "Papelería Universitaria",
        type: "stationery",
        rating: 4.9,
        isOpen: true,
        imageUrl: "",
        locationDescription: "Planta baja del Edificio Administrativo",
        ownerEmail: "papeleria@demo.app",
      ),
    ]);

    _mockProducts.addAll([
      // Bar Central
      ProductModel(
        id: "p-1",
        storeId: "store-1",
        name: "Almuerzo Universitario",
        description: "Entrada (sopa caliente), plato fuerte balanceado y bebida de fruta natural.",
        price: 3.25,
        imageUrl: "",
        category: "Almuerzos",
        isAvailable: true,
        preparationTimeMinutes: 15,
      ),
      ProductModel(
        id: "p-2",
        storeId: "store-1",
        name: "Empanada de Viento con Queso",
        description: "Empanada crocante rellena de queso, espolvoreada con azúcar blanca.",
        price: 0.85,
        imageUrl: "",
        category: "Snacks",
        isAvailable: true,
        preparationTimeMinutes: 5,
      ),
      ProductModel(
        id: "p-3",
        storeId: "store-1",
        name: "Café Pasado Caliente",
        description: "Delicioso café filtrado con granos seleccionados locales.",
        price: 1.00,
        imageUrl: "",
        category: "Bebidas",
        isAvailable: true,
        preparationTimeMinutes: 5,
      ),
      // El Rincón
      ProductModel(
        id: "p-4",
        storeId: "store-2",
        name: "Tarta Húmeda de Chocolate",
        description: "Porción generosa de pastel de chocolate fudge extra suave.",
        price: 2.20,
        imageUrl: "",
        category: "Postres",
        isAvailable: true,
        preparationTimeMinutes: 2,
      ),
      ProductModel(
        id: "p-5",
        storeId: "store-2",
        name: "Capuccino Cremoso",
        description: "Shot de espresso con leche texturizada y un toque de canela molida.",
        price: 1.75,
        imageUrl: "",
        category: "Bebidas",
        isAvailable: true,
        preparationTimeMinutes: 5,
      ),
      // Papeleria
      ProductModel(
        id: "p-6",
        storeId: "store-3",
        name: "Impresión Blanco y Negro (A4)",
        description: "Impresión de alta resolución por una carilla en papel bond standard.",
        price: 0.05,
        imageUrl: "",
        category: "Servicios",
        isAvailable: true,
        preparationTimeMinutes: 10,
      ),
      ProductModel(
        id: "p-7",
        storeId: "store-3",
        name: "Cuaderno Universitario Cuadros",
        description: "Cuaderno anillado espiral metálico, 100 hojas a cuadros.",
        price: 1.50,
        imageUrl: "",
        category: "Útiles",
        isAvailable: true,
        preparationTimeMinutes: 2,
      ),
    ]);

    _mockEntrepreneurships.addAll([
      EntrepreneurshipModel(
        id: "e-1",
        studentId: "mock-student-99",
        studentName: "Sofía Martínez (Negocios)",
        title: "Cupcakes Temáticos Artesanales",
        description: "Cupcakes decorados con crema y diseños personalizados. Ideales para regalos de cumpleaños y fechas especiales.",
        category: "Comida",
        contactPhone: "0998765432",
        imageUrl: "",
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        approved: true,
      ),
      EntrepreneurshipModel(
        id: "e-2",
        studentId: "mock-student-88",
        studentName: "Carlos Mora (Sistemas)",
        title: "Soporte Técnico de Computadoras",
        description: "Mantenimiento preventivo, formateo de PCs, instalación de software licenciado y antivirus para estudiantes.",
        category: "Servicios",
        contactPhone: "0987654321",
        imageUrl: "",
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        approved: true,
      ),
    ]);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
    } else {
      await fetchUserData(firebaseUser.uid);
    }
    notifyListeners();
  }

  Future<void> fetchUserData(String uid) async {
    if (useMock) {
      if (_currentUser?.role == 'merchant') {
        merchantStoreId = _mockStores.firstWhere((s) => s.ownerEmail == _currentUser?.email, orElse: () => _mockStores.first).id;
      }
      return;
    }
    try {
      DocumentSnapshot doc = await db.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        
        if (_currentUser?.role == 'merchant') {
          final storeQuery = await db.collection('stores').where('ownerEmail', isEqualTo: _currentUser!.email).limit(1).get();
          if (storeQuery.docs.isNotEmpty) {
            merchantStoreId = storeQuery.docs.first.id;
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

  // --- AUTHENTICATION METHODS ---

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String role,
  }) async {
    _setLoading(true);
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      _currentUser = UserModel(
        uid: "mock-user-${DateTime.now().millisecondsSinceEpoch}",
        name: name,
        email: email,
        role: role,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );
      _setLoading(false);
      notifyListeners();
      return null;
    }
    try {
      UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = credential.user;
      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          role: role,
          phoneNumber: phoneNumber,
          createdAt: DateTime.now(),
        );
        
        await db.collection('users').doc(user.uid).set(newUser.toMap());
        _currentUser = newUser;
      }
      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message;
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      String role = 'student';
      String name = 'Daniela Ibarra';
      if (email.contains('bar') || email.contains('merchant') || email.contains('papeleria')) {
        role = 'merchant';
        name = 'Don Tito (Bar Central)';
      }
      _currentUser = UserModel(
        uid: "mock-user-login",
        name: name,
        email: email,
        role: role,
        phoneNumber: "0998887776",
        createdAt: DateTime.now(),
      );
      _setLoading(false);
      notifyListeners();
      return null;
    }
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.message;
    } catch (e) {
      _setLoading(false);
      return e.toString();
    }
  }

  Future<void> signOut() async {
    if (useMock) {
      _currentUser = null;
      notifyListeners();
      return;
    }
    try {
      await auth.signOut();
    } catch (e) {
      debugPrint("Auth signout failed: $e");
    }
    _currentUser = null;
    notifyListeners();
  }

  // --- STORES & PRODUCTS ---

  Future<String?> createStore({
    required String name,
    required String type,
    required String locationDescription,
  }) async {
    if (_currentUser?.role != 'admin') return "Acceso denegado";
    if (useMock) return "No disponible en Modo Mock";

    try {
      DocumentReference docRef = db.collection('stores').doc();
      StoreModel newStore = StoreModel(
        id: docRef.id,
        name: name,
        type: type,
        rating: 5.0, // Default rating
        isOpen: true,
        imageUrl: "", // Left blank for now
        locationDescription: locationDescription,
      );

      await docRef.set(newStore.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<StoreModel>> streamStores() {
    if (useMock) {
      return Stream.value(_mockStores);
    }
    return db.collection('stores').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => StoreModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> toggleStoreStatus(String storeId, bool isOpen) async {
    if (_currentUser?.role != 'admin') return;
    try {
      await db.collection('stores').doc(storeId).update({'isOpen': isOpen});
    } catch (e) {
      debugPrint("Error toggling store status: $e");
    }
  }

  Stream<List<ProductModel>> streamProducts(String storeId) {
    if (useMock) {
      return Stream.value(_mockProducts.where((p) => p.storeId == storeId).toList());
    }
    return db
        .collection('products')
        .where('storeId', isEqualTo: storeId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<ProductModel>> streamAllProducts() {
    if (useMock) {
      return Stream.value(_mockProducts);
    }
    return db
        .collection('products')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<String?> createProduct({
    required String storeId,
    required String name,
    required String description,
    required double price,
    required String category,
    required int preparationTimeMinutes,
  }) async {
    if (_currentUser?.role != 'admin' && _currentUser?.role != 'merchant') return "Acceso denegado";
    if (useMock) return "No disponible en Mock";

    try {
      DocumentReference docRef = db.collection('products').doc();
      ProductModel newProduct = ProductModel(
        id: docRef.id,
        storeId: storeId,
        name: name,
        description: description,
        price: price,
        imageUrl: "",
        category: category,
        isAvailable: true,
        preparationTimeMinutes: preparationTimeMinutes,
      );

      await docRef.set(newProduct.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> toggleProductAvailability(String productId, bool isAvailable) async {
    if (_currentUser?.role != 'admin' && _currentUser?.role != 'merchant') return;
    try {
      await db.collection('products').doc(productId).update({'isAvailable': isAvailable});
    } catch (e) {
      debugPrint("Error toggling product availability: $e");
    }
  }

  Future<String?> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required String category,
    required int preparationTimeMinutes,
  }) async {
    if (_currentUser?.role != 'admin' && _currentUser?.role != 'merchant') return "Acceso denegado";
    if (useMock) {
      final index = _mockProducts.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final old = _mockProducts[index];
        _mockProducts[index] = ProductModel(
          id: old.id,
          storeId: old.storeId,
          name: name,
          description: description,
          price: price,
          imageUrl: old.imageUrl,
          category: category,
          isAvailable: old.isAvailable,
          preparationTimeMinutes: preparationTimeMinutes,
        );
        notifyListeners();
      }
      return null;
    }

    try {
      await db.collection('products').doc(productId).update({
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'preparationTimeMinutes': preparationTimeMinutes,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // --- ORDERS ---

  Future<String?> placeOrder({
    required String storeId,
    required String storeName,
    required List<CartItem> items,
    required double total,
    required String deliveryLocation,
  }) async {
    if (_currentUser == null) return "User not logged in";
    
    if (useMock) {
      _setLoading(true);
      await Future.delayed(const Duration(milliseconds: 600));
      final newOrder = OrderModel(
        id: "order-${DateTime.now().millisecondsSinceEpoch}",
        clientId: _currentUser!.uid,
        storeId: storeId,
        storeName: storeName,
        items: items,
        total: total,
        status: 'pending',
        deliveryLocation: deliveryLocation,
        createdAt: DateTime.now(),
      );
      _mockOrders.insert(0, newOrder);
      _setLoading(false);
      notifyListeners();
      return null;
    }
    
    try {
      DocumentReference docRef = db.collection('orders').doc();
      OrderModel newOrder = OrderModel(
        id: docRef.id,
        clientId: _currentUser!.uid,
        storeId: storeId,
        storeName: storeName,
        items: items,
        total: total,
        status: 'pending',
        deliveryLocation: deliveryLocation,
        createdAt: DateTime.now(),
      );

      await docRef.set(newOrder.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<OrderModel>> streamClientOrders() {
    if (_currentUser == null) return Stream.value([]);
    if (useMock) {
      if (_currentUser!.role == 'merchant') {
        // Mock merchant sees all orders directed to the campus bars
        return Stream.value(_mockOrders);
      }
      return Stream.value(_mockOrders.where((o) => o.clientId == _currentUser!.uid).toList());
    }
    return db
        .collection('orders')
        .where('clientId', isEqualTo: _currentUser!.uid)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<OrderModel>> streamAllOrders() {
    if (_currentUser?.role != 'admin' && _currentUser?.role != 'merchant') return Stream.value([]);
    
    // If the user is a merchant and has a specific store, only stream their store's orders
    if (_currentUser?.role == 'merchant' && merchantStoreId != null) {
      return streamMerchantOrders(merchantStoreId!);
    }

    if (useMock) return Stream.value(_mockOrders);

    return db
        .collection('orders')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<OrderModel>> streamMerchantOrders(String storeId) {
    if (useMock) {
      return Stream.value(_mockOrders.where((o) => o.storeId == storeId).toList());
    }
    return db
        .collection('orders')
        .where('storeId', isEqualTo: storeId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    if (useMock) {
      final index = _mockOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        final order = _mockOrders[index];
        _mockOrders[index] = OrderModel(
          id: order.id,
          clientId: order.clientId,
          storeId: order.storeId,
          storeName: order.storeName,
          items: order.items,
          total: order.total,
          status: newStatus,
          deliveryLocation: order.deliveryLocation,
          createdAt: order.createdAt,
        );
        notifyListeners();
      }
      return;
    }
    try {
      await db.collection('orders').doc(orderId).update({'status': newStatus});
    } catch (e) {
      debugPrint("Error updating order status: $e");
    }
  }

  // --- STUDENT ENTREPRENEURSHIPS ---

  Future<String?> postEntrepreneurship({
    required String title,
    required String description,
    required String category,
    required String contactPhone,
    required String imageUrl,
  }) async {
    if (_currentUser == null) return "User not logged in";

    if (useMock) {
      _setLoading(true);
      await Future.delayed(const Duration(milliseconds: 600));
      final newPost = EntrepreneurshipModel(
        id: "ent-${DateTime.now().millisecondsSinceEpoch}",
        studentId: _currentUser!.uid,
        studentName: _currentUser!.name,
        title: title,
        description: description,
        category: category,
        contactPhone: contactPhone,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        approved: true,
      );
      _mockEntrepreneurships.insert(0, newPost);
      _setLoading(false);
      notifyListeners();
      return null;
    }

    try {
      DocumentReference docRef = db.collection('entrepreneurships').doc();
      EntrepreneurshipModel newPost = EntrepreneurshipModel(
        id: docRef.id,
        studentId: _currentUser!.uid,
        studentName: _currentUser!.name,
        title: title,
        description: description,
        category: category,
        contactPhone: contactPhone,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        approved: false, // Ahora requieren aprobación del admin
      );

      await docRef.set(newPost.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<EntrepreneurshipModel>> streamEntrepreneurships() {
    if (useMock) {
      return Stream.value(_mockEntrepreneurships);
    }
    return db
        .collection('entrepreneurships')
        .where('approved', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => EntrepreneurshipModel.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<EntrepreneurshipModel>> adminStreamEntrepreneurships() {
    if (_currentUser?.role != 'admin') return Stream.value([]);
    if (useMock) return Stream.value(_mockEntrepreneurships);

    return db.collection('entrepreneurships').snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => EntrepreneurshipModel.fromMap(doc.data(), doc.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> toggleEntrepreneurshipApproval(String id, bool approved) async {
    if (_currentUser?.role != 'admin') return;
    try {
      await db.collection('entrepreneurships').doc(id).update({'approved': approved});
    } catch (e) {
      debugPrint("Error updating entrepreneurship approval: $e");
    }
  }

  // --- SUGGESTIONS ---

  Future<void> submitSuggestion(String text) async {
    if (_currentUser == null) return;
    if (useMock) return;

    try {
      await db.collection('suggestions').add({
        'studentId': _currentUser!.uid,
        'studentName': _currentUser!.name,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error submitting suggestion: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> streamSuggestions() {
    if (_currentUser?.role != 'admin') return Stream.value([]);
    if (useMock) return Stream.value([]);

    return db.collection('suggestions').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> seedDatabase() async {
    if (useMock) {
      debugPrint("No se puede migrar datos en Modo Mock. Inicializa Firebase primero.");
      return;
    }
    _setLoading(true);
    try {
      // 1. Seed Stores
      for (var store in _mockStores) {
        await db.collection('stores').doc(store.id).set(store.toMap());
      }
      // 2. Seed Products
      for (var product in _mockProducts) {
        await db.collection('products').doc(product.id).set(product.toMap());
      }
      // 3. Seed Entrepreneurships
      for (var ent in _mockEntrepreneurships) {
        await db.collection('entrepreneurships').doc(ent.id).set(ent.toMap());
      }
      
      // 4. Create a test admin user if it doesn't exist
      try {
        await signUp(
          email: 'admin@demo.app',
          password: 'admin123',
          name: 'Super Administrador',
          phoneNumber: '0999999999',
          role: 'admin',
        );
        debugPrint("Usuario admin creado exitosamente.");
      } catch (e) {
        debugPrint("Usuario admin ya existía o error al crear: $e");
      }

      // 5. Create merchant accounts
      final merchants = [
        {'email': 'bar1@demo.app', 'name': 'Bar Central'},
        {'email': 'bar2@demo.app', 'name': 'El Rincón del Dulce'},
        {'email': 'papeleria@demo.app', 'name': 'Papelería Universitaria'},
      ];

      for (var m in merchants) {
        try {
          await signUp(
            email: m['email']!,
            password: 'bar123', // Default password
            name: m['name']!,
            phoneNumber: '0999999999',
            role: 'merchant',
          );
          debugPrint("Merchant ${m['email']} creado exitosamente.");
        } catch (e) {
          debugPrint("Merchant ${m['email']} ya existía o error al crear: $e");
        }
      }

      debugPrint("¡Migración de datos a Firebase completada con éxito!");
    } catch (e) {
      debugPrint("Error durante la migración a Firebase: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
