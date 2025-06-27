import '../local/property_dao.dart';
import '../../features/properties/models/property_model.dart';
import '../../core/exceptions/database_exception.dart';

class PropertyRepository {
  final PropertyDao _propertyDao = PropertyDao();

  Future<Property> createProperty({
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
      final property = Property(
        title: title.trim(),
        description: description?.trim(),
        price: price,
        propertyType: propertyType,
        address: address.trim(),
        city: city.trim(),
        state: state.trim(),
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        area: area,
        imagePaths: imagePaths ?? [],
        userId: userId,
      );

      return await _propertyDao.insertProperty(property);
    } catch (e) {
      throw DatabaseException('Error al crear propiedad: ${e.toString()}');
    }
  }

  Future<Property?> getPropertyById(int id) async {
    try {
      return await _propertyDao.getPropertyById(id);
    } catch (e) {
      throw DatabaseException('Error al obtener propiedad: ${e.toString()}');
    }
  }

  Future<List<Property>> getAllProperties() async {
    try {
      return await _propertyDao.getAllProperties();
    } catch (e) {
      throw DatabaseException('Error al obtener propiedades: ${e.toString()}');
    }
  }

  Future<List<Property>> getPropertiesByUser(int userId) async {
    try {
      return await _propertyDao.getPropertiesByUser(userId);
    } catch (e) {
      throw DatabaseException(
        'Error al obtener propiedades del usuario: ${e.toString()}',
      );
    }
  }

  Future<List<Property>> searchProperties({
    String? query,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    String? city,
  }) async {
    try {
      return await _propertyDao.searchProperties(
        query: query?.trim(),
        propertyType: propertyType,
        minPrice: minPrice,
        maxPrice: maxPrice,
        city: city?.trim(),
      );
    } catch (e) {
      throw DatabaseException('Error al buscar propiedades: ${e.toString()}');
    }
  }

  Future<Property> updateProperty(Property property) async {
    try {
      return await _propertyDao.updateProperty(property);
    } catch (e) {
      throw DatabaseException('Error al actualizar propiedad: ${e.toString()}');
    }
  }

  Future<void> deleteProperty(int id) async {
    try {
      await _propertyDao.deleteProperty(id);
    } catch (e) {
      if (e is DatabaseException) {
        rethrow;
      }
      throw DatabaseException('Error al eliminar propiedad: ${e.toString()}');
    }
  }

  Future<int> getPropertiesCount() async {
    try {
      return await _propertyDao.getPropertiesCount();
    } catch (e) {
      throw DatabaseException('Error al contar propiedades: ${e.toString()}');
    }
  }

  Future<int> getPropertiesCountByUser(int userId) async {
    try {
      return await _propertyDao.getPropertiesCountByUser(userId);
    } catch (e) {
      throw DatabaseException(
        'Error al contar propiedades del usuario: ${e.toString()}',
      );
    }
  }

  Future<List<String>> getCities() async {
    try {
      final properties = await _propertyDao.getAllProperties();
      final cities = properties.map((p) => p.city).toSet().toList();
      cities.sort();
      return cities;
    } catch (e) {
      throw DatabaseException('Error al obtener ciudades: ${e.toString()}');
    }
  }

  Future<List<String>> getPropertyTypes() async {
    try {
      final properties = await _propertyDao.getAllProperties();
      final types = properties.map((p) => p.propertyType).toSet().toList();
      types.sort();
      return types;
    } catch (e) {
      throw DatabaseException(
        'Error al obtener tipos de propiedad: ${e.toString()}',
      );
    }
  }
}
