import 'package:flutter/foundation.dart';

import '../data/repositories/property_repository.dart';
import '../features/properties/models/property_model.dart';
import '../core/exceptions/database_exception.dart';

enum PropertyStatus { idle, loading, success, error }

class PropertyProvider extends ChangeNotifier {
  final PropertyRepository _propertyRepository = PropertyRepository();

  List<Property> _properties = [];
  List<Property> _filteredProperties = [];
  PropertyStatus _status = PropertyStatus.idle;
  String? _errorMessage;
  Property? _selectedProperty;

  List<Property> get properties =>
      _filteredProperties.isEmpty ? _properties : _filteredProperties;
  PropertyStatus get status => _status;
  String? get errorMessage => _errorMessage;
  Property? get selectedProperty => _selectedProperty;
  bool get isLoading => _status == PropertyStatus.loading;

  Future<void> loadProperties() async {
    try {
      _status = PropertyStatus.loading;
      _errorMessage = null;
      notifyListeners();

      _properties = await _propertyRepository.getAllProperties();
      _filteredProperties.clear();
      _status = PropertyStatus.success;
    } catch (e) {
      _status = PropertyStatus.error;
      _errorMessage = e is DatabaseException
          ? e.message
          : 'Error al cargar propiedades';
    }
    notifyListeners();
  }

  Future<void> loadPropertiesByUser(int userId) async {
    try {
      _status = PropertyStatus.loading;
      _errorMessage = null;
      notifyListeners();

      _properties = await _propertyRepository.getPropertiesByUser(userId);
      _filteredProperties.clear();
      _status = PropertyStatus.success;
    } catch (e) {
      _status = PropertyStatus.error;
      _errorMessage = e is DatabaseException
          ? e.message
          : 'Error al cargar propiedades del usuario';
    }
    notifyListeners();
  }

  Future<bool> createProperty({
    required String title,
    String? description,
    required double price,
    required String propertyType,
    required String address,
    required String city,
    required String state,
    int? bedrooms,
    int? bathrooms,
    double? area,
    List<String>? imagePaths,
    required int userId,
  }) async {
    try {
      _status = PropertyStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final property = await _propertyRepository.createProperty(
        title: title,
        description: description,
        price: price,
        propertyType: propertyType,
        address: address,
        city: city,
        state: state,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        area: area,
        imagePaths: imagePaths ?? [],
        userId: userId,
      );

      _properties.insert(0, property);
      _status = PropertyStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = PropertyStatus.error;
      _errorMessage = e is DatabaseException
          ? e.message
          : 'Error al crear propiedad';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProperty(Property property) async {
    try {
      _status = PropertyStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final updatedProperty = await _propertyRepository.updateProperty(
        property,
      );

      final index = _properties.indexWhere((p) => p.id == property.id);
      if (index != -1) {
        _properties[index] = updatedProperty;
      }

      _status = PropertyStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = PropertyStatus.error;
      _errorMessage = e is DatabaseException
          ? e.message
          : 'Error al actualizar propiedad';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProperty(int id) async {
    try {
      _status = PropertyStatus.loading;
      _errorMessage = null;
      notifyListeners();

      await _propertyRepository.deleteProperty(id);

      _properties.removeWhere((p) => p.id == id);
      _filteredProperties.removeWhere((p) => p.id == id);

      _status = PropertyStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = PropertyStatus.error;
      _errorMessage = e is DatabaseException
          ? e.message
          : 'Error al eliminar propiedad';
      notifyListeners();
      return false;
    }
  }

  Future<void> searchProperties({
    String? query,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    String? city,
  }) async {
    try {
      _status = PropertyStatus.loading;
      _errorMessage = null;
      notifyListeners();

      _filteredProperties = await _propertyRepository.searchProperties(
        query: query,
        propertyType: propertyType,
        minPrice: minPrice,
        maxPrice: maxPrice,
        city: city,
      );

      _status = PropertyStatus.success;
    } catch (e) {
      _status = PropertyStatus.error;
      _errorMessage = e is DatabaseException
          ? e.message
          : 'Error al buscar propiedades';
    }
    notifyListeners();
  }

  void clearSearch() {
    _filteredProperties.clear();
    notifyListeners();
  }

  void selectProperty(Property? property) {
    _selectedProperty = property;
    notifyListeners();
  }

  Future<Property?> getPropertyById(int id) async {
    try {
      return await _propertyRepository.getPropertyById(id);
    } catch (e) {
      _errorMessage = e is DatabaseException
          ? e.message
          : 'Error al obtener propiedad';
      notifyListeners();
      return null;
    }
  }

  Future<int> getPropertiesCount() async {
    try {
      return await _propertyRepository.getPropertiesCount();
    } catch (e) {
      return 0;
    }
  }

  Future<List<String>> getCities() async {
    try {
      return await _propertyRepository.getCities();
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getPropertyTypes() async {
    try {
      return await _propertyRepository.getPropertyTypes();
    } catch (e) {
      return [];
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
