import 'package:flutter/material.dart';
import '../../shared/widgets/common_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
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
      appBar: CommonAppBar(
        title: 'Crear Cuenta',
        showHomeButton: false,
        showBackButton: true,
      ),
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
                    SizedBox(height: isLandscape ? 10 : 20),

                    Icon(
                      Icons.person_add,
                      size: ResponsiveUtils.getImageSize(
                        context,
                        mobile: 60,
                        tablet: 75,
                        desktop: 90,
                      ),
                      color: AppColors.primaryRed,
                    ),

                    SizedBox(height: verticalSpacing),

                    Text(
                      'Únete a InmoGestion',
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
                        mobile: 10,
                        tablet: 15,
                        desktop: 20,
                      ),
                    ),

                    Text(
                      'Crea tu cuenta y comienza a gestionar propiedades',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          baseFontSize: 14,
                        ),
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(
                      height: ResponsiveUtils.getVerticalSpacing(
                        context,
                        mobile: 30,
                        tablet: 35,
                        desktop: 40,
                      ),
                    ),

                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          baseFontSize: 16,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Nombre completo',
                        hintText: 'Ingresa tu nombre completo',
                        prefixIcon: Icon(
                          Icons.person,
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
                      validator: (value) =>
                          FormValidators.validateRequired(value, 'Nombre'),
                    ),

                    SizedBox(height: verticalSpacing),

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
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          baseFontSize: 16,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Teléfono (opcional)',
                        hintText: 'Ingresa tu teléfono',
                        prefixIcon: Icon(
                          Icons.phone,
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
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          return FormValidators.validatePhone(value);
                        }
                        return null;
                      },
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
                        hintText: 'Crea una contraseña segura',
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

                    SizedBox(height: verticalSpacing),

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          baseFontSize: 16,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña',
                        hintText: 'Confirma tu contraseña',
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: AppColors.primaryRed,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.primaryRed,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
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
                      validator: _validateConfirmPassword,
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
                            onPressed: authProvider.isLoading
                                ? null
                                : _register,
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
                                : Text('Crear Cuenta'),
                          ),
                        );
                      },
                    ),

                    SizedBox(
                      height: ResponsiveUtils.getVerticalSpacing(
                        context,
                        mobile: 20,
                        tablet: 25,
                        desktop: 30,
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes cuenta? ',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              baseFontSize: 14,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
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
                          child: Text('Inicia sesión aquí'),
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
