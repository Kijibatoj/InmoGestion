import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import '../../../providers/property_provider.dart';
import '../models/property_model.dart';
import '../../shared/widgets/common_app_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';

class PropertyDetailView extends StatefulWidget {
  final int propertyId;

  const PropertyDetailView({super.key, required this.propertyId});

  @override
  State<PropertyDetailView> createState() => _PropertyDetailViewState();
}

class _PropertyDetailViewState extends State<PropertyDetailView> {
  Property? _property;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProperty();
  }

  Future<void> _loadProperty() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final propertyProvider = Provider.of<PropertyProvider>(
        context,
        listen: false,
      );
      final property = await propertyProvider.getPropertyById(
        widget.propertyId,
      );

      if (mounted) {
        setState(() {
          _property = property;
          _isLoading = false;
          if (property == null) {
            _errorMessage = 'Propiedad no encontrada';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar la propiedad: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Detalle de Propiedad',
        showBackButton: true,
        showHomeButton: false,
        actions: [
          if (_property != null) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () =>
                  context.go('/property-edit/${widget.propertyId}'),
              tooltip: 'Editar propiedad',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => _showDeleteDialog(),
              tooltip: 'Eliminar propiedad',
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final responsivePadding = ResponsiveUtils.getResponsivePadding(context);
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
            ),
            SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
            Text(
              'Cargando propiedad...',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  baseFontSize: 16,
                ),
                color: AppColors.primaryRed,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth * 0.8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                size: ResponsiveUtils.getImageSize(
                  context,
                  mobile: 64,
                  tablet: 80,
                  desktop: 96,
                ),
                color: Colors.red[300],
              ),
              SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    baseFontSize: 16,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
              ElevatedButton(
                onPressed: _loadProperty,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                ),
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_property == null) {
      return Center(
        child: Text(
          'Propiedad no encontrada',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              baseFontSize: 18,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
              _buildInfoSection(),
              SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
              _buildLocationSection(),
              SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
              _buildFeaturesSection(),
              SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
              _buildDescriptionSection(),
              SizedBox(
                height: ResponsiveUtils.getVerticalSpacing(
                  context,
                  mobile: 32,
                  tablet: 40,
                  desktop: 48,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final borderRadius = ResponsiveUtils.getBorderRadius(context);

    return Container(
      height: ResponsiveUtils.getImageSize(
        context,
        mobile: 250,
        tablet: 300,
        desktop: 350,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: _property!.imagePaths.isNotEmpty
            ? Stack(
                children: [
                  PageView.builder(
                    itemCount: _property!.imagePaths.length,
                    itemBuilder: (context, index) {
                      return Image.file(
                        File(_property!.imagePaths[index]),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      );
                    },
                  ),
                  if (_property!.imagePaths.length > 1) ...[
                    Positioned(
                      top: ResponsiveUtils.getResponsivePadding(context) * 0.5,
                      right:
                          ResponsiveUtils.getResponsivePadding(context) * 0.5,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.getHorizontalSpacing(
                            context,
                            mobile: 8,
                            tablet: 10,
                            desktop: 12,
                          ),
                          vertical: ResponsiveUtils.getVerticalSpacing(
                            context,
                            mobile: 4,
                            tablet: 6,
                            desktop: 8,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                baseFontSize: 16,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${_property!.imagePaths.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context,
                                  baseFontSize: 12,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom:
                          ResponsiveUtils.getResponsivePadding(context) * 0.5,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.getHorizontalSpacing(
                              context,
                            ),
                            vertical: ResponsiveUtils.getVerticalSpacing(
                              context,
                              mobile: 4,
                              tablet: 6,
                              desktop: 8,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(
                              borderRadius * 0.5,
                            ),
                          ),
                          child: Text(
                            'Desliza para ver más imágenes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                baseFontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.home_work_outlined,
          size: ResponsiveUtils.getImageSize(
            context,
            mobile: 60,
            tablet: 80,
            desktop: 100,
          ),
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    final verticalSpacing = ResponsiveUtils.getVerticalSpacing(context);
    final isLandscape = ResponsiveUtils.isLandscape(context);

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
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
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y precio en fila o columna según el espacio
          if (isLandscape || !ResponsiveUtils.isMobile(context))
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildTitle()),
                SizedBox(width: ResponsiveUtils.getHorizontalSpacing(context)),
                _buildPrice(),
              ],
            )
          else ...[
            _buildTitle(),
            SizedBox(height: verticalSpacing),
            _buildPrice(),
          ],

          SizedBox(height: verticalSpacing),

          _buildPropertyType(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      _property!.title,
      style: TextStyle(
        fontSize: ResponsiveUtils.getResponsiveFontSize(
          context,
          baseFontSize: 24,
        ),
        fontWeight: FontWeight.bold,
        color: AppColors.primaryRed,
      ),
    );
  }

  Widget _buildPrice() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalSpacing(context),
        vertical: ResponsiveUtils.getVerticalSpacing(
          context,
          mobile: 8,
          tablet: 10,
          desktop: 12,
        ),
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getBorderRadius(context),
        ),
        border: Border.all(color: AppColors.primaryRed.withOpacity(0.3)),
      ),
      child: Text(
        '\$${_property!.price.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            baseFontSize: 20,
          ),
          fontWeight: FontWeight.bold,
          color: AppColors.primaryRed,
        ),
      ),
    );
  }

  Widget _buildPropertyType() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalSpacing(
          context,
          mobile: 12,
          tablet: 16,
          desktop: 20,
        ),
        vertical: ResponsiveUtils.getVerticalSpacing(
          context,
          mobile: 6,
          tablet: 8,
          desktop: 10,
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getBorderRadius(context),
        ),
      ),
      child: Text(
        _property!.propertyType,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            baseFontSize: 14,
          ),
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return _buildSection(
      title: 'Ubicación',
      icon: Icons.location_on,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _property!.address,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                baseFontSize: 16,
              ),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context) * 0.5),
          Text(
            '${_property!.city}, ${_property!.state}',
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
    );
  }

  Widget _buildFeaturesSection() {
    final features = <Widget>[];

    if (_property!.bedrooms != null) {
      features.add(
        _buildFeatureItem(
          Icons.bed_outlined,
          '${_property!.bedrooms} Habitaciones',
        ),
      );
    }

    if (_property!.bathrooms != null) {
      features.add(
        _buildFeatureItem(
          Icons.bathroom_outlined,
          '${_property!.bathrooms} Baños',
        ),
      );
    }

    if (_property!.area != null) {
      features.add(
        _buildFeatureItem(
          Icons.square_foot_outlined,
          '${_property!.area!.toStringAsFixed(0)} m²',
        ),
      );
    }

    if (features.isEmpty) return SizedBox.shrink();

    return _buildSection(
      title: 'Características',
      icon: Icons.home,
      child: Wrap(
        spacing: ResponsiveUtils.getHorizontalSpacing(context),
        runSpacing: ResponsiveUtils.getVerticalSpacing(context) * 0.5,
        children: features,
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getHorizontalSpacing(
          context,
          mobile: 12,
          tablet: 16,
          desktop: 20,
        ),
        vertical: ResponsiveUtils.getVerticalSpacing(
          context,
          mobile: 8,
          tablet: 10,
          desktop: 12,
        ),
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getBorderRadius(context),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: ResponsiveUtils.getResponsiveFontSize(
              context,
              baseFontSize: 16,
            ),
            color: AppColors.primaryRed,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                baseFontSize: 14,
              ),
              fontWeight: FontWeight.w500,
              color: AppColors.primaryRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    if (_property!.description == null || _property!.description!.isEmpty) {
      return SizedBox.shrink();
    }

    return _buildSection(
      title: 'Descripción',
      icon: Icons.description,
      child: Text(
        _property!.description!,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            baseFontSize: 16,
          ),
          height: 1.4,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
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
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primaryRed,
                size: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  baseFontSize: 20,
                ),
              ),
              SizedBox(
                width: ResponsiveUtils.getHorizontalSpacing(context) * 0.5,
              ),
              Text(
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
            ],
          ),
          SizedBox(height: ResponsiveUtils.getVerticalSpacing(context)),
          child,
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Propiedad'),
        content: Text('¿Estás seguro de que quieres eliminar esta propiedad?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final propertyProvider = Provider.of<PropertyProvider>(
                context,
                listen: false,
              );
              await propertyProvider.deleteProperty(widget.propertyId);
              if (mounted) {
                context.go('/');
              }
            },
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
