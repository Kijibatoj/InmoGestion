/*
Este archivo es la base de datos de las propiedades, es decir la base de datos de las propiedades

Este archivo controla todo lo que es consulta de la aplicacion, es decir, insertar, buscar, actualizar y eliminar propiedades
*/

import 'database.dart';
import '../../core/constants/app_constants.dart';
import '../../core/exceptions/database_exception.dart';
import '../../features/properties/models/property_model.dart';

class PropertyDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Property> insertProperty(Property property) async {
    final db = await _dbHelper.database;

    final propertyMap = property.toMap();
    propertyMap['created_at'] = DateTime.now().toIso8601String();
    propertyMap['updated_at'] = DateTime.now().toIso8601String();

    final id = await db.insert(AppConstants.propertyTableName, propertyMap);
    return property.copyWith(id: id);
  }

  //por aca esta el filtro por id de las propiedades
  Future<Property?> getPropertyById(int id) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      AppConstants.propertyTableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Property.fromMap(maps.first);
    }
    return null;
  }
  //por aca esta el filtro general de las propiedades

  Future<List<Property>> getAllProperties() async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      AppConstants.propertyTableName,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Property.fromMap(maps[i]);
    });
  }
  //por aca esta el filtro por usuario, por si algun usuario quiere ver sus propiedades

  Future<List<Property>> getPropertiesByUser(int userId) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      AppConstants.propertyTableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Property.fromMap(maps[i]);
    });
  }

  //FILTROS GENERALES PARA BUSCAR PROPIEDADES
  //aQUI esta lo que es el por precio, ciudad, tipo de propiedad y demas
  Future<List<Property>> searchProperties({
    String? query,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    String? city,
  }) async {
    final db = await _dbHelper.database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (query != null && query.isNotEmpty) {
      whereClause += 'title LIKE ? OR description LIKE ? OR address LIKE ?';
      whereArgs.addAll(['%$query%', '%$query%', '%$query%']);
    }

    if (propertyType != null && propertyType.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'property_type = ?';
      whereArgs.add(propertyType);
    }

    if (minPrice != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'price >= ?';
      whereArgs.add(minPrice);
    }

    if (maxPrice != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'price <= ?';
      whereArgs.add(maxPrice);
    }

    if (city != null && city.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'city LIKE ?';
      whereArgs.add('%$city%');
    }

    final maps = await db.query(
      AppConstants.propertyTableName,
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Property.fromMap(maps[i]);
    });
  }
  //para poder actualizar las propiedades

  Future<Property> updateProperty(Property property) async {
    final db = await _dbHelper.database;

    final propertyMap = property.toMap();
    propertyMap['updated_at'] = DateTime.now().toIso8601String();

    await db.update(
      AppConstants.propertyTableName,
      propertyMap,
      where: 'id = ?',
      whereArgs: [property.id],
    );

    return property;
  }
  //para poder borrar las propiedades, esta funcion SOLO SE USA PARA ESTE PROYECTO, para mostrar el delete
  //deberia ser poner un estatus false para que no se elimine de la base de datos

  Future<void> deleteProperty(int id) async {
    final db = await _dbHelper.database;

    final result = await db.delete(
      AppConstants.propertyTableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result == 0) {
      throw const PropertyNotFoundException();
    }
  }
  //para poder ver las propiedades en general

  Future<int> getPropertiesCount() async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.propertyTableName}',
    );

    return result.first['count'] as int;
  }

  //para poder contabilizar las propiedades dde cada usuario unico
  Future<int> getPropertiesCountByUser(int userId) async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.propertyTableName} WHERE user_id = ?',
      [userId],
    );

    return result.first['count'] as int;
  }
}
