import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../services/firebase_service.dart';
import '../../core/theme.dart';
import 'register_view.dart';
import '../home/home_view.dart';
import '../home/merchant_dashboard_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final service = Provider.of<FirebaseService>(context, listen: false);
    final error = await service.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Widget nextView = const HomeView();
      if (service.currentUser?.role == 'merchant') {
        nextView = const MerchantDashboardView();
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => nextView),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<FirebaseService>().isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryColor, AppTheme.darkPurple],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // University Logo / Icon Mockup
                    Center(
                      child: Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.5), width: 2),
                        ),
                        child: const Icon(
                          Icons.local_shipping_rounded,
                          color: AppTheme.accentColor,
                          size: 45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "PUCE-SI Delivery",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Pide de los bares y papelerías de la sede",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Login Card
                    Card(
                      elevation: 8,
                      shadowColor: Colors.black26,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Iniciar Sesión",
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.darkPurple,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Email input
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: "Correo Institucional",
                                hintText: "usuario@pucesi.edu.ec",
                                prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor),
                                fillColor: Color(0xFFF1F5F9),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Por favor ingresa tu correo";
                                }
                                if (!value.contains('@')) {
                                  return "Ingresa un correo válido";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // Password input
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: "Contraseña",
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryColor),
                                fillColor: const Color(0xFFF1F5F9),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: AppTheme.primaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Por favor ingresa tu contraseña";
                                }
                                if (value.length < 6) {
                                  return "La contraseña debe tener al menos 6 caracteres";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            // Action Button
                            isLoading
                                ? const Center(
                                    child: SpinKitRing(
                                      color: AppTheme.primaryColor,
                                      size: 50,
                                      lineWidth: 4,
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: _submit,
                                    child: const Text("Entrar"),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "¿No tienes una cuenta? ",
                          style: TextStyle(color: Color(0xCCFFFFFF)),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterView()),
                            );
                          },
                          child: const Text(
                            "Regístrate aquí",
                            style: TextStyle(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: AppTheme.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
