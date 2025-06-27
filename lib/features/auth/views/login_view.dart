/*
Este archivo es la vista de login, es decir el inicio de sesion de la aplicacion

A nivel de codigo podemos determinar cuales son los campos de ingreso, y el boton de inicio de sesion, tambien la posibilidad
de navergar a el registro de usuarios, SE TIENE QUE CREAR UN USUARIO PARA PODER INGRESAR A LA APLICACION

*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';

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

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (success && mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsivePadding = ResponsiveUtils.getResponsivePadding(context);
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);
    final isLandscape = ResponsiveUtils.isLandscape(context);
    final verticalSpacing = ResponsiveUtils.getVerticalSpacing(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(responsivePadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: isLandscape ? 20 : 60),

                    Icon(
                      Icons.home_work,
                      size: ResponsiveUtils.getImageSize(
                        context,
                        mobile: 80,
                        tablet: 100,
                        desktop: 120,
                      ),
                      color: AppColors.primaryRed,
                    ),

                    SizedBox(height: verticalSpacing),

                    Text(
                      'InmoGestion',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          baseFontSize: 32,
                        ),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryRed,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(
                      height: ResponsiveUtils.getVerticalSpacing(
                        context,
                        mobile: 10,
                        tablet: 15,
                        desktop: 20,
                      ),
                    ),

                    Text(
                      'Gestiona tus propiedades fácilmente',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          baseFontSize: 16,
                        ),
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(
                      height: ResponsiveUtils.getVerticalSpacing(
                        context,
                        mobile: 40,
                        tablet: 50,
                        desktop: 60,
                      ),
                    ),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          baseFontSize: 16,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Ingresa tu email',
                        prefixIcon: Icon(
                          Icons.email,
                          color: AppColors.primaryRed,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.getBorderRadius(context),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.getBorderRadius(context),
                          ),
                          borderSide: BorderSide(
                            color: AppColors.primaryRed,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: FormValidators.validateEmail,
                    ),

                    SizedBox(height: verticalSpacing),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          baseFontSize: 16,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        hintText: 'Ingresa tu contraseña',
                        prefixIcon: Icon(
                          Icons.lock,
                          color: AppColors.primaryRed,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.primaryRed,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.getBorderRadius(context),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.getBorderRadius(context),
                          ),
                          borderSide: BorderSide(
                            color: AppColors.primaryRed,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: FormValidators.validatePassword,
                    ),

                    SizedBox(
                      height: ResponsiveUtils.getVerticalSpacing(
                        context,
                        mobile: 24,
                        tablet: 30,
                        desktop: 36,
                      ),
                    ),

                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (authProvider.errorMessage != null) {
                          return Container(
                            padding: EdgeInsets.all(responsivePadding * 0.75),
                            margin: EdgeInsets.only(bottom: verticalSpacing),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(
                                ResponsiveUtils.getBorderRadius(context),
                              ),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error,
                                  color: Colors.red.shade600,
                                  size: ResponsiveUtils.getResponsiveFontSize(
                                    context,
                                    baseFontSize: 20,
                                  ),
                                ),
                                SizedBox(width: responsivePadding * 0.5),
                                Expanded(
                                  child: Text(
                                    authProvider.errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade600,
                                      fontSize:
                                          ResponsiveUtils.getResponsiveFontSize(
                                            context,
                                            baseFontSize: 14,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return SizedBox(
                          height: ResponsiveUtils.getVerticalSpacing(
                            context,
                            mobile: 50,
                            tablet: 55,
                            desktop: 60,
                          ),
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading ? null : _login,
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
                            child: authProvider.isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text('Iniciar Sesión'),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: verticalSpacing),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿No tienes cuenta? ',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              baseFontSize: 14,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryRed,
                            textStyle: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                baseFontSize: 14,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: Text('Regístrate aquí'),
                        ),
                      ],
                    ),

                    SizedBox(height: isLandscape ? 10 : 20),
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
