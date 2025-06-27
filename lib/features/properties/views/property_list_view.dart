import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/property_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../models/property_model.dart';

class PropertyListView extends StatefulWidget {
  const PropertyListView({super.key});

  @override
  State<PropertyListView> createState() => _PropertyListViewState();
}

class _PropertyListViewState extends State<PropertyListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final propertyProvider = Provider.of<PropertyProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Cargar solo las propiedades del usuario actual
      if (authProvider.currentUser?.id != null) {
        propertyProvider.loadPropertiesByUser(authProvider.currentUser!.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsivePadding = ResponsiveUtils.getResponsivePadding(context);
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Propiedades'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              final propertyProvider = Provider.of<PropertyProvider>(
                context,
                listen: false,
              );
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );

              // Recargar solo las propiedades del usuario actual
              if (authProvider.currentUser?.id != null) {
                propertyProvider.loadPropertiesByUser(
                  authProvider.currentUser!.id!,
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<PropertyProvider>(
        builder: (context, propertyProvider, child) {
          if (propertyProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryRed,
                    ),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
                  Text(
                    'Cargando propiedades...',
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        baseFontSize: 16,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (propertyProvider.status == PropertyStatus.error) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth * 0.8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: ResponsiveUtils.getImageSize(
                        context,
                        mobile: 64,
                        tablet: 80,
                        desktop: 96,
                      ),
                      color: Colors.red,
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getVerticalSpacing(context),
                    ),
                    Text(
                      'Error al cargar propiedades',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          baseFontSize: 18,
                        ),
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getVerticalSpacing(
                        context,
                        mobile: 8,
                        tablet: 12,
                        desktop: 16,
                      ),
                    ),
                    Text(
                      propertyProvider.errorMessage ?? 'Error desconocido',
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
                      height: ResponsiveUtils.getVerticalSpacing(context),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
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
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'Reintentar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        padding: EdgeInsets.symmetric(
                          horizontal: responsivePadding,
                          vertical: ResponsiveUtils.getVerticalSpacing(
                            context,
                            mobile: 12,
                            tablet: 16,
                            desktop: 20,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (propertyProvider.properties.isEmpty) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth * 0.8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home_work_outlined,
                      size: ResponsiveUtils.getImageSize(
                        context,
                        mobile: 80,
                        tablet: 100,
                        desktop: 120,
                      ),
                      color: Colors.grey[400],
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getVerticalSpacing(context),
                    ),
                    Text(
                      'No tienes propiedades',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          baseFontSize: 20,
                        ),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getVerticalSpacing(
                        context,
                        mobile: 8,
                        tablet: 12,
                        desktop: 16,
                      ),
                    ),
                    Text(
                      'Comienza agregando tu primera propiedad',
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
                      height: ResponsiveUtils.getVerticalSpacing(context),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/property-form'),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Agregar Propiedad',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        padding: EdgeInsets.symmetric(
                          horizontal: responsivePadding,
                          vertical: ResponsiveUtils.getVerticalSpacing(
                            context,
                            mobile: 12,
                            tablet: 16,
                            desktop: 20,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Mostrar lista de propiedades
          return RefreshIndicator(
            onRefresh: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              if (authProvider.currentUser?.id != null) {
                await propertyProvider.loadPropertiesByUser(
                  authProvider.currentUser!.id!,
                );
              }
            },
            color: AppColors.primaryRed,
            backgroundColor: Colors.white,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final shouldUseList = ResponsiveUtils.shouldUseSingleColumn(
                    context,
                  );

                  if (shouldUseList) {
                    return ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsivePadding,
                        vertical: ResponsiveUtils.getVerticalSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        ),
                      ),
                      itemCount: propertyProvider.properties.length,
                      separatorBuilder: (context, index) => SizedBox(
                        height: ResponsiveUtils.getVerticalSpacing(
                          context,
                          mobile: 12,
                          tablet: 16,
                          desktop: 20,
                        ),
                      ),
                      itemBuilder: (context, index) {
                        final property = propertyProvider.properties[index];
                        return PropertyCard(
                          property: property,
                          onTap: () =>
                              context.go('/property-detail/${property.id}'),
                        );
                      },
                    );
                  } else {
                    return GridView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsivePadding,
                        vertical: ResponsiveUtils.getVerticalSpacing(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        ),
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveUtils.getGridColumns(context),
                        childAspectRatio: 0.8,
                        crossAxisSpacing: ResponsiveUtils.getHorizontalSpacing(
                          context,
                        ),
                        mainAxisSpacing: ResponsiveUtils.getVerticalSpacing(
                          context,
                        ),
                      ),
                      itemCount: propertyProvider.properties.length,
                      itemBuilder: (context, index) {
                        final property = propertyProvider.properties[index];
                        return PropertyCard(
                          property: property,
                          onTap: () =>
                              context.go('/property-detail/${property.id}'),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/property-form'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;

  const PropertyCard({super.key, required this.property, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final cardPadding = ResponsiveUtils.getResponsivePadding(
      context,
      mobile: 12,
      tablet: 16,
      desktop: 20,
    );
    final borderRadius = ResponsiveUtils.getBorderRadius(
      context,
      mobile: 12,
      tablet: 16,
      desktop: 20,
    );

    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getVerticalSpacing(
          context,
          mobile: 12,
          tablet: 16,
          desktop: 20,
        ),
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la propiedad
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(borderRadius),
              ),
              child: AspectRatio(
                aspectRatio: ResponsiveUtils.getResponsiveAspectRatio(
                  context,
                  mobile: 16 / 9,
                  tablet: 4 / 3,
                  desktop: 16 / 10,
                ),
                child: _buildPropertyImage(),
              ),
            ),

            // Contenido de la tarjeta
            Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y precio
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              baseFontSize: 16,
                            ),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryRed,
                          ),
                          maxLines: isMobile ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 8 : 12,
                          vertical: isMobile ? 4 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryRed.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '\$${property.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              baseFontSize: 14,
                            ),
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: ResponsiveUtils.getVerticalSpacing(
                      context,
                      mobile: 8,
                      tablet: 12,
                      desktop: 16,
                    ),
                  ),

                  // Tipo de propiedad
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 10,
                      vertical: isMobile ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      property.propertyType,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          baseFontSize: 12,
                        ),
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),

                  SizedBox(
                    height: ResponsiveUtils.getVerticalSpacing(
                      context,
                      mobile: 8,
                      tablet: 12,
                      desktop: 16,
                    ),
                  ),

                  // Ubicación
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          baseFontSize: 16,
                        ),
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property.city}, ${property.state}',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              baseFontSize: 13,
                            ),
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  if (property.bedrooms != null ||
                      property.bathrooms != null ||
                      property.area != null) ...[
                    SizedBox(
                      height: ResponsiveUtils.getVerticalSpacing(
                        context,
                        mobile: 8,
                        tablet: 12,
                        desktop: 16,
                      ),
                    ),

                    // Características
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _buildPropertyFeatures(context),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyImage() {
    if (property.imagePaths.isNotEmpty) {
      return Container(
        color: Colors.grey[200],
        child: Center(
          child: Icon(
            Icons.home_work_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 60,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  List<Widget> _buildPropertyFeatures(BuildContext context) {
    final features = <Widget>[];
    final isMobile = ResponsiveUtils.isMobile(context);

    if (property.bedrooms != null) {
      features.add(
        _buildFeatureChip(
          context,
          Icons.bed_outlined,
          '${property.bedrooms} hab',
          isMobile,
        ),
      );
    }

    if (property.bathrooms != null) {
      features.add(
        _buildFeatureChip(
          context,
          Icons.bathroom_outlined,
          '${property.bathrooms} baños',
          isMobile,
        ),
      );
    }

    if (property.area != null) {
      features.add(
        _buildFeatureChip(
          context,
          Icons.square_foot_outlined,
          '${property.area!.toStringAsFixed(0)} m²',
          isMobile,
        ),
      );
    }

    return features;
  }

  Widget _buildFeatureChip(
    BuildContext context,
    IconData icon,
    String label,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 8,
        vertical: isMobile ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: ResponsiveUtils.getResponsiveFontSize(
              context,
              baseFontSize: 12,
            ),
            color: AppColors.primaryRed,
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                baseFontSize: 11,
              ),
              fontWeight: FontWeight.w500,
              color: AppColors.primaryRed,
            ),
          ),
        ],
      ),
    );
  }
}
