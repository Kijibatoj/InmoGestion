import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'onboarding_service.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  Future<void> _finishOnboarding(BuildContext context) async {
    await OnboardingService.completeOnboarding();
    // El sistema de rutas se encarga automáticamente de la redirección
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo SVG o imagen personalizada
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset(
                  'assets/images/logo_house_red.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback al icono si no existe la imagen
                    return Icon(
                      Icons.home_work,
                      size: 80,
                      color: AppColors.primaryRed,
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Bienvenido a InmoGestion',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Gestiona tus propiedades de forma sencilla y segura. Publica, edita y administra tus inmuebles desde cualquier lugar.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _finishOnboarding(context),
                child: const Text(
                  'Comenzar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
