/* 
Este archivo es la vista principal del usuario, es decir el home donde se muestra la informacion de la aplicacion

A nivel de codigo podemos determinar cuales son las estadisticas del usuario, y mostrar esa informacion en cartas, tenemos los accesos
que a pesar de que esta el menu de opciones abajo podemos acceder a ellas de manera rapida y sencilla
*/

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../routes/app_routes.dart';
import 'property_list_view.dart';
import 'property_form_view.dart';
import 'search_view.dart';
import '../../auth/views/profile_view.dart';

class HomeView extends StatefulWidget {
  final int initialTabIndex;

  const HomeView({super.key, this.initialTabIndex = 0});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  bool _showPropertyForm = false;

  late final List<Widget> _pages;

  void showPropertyForm() {
    setState(() {
      _showPropertyForm = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    _pages = [
      const DashboardPage(),
      const PropertyListView(),
      const SearchView(),
      const ProfileView(),
      PropertyFormView(
        onSaved: () {
          setState(() {
            _showPropertyForm = false;
            _currentIndex = 1; // Regresar a propiedades
          });
          // Recargar la lista de propiedades
          final propertyProvider = Provider.of<PropertyProvider>(
            context,
            listen: false,
          );
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          if (authProvider.currentUser?.id != null) {
            propertyProvider.loadPropertiesByUser(
              authProvider.currentUser!.id!,
            );
          }
        },
        onCancel: () {
          setState(() {
            _showPropertyForm = false;
            _currentIndex = 1; // Regresar a propiedades
          });
        },
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final propertyProvider = Provider.of<PropertyProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser?.id != null) {
        propertyProvider.loadPropertiesByUser(authProvider.currentUser!.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determinar el índice actual para mostrar
    int displayIndex = _showPropertyForm ? 4 : _currentIndex;

    return Scaffold(
      body: IndexedStack(index: displayIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _showPropertyForm
            ? 1
            : _currentIndex, // Mostrar propiedades como activo cuando está en el formulario
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _showPropertyForm = false;
          });
        },
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dashboard_outlined,
              color: (_showPropertyForm ? false : _currentIndex == 0)
                  ? AppColors.primaryRed
                  : Colors.grey[600],
            ),
            activeIcon: Icon(Icons.dashboard, color: AppColors.primaryRed),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_work_outlined,
              color: (_showPropertyForm || _currentIndex == 1)
                  ? AppColors.primaryRed
                  : Colors.grey[600],
            ),
            activeIcon: Icon(Icons.home_work, color: AppColors.primaryRed),
            label: 'Propiedades',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search_outlined,
              color: (_showPropertyForm ? false : _currentIndex == 2)
                  ? AppColors.primaryRed
                  : Colors.grey[600],
            ),
            activeIcon: Icon(Icons.search, color: AppColors.primaryRed),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
              color: (_showPropertyForm ? false : _currentIndex == 3)
                  ? AppColors.primaryRed
                  : Colors.grey[600],
            ),
            activeIcon: Icon(Icons.person, color: AppColors.primaryRed),
            label: 'Perfil',
          ),
        ],
      ),
      floatingActionButton: (_currentIndex == 1 || _showPropertyForm)
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showPropertyForm = !_showPropertyForm;
                });
              },
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              elevation: 6,
              child: Icon(
                _showPropertyForm ? Icons.list : Icons.add,
                color: Colors.white,
                size: 28,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class DashboardPage extends StatelessWidget with ResponsiveMixin {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsivePadding = ResponsiveUtils.getResponsivePadding(context);
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);
    final isLandscape = ResponsiveUtils.isLandscape(context);
    final isMobile = ResponsiveUtils.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('InmoGestion'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: EdgeInsets.all(responsivePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.getBorderRadius(context),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                ResponsiveUtils.getBorderRadius(context),
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryRed.withOpacity(0.1),
                                  AppColors.primaryRed.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(responsivePadding),
                              child: isLandscape && !isMobile
                                  ? Row(
                                      children: [
                                        _buildUserAvatar(authProvider),
                                        SizedBox(width: responsivePadding),
                                        Expanded(
                                          child: _buildUserInfo(
                                            context,
                                            authProvider,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _buildUserAvatar(authProvider),
                                        SizedBox(
                                          height:
                                              ResponsiveUtils.getVerticalSpacing(
                                                context,
                                              ),
                                        ),
                                        _buildUserInfo(context, authProvider),
                                      ],
                                    ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(
                      height: ResponsiveUtils.getVerticalSpacing(context),
                    ),

                    Text(
                      'Panel de Control',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryRed,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          baseFontSize: 24,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: ResponsiveUtils.getVerticalSpacing(
                        context,
                        mobile: 16,
                        tablet: 20,
                        desktop: 24,
                      ),
                    ),

                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getBorderRadius(context),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(responsivePadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.primaryRed,
                                  size: ResponsiveUtils.getResponsiveFontSize(
                                    context,
                                    baseFontSize: 24,
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      ResponsiveUtils.getHorizontalSpacing(
                                        context,
                                      ) *
                                      0.5,
                                ),
                                Expanded(
                                  child: Text(
                                    'Información del Sistema',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryRed,
                                      fontSize:
                                          ResponsiveUtils.getResponsiveFontSize(
                                            context,
                                            baseFontSize: 18,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: ResponsiveUtils.getVerticalSpacing(
                                context,
                              ),
                            ),
                            Text(
                              'Sistema de gestión inmobiliaria para administrar tus propiedades de manera eficiente.',
                              style: TextStyle(
                                color: Colors.grey[700],
                                height: 1.5,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context,
                                  baseFontSize: 14,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: ResponsiveUtils.getVerticalSpacing(
                                context,
                                mobile: 20,
                                tablet: 24,
                                desktop: 28,
                              ),
                            ),

                            // Accesos rápidos
                            Text(
                              'Accesos Rápidos',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryRed,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context,
                                  baseFontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: ResponsiveUtils.getVerticalSpacing(
                                context,
                                mobile: 12,
                                tablet: 16,
                                desktop: 20,
                              ),
                            ),

                            ResponsiveUtils.shouldUseSingleColumn(context)
                                ? Column(
                                    children: _buildQuickAccessButtons(context),
                                  )
                                : Wrap(
                                    spacing:
                                        ResponsiveUtils.getHorizontalSpacing(
                                          context,
                                        ) *
                                        0.75,
                                    runSpacing:
                                        ResponsiveUtils.getVerticalSpacing(
                                          context,
                                        ) *
                                        0.75,
                                    children: _buildQuickAccessButtons(context),
                                  ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: ResponsiveUtils.getVerticalSpacing(
                        context,
                        mobile: 20,
                        tablet: 24,
                        desktop: 28,
                      ),
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

  Widget _buildUserAvatar(AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 30,
        backgroundColor: AppColors.primaryRed,
        child: Text(
          authProvider.currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Hola, ${authProvider.currentUser?.name ?? 'Usuario'}!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryRed,
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              baseFontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Bienvenido a tu panel de control',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              baseFontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildQuickAccessButtons(BuildContext context) {
    return [
      _buildQuickAccessButton(
        context,
        icon: Icons.add_home,
        label: 'Nueva Propiedad',
        onTap: () {
          context.go(AppRoutes.homeProperties);
          // Trigger add property in home view
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final homeState = context.findAncestorStateOfType<_HomeViewState>();
            homeState?.showPropertyForm();
          });
        },
      ),
      _buildQuickAccessButton(
        context,
        icon: Icons.list_alt,
        label: 'Ver Propiedades',
        onTap: () => context.go(AppRoutes.homeProperties),
      ),
      _buildQuickAccessButton(
        context,
        icon: Icons.search,
        label: 'Buscar',
        onTap: () => context.go(AppRoutes.homeSearch),
      ),
    ];
  }

  Widget _buildQuickAccessButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: ResponsiveUtils.shouldUseSingleColumn(context)
            ? double.infinity
            : null,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 10 : 12,
        ),
        margin: ResponsiveUtils.shouldUseSingleColumn(context)
            ? const EdgeInsets.only(bottom: 8)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: AppColors.primaryRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryRed.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: ResponsiveUtils.shouldUseSingleColumn(context)
              ? MainAxisSize.max
              : MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryRed, size: isMobile ? 18 : 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  baseFontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryRed.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryRed, size: isMobile ? 20 : 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                baseFontSize: 24,
              ),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryRed,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                baseFontSize: 12,
              ),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
