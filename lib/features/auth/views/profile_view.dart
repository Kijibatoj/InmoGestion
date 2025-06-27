import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../shared/widgets/common_app_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsivePadding = ResponsiveUtils.getResponsivePadding(context);
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);

    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Mi Perfil',
        automaticallyImplyLeading: false,
        showHomeButton: false, // No mostrar botón home ya que estamos en home
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return Center(
              child: Text(
                'No hay usuario autenticado',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    baseFontSize: 16,
                  ),
                ),
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(responsivePadding),
                child: Column(
                  children: [
                    // Avatar y datos básicos
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                        ResponsiveUtils.getResponsivePadding(
                          context,
                          mobile: 24,
                          tablet: 30,
                          desktop: 36,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getBorderRadius(context),
                        ),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius:
                                ResponsiveUtils.getImageSize(
                                  context,
                                  mobile: 50,
                                  tablet: 60,
                                  desktop: 70,
                                ) /
                                2,
                            backgroundColor: AppColors.primaryRed,
                            child: Text(
                              user.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context,
                                  baseFontSize: 36,
                                ),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveUtils.getVerticalSpacing(context),
                          ),
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                baseFontSize: 22,
                              ),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryRed,
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveUtils.getVerticalSpacing(
                              context,
                              mobile: 8,
                              tablet: 10,
                              desktop: 12,
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                baseFontSize: 16,
                              ),
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: ResponsiveUtils.getVerticalSpacing(
                        context,
                        mobile: 24,
                        tablet: 30,
                        desktop: 36,
                      ),
                    ),

                    // Información del perfil
                    _ProfileSection(
                      title: 'Información Personal',
                      children: [
                        _ProfileItem(
                          icon: Icons.person,
                          label: 'Nombre',
                          value: user.name,
                        ),
                        _ProfileItem(
                          icon: Icons.email,
                          label: 'Email',
                          value: user.email,
                        ),
                        _ProfileItem(
                          icon: Icons.phone,
                          label: 'Teléfono',
                          value: user.phone ?? 'No especificado',
                        ),
                      ],
                    ),

                    SizedBox(
                      height: ResponsiveUtils.getVerticalSpacing(
                        context,
                        mobile: 24,
                        tablet: 30,
                        desktop: 36,
                      ),
                    ),

                    // Acciones
                    _ProfileSection(
                      title: 'Acciones',
                      children: [
                        _ResponsiveListTile(
                          leading: Icon(
                            Icons.edit,
                            color: AppColors.primaryRed,
                          ),
                          title: 'Editar Perfil',
                          onTap: () {
                            _showEditProfileDialog(context, authProvider);
                          },
                        ),
                        _ResponsiveListTile(
                          leading: Icon(
                            Icons.lock,
                            color: AppColors.primaryRed,
                          ),
                          title: 'Cambiar Contraseña',
                          onTap: () {
                            _showChangePasswordDialog(context, authProvider);
                          },
                        ),
                        Divider(color: Colors.grey[300], thickness: 1),
                        _ResponsiveListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: 'Cerrar Sesión',
                          titleColor: Colors.red,
                          onTap: () {
                            _showLogoutDialog(context, authProvider);
                          },
                        ),
                      ],
                    ),

                    SizedBox(
                      height: ResponsiveUtils.getVerticalSpacing(
                        context,
                        mobile: 24,
                        tablet: 30,
                        desktop: 36,
                      ),
                    ),

                    // Información de la app
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(responsivePadding),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getBorderRadius(context),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'InmoGestion',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                baseFontSize: 18,
                              ),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryRed,
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveUtils.getVerticalSpacing(
                              context,
                              mobile: 4,
                              tablet: 6,
                              desktop: 8,
                            ),
                          ),
                          Text(
                            'Versión 1.0.0',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                baseFontSize: 14,
                              ),
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final nameController = TextEditingController(
      text: authProvider.currentUser?.name,
    );
    final phoneController = TextEditingController(
      text: authProvider.currentUser?.phone,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Editar Perfil',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              baseFontSize: 18,
            ),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryRed,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  baseFontSize: 16,
                ),
              ),
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getBorderRadius(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getBorderRadius(context),
                  ),
                  borderSide: BorderSide(color: AppColors.primaryRed, width: 2),
                ),
              ),
            ),
            SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
            TextField(
              controller: phoneController,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  baseFontSize: 16,
                ),
              ),
              decoration: InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getBorderRadius(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getBorderRadius(context),
                  ),
                  borderSide: BorderSide(color: AppColors.primaryRed, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  baseFontSize: 14,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await authProvider.updateProfile(
                name: nameController.text,
                phone: phoneController.text.isNotEmpty
                    ? phoneController.text
                    : null,
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Perfil actualizado')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Guardar',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
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

  void _showChangePasswordDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cambiar Contraseña',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              baseFontSize: 18,
            ),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryRed,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  baseFontSize: 16,
                ),
              ),
              decoration: InputDecoration(
                labelText: 'Nueva contraseña',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getBorderRadius(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getBorderRadius(context),
                  ),
                  borderSide: BorderSide(color: AppColors.primaryRed, width: 2),
                ),
              ),
            ),
            SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  baseFontSize: 16,
                ),
              ),
              decoration: InputDecoration(
                labelText: 'Confirmar nueva contraseña',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getBorderRadius(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getBorderRadius(context),
                  ),
                  borderSide: BorderSide(color: AppColors.primaryRed, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  baseFontSize: 14,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Las contraseñas no coinciden')),
                );
                return;
              }

              final success = await authProvider.updateProfile(
                password: newPasswordController.text,
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Contraseña actualizada'
                          : 'Error al actualizar contraseña',
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Cambiar',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
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

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cerrar Sesión',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              baseFontSize: 18,
            ),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryRed,
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              baseFontSize: 16,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  baseFontSize: 14,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Cerrar Sesión',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
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
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getBorderRadius(context),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(
              ResponsiveUtils.getResponsivePadding(context),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  baseFontSize: 18,
                ),
                fontWeight: FontWeight.bold,
                color: AppColors.primaryRed,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsivePadding(context),
        vertical: ResponsiveUtils.getVerticalSpacing(
          context,
          mobile: 8,
          tablet: 10,
          desktop: 12,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primaryRed,
            size: ResponsiveUtils.getResponsiveFontSize(
              context,
              baseFontSize: 20,
            ),
          ),
          SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      baseFontSize: 12,
                    ),
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.getVerticalSpacing(
                    context,
                    mobile: 2,
                    tablet: 3,
                    desktop: 4,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      baseFontSize: 16,
                    ),
                    fontWeight: FontWeight.w500,
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

class _ResponsiveListTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;

  const _ResponsiveListTile({
    required this.leading,
    required this.title,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            baseFontSize: 16,
          ),
          color: titleColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: ResponsiveUtils.getResponsiveFontSize(context, baseFontSize: 16),
        color: titleColor ?? Colors.grey[600],
      ),
      onTap: onTap,
    );
  }
}
