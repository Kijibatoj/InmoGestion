/*
Este archivo es la base de datos de los usuarios, es decir la base de datos de los usuarios

Eeste es lo mismo que property_dao.dart, pero para los usuarios
*/

import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'database.dart';
import '../../core/constants/app_constants.dart';
import '../../core/exceptions/database_exception.dart';
import '../../features/auth/models/user_model.dart';

class UserDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  //hashear la contraseña para seguridad extra
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  //insertar el usuario en la db
  Future<User> insertUser(User user) async {
    final db = await _dbHelper.database;

    final existingUser = await getUserByEmail(user.email);
    if (existingUser != null) {
      throw const DuplicateUserException();
    }

    final userMap = user.toMap();
    userMap['password'] = _hashPassword(user.password);
    userMap['created_at'] = DateTime.now().toIso8601String();
    userMap['updated_at'] = DateTime.now().toIso8601String();

    final id = await db.insert(AppConstants.userTableName, userMap);
    return user.copyWith(id: id);
  }
  //BUSCA EL USUARIO POR EMIAL

  Future<User?> getUserByEmail(String email) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      AppConstants.userTableName,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
  //busca el usuario por id

  Future<User?> getUserById(int id) async {
    final db = await _dbHelper.database;

    final maps = await db.query(
      AppConstants.userTableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  //autenticacion del usuario, valida que el usuario exista o no en la db
  Future<User?> authenticateUser(String email, String password) async {
    final user = await getUserByEmail(email);

    if (user == null) {
      throw const UserNotFoundException();
    }

    final hashedPassword = _hashPassword(password);
    if (user.password != hashedPassword) {
      throw const InvalidCredentialsException();
    }

    return user;
  }

  //actualizar el usuario
  Future<User> updateUser(User user) async {
    final db = await _dbHelper.database;

    final userMap = user.toMap();
    userMap['updated_at'] = DateTime.now().toIso8601String();

    if (userMap.containsKey('password')) {
      userMap['password'] = _hashPassword(userMap['password']);
    }

    await db.update(
      AppConstants.userTableName,
      userMap,
      where: 'id = ?',
      whereArgs: [user.id],
    );

    return user;
  }
  //borra el usuarioo de la db, para este proyecto en especifico se usa el delete, pero no se deben borrar usuarios de la db
  //se pondria un estatus false para que no se elimine de la base de datos

  Future<void> deleteUser(int id) async {
    final db = await _dbHelper.database;

    await db.delete(
      AppConstants.userTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //buscar todos los usuarios de la app
  Future<List<User>> getAllUsers() async {
    final db = await _dbHelper.database;

    final maps = await db.query(AppConstants.userTableName);

    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }
}
