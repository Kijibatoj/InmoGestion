import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive_utils.dart';
import 'onboarding_service.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  Future<void> _finishOnboarding(BuildContext context) async {
    await OnboardingService.completeOnboarding();
    // El sistema de rutas se encarga automáticamente de la redirección
  }

  @override
  Widget build(BuildContext context) {
    final responsivePadding = ResponsiveUtils.getResponsivePadding(context);
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);
    final isLandscape = ResponsiveUtils.isLandscape(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.all(responsivePadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo SVG o imagen personalizada
                  Container(
                    width: ResponsiveUtils.getImageSize(
                      context,
                      mobile: 100,
                      tablet: 130,
                      desktop: 160,
                    ),
                    height: ResponsiveUtils.getImageSize(
                      context,
                      mobile: 100,
                      tablet: 130,
                      desktop: 160,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getBorderRadius(
                          context,
                          mobile: 20,
                          tablet: 25,
                          desktop: 30,
                        ),
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/logo_house_red.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback al icono si no existe la imagen
                        return Icon(
                          Icons.home_work,
                          size: ResponsiveUtils.getImageSize(
                            context,
                            mobile: 80,
                            tablet: 100,
                            desktop: 120,
                          ),
                          color: AppColors.primaryRed,
                        );
                      },
                    ),
                  ),

                  SizedBox(
                    height: ResponsiveUtils.getVerticalSpacing(
                      context,
                      mobile: 32,
                      tablet: 40,
                      desktop: 48,
                    ),
                  ),

                  Text(
                    'Bienvenido a InmoGestion',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        baseFontSize: 28,
                      ),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryRed,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(
                    height: ResponsiveUtils.getVerticalSpacing(
                      context,
                      mobile: 16,
                      tablet: 20,
                      desktop: 24,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getHorizontalSpacing(
                        context,
                        mobile: 16,
                        tablet: 32,
                        desktop: 64,
                      ),
                    ),
                    child: Text(
                      'Gestiona tus propiedades de forma sencilla y segura. Publica, edita y administra tus inmuebles desde cualquier lugar.',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          baseFontSize: 16,
                        ),
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(
                    height: ResponsiveUtils.getVerticalSpacing(
                      context,
                      mobile: 32,
                      tablet: 40,
                      desktop: 48,
                    ),
                  ),

                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveUtils.isMobile(context)
                          ? double.infinity
                          : 400,
                    ),
                    child: SizedBox(
                      height: ResponsiveUtils.getVerticalSpacing(
                        context,
                        mobile: 50,
                        tablet: 55,
                        desktop: 60,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveUtils.getVerticalSpacing(
                              context,
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
                            ),
                            horizontal: responsivePadding,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.getBorderRadius(context),
                            ),
                          ),
                          textStyle: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              baseFontSize: 16,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => _finishOnboarding(context),
                        child: Text('Comenzar'),
                      ),
                    ),
                  ),

                  // Padding extra en landscape para evitar que se vea muy comprimido
                  SizedBox(height: isLandscape ? 20 : 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
