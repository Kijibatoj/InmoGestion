import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../../providers/property_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/services/image_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/keyboard_utils.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../routes/app_routes.dart';

class PropertyFormView extends StatefulWidget {
  final int? propertyId;
  final VoidCallback? onSaved;
  final VoidCallback? onCancel;

  const PropertyFormView({
    super.key,
    this.propertyId,
    this.onSaved,
    this.onCancel,
  });

  @override
  State<PropertyFormView> createState() => _PropertyFormViewState();
}

class _PropertyFormViewState extends State<PropertyFormView>
    with SafeNavigationMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _areaController = TextEditingController();

  String _selectedPropertyType = 'house';
  bool _isLoading = false;
  List<String> _selectedImagePaths = [];

  final List<Map<String, String>> _propertyTypes = [
    {'value': 'house', 'label': 'Casa'},
    {'value': 'apartment', 'label': 'Apartamento'},
    {'value': 'condo', 'label': 'Condominio'},
    {'value': 'townhouse', 'label': 'Casa adosada'},
    {'value': 'land', 'label': 'Terreno'},
    {'value': 'commercial', 'label': 'Comercial'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.propertyId != null) {
      _loadPropertyData();
    }
  }

  void _loadPropertyData() async {
    final propertyProvider = Provider.of<PropertyProvider>(
      context,
      listen: false,
    );
    final property = await propertyProvider.getPropertyById(widget.propertyId!);

    if (property != null && mounted) {
      // Filtrar imágenes que realmente existen
      List<String> validImagePaths = [];
      for (String imagePath in property.imagePaths) {
        if (await ImageService.imageExists(imagePath)) {
          validImagePaths.add(imagePath);
        }
      }

      setState(() {
        _titleController.text = property.title;
        _descriptionController.text = property.description ?? '';
        _priceController.text = property.price.toString();
        _addressController.text = property.address;
        _cityController.text = property.city;
        _stateController.text = property.state;
        _bedroomsController.text = property.bedrooms?.toString() ?? '';
        _bathroomsController.text = property.bathrooms?.toString() ?? '';
        _areaController.text = property.area?.toString() ?? '';
        _selectedPropertyType = property.propertyType;
        _selectedImagePaths = validImagePaths;
      });

      // Si se eliminaron imágenes inválidas, mostrar mensaje
      if (validImagePaths.length < property.imagePaths.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Se encontraron ${property.imagePaths.length - validImagePaths.length} imágenes no válidas que fueron removidas',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _saveProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final propertyProvider = Provider.of<PropertyProvider>(
      context,
      listen: false,
    );

    try {
      bool success;

      if (widget.propertyId == null) {
        // Crear nueva propiedad
        success = await propertyProvider.createProperty(
          title: _titleController.text,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          price: double.parse(_priceController.text),
          propertyType: _selectedPropertyType,
          address: _addressController.text,
          city: _cityController.text,
          state: _stateController.text,
          bedrooms: _bedroomsController.text.isNotEmpty
              ? int.parse(_bedroomsController.text)
              : null,
          bathrooms: _bathroomsController.text.isNotEmpty
              ? int.parse(_bathroomsController.text)
              : null,
          area: _areaController.text.isNotEmpty
              ? double.parse(_areaController.text)
              : null,
          imagePaths: _selectedImagePaths,
          userId: authProvider.currentUser!.id!,
        );
      } else {
        // Actualizar propiedad existente
        final property = await propertyProvider.getPropertyById(
          widget.propertyId!,
        );
        if (property != null) {
          final updatedProperty = property.copyWith(
            title: _titleController.text,
            description: _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null,
            price: double.parse(_priceController.text),
            propertyType: _selectedPropertyType,
            address: _addressController.text,
            city: _cityController.text,
            state: _stateController.text,
            bedrooms: _bedroomsController.text.isNotEmpty
                ? int.parse(_bedroomsController.text)
                : null,
            bathrooms: _bathroomsController.text.isNotEmpty
                ? int.parse(_bathroomsController.text)
                : null,
            area: _areaController.text.isNotEmpty
                ? double.parse(_areaController.text)
                : null,
            imagePaths: _selectedImagePaths,
          );

          success = await propertyProvider.updateProperty(updatedProperty);
        } else {
          success = false;
        }
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.propertyId == null
                  ? 'Propiedad creada exitosamente'
                  : 'Propiedad actualizada exitosamente',
            ),
            backgroundColor: AppColors.primaryRed,
          ),
        );
        if (widget.onSaved != null) {
          widget.onSaved!();
        } else {
          await safeNavigate(AppRoutes.homeProperties);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              propertyProvider.errorMessage ?? 'Error al guardar la propiedad',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectImage() async {
    try {
      final imagePath = await ImageService.showImageSourceBottomSheet(context);
      if (imagePath != null && imagePath.isNotEmpty) {
        // Verificar que la imagen existe
        if (await ImageService.imageExists(imagePath)) {
          setState(() {
            _selectedImagePaths.add(imagePath);
          });

          // Mostrar confirmación
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Imagen agregada correctamente'),
                backgroundColor: AppColors.primaryRed,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: La imagen no se pudo guardar'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImagePaths.removeAt(index);
    });
  }

  Widget _buildResponsiveRow({
    required List<Widget> children,
    double? spacing,
  }) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final isLandscape = ResponsiveUtils.isLandscape(context);
    final defaultSpacing = ResponsiveUtils.getHorizontalSpacing(
      context,
      mobile: 12,
      tablet: 16,
      desktop: 20,
    );
    final actualSpacing = spacing ?? defaultSpacing;

    // En móvil vertical, mostrar en columna. En otros casos, en fila.
    if (isMobile && !isLandscape) {
      return Column(
        children: children
            .map(
              (child) => Padding(
                padding: EdgeInsets.only(
                  bottom: ResponsiveUtils.getVerticalSpacing(
                    context,
                    mobile: 16,
                    tablet: 20,
                    desktop: 24,
                  ),
                ),
                child: child,
              ),
            )
            .toList(),
      );
    } else {
      return Row(
        children: children
            .map((child) => Expanded(child: child))
            .expand((child) => [child, SizedBox(width: actualSpacing)])
            .take(children.length * 2 - 1)
            .toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsivePadding = ResponsiveUtils.getResponsivePadding(context);
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.propertyId == null ? 'Nueva Propiedad' : 'Editar Propiedad',
        ),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        leading: widget.onCancel != null
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: widget.onCancel!,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () =>
                    safeGoBack(fallbackRoute: AppRoutes.homeProperties),
              ),
        actions: widget.onCancel == null
            ? [
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white),
                  onPressed: () => safeNavigate(AppRoutes.homeDashboard),
                ),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: EdgeInsets.all(responsivePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Título
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Título *',
                        hintText: 'Ej: Casa en venta en el centro',
                        prefixIcon: Icon(
                          Icons.title,
                          color: AppColors.primaryRed,
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
                      ),
                      validator: (value) =>
                          FormValidators.validateRequired(value, 'Título'),
                    ),

                    const SizedBox(height: 20),

                    // Descripción
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        hintText:
                            'Describe las características de la propiedad',
                        prefixIcon: Icon(
                          Icons.description,
                          color: AppColors.primaryRed,
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
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Precio
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Precio *',
                        hintText: 'Ej: 250000',
                        prefixIcon: Icon(
                          Icons.attach_money,
                          color: AppColors.primaryRed,
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
                      ),
                      validator: (value) =>
                          FormValidators.validateNumber(value, 'Precio'),
                    ),

                    const SizedBox(height: 20),

                    // Tipo de propiedad
                    DropdownButtonFormField<String>(
                      value: _selectedPropertyType,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Propiedad *',
                        prefixIcon: Icon(
                          Icons.home_work,
                          color: AppColors.primaryRed,
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
                      ),
                      items: _propertyTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type['value'],
                          child: Text(type['label']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPropertyType = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // Dirección
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Dirección *',
                        hintText: 'Ej: Calle 123 #45-67',
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: AppColors.primaryRed,
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
                      ),
                      validator: (value) =>
                          FormValidators.validateRequired(value, 'Dirección'),
                    ),

                    const SizedBox(height: 20),

                    // Ciudad y Estado (responsive)
                    _buildResponsiveRow(
                      children: [
                        TextFormField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            labelText: 'Ciudad *',
                            prefixIcon: Icon(
                              Icons.location_city,
                              color: AppColors.primaryRed,
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
                          ),
                          validator: (value) =>
                              FormValidators.validateRequired(value, 'Ciudad'),
                        ),
                        TextFormField(
                          controller: _stateController,
                          decoration: InputDecoration(
                            labelText: 'Estado *',
                            prefixIcon: Icon(
                              Icons.map,
                              color: AppColors.primaryRed,
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
                          ),
                          validator: (value) =>
                              FormValidators.validateRequired(value, 'Estado'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Habitaciones y Baños (responsive)
                    _buildResponsiveRow(
                      children: [
                        TextFormField(
                          controller: _bedroomsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Habitaciones',
                            prefixIcon: Icon(
                              Icons.bed,
                              color: AppColors.primaryRed,
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
                          ),
                        ),
                        TextFormField(
                          controller: _bathroomsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Baños',
                            prefixIcon: Icon(
                              Icons.bathroom,
                              color: AppColors.primaryRed,
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
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Área
                    TextFormField(
                      controller: _areaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Área (m²)',
                        hintText: 'Ej: 120.5',
                        prefixIcon: Icon(
                          Icons.square_foot,
                          color: AppColors.primaryRed,
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
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Sección de imágenes mejorada
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(
                          color: AppColors.primaryRed.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.image,
                                color: AppColors.primaryRed,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Imágenes de la propiedad (${_selectedImagePaths.length})',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryRed,
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _selectImage,
                                icon: const Icon(
                                  Icons.add_a_photo,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Agregar',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryRed,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (_selectedImagePaths.isNotEmpty) ...[
                            LayoutBuilder(
                              builder: (context, constraints) {
                                int crossAxisCount = constraints.maxWidth < 400
                                    ? 1
                                    : constraints.maxWidth < 600
                                    ? 2
                                    : 3;
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 1.2,
                                      ),
                                  itemCount: _selectedImagePaths.length,
                                  itemBuilder: (context, index) {
                                    return Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: AppColors.primaryRed
                                                  .withOpacity(0.3),
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.1,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: FutureBuilder<bool>(
                                              future: ImageService.imageExists(
                                                _selectedImagePaths[index],
                                              ),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Container(
                                                    color: Colors.grey.shade200,
                                                    child: Center(
                                                      child: CircularProgressIndicator(
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                              Color
                                                            >(
                                                              AppColors
                                                                  .primaryRed,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                }

                                                if (snapshot.data == true) {
                                                  return Image.file(
                                                    File(
                                                      _selectedImagePaths[index],
                                                    ),
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        color: Colors
                                                            .grey
                                                            .shade200,
                                                        child: Center(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .broken_image,
                                                                size: 40,
                                                                color: AppColors
                                                                    .primaryRed
                                                                    .withOpacity(
                                                                      0.5,
                                                                    ),
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                'Error al cargar',
                                                                style: TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .grey[600],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  return Container(
                                                    color: Colors.grey.shade200,
                                                    child: Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            size: 40,
                                                            color: AppColors
                                                                .primaryRed
                                                                .withOpacity(
                                                                  0.5,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            'Archivo no encontrado',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color: Colors
                                                                  .grey[600],
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () => _removeImage(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(
                                                  0.9,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Toca la X para eliminar una imagen',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ] else ...[
                            InkWell(
                              onTap: _selectImage,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 140,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primaryRed.withOpacity(
                                      0.3,
                                    ),
                                    width: 2,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 50,
                                      color: AppColors.primaryRed.withOpacity(
                                        0.7,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Toca para agregar imágenes',
                                      style: TextStyle(
                                        color: AppColors.primaryRed.withOpacity(
                                          0.8,
                                        ),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Botón de guardar mejorado
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProperty,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                widget.propertyId == null
                                    ? 'Crear Propiedad'
                                    : 'Actualizar Propiedad',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        '* Campos obligatorios',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
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
