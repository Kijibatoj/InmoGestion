import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import '../../../providers/property_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/properties/models/property_model.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _searchController = TextEditingController();
  String? _selectedPropertyType;
  double? _minPrice;
  double? _maxPrice;
  String? _selectedCity;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final propertyProvider = Provider.of<PropertyProvider>(
      context,
      listen: false,
    );

    propertyProvider.searchProperties(
      query: _searchController.text.isNotEmpty ? _searchController.text : null,
      propertyType: _selectedPropertyType,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      city: _selectedCity,
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _selectedPropertyType = null;
      _minPrice = null;
      _maxPrice = null;
      _selectedCity = null;
    });

    final propertyProvider = Provider.of<PropertyProvider>(
      context,
      listen: false,
    );
    propertyProvider.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Propiedades'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: _clearSearch,
            icon: const Icon(Icons.clear, color: Colors.white),
            tooltip: 'Limpiar búsqueda',
          ),
        ],
      ),
      body: Column(
        children: [
          // Panel de búsqueda mejorado
          Container(
            margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.search, color: AppColors.primaryRed, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Buscar Propiedades',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Campo de búsqueda principal
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar propiedades por título, ubicación...',
                    prefixIcon: Icon(Icons.search, color: AppColors.primaryRed),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: _performSearch,
                        icon: const Icon(Icons.send, color: Colors.white),
                        tooltip: 'Buscar',
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primaryRed,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),

                const SizedBox(height: 20),

                // Filtros mejorados
                Text(
                  'Filtros',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryRed,
                  ),
                ),
                const SizedBox(height: 12),

                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      // En pantallas pequeñas, mostrar en columna
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildPropertyTypeDropdown(),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          _buildCityTextField(),
                        ],
                      );
                    } else {
                      // En pantallas grandes, mostrar en fila
                      return Row(
                        children: [
                          Expanded(child: _buildPropertyTypeDropdown()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildCityTextField()),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // Resultados
          Expanded(
            child: Consumer<PropertyProvider>(
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
                        const SizedBox(height: 16),
                        Text(
                          'Buscando propiedades...',
                          style: TextStyle(
                            color: AppColors.primaryRed,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (propertyProvider.properties.isEmpty) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Calcular tamaños responsivos basados en el espacio disponible
                      final availableHeight = constraints.maxHeight;
                      final iconSize = availableHeight > 400 ? 80.0 : 60.0;
                      final titleFontSize = availableHeight > 400 ? 24.0 : 20.0;
                      final subtitleFontSize = availableHeight > 400
                          ? 16.0
                          : 14.0;
                      final padding = availableHeight > 400 ? 32.0 : 16.0;
                      final spacing = availableHeight > 400 ? 24.0 : 16.0;

                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: EdgeInsets.all(padding),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.all(iconSize * 0.25),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryRed.withOpacity(
                                          0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.search_off,
                                        size: iconSize,
                                        color: AppColors.primaryRed.withOpacity(
                                          0.7,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: spacing),
                                  Text(
                                    'No se encontraron propiedades',
                                    style: TextStyle(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryRed,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: spacing * 0.5),
                                  Text(
                                    'Intenta ajustar los filtros de búsqueda para encontrar propiedades',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: subtitleFontSize,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: spacing),
                                  ElevatedButton.icon(
                                    onPressed: _clearSearch,
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Limpiar Filtros',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryRed,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: availableHeight > 400
                                            ? 24
                                            : 20,
                                        vertical: availableHeight > 400
                                            ? 12
                                            : 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width * 0.04,
                    8,
                    MediaQuery.of(context).size.width * 0.04,
                    MediaQuery.of(context).padding.bottom + 16,
                  ),
                  itemCount: propertyProvider.properties.length,
                  itemBuilder: (context, index) {
                    final property = propertyProvider.properties[index];
                    return SearchPropertyCard(
                      property: property,
                      onTap: () => context.go('/property/${property.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPropertyType,
      decoration: InputDecoration(
        labelText: 'Tipo de Propiedad',
        prefixIcon: Icon(Icons.home_work, color: AppColors.primaryRed),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryRed, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: const [
        DropdownMenuItem(value: 'house', child: Text('Casa')),
        DropdownMenuItem(value: 'apartment', child: Text('Apartamento')),
        DropdownMenuItem(value: 'condo', child: Text('Condominio')),
        DropdownMenuItem(value: 'townhouse', child: Text('Casa adosada')),
        DropdownMenuItem(value: 'land', child: Text('Terreno')),
        DropdownMenuItem(value: 'commercial', child: Text('Comercial')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedPropertyType = value;
        });
        _performSearch();
      },
    );
  }

  Widget _buildCityTextField() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Ciudad',
        prefixIcon: Icon(Icons.location_city, color: AppColors.primaryRed),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryRed, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      onChanged: (value) {
        _selectedCity = value.isNotEmpty ? value : null;
        _performSearch();
      },
    );
  }
}

class SearchPropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;

  const SearchPropertyCard({super.key, required this.property, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen miniatura
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.width * 0.2,
                constraints: const BoxConstraints(
                  minWidth: 70,
                  minHeight: 70,
                  maxWidth: 90,
                  maxHeight: 90,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryRed.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: property.imagePaths.isNotEmpty
                          ? Image.file(
                              File(property.imagePaths.first),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.home_work,
                                    size: 32,
                                    color: AppColors.primaryRed.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Icon(
                                Icons.home_work,
                                size: 32,
                                color: AppColors.primaryRed.withOpacity(0.5),
                              ),
                            ),
                    ),
                    if (property.imagePaths.length > 1)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${property.imagePaths.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Información de la propiedad
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 400
                            ? 14
                            : 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryRed,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      property.formattedPrice,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 400
                            ? 16
                            : 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryRed,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.primaryRed.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${property.city}, ${property.state}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        property.propertyTypeDisplayName,
                        style: TextStyle(
                          color: AppColors.primaryRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Indicador de navegación
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primaryRed.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
