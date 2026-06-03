import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme.dart';
import '../home/home_view.dart';
import '../auth/login_view.dart';
import '../auth/register_view.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Abstract Aesthetic Background
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.accentGradient,
              ),
            ),
          ),
          // Blur the shapes for a gradient mesh effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),

          // 2. Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 3),
                
                // Typography
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PUCE-SI\nDelivery.",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 54,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Comida rápida, papelería y emprendimientos a un toque de distancia.",
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.darkPurple.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 4),

                // 3. Glassmorphic Bottom Panel
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        border: Border(
                          top: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.05),
                            blurRadius: 30,
                            offset: const Offset(0, -10),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Start Button
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: AppTheme.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const RegisterView()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 22),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Comenzar",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "¿Ya eres parte? ",
                                style: TextStyle(color: AppTheme.darkPurple.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LoginView()),
                                  );
                                },
                                child: const Text(
                                  "Inicia Sesión",
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
