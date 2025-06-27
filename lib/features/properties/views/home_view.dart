/* 
Este archivo es la vista principal del usuario, es decir el home donde se muestra la informacion de la aplicacion

A nivel de codigo podemos determinar cuales son las estadisticas del usuario, y mostrar esa informacion en cartas, tenemos los accesos
que a pesar de que esta el menu de opciones abajo podemos acceder a ellas de manera rapida y sencilla
*/

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
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
          propertyProvider.loadProperties();
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
      propertyProvider.loadProperties();
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

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InmoGestion'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
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
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
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
                                authProvider.currentUser?.name
                                        .substring(0, 1)
                                        .toUpperCase() ??
                                    'U',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¡Hola, ${authProvider.currentUser?.name ?? 'Usuario'}!',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryRed,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Bienvenido a InmoGestion de gestion, Gestiona tus propiedades de manera eficiente',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey[700]),
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

            const SizedBox(height: 30),

            Text(
              'Panel de Control',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryRed,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primaryRed,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Información del Sistema',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryRed,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sistema de gestión inmobiliaria para administrar tus propiedades de manera eficiente.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Accesos rápidos
                    Text(
                      'Accesos Rápidos',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryRed,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildQuickAccessButton(
                          context,
                          icon: Icons.add_home,
                          label: 'Nueva Propiedad',
                          onTap: () {
                            context.go(AppRoutes.homeProperties);
                            // Trigger add property in home view
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              final homeState = context
                                  .findAncestorStateOfType<_HomeViewState>();
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
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Estadísticas rápidas
            Consumer<PropertyProvider>(
              builder: (context, propertyProvider, child) {
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              color: AppColors.primaryRed,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Estadísticas',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryRed,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                'Total Propiedades',
                                '${propertyProvider.properties.length}',
                                Icons.home_work,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                'En Gestión',
                                '${propertyProvider.properties.length}',
                                Icons.manage_search,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryRed.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryRed, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.w600,
                fontSize: 14,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryRed.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryRed, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryRed,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
