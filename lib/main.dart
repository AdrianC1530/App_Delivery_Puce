import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart' hide FirebaseService;
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'services/cart_provider.dart';
import 'core/theme.dart';
import 'views/welcome/welcome_view.dart';
import 'views/home/home_view.dart';
import 'views/home/merchant_dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseService.useMock = false;
    debugPrint("Firebase successfully initialized with live DB.");

    // Seeding database (only runs if live mode is active)
    // Uncomment this line to seed the database again if needed:
    await FirebaseService().seedDatabase();
  } catch (e) {
    debugPrint("Firebase initialization failed ($e). Falling back to Offline/Mock mode.");
    FirebaseService.useMock = true;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FirebaseService()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const PuceDeliveryApp(),
    ),
  );
}

class PuceDeliveryApp extends StatelessWidget {
  const PuceDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Session persistence check via the FirebaseService provider
    final firebaseService = context.watch<FirebaseService>();
    final user = firebaseService.currentUser;

    Widget homeWidget = const WelcomeView();
    if (user != null) {
      if (user.role == 'merchant') {
        homeWidget = const MerchantDashboardView();
      } else {
        homeWidget = const HomeView();
      }
    }

    return MaterialApp(
      title: 'PUCE-SI Delivery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Dynamically matches user OS setting
      home: homeWidget,
    );
  }
}

